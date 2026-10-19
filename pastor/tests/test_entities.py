"""Fases 2 y 3: entidades del ECS, movimiento del pastor y colisiones.

Posiciones de level_1_spawns: pastor en (8,4); ovejas en (3,10), (6,15),
(8,12), (13,5) y (15,9). Las ovejas se congelan para que su IA no interfiera.
"""
import pytest

from conftest import (
    LY, SHEPHERD_STEP_FRAMES, SIZEOF_ENTITY, E_OLD_X, E_OLD_Y, Game,
    TILE_GRASS, TILE_SHEEP, TILE_SHEPHERD, TYPE_SHEEP, TYPE_SHEPHERD,
)

SHEEP_START = [(3, 10), (6, 15), (8, 12), (13, 5), (15, 9)]


@pytest.fixture
def still(game):
    """Partida con las ovejas congeladas y la pantalla al día."""
    game.freeze_sheep()
    game.gb.tick(3)
    return game


def test_spawns_one_shepherd_and_all_sheep():
    g = Game(start=False)
    seen = []
    g.gb.hook_register(0, g.sym["scene_game_update"], lambda _: seen.append(g.entities()) if not seen else None, None)
    g.press("start")
    g.stop()
    assert seen, "no se llegó a ejecutar ningún frame"
    start = seen[0]
    shepherd = [e for e in start if e.type == TYPE_SHEPHERD]
    assert [(e.y, e.x) for e in shepherd] == [(8, 4)]
    assert sorted((e.y, e.x) for e in start if e.type == TYPE_SHEEP) == sorted(SHEEP_START)


def test_entities_are_drawn(still):
    for e in still.entities():
        expected = TILE_SHEPHERD if e.type == TYPE_SHEPHERD else TILE_SHEEP
        assert still.tile_on_screen(e.y, e.x) == expected, f"entidad {e} no está dibujada"


def test_short_tap_moves_exactly_one_tile(still):
    still.hold("down", 1)
    assert (still.shepherd().y, still.shepherd().x) == (9, 4)


def test_holding_moves_one_tile_every_step_frames(still):
    # 4 pasos: el primero inmediato y luego uno cada SHEPHERD_STEP_FRAMES
    still.hold("down", 3 * SHEPHERD_STEP_FRAMES + 1)
    assert still.shepherd().y == 8 + 4


def test_fence_blocks_movement(still):
    still.hold("left", 120)         # pared exterior en la columna 0
    assert still.shepherd().x == 1
    still.hold("up", 120)           # columna 1 libre hasta la valla de la fila 1
    assert still.shepherd().y == 2


def test_inner_fence_blocks_movement(still):
    still.hold("up", 120)           # valla interior en (4,4)
    assert (still.shepherd().y, still.shepherd().x) == (5, 4)


def test_sheep_blocks_movement(still):
    still.hold("right", 120)        # oveja (congelada) en (8,12)
    assert (still.shepherd().y, still.shepherd().x) == (8, 11)


def test_old_position_is_repainted_with_background(still):
    still.hold("right", 1)
    assert still.tile_on_screen(8, 4) == TILE_GRASS
    assert still.tile_on_screen(8, 5) == TILE_SHEPHERD


def test_render_fits_in_vblank_when_every_entity_moved(still):
    """Peor caso: todas las entidades se redibujan en el mismo frame.

    Si el volcado a VRAM se pasa del VBLANK (líneas 144-153), las escrituras
    se pierden y aparecen tiles corruptos en una Game Boy real.
    """
    base = still.sym["entity_array"]
    for e in still.entities():
        addr = base + e.index * SIZEOF_ENTITY
        still.gb.memory[addr + E_OLD_Y] = 2   # (2,2) es hierba libre: borrarla es inocuo
        still.gb.memory[addr + E_OLD_X] = 2

    lines = []
    still.gb.hook_register(0, still.sym["sys_render_flush.done"], lambda _: lines.append(still.gb.memory[LY]), None)
    still.gb.tick(3)  # frame 1: se encola todo; frame 2: se vuelca a VRAM
    assert lines, "no se ejecutó el final de sys_render_flush"
    assert all(144 <= ly <= 153 for ly in lines), f"el volcado a VRAM terminó en las líneas {lines}"
    test_entities_are_drawn(still)
    assert still.tile_on_screen(2, 2) == TILE_GRASS


def test_vblank_worst_case_with_full_hud_on_level_3(game):
    """Nivel 3 (10 entidades) + marcador entero repintándose en el mismo frame."""
    game.goto_level(2)
    game.freeze_sheep()
    game.gb.tick(3)
    base = game.sym["entity_array"]
    for e in game.entities():
        addr = base + e.index * SIZEOF_ENTITY
        game.gb.memory[addr + E_OLD_Y] = 4
        game.gb.memory[addr + E_OLD_X] = 2
    game.gb.memory[game.sym["hud_dirty"]] = 0b111
    lines = []
    game.gb.hook_register(0, game.sym["sys_render_flush.done"], lambda _: lines.append(game.gb.memory[LY]), None)
    game.gb.tick(3)
    assert lines and all(144 <= ly <= 153 for ly in lines), f"el volcado a VRAM terminó en las líneas {lines}"
