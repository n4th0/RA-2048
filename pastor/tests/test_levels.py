"""Los mapas de los 3 niveles son jugables (sin emulador: lee levels.asm)."""
import pytest

import level_check as lc

MAPS = lc.load_maps()
SPAWNS = lc.load_spawns()
LEVELS = sorted(MAPS)
EXPECTED_SHEEP = {"level_1": 5, "level_2": 7, "level_3": 9}


def test_there_are_three_levels():
    assert LEVELS == ["level_1", "level_2", "level_3"]


@pytest.mark.parametrize("name", LEVELS)
def test_map_is_closed_by_fence(name):
    m = MAPS[name]
    assert m[1] == "#" * 20 and m[17] == "#" * 20
    assert all(row[0] == "#" and row[19] == "#" for row in m[1:18])


@pytest.mark.parametrize("name", LEVELS)
def test_spawns_are_valid(name):
    m, spawns = MAPS[name], SPAWNS[name]
    assert len(spawns) - 1 == EXPECTED_SHEEP[name]
    assert len(set(spawns)) == len(spawns), "dos entidades en la misma casilla"
    for y, x in spawns:
        assert m[y][x] == ".", f"spawn ({y},{x}) no está sobre hierba"


@pytest.mark.parametrize("name", LEVELS)
def test_corral_fits_all_sheep_with_room_to_spare(name):
    corral = sum(row.count(":") for row in MAPS[name])
    assert corral >= EXPECTED_SHEEP[name] * 2, "las ovejas encerradas taparían la entrada"


@pytest.mark.parametrize("name", LEVELS)
def test_no_trap_cells(name):
    """Desde cualquier casilla de hierba hay una ruta de empujones al corral."""
    assert lc.trapped_cells(MAPS[name]) == []
