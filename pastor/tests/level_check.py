"""Análisis de los mapas: ¿desde qué casillas se puede llevar una oveja al corral?

Usa el mismo modelo de empujones que el bot (bot.push_moves): una casilla es
una TRAMPA si ninguna secuencia de empujones lleva a la oveja al corral (solo
saldría de ahí con un paso al azar). Lee los mapas de levels.asm, sin emulador.

Uso:  python tests/level_check.py
"""
import re
from collections import deque
from pathlib import Path

LEVELS_ASM = Path(__file__).resolve().parent.parent / "src" / "levels.asm"
WALK = ".:"
DIRS = [(-1, 0), (1, 0), (0, -1), (0, 1)]


def load_maps() -> dict[str, list[str]]:
    """Mapas de levels.asm: {etiqueta: 18 filas de 20 caracteres}."""
    maps, current = {}, None
    for line in LEVELS_ASM.read_text().splitlines():
        label = re.match(r"^(level_\d+)::", line)
        if label:
            current = label.group(1)
            maps[current] = []
            continue
        row = re.match(r'^\s+db "(.{20})"', line)
        if row and current and len(maps[current]) < 18:
            maps[current].append(row.group(1))
    return maps


def load_spawns() -> dict[str, list[tuple[int, int]]]:
    spawns, current = {}, None
    for line in LEVELS_ASM.read_text().splitlines():
        label = re.match(r"^(level_\d+)_spawns::", line)
        if label:
            current = label.group(1)
            spawns[current] = []
            continue
        pair = re.match(r"^\s+db\s+(\d+),\s*(\d+)", line)
        if pair and current:
            spawns[current].append((int(pair.group(1)), int(pair.group(2))))
        elif "END_OF_LIST" in line:
            current = None
    return spawns


def walkable(m, y, x):
    return 0 <= y < len(m) and 0 <= x < len(m[0]) and m[y][x] in WALK


def push_moves(m, s):
    for d in DIRS:
        if not walkable(m, s[0] - d[0], s[1] - d[1]):
            continue                          # el pastor no cabe detrás
        ahead = (s[0] + d[0], s[1] + d[1])
        if walkable(m, *ahead):
            yield ahead
            continue
        sides = [(s[0] + p[0], s[1] + p[1]) for p in ((d[1], d[0]), (-d[1], -d[0]))]
        free = [c for c in sides if walkable(m, *c)]
        if len(free) == 1:
            yield free[0]                     # resbala por la pared


def trapped_cells(m) -> list[tuple[int, int]]:
    """Casillas de hierba desde las que no hay ruta de empujones al corral."""
    cells = [(y, x) for y in range(len(m)) for x in range(len(m[0])) if m[y][x] == "."]
    # BFS inverso: qué casillas llegan al corral
    reach = {(y, x) for y in range(len(m)) for x in range(len(m[0])) if m[y][x] == ":"}
    changed = True
    while changed:
        changed = False
        for c in cells:
            if c not in reach and any(n in reach for n in push_moves(m, c)):
                reach.add(c)
                changed = True
    return [c for c in cells if c not in reach]


def show(m, marks):
    for y, row in enumerate(m):
        print("".join("X" if (y, x) in marks else ch for x, ch in enumerate(row)))


if __name__ == "__main__":
    for name, m in load_maps().items():
        bad = trapped_cells(m)
        print(f"{name}: {len(bad)} casillas trampa")
        if bad:
            show(m, set(bad))
