"""Fase 5: escenas, marcador, tiempo, puntuación, pausa y récord."""
import pytest

from conftest import (
    SCENE_GAME, SCENE_MESSAGE, SCENE_TITLE, Game,
    TILE_SHEPHERD, TYPE_SHEPHERD,
)


def set_time(game, seconds: int) -> None:
    """Pone time_left (BCD de 2 bytes) a un valor decimal."""
    digits = f"{seconds:04d}"
    game.gb.memory[game.sym["time_left"]] = int(digits[:2], 16)
    game.gb.memory[game.sym["time_left"] + 1] = int(digits[2:], 16)


def test_boots_into_title_screen():
    g = Game(start=False)
    assert g.var("scene_id") == SCENE_TITLE
    assert g.text_at(4, 7, 6) == "PASTOR"
    assert g.text_at(14, 3, 13) == "RECORD 000000"
    g.stop()


def test_start_begins_level_1_with_full_hud(game):
    game.gb.tick(3)
    assert game.var("scene_id") == SCENE_GAME
    assert game.var("current_level") == 0
    assert game.text_at(0, 0, 14) == "N1 T120 000000"
    assert game.text_at(0, 18, 2) == "05"


def test_timer_counts_down_once_per_second(game):
    start = game.bcd("time_left", 2)
    game.gb.tick(60)
    assert game.bcd("time_left", 2) == start - 1


@pytest.mark.parametrize("before, after", [(10, 9), (100, 99), (200, 199)])
def test_timer_bcd_borrows_correctly(game, before, after):
    set_time(game, before)
    game.gb.tick(61)
    assert game.bcd("time_left", 2) == after


def test_time_up_shows_message_and_returns_to_title(game):
    set_time(game, 1)
    game.gb.tick(70)
    assert game.var("scene_id") == SCENE_MESSAGE
    assert game.text_at(5, 3, 14) == "TIEMPO AGOTADO"
    game.press("start")                     # demasiado pronto: se ignora
    assert game.var("scene_id") == SCENE_MESSAGE
    game.gb.tick(40)
    game.press("start")
    assert game.var("scene_id") == SCENE_TITLE


def test_pause_freezes_everything_and_restores_screen(game):
    game.hold("right", 1)
    game.press("start")
    assert game.var("paused") == 1
    assert game.text_at(9, 7, 5) == "PAUSA"
    positions = [(e.y, e.x) for e in game.entities()]
    time_before = game.bcd("time_left", 2)
    game.hold("down", 120)                  # ni el pastor ni las ovejas ni el reloj
    assert [(e.y, e.x) for e in game.entities()] == positions
    assert game.bcd("time_left", 2) == time_before

    game.press("start")
    game.gb.tick(2)
    assert game.var("paused") == 0
    for x in range(7, 12):
        under = [e for e in game.entities() if (e.y, e.x) == (9, x)]
        expected = (TILE_SHEPHERD if under[0].type == TYPE_SHEPHERD else under[0].tile) if under else game.map_tile(9, x)
        assert game.tile_on_screen(9, x) == expected, f"({9},{x}) no se restauró"


def test_penning_a_sheep_scores_10(game):
    s = game.sheep()[0]
    game.place(s.index, 13, 16)
    game.gb.tick(3)
    assert game.bcd("score", 3) == 10
    assert game.text_at(0, 8, 6) == "000010"


def test_level_bonus_is_100_plus_10_per_second_left(game):
    set_time(game, 145)
    game.gb.tick(1)
    left = game.bcd("time_left", 2)
    game.win_level_by_teleport()
    sheep_points = 5 * 10
    assert game.bcd("score", 3) == sheep_points + 100 + left * 10


def test_record_is_saved_to_cartridge_ram_and_loaded_on_boot():
    g = Game()
    s = g.sheep()[0]
    g.place(s.index, 13, 16)                # 10 puntos
    g.gb.tick(3)
    set_time(g, 1)
    g.gb.tick(70)                           # fin de partida
    assert g.var("new_record") == 1
    assert g.text_at(13, 4, 12) == "NUEVO RECORD"
    sram = g.stop_and_save_sram()
    assert sram[:4] == b"PSTR", "falta la firma del guardado"

    again = Game(start=False, sram=sram)    # "apagar y encender"
    assert again.text_at(14, 3, 13) == "RECORD 000010"
    again.stop()


def test_garbage_in_cartridge_ram_means_no_record():
    g = Game(start=False, sram=bytes([0xA7]) * 8192)
    assert g.text_at(14, 3, 13) == "RECORD 000000"
    g.stop()


def test_lower_score_does_not_replace_record():
    sram = bytes(b"PSTR" + bytes([0x00, 0x05, 0x00])) + bytes(8192 - 7)   # récord 500
    g = Game(sram=sram)
    set_time(g, 1)
    g.gb.tick(70)
    assert g.var("new_record") == 0
    assert g.bcd("record", 3) == 500
    g.stop()


def test_winning_level_1_moves_to_level_2_and_keeps_score(game):
    game.win_level_by_teleport()
    score = game.bcd("score", 3)
    game.gb.tick(40)
    game.press("start")
    assert game.var("scene_id") == SCENE_GAME
    assert game.var("current_level") == 1
    assert len(game.sheep()) == 7
    assert game.bcd("score", 3) == score
    assert game.text_at(0, 0, 2) == "N2"


def test_finishing_level_3_shows_congratulations(game):
    game.goto_level(2)
    game.win_level_by_teleport()
    assert game.text_at(5, 4, 11) == "ENHORABUENA"
    assert game.var("new_record") == 1
    game.gb.tick(40)
    game.press("start")
    assert game.var("scene_id") == SCENE_TITLE


def test_new_game_resets_score_and_level(game):
    game.win_level_by_teleport()
    game.gb.memory[game.sym["current_level"]] = 2
    game.gb.tick(40)
    game.press("start")
    game.win_level_by_teleport()            # final
    game.gb.tick(40)
    game.press("start")                     # título
    game.press("start")                     # partida nueva
    assert game.var("current_level") == 0
    assert game.bcd("score", 3) == 0
