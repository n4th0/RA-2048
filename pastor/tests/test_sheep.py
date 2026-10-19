"""Fase 4: IA de las ovejas, corral y victoria.

Cada test congela todas las ovejas y "despierta" solo las que prueba,
colocándolas a mano con place() para controlar la situación.
"""
import sys
from pathlib import Path

import pytest

from conftest import (
    SCENE_GAME, SCENE_MESSAGE, TILE_CORRAL, TILE_DIGIT_0, TILE_GRASS, TYPE_SHEEP_PENNED, TYPE_SHEPHERD,
)

sys.path.insert(0, str(Path(__file__).parent))  # para importar bot.py

CORRAL = [(y, x) for y in range(11, 17) for x in range(14, 19)]


@pytest.fixture
def lab(game):
    """Ovejas congeladas: cada test elige a cuál despierta."""
    game.freeze_sheep()
    game.gb.tick(2)
    return game


def first_sheep(game):
    return game.sheep()[0].index


def wake(game, index):
    """La oveja decide dentro de 2 frames.

    No vale cooldown 0: PyBoy corta los frames al empezar el VBLANK, justo
    cuando corre la lógica, y place() podría caer entre "buscar al pastor" y
    "decidir". Con 1 frame de margen decide con las posiciones ya colocadas.
    """
    game.set_cooldown(index, 1)
    game.gb.tick(3)


def test_sheep_flees_away_from_shepherd(lab):
    s = first_sheep(lab)
    lab.place(0, 6, 8)              # pastor justo debajo
    lab.place(s, 5, 8)
    wake(lab, s)
    assert (lab.entity(s).y, lab.entity(s).x) == (4, 8)


def test_sheep_flees_along_the_farther_axis(lab):
    s = first_sheep(lab)
    lab.place(0, 8, 5)
    lab.place(s, 7, 7)              # dy = -1, dx = +2: huye en horizontal
    wake(lab, s)
    assert (lab.entity(s).y, lab.entity(s).x) == (7, 8)


def test_sheep_still_flees_at_exactly_scare_distance(lab):
    # A distancia 4 no huye, pero eso no se distingue de un paso de pasto al
    # azar: probamos el límite por el lado que sí es determinista.
    s = first_sheep(lab)
    lab.place(0, 8, 8)
    lab.place(s, 5, 8)              # distancia 3
    wake(lab, s)
    assert (lab.entity(s).y, lab.entity(s).x) == (4, 8)


def test_sheep_against_fence_escapes_sideways(lab):
    s = first_sheep(lab)
    lab.place(0, 3, 8)
    lab.place(s, 2, 8)              # arriba hay valla: tiene que ir de lado
    wake(lab, s)
    e = lab.entity(s)
    assert e.y == 2 and e.x in (7, 9)


def test_sheep_entering_corral_gets_penned_and_counted(lab):
    s = first_sheep(lab)
    lab.place(s, 13, 16)
    lab.gb.tick(3)
    assert lab.entity(s).type == TYPE_SHEEP_PENNED
    assert lab.var("sheep_left") == 4
    assert [lab.tile_on_screen(0, 18), lab.tile_on_screen(0, 19)] == [TILE_DIGIT_0, TILE_DIGIT_0 + 4]


def test_penned_sheep_never_leaves_corral(lab):
    s = first_sheep(lab)
    lab.place(s, 10, 15)            # en la entrada
    lab.gb.tick(2)
    lab.place(0, 11, 15)            # el pastor la empuja hacia fuera
    for _ in range(20):
        wake(lab, s)
        e = lab.entity(s)
        assert lab.map_tile(e.y, e.x) == TILE_CORRAL, f"la oveja salió del corral a ({e.y},{e.x})"


def test_herding_a_sheep_into_the_corral(lab):
    """Integración: el pastor empuja una oveja desde fuera hasta el corral."""
    s = first_sheep(lab)
    lab.place(s, 8, 16)
    lab.place(0, 7, 16)
    wake(lab, s)
    lab.hold("down", 60)
    assert lab.entity(s).type == TYPE_SHEEP_PENNED


def test_all_sheep_penned_wins_and_freezes_the_game(lab):
    for s, (y, x) in zip(lab.sheep(), CORRAL):
        lab.place(s.index, y, x)
    lab.gb.tick(3)
    assert lab.var("game_won") == 1
    before = lab.shepherd()
    lab.hold("left", 30)
    assert (lab.shepherd().y, lab.shepherd().x) == (before.y, before.x), "tras ganar no se debería mover"
    assert lab.var("scene_id") == SCENE_GAME, "1 s de espera antes del mensaje"
    lab.gb.tick(40)
    assert lab.var("scene_id") == SCENE_MESSAGE
    assert lab.text_at(5, 3, 14) == "NIVEL SUPERADO"


def test_long_random_play_keeps_world_consistent(game):
    """Invariantes durante 25 s de juego con el pastor dando vueltas."""
    moves = ["right", "down", "left", "up", "right", "up"]
    for step in range(50):
        game.hold(moves[step % len(moves)], 30)
        entities = game.entities()
        cells = [(e.y, e.x) for e in entities]
        assert len(cells) == len(set(cells)), f"dos entidades en la misma casilla: {entities}"
        for e in entities:
            tile = game.map_tile(e.y, e.x)
            assert tile in (TILE_GRASS, TILE_CORRAL), f"{e} está sobre el tile {tile}"
            if e.type == TYPE_SHEEP_PENNED:
                assert tile == TILE_CORRAL
        assert sum(e.type == TYPE_SHEPHERD for e in entities) == 1


@pytest.mark.parametrize("level", [0, 1, 2])
@pytest.mark.parametrize("seed", [(17, 99), (200, 3)])
def test_bot_can_win_every_level_in_time(level, seed):
    """Un bot que solo usa la cruceta gana cada nivel dentro de su tiempo.

    Si alguien cambia la IA, las velocidades o un mapa y lo hace imposible
    (o demasiado justo), este test falla.
    """
    import bot
    from conftest import Game
    g = Game()
    g.goto_level(level)
    g.gb.memory[g.sym["rng_state"]], g.gb.memory[g.sym["rng_state"] + 1] = seed
    limit = g.bcd("time_left", 2)
    used = bot.play_level(g) / 60
    won, left = g.var("game_won"), g.var("sheep_left")
    g.stop()
    assert won == 1, f"el bot no ganó el nivel {level + 1}: quedan {left} ovejas"
    assert used < limit * 0.75, f"nivel {level + 1}: el bot tardó {used:.0f} de {limit} s, demasiado justo"
