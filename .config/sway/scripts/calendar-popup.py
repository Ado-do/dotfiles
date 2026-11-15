#!/usr/bin/env python3
"""Calendar popup under waybar's clock.

A GtkCalendar on a layer-shell surface, top center of the focused output.
Running it again closes the open one (Gtk.Application is single-instance),
so the same command serves waybar's on-click and the sway binding.

Keys: h/j/k/l (or arrows) move by day/week, H/L (or PageUp/PageDown) by
month, J/K by year, t jumps back to today, Enter opens calcure, Escape/q closes.
It grabs the keyboard while open, like fuzzel: focus-out can't close it,
since layer-shell surfaces get spurious focus-out events on map.

Requires: python3-gobject, gtk3, gtk-layer-shell
"""

import calendar
import datetime
import os
import subprocess
import sys

# en_GB: weeks start on Monday, like waybar's clock (GTK reads it at init)
os.environ["LC_TIME"] = "en_GB.UTF-8"

import gi  # noqa: E402

gi.require_version("Gdk", "3.0")
gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gdk, Gtk, GtkLayerShell  # noqa: E402

PANEL = os.path.expanduser("~/.config/sway/scripts/panel.sh")

# Tokyo Night, matching waybar's tooltip calendar
CSS = b"""
window { background: transparent; }
.popup {
    background-color: #1a1b26;
    border: 1px solid #414868;
    border-radius: 10px;
    padding: 12px 16px;
    color: #c0caf5;
    font-family: 'IosevkaTerm NFP', monospace;
    font-weight: 600;
    font-size: 20px;
}
calendar {
    background: transparent;
    color: #c0caf5;
    border: none;
    padding: 4px;
}
calendar.header { background: transparent; border: none; }
calendar.button { color: #7aa2f7; }
calendar.button:hover { color: #c0caf5; }
calendar.highlight { color: #7aa2f7; }
calendar:indeterminate { color: #414868; }
calendar:selected {
    background-color: #414868;
    color: #ff9e64;
    border-radius: 6px;
}
.footer { color: #737aa2; padding-top: 10px; }
"""


def shift_month(date, n):
    month = date.month - 1 + n
    year = date.year + month // 12
    month = month % 12 + 1
    day = min(date.day, calendar.monthrange(year, month)[1])
    return date.replace(year=year, month=month, day=day)


class Popup(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="local.sway.CalendarPopup")
        self.win = None

    def do_activate(self):
        # A second launch lands here in the running instance: toggle off
        if self.win:
            self.quit()
            return

        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        win = self.win = Gtk.ApplicationWindow(application=self)
        visual = win.get_screen().get_rgba_visual()
        if visual:
            win.set_visual(visual)  # transparent corners around the rounded box

        GtkLayerShell.init_for_window(win)
        GtkLayerShell.set_namespace(win, "calendar")
        # Overlay, not top: over fullscreen windows it'd grab keys while hidden
        GtkLayerShell.set_layer(win, GtkLayerShell.Layer.OVERLAY)
        # Only the top edge: centered horizontally, below waybar's exclusive zone
        GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_margin(win, GtkLayerShell.Edge.TOP, 6)
        GtkLayerShell.set_keyboard_mode(win, GtkLayerShell.KeyboardMode.EXCLUSIVE)

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        box.get_style_context().add_class("popup")
        self.cal = Gtk.Calendar(show_week_numbers=True)
        self.footer = Gtk.Label()
        self.footer.get_style_context().add_class("footer")
        box.add(self.cal)
        box.add(self.footer)
        win.add(box)

        self.cal.connect("month-changed", lambda _: self.mark_today())
        self.cal.connect("day-selected", lambda _: self.update_footer())
        self.cal.connect("day-selected-double-click", lambda _: self.open_calcure())
        win.connect("key-press-event", self.on_key)

        self.mark_today()
        self.update_footer()
        win.show_all()
        self.cal.grab_focus()

    def selected(self):
        year, month0, day = self.cal.get_date()
        return datetime.date(year, month0 + 1, day)

    def select(self, date):
        self.cal.select_day(1)  # so a 31 doesn't overflow a shorter month
        self.cal.select_month(date.month - 1, date.year)
        self.cal.select_day(date.day)

    def mark_today(self):
        today = datetime.date.today()
        year, month0, _ = self.cal.get_date()
        self.cal.clear_marks()
        if (year, month0 + 1) == (today.year, today.month):
            self.cal.mark_day(today.day)  # bold, still visible once the selection moves

    def update_footer(self):
        date = self.selected()
        delta = (date - datetime.date.today()).days
        if delta == 0:
            when = "today"
        elif abs(delta) == 1:
            when = "tomorrow" if delta > 0 else "yesterday"
        elif delta > 0:
            when = f"in {delta} days"
        else:
            when = f"{-delta} days ago"
        self.footer.set_text(f"{date:%a %d %b} · W{date:%V} · {when}")

    def open_calcure(self):
        subprocess.Popen([PANEL, "Calendar", "calcure"], start_new_session=True)
        self.quit()

    def on_key(self, _win, event):
        key = Gdk.keyval_name(event.keyval)
        date = self.selected()
        moves = {
            "h": datetime.timedelta(days=-1),
            "l": datetime.timedelta(days=1),
            "k": datetime.timedelta(weeks=-1),
            "j": datetime.timedelta(weeks=1),
        }
        if key in ("Escape", "q"):
            self.quit()
        elif key in moves:
            self.select(date + moves[key])
        elif key in ("H", "L"):
            self.select(shift_month(date, -1 if key == "H" else 1))
        elif key in ("J", "K"):
            self.select(shift_month(date, 12 if key == "J" else -12))
        elif key == "t":
            self.select(datetime.date.today())
        elif key in ("Return", "KP_Enter"):
            self.open_calcure()
        else:
            return False  # arrows, PageUp/PageDown: GtkCalendar's own handling
        return True


if __name__ == "__main__":
    sys.exit(Popup().run(sys.argv[:1]))
