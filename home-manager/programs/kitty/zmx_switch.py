# zmx helpers for kitty keybindings. zmx's own ctrl+\ detach key is disabled
# (ZMX_NO_DETACH_KEY in zshrc), so detaching runs `zmx detach` out of band,
# which works no matter what program is running inside the session.
#
#   kitten zmx_switch.py detach   detach the session in this window
#   kitten zmx_switch.py switch   inside zmx: detach (zsm, if it attached the
#                                 session, reopens its list); at a bare zsh
#                                 prompt: run zsm; otherwise: do nothing
import os
import shutil
import subprocess

from kittens.tui.handler import result_handler


def main(args):
    pass


def attached_session(cmdline):
    """Session name from `zmx attach [--labels kv] <name> [cmd...]`."""
    if len(cmdline) < 3 or os.path.basename(cmdline[0]) != 'zmx' or cmdline[1] not in ('attach', 'a'):
        return None
    rest = cmdline[2:]
    while rest and rest[0].startswith('--'):
        rest = rest[2:] if rest[0] == '--labels' else rest[1:]
    return rest[0] if rest else None


def detach(exe, session):
    zmx = exe if os.path.isabs(exe) else shutil.which('zmx') or 'zmx'
    subprocess.Popen([zmx, 'detach'], env={**os.environ, 'ZMX_SESSION': session},
                     stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    w = boss.window_id_map.get(target_window_id)
    if w is None:
        return
    mode = args[1] if len(args) > 1 else 'switch'
    procs = [p['cmdline'] for p in w.child.foreground_processes if p.get('cmdline')]

    for cmdline in procs:
        session = attached_session(cmdline)
        if session:
            detach(cmdline[0], session)
            return

    if mode == 'switch' and any(os.path.basename(c[0]).lstrip('-') == 'zsh' for c in procs):
        w.write_to_child(b'\x15zsm\r')
