import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.workspace.calendar as PlasmaCalendar
import org.kde.plasma.plasmoid

import "../lib"
import "../calendars/PlasmaCalendarUtils.js" as PlasmaCalendarUtils

ConfigPage {
	id: page

	HeaderText {
		text: i18n("Event Calendar Plugins")
		visible: Plasmoid.configuration.debugging
	}

	ConfigSection {
		visible: Plasmoid.configuration.debugging
		CheckBox {
			text: i18n("ICalendar (.ics)")
			checked: true
			enabled: false
		}
	}


	HeaderText {
		text: i18n("Plasma Calendar Plugins")
	}

	Label {
		Layout.fillWidth: true
		wrapMode: Text.Wrap
		text: i18n("Enable the calendar events (PIM) plugin to show calendars from KOrganizer/Akonadi, eg: Google Calendar. Choose the calendars on its settings page, which appears in the sidebar once the plugin is enabled.")
	}

	// From digitalclock's configCalendar.qml
	PlasmaCalendar.EventPluginsManager {
		id: eventPluginsManager
		Component.onCompleted: populateEnabledPluginsList(PlasmaCalendarUtils.toPluginIdList(Plasmoid.configuration.enabledCalendarPlugins))
	}
	ConfigSection {
		Repeater {
			id: calendarPluginsRepeater
			model: eventPluginsManager.model
			delegate: CheckBox {
				text: model.display
				checked: model.checked
				onClicked: {
					model.checked = checked // needed for model's setData to be called
					page.saveConfig()
				}
			}
		}
	}
	function saveConfig() {
		Plasmoid.configuration.enabledCalendarPlugins = eventPluginsManager.enabledPlugins
	}

	HeaderText {
		text: i18n("Misc")
	}
	ColumnLayout {

		ConfigSpinBox {
			configKey: 'eventsPollInterval'
			before: i18n("Refresh events every: ")
			suffix: i18nc("Polling interval in minutes", "min")
			minimumValue: 5
			maximumValue: 90
		}
	}

	HeaderText {
		text: i18n("Notifications")
	}

	ConfigSection {
		ConfigNotification {
			label: i18n("Event Reminder")
			notificationEnabledKey: 'eventReminderNotificationEnabled'
			sfxEnabledKey: 'eventReminderSfxEnabled'
			sfxPathKey: 'eventReminderSfxPath'
			sfxPathDefaultValue: '/usr/share/sounds/Oxygen-Im-Nudge.ogg'

			RowLayout {
				spacing: 0
				Item { implicitWidth: parent.parent.indentWidth } // indent
				ConfigSpinBox {
					configKey: 'eventReminderMinutesBefore'
					suffix: i18nc("Polling interval in minutes", "min")
					minimumValue: 1
				}
			}
		}
	}

	ConfigSection {
		ConfigNotification {
			label: i18n("Event Starting")
			notificationEnabledKey: 'eventStartingNotificationEnabled'
			sfxEnabledKey: 'eventStartingSfxEnabled'
			sfxPathKey: 'eventStartingSfxPath'
			sfxPathDefaultValue: '/usr/share/sounds/Oxygen-Im-Nudge.ogg'
		}
	}

}
