# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Event Calendar is a KDE Plasma 6 plasmoid (`org.kde.plasma.eventcalendar`) written in QML/JavaScript: a calendar + agenda + weather + timer popup that replaces the digital clock. There is no compiled code; the `package/` directory *is* the plasmoid. Target is current openSUSE Tumbleweed (Qt 6, KF6, Plasma 6). Plasma 5 is not supported any more, and the built-in Google Calendar/Tasks sync was removed on purpose (Google calendars come in through Akonadi and the PIM events plugin) — don't reintroduce either. The plugin id is kept unchanged so existing widgets and their settings carry over.

## Commands

Scripts run from the repo root, read `package/metadata.json` (helpers in `scripts/common.sh`) and are bash.

- `./install` — install with `kpackagetool6`; if already installed, upgrades **and restarts plasmashell** (`--restart` forces a restart on a fresh install too). `./uninstall`, `./update` (git pull + install).
- `./build` — runs translate `merge` + `build`, aborts if that changes `package/translate` (commit those first), then zips `eventcalendar-v<version>-plasma6.plasmoid`.
- `scripts/viewer-log.sh [seconds] [plasmoidviewer args]` — load the widget from the checkout headless (`QT_QPA_PLATFORM=offscreen`) and print the QML log. Use `-l floating -f planar` to get the full popup view loaded, `-l topedge -f horizontal` for the panel clock. This is the main "does it load" test.
- `scripts/viewer-shot.sh out.png [seconds] [args]` — same on a private Xvfb display with a screenshot (add `-c org.kde.panel` to see the compact clock).
- `scripts/config-shot.sh config/ConfigGeneral.qml out.png` — opens the settings dialog on that page (temporary package copy with the page moved first) and saves screenshot + log.
- `qmllint6 -I /usr/lib64/qt6/qml <files>` — useful, but ignore `[unqualified]` and most `[missing-property]`: the code relies on ids from parent scopes (`logger`, `appletConfig`, `eventModel`, `timeModel`, …) and dynamic lookups.
- `package/translate/merge` / `build` — extract `i18n()` strings into `template.pot` + merge `*.po` (also updates the status table in `package/translate/ReadMe.md`) / compile to `contents/locale` (gitignored).

Notes for testing: plasmoidviewer creates a fresh applet config each run, so to see `logger.debug` output temporarily set `showDebug: true` in `main.qml`'s `Logger`. Qt only logs to stderr with `QT_FORCE_STDERR_LOGGING=1` (the scripts set it). Bundled translations are only loaded for an *installed* package; to test them without touching the user's install use `XDG_DATA_HOME=<tmpdir> kpackagetool6 -t Plasma/Applet -i package` and `plasmoidviewer -a org.kde.plasma.eventcalendar` with the same `XDG_DATA_HOME`. The settings dialog logs one harmless "does not have a property called cfg_…" line per config key, because pages write `Plasmoid.configuration` directly instead of using `cfg_` properties.

There is no automated test suite. Debug aids: the `debugging` config option (also shows the hidden "ICalendar" and "Advanced" settings pages), `DebugCalendarManager` (fixtures in `ui/code/DebugFixtures.js`) which can be bound in `EventModel.qml`.

## Architecture

Entry point `package/contents/ui/main.qml` is a `PlasmoidItem`. It instantiates objects that the rest of the UI reaches by id through QML scope: `logger`, `configMigration`, `appletConfig`, `notificationManager`, `networkMonitor`, `timeModel`, `timerModel`, `eventModel`, `upcomingEvents`, `agendaModel`, `logic`. Compact representation is `ClockView.qml`, full representation `PopupView.qml` (meteogram, timer, month view, agenda). `Logic.qml` drives polling and weather updates.

