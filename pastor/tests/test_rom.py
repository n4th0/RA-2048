"""Fase 1: el nivel se carga en WRAM y se pinta en el tilemap."""
from conftest import LCDC, LEVEL_SIZE, SCREEN_H, SCREEN_W

HUD_ROW = 0


def rom_level(game) -> list[int]:
    start = game.sym["level_1"]
    return [game.gb.memory[start + i] for i in range(LEVEL_SIZE)]


def test_screen_is_on(game):
    assert game.gb.memory[LCDC] & 0x80, "la pantalla debería estar encendida"


def test_level_copied_to_wram(game):
    wram = [game.gb.memory[game.sym["level_map"] + i] for i in range(LEVEL_SIZE)]
    assert wram == rom_level(game)


def test_level_drawn_in_tilemap_except_under_entities_and_hud(game):
    game.freeze_sheep()
    game.gb.tick(3)  # que la pantalla refleje las posiciones actuales
    expected = rom_level(game)
    skip = {(e.y, e.x) for e in game.entities()}
    for y in range(HUD_ROW + 1, SCREEN_H):
        for x in range(SCREEN_W):
            if (y, x) not in skip:
                assert game.tile_on_screen(y, x) == expected[y * SCREEN_W + x], f"casilla ({y},{x}) mal pintada"
