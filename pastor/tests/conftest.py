"""Utilidades compartidas por los tests: arrancar la ROM y leer su estado.

Las direcciones salen del .sym que genera el linker, así los tests no se
rompen si cambia dónde se coloca cada SECTION.
"""
import io
from dataclasses import dataclass
from pathlib import Path

import pytest
from pyboy import PyBoy

ROOT = Path(__file__).resolve().parent.parent
ROM = ROOT / "game.gb"
SYM = ROOT / "obj" / "game.sym"

SCREEN_W, SCREEN_H, MAP_STRIDE = 20, 18, 32
LEVEL_SIZE = SCREEN_W * SCREEN_H
SCRN0 = 0x9800
LCDC, LY = 0xFF40, 0xFF44

# Deben coincidir con constants.inc
MAX_ENTITIES, SIZEOF_ENTITY = 16, 8
E_ACTIVE, E_TYPE, E_Y, E_X, E_TILE, E_OLD_Y, E_OLD_X, E_COOLDOWN = range(8)
TYPE_SHEPHERD, TYPE_SHEEP, TYPE_SHEEP_PENNED = 0, 1, 2
TILE_GRASS, TILE_FENCE, TILE_CORRAL, TILE_SHEPHERD, TILE_SHEEP = 1, 2, 3, 4, 5
TILE_DIGIT_0 = 6
TILE_FONT_A = TILE_DIGIT_0 + 10
SHEPHERD_STEP_FRAMES, SHEEP_STEP_FRAMES = 6, 10
BOOT_FRAMES = 150  # PyBoy dedica ~100 frames a su propia animación de arranque
SCENE_TITLE, SCENE_GAME, SCENE_MESSAGE = 0, 1, 2
SRAM_SIZE = 8 * 1024


def load_symbols(path: Path) -> dict[str, int]:
    """Lee las líneas 'banco:dirección nombre' del .sym de rgblink."""
    symbols: dict[str, int] = {}
    for line in path.read_text().splitlines():
        line = line.split(";", 1)[0].strip()
        if line:
            address, name = line.split()
            symbols[name] = int(address.split(":")[1], 16)
    return symbols


@dataclass
class Entity:
    index: int
    type: int
    y: int
    x: int
    tile: int


