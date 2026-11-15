#!/usr/bin/env python3
"""Transparent input blocker for freeze.sh.

One fully transparent layer-shell surface per output (overlay layer, over
waybar too) with exclusive keyboard focus: keys that sway doesn't bind in
the "frozen" mode end up here and are dropped instead of reaching the
focused window. Nothing is drawn; waybar's mode module blinks instead.
Pointer input is disabled in sway by freeze.sh.

Usage: freeze-overlay.py READY_FILE
  READY_FILE is created once the surfaces are shown. Exits on SIGTERM/SIGINT.

Requires: python3-gobject, gtk3, gtk-layer-shell
"""

import signal
import sys

import gi

gi.require_version("Gdk", "3.0")
gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
gi.require_version("GLibUnix", "2.0")
from gi.repository import Gdk, GLib, GLibUnix, Gtk, GtkLayerShell  # noqa: E402


def clear(_widget, cr):
    cr.set_source_rgba(0, 0, 0, 0)
    cr.set_operator(1)  # cairo.OPERATOR_SOURCE
    cr.paint()
    return False


def cover(monitor):
    win = Gtk.Window()
    win.set_app_paintable(True)
    visual = win.get_screen().get_rgba_visual()
    if visual:
        win.set_visual(visual)

    GtkLayerShell.init_for_window(win)
    GtkLayerShell.set_namespace(win, "freeze")
    GtkLayerShell.set_layer(win, GtkLayerShell.Layer.OVERLAY)
    GtkLayerShell.set_monitor(win, monitor)
    for edge in GtkLayerShell.Edge.LEFT, GtkLayerShell.Edge.RIGHT, GtkLayerShell.Edge.TOP, GtkLayerShell.Edge.BOTTOM:
        GtkLayerShell.set_anchor(win, edge, True)
    GtkLayerShell.set_exclusive_zone(win, -1)
    GtkLayerShell.set_keyboard_mode(win, GtkLayerShell.KeyboardMode.EXCLUSIVE)

    win.connect("draw", clear)
    win.connect("key-press-event", lambda *_: True)  # swallow it
    win.show_all()


def main():
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} READY_FILE", file=sys.stderr)
        return 2
    if not GtkLayerShell.is_supported():
        print("layer-shell not supported", file=sys.stderr)
        return 1

    display = Gdk.Display.get_default()
    for i in range(display.get_n_monitors()):
        cover(display.get_monitor(i))
    # An output plugged in while frozen gets covered too
    display.connect("monitor-added", lambda _display, monitor: cover(monitor))

    for sig in signal.SIGTERM, signal.SIGINT:
        GLibUnix.signal_add(GLib.PRIORITY_DEFAULT, sig, Gtk.main_quit)

    open(sys.argv[1], "w").close()
    Gtk.main()
    return 0


if __name__ == "__main__":
    sys.exit(main())