**Calendar backends** (`ui/calendars/`): `CalendarManager.qml` is the base type with the common signals (`calendarFetched`, `eventAdded/Created/Removed/Deleted/Updated`, `error`, `allDataFetched`) and overridable functions. Events use Google-Calendar-shaped JSON (`start.date`/`start.dateTime`, `summary`, `backgroundColor`, …) throughout, also for non-Google sources. `EventModel.qml` is itself a `CalendarManager` that aggregates the others via `bindSignals()`, maps `calendarId → manager` and flattens everything into `eventsData` in `mergeEvents()`. Backends:
- `PlasmaCalendarManager` — Plasma calendar plugins (holidays, PIM/Akonadi, astronomical, …) via `org.kde.plasma.workspace.calendar`: its own `EventPluginsManager` + a `Calendar` whose `daysModel.eventsForDate()` is queried day by day. Plugins deliver data asynchronously, so `daysModel.agendaUpdated` triggers a debounced refresh. The event type of a plugin item is only available as a translated string (domain `plasmashellprivateplugin`). New events in Akonadi calendars are created with `konsolekalendar`.
- `ICalManager` — reads `.ics` via `scripts/icsjson.py` (needs python `icalendar`); currently not bound in `EventModel`.

`enabledCalendarPlugins` stores Plasma 6 plugin ids (`holidaysevents`, `pimevents`, …); `PlasmaCalendarUtils.toPluginIdList()` also normalizes old file names/paths.

**Weather** (`ui/weather/`): `WeatherApi.js` dispatches to `OpenWeatherMap.js` (the only provider), consumed by `MeteogramView` and `AgendaModel`. Icons come from the bundled weather icon font via `FontIcon.qml`.

**External processes**: `lib/ExecUtil.qml` wraps a `Plasma5Support.DataSource` (`executable` engine) with `exec(cmdOrArgv, callback)`; pass an array to get shell-quoted arguments. Used for notifications (`scripts/notification.py`, needs PyGObject/libnotify/libcanberra), `konsolekalendar`, `icsjson.py`, the clock's mouse wheel commands and `NetworkMonitor` (polls `ip route show default`, backend agnostic). Package files are located with `Qt.resolvedUrl()` (+ `Shared.urlToPath()` for a local path); `Plasmoid.file()` no longer exists.

**Configuration**: schema in `package/contents/config/main.xml`; categories in `config/config.qml` (plus one per enabled calendar plugin that has a config UI); pages in `ui/config/`. Pages are `ConfigPage` (`KCM.SimpleKCM`) or `KCM.ScrollViewKCM` and use the `ui/lib/Config*.qml` controls, which take a `configKey` and write `Plasmoid.configuration` directly (throttled), so changes are previewed live. `lib/ConfigTransaction.qml` (wired into `ConfigPage`, `ConfigTimezones` and `ConfigAdvanced`; add it to any new `ScrollViewKCM` page) remembers the values when a page opens, reports `unsavedChanges` + emits `configurationChanged()` so the dialog enables Apply, and restores the values on Cancel/Discard; keys the widget writes itself must be listed in its `isInternalKey()`. Don't name a page function `saveConfig()` for anything else, the dialog calls it on Apply. `ConfigSpinBox` emulates decimals on top of QQC2's int-only SpinBox. Complex values are base64-encoded JSON strings (`stringType="base64json"`, `lib/Base64Json*.qml`). Renamed/converted keys are migrated once in `ui/ConfigMigration.qml`, guarded by a `vNNMigration` bool in `main.xml` — add a new flag + block there when changing a stored format.

## Conventions and pitfalls

- Indent with tabs. All user-visible strings go through `i18n()`/`i18nc()`.
- Format dates with `date.toLocaleString(Qt.locale(), format)` (or `toLocaleDateString`/`toLocaleTimeString`); Qt 6's `Qt.formatDateTime(date, "format")` ignores the locale.
- Signal handlers that use arguments must declare them (`onClicked: function(mouse) { … }`), and `Connections` use `function onFoo(args) {}`.
- Use `Kirigami.Units`/`Kirigami.Theme`, `Kirigami.Icon`, `PlasmaExtras.Menu` for context menus, QQC2/PlasmaComponents3 controls; there is no `units`/`theme` context property and no Controls 1.
- Release: bump `KPlugin.Version` in `package/metadata.json` and add a `Changelog.md` section. Metadata name/description translations are maintained by hand in `metadata.json`.