class Game:
    """Envoltorio fino sobre PyBoy con lo que los tests necesitan leer."""

    def __init__(self, boot_frames: int = BOOT_FRAMES, start: bool = True, sram: bytes | None = None) -> None:
        """Arranca la ROM. Por defecto pulsa START en el título y deja el nivel 1 en marcha.

        sram: contenido inicial de la RAM del cartucho. Por defecto, vacía (a 0),
        para que cada test empiece sin récord y no se escriba ningún .ram en disco.
        """
        self.gb = PyBoy(str(ROM), window="null", ram_file=io.BytesIO(sram or bytes(SRAM_SIZE)))
        self.sym = load_symbols(SYM)
        self.gb.tick(boot_frames)
        if start:
            self.press("start")

    def press(self, button: str) -> None:
        """Pulsación corta (un toque) y unos frames para que se procese."""
        self.gb.button_press(button)
        self.gb.tick(2)
        self.gb.button_release(button)
        self.gb.tick(3)

    def bcd(self, name: str, size: int = 1) -> int:
        """Lee una variable BCD como número decimal (score, time_left...)."""
        digits = "".join(f"{self.gb.memory[self.sym[name] + i]:02x}" for i in range(size))
        return int(digits)

    def text_at(self, y: int, x: int, length: int) -> str:
        """Lee de la pantalla un texto escrito con la fuente del juego."""
        out = []
        for i in range(length):
            t = self.tile_on_screen(y, x + i)
            if TILE_FONT_A <= t < TILE_FONT_A + 26:
                out.append(chr(ord("A") + t - TILE_FONT_A))
            elif TILE_DIGIT_0 <= t < TILE_DIGIT_0 + 10:
                out.append(str(t - TILE_DIGIT_0))
            else:
                out.append(" ")
        return "".join(out)

    def entities(self) -> list[Entity]:
        base = self.sym["entity_array"]
        found = []
        for i in range(MAX_ENTITIES):
            e = base + i * SIZEOF_ENTITY
            if self.gb.memory[e + E_ACTIVE]:
                m = self.gb.memory
                found.append(Entity(i, m[e + E_TYPE], m[e + E_Y], m[e + E_X], m[e + E_TILE]))
        return found

    def shepherd(self) -> Entity:
        shepherds = [e for e in self.entities() if e.type == TYPE_SHEPHERD]
        assert len(shepherds) == 1, f"debería haber un pastor, hay {len(shepherds)}"
        return shepherds[0]

    def sheep(self) -> list[Entity]:
        return [e for e in self.entities() if e.type in (TYPE_SHEEP, TYPE_SHEEP_PENNED)]

    def entity(self, index: int) -> Entity:
        return next(e for e in self.entities() if e.index == index)

    def place(self, index: int, y: int, x: int) -> None:
        """Teletransporta una entidad (el render borra y repinta solo)."""
        addr = self.sym["entity_array"] + index * SIZEOF_ENTITY
        self.gb.memory[addr + E_Y] = y
        self.gb.memory[addr + E_X] = x

    def set_cooldown(self, index: int, frames: int) -> None:
        self.gb.memory[self.sym["entity_array"] + index * SIZEOF_ENTITY + E_COOLDOWN] = frames

    def freeze_sheep(self) -> None:
        """Las ovejas no deciden nada en ~4 s: para probar al pastor sin azar."""
        for s in self.sheep():
            self.set_cooldown(s.index, 255)

    def var(self, name: str) -> int:
        return self.gb.memory[self.sym[name]]

    def tile_on_screen(self, y: int, x: int) -> int:
        return self.gb.memory[SCRN0 + y * MAP_STRIDE + x]

    def map_tile(self, y: int, x: int) -> int:
        return self.gb.memory[self.sym["level_map"] + y * SCREEN_W + x]

    def hold(self, button: str, frames: int) -> None:
        """Mantiene pulsado un botón durante N frames y lo suelta."""
        self.gb.button_press(button)
        self.gb.tick(frames)
        self.gb.button_release(button)
        self.gb.tick(2)  # que se procese la suelta y se redibuje

    def corral_cells(self) -> list[tuple[int, int]]:
        return [(y, x) for y in range(SCREEN_H) for x in range(SCREEN_W) if self.map_tile(y, x) == TILE_CORRAL]

    def win_level_by_teleport(self) -> None:
        """Mete todas las ovejas en el corral a mano y espera al mensaje."""
        cells = [c for c in self.corral_cells() if c != (self.shepherd().y, self.shepherd().x)]
        for s, (y, x) in zip(self.sheep(), cells):
            self.place(s.index, y, x)
        for _ in range(200):
            self.gb.tick(1)
            if self.var("scene_id") == SCENE_MESSAGE:
                return
        raise AssertionError("no se llegó a la pantalla de mensaje")

    def goto_level(self, level: int) -> None:
        """Salta al nivel indicado (0, 1, 2) desde el nivel 1."""
        if level == 0:
            return
        self.win_level_by_teleport()
        self.gb.memory[self.sym["current_level"]] = level
        self.gb.tick(40)                       # el mensaje ignora START al principio
        self.press("start")
        assert self.var("scene_id") == SCENE_GAME and self.var("current_level") == level

    def stop(self) -> None:
        self.gb.stop(save=False)

    def stop_and_save_sram(self) -> bytes:
        sav = io.BytesIO()
        self.gb.stop(ram_file=sav)
        return sav.getvalue()


@pytest.fixture
def game():
    if not ROM.exists() or not SYM.exists():
        pytest.skip("Falta game.gb: ejecuta `make` primero")
    g = Game()
    yield g
    g.stop()
