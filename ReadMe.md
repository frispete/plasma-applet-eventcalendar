# Event Calendar

A KDE Plasma 6 replacement for the digital clock: a calendar and agenda with a
weather forecast, meteogram and timer.

This is a Plasma 6 port of [Zren's Event Calendar](https://github.com/Zren/plasma-applet-eventcalendar)
(last released for Plasma 5 as v76). It targets current openSUSE Tumbleweed but
should run on any distribution with Plasma 6.

![](https://i.imgur.com/qdJ71sb.jpg)

## Changes from the Plasma 5 version

* **No built-in Google Calendar/Tasks sync.** Google shut down the login flow it
  used. Use Akonadi instead, see [Google Calendar](#google-calendar) below.
* Event editing/deleting from the agenda is gone, since Plasma calendar events
  are read-only. New events can still be created in Akonadi calendars.
* The Weather Canada provider is gone; OpenWeatherMap remains.
* Network detection works with NetworkManager, wicked or systemd-networkd.

The plugin id is unchanged (`org.kde.plasma.eventcalendar`), so an existing
widget and its settings carry over.

## Requirements

On openSUSE Tumbleweed:

```
sudo zypper install plasma6-workspace plasma5support6 qt6-qt5compat-imports \
	kdepim-addons akonadi-calendar-tools \
	python3-gobject typelib-1_0-Notify-0_7 libcanberra0 iproute2
```

* `kdepim-addons`: the PIM events calendar plugin (Akonadi/KOrganizer calendars)
* `akonadi-calendar-tools`: `konsolekalendar`, used to create new events
* `python3-gobject`, `typelib-1_0-Notify-0_7`, `libcanberra0`: notifications with sounds
* `iproute2`: the `ip` command for network detection

## Install

```
git clone https://github.com/frispete/plasma-applet-eventcalendar.git eventcalendar
cd eventcalendar
./install
```

If the widget is already installed, `./install` upgrades it and restarts
plasmashell so the new version is loaded. `./update` runs `git pull` and then
`./install`. `./uninstall` removes the widget.

Then right click your clock in the panel > Show Alternatives > Event Calendar.

## Configure

### Google Calendar

1. Add your Google account to Akonadi as a "Google Groupware" calendar,
   eg: with the add calendar button in KOrganizer or Merkuro.
2. Open the Event Calendar settings > Events and enable the calendar events
   (PIM) plugin.
3. Its settings page appears in the sidebar; select the calendars to show there.

The same works for any other calendar in KOrganizer/Akonadi (CalDAV, iCal files, …).

### Weather

Go to the Weather tab and enter your OpenWeatherMap city id, or use "Find City".
The widget ships a shared API key; if it hits its rate limit you can enter your
own key from [openweathermap.org](https://openweathermap.org/appid).

## Development

See [CLAUDE.md](CLAUDE.md) for an overview of the code, and
[package/translate/ReadMe.md](package/translate/ReadMe.md) for translations.

* `scripts/viewer-log.sh [seconds] [plasmoidviewer args]`: run the widget from
  the checkout without a window and print the QML log
* `scripts/viewer-shot.sh out.png [seconds] [args]`: same on a private Xvfb display,
  saving a screenshot
* `scripts/config-shot.sh config/ConfigGeneral.qml out.png`: open a settings page
* `./build`: build the `*.plasmoid` for the KDE Store
