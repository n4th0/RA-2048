"""Bot que juega a Pastor pulsando la cruceta, para comprobar que se puede ganar.

Sirve para cualquier nivel. Para cada oveja suelta planifica, con una búsqueda
en anchura, una ruta de "empujones" hasta el corral:
  - Empujar en la dirección d es posible si el pastor cabe detrás (en s - d):
    la oveja huye y avanza a s + d.
  - Si s + d es valla, la oveja resbala de lado; si solo uno de los dos lados
    está libre, el resultado es seguro y también vale como paso de la ruta.
    Así se modela el truco de las esquinas y las paredes.
Luego el pastor rodea la oveja (sin entrar en su zona de miedo salvo por
detrás) hasta su casilla de empuje y avanza hacia ella.

Uso:  python tests/bot.py [salida.gif]   (juega la partida entera)
"""
import sys
from collections import deque
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from conftest import (  # noqa: E402
    SCENE_GAME, SCENE_MESSAGE, SCREEN_H, SCREEN_W, TILE_CORRAL, TILE_GRASS, TYPE_SHEEP, Game,
)

DIRS = {"up": (-1, 0), "down": (1, 0), "left": (0, -1), "right": (0, 1)}
STEP_FRAMES = 6


def walkable(game, y, x):
    return 0 <= y < SCREEN_H and 0 <= x < SCREEN_W and game.map_tile(y, x) in (TILE_GRASS, TILE_CORRAL)


def push_moves(game, s):
    """Empujones posibles desde la casilla s: (dirección del empujón, destino)."""
    for d in DIRS.values():
        stand = (s[0] - d[0], s[1] - d[1])
        if not walkable(game, *stand):
            continue
        ahead = (s[0] + d[0], s[1] + d[1])
        if walkable(game, *ahead):
            yield d, ahead
            continue
        sides = [(s[0] + p[0], s[1] + p[1]) for p in ((d[1], d[0]), (-d[1], -d[0]))]
        free = [c for c in sides if walkable(game, *c)]
        if len(free) == 1:                    # resbala por la pared: resultado seguro
            yield d, free[0]


def plan_push(game, sheep):
    """Primer empujón de la ruta más corta de la oveja al corral (o None)."""
    start = (sheep.y, sheep.x)
    came = {start: None}
    queue = deque([start])
    while queue:
        cur = queue.popleft()
        if game.map_tile(*cur) == TILE_CORRAL:
            while came[cur] is not None and came[cur][0] != start:
                cur = came[cur][0]
            return came[cur][1] if came[cur] else None
        for d, nxt in push_moves(game, cur):
            if nxt not in came:
                came[nxt] = (cur, d)
                queue.append(nxt)
    return None


def walk_step(game, start, goal, blocked):
    """Primera casilla del camino más corto del pastor, evitando 'blocked'."""
    came = {start: None}
    queue = deque([start])
    while queue:
        cur = queue.popleft()
        if cur == goal:
            while came[cur] != start:
                cur = came[cur]
            return cur
        for d in DIRS.values():
            nxt = (cur[0] + d[0], cur[1] + d[1])
            if nxt not in came and walkable(game, *nxt) and nxt not in blocked:
                came[nxt] = cur
                queue.append(nxt)
    return None


def choose_step(game):
    me = game.shepherd()
    pos = (me.y, me.x)
    loose = [s for s in game.entities() if s.type == TYPE_SHEEP]
    others = {(e.y, e.x) for e in game.entities() if e.index != me.index}
    plans = []
    for s in loose:
        d = plan_push(game, s)
        if d:
            stand = (s.y - d[0], s.x - d[1])
            plans.append((abs(stand[0] - me.y) + abs(stand[1] - me.x), s, d, stand))
    if not plans:
        return None
    _, s, d, stand = min(plans, key=lambda p: p[0])
    if pos == stand:
        return (s.y, s.x)                     # empujar
    # Rodearla sin asustarla: la zona de miedo se evita salvo la línea de detrás
    behind = {(s.y - k * d[0], s.x - k * d[1]) for k in range(1, 4)}
    fear = {(s.y + a, s.x + b) for a in range(-3, 4) for b in range(-3, 4) if abs(a) + abs(b) <= 3} - behind
    blocked = (others | fear) - {stand}
    return walk_step(game, pos, stand, blocked) or walk_step(game, pos, stand, others - {stand})


def play_level(game, record=None):
    """Juega el nivel actual hasta ganarlo o perderlo. Devuelve frames usados."""
    frames = 0
    while game.var("scene_id") == SCENE_GAME and not game.var("game_won"):
        me = game.shepherd()
        step = choose_step(game)
        button = None
        if step:
            move = (step[0] - me.y, step[1] - me.x)
            button = next((b for b, v in DIRS.items() if v == move), None)
        if button:
            game.gb.button_press(button)
        for _ in range(STEP_FRAMES):
            game.gb.tick(1)
            frames += 1
            if record is not None and frames % 3 == 0:
                record.append(game.gb.screen.image.convert("RGB"))
        if button:
            game.gb.button_release(button)
    return frames


def wait_for_scene(game, scene, record=None, max_frames=600):
    for i in range(max_frames):
        if game.var("scene_id") == scene:
            return True
        game.gb.tick(1)
        if record is not None and i % 3 == 0:
            record.append(game.gb.screen.image.convert("RGB"))
    return False


def play_game(game, record=None):
    """Juega la partida entera desde el nivel 1. Devuelve segundos por nivel."""
    seconds = []
    while True:
        seconds.append(play_level(game, record) / 60)
        if not wait_for_scene(game, SCENE_MESSAGE, record):
            raise AssertionError("no apareció la pantalla de mensaje")
        if game.var("current_level") == 0 or not game.var("game_won"):
            return seconds                    # perdió (o terminó y volvió a empezar)
        game.gb.tick(40)                      # el mensaje ignora START los primeros frames
        if record is not None:
            for _ in range(20):
                game.gb.tick(2)
                record.append(game.gb.screen.image.convert("RGB"))
        finished = game.var("after_message") == 1
        game.press("start")
        if finished:
            return seconds


if __name__ == "__main__":
    from PIL import Image

    g = Game()
    shots: list = [] if len(sys.argv) > 1 else None
    per_level = play_game(g, shots)
    print("segundos por nivel:", [round(s, 1) for s in per_level],
          "| escena final:", g.var("scene_id"), "| puntos:", g.number("score", 6))
    if shots:
        big = [s.resize((320, 288), Image.NEAREST) for s in shots[::2]]
        big[0].save(sys.argv[1], save_all=True, append_images=big[1:], duration=60, loop=0)
    g.stop()
