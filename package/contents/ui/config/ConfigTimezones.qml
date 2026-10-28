import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kcmutils as KCM
import org.kde.plasma.private.digitalclock as DigitalClock
import org.kde.plasma.plasmoid

import ".."
import "../lib"

// Mostly copied from digitalclock
KCM.ScrollViewKCM {
	id: page

	// Lets the settings dialog enable Apply and undo changes on Cancel/Discard.
	// Older dialogs (and plasmoidviewer) only know the configurationChanged signal.
	property alias unsavedChanges: configTransaction.unsavedChanges
	signal configurationChanged()
	function saveConfig() {
		configTransaction.save()
	}
	property ConfigTransaction configTransaction: ConfigTransaction {
		id: configTransaction
		window: page.Window.window
		onUnsavedChangesChanged: {
			if (unsavedChanges) {
				page.configurationChanged()
			}
		}
	}

	function digitalclock_i18n(message) {
		return i18nd("plasma_applet_org.kde.plasma.digitalclock", message)
	}

	DigitalClock.TimeZoneModel {
		id: timeZoneModel

		selectedTimeZones: Plasmoid.configuration.selectedTimeZones
		onSelectedTimeZonesChanged: Plasmoid.configuration.selectedTimeZones = selectedTimeZones
	}

	header: ColumnLayout {
		MessageWidget {
			id: messageWidget
			Layout.fillWidth: true
		}

		TextField {
			id: filter
			Layout.fillWidth: true
			placeholderText: digitalclock_i18n("Search Time Zones")
		}
	}

	view: ListView {
		id: timeZoneView
		clip: true

		model: DigitalClock.TimeZoneFilterProxy {
			sourceModel: timeZoneModel
			filterString: filter.text
		}

		delegate: CheckDelegate {
			id: timeZoneDelegate
			width: ListView.view.width
			text: {
				var name = model.region ? i18nc("city, region", "%1, %2", model.city, model.region) : model.city
				return model.comment ? i18nc("time zone name (comment)", "%1 (%2)", name, model.comment) : name
			}
			checked: model.checked

			onToggled: {
				if (!checked && model.region == "Local") {
					messageWidget.warn(i18n("Cannot deselect Local time from the tooltip"))
				} else {
					model.checked = checked // needed for model's setData to be called
				}
				checked = Qt.binding(function() { return model.checked })
			}
		}
	}

	footer: RowLayout {
		ButtonGroup { id: timezoneDisplayType }

		Label {
			text: digitalclock_i18n("Display time zone as:")
		}

		RadioButton {
			id: timezoneCityRadio
			text: digitalclock_i18n("Time zone city")
			ButtonGroup.group: timezoneDisplayType
			checked: !Plasmoid.configuration.displayTimezoneAsCode
			onClicked: Plasmoid.configuration.displayTimezoneAsCode = false
		}

		RadioButton {
			id: timezoneCodeRadio
			text: digitalclock_i18n("Time zone code")
			ButtonGroup.group: timezoneDisplayType
			checked: Plasmoid.configuration.displayTimezoneAsCode
			onClicked: Plasmoid.configuration.displayTimezoneAsCode = true
		}
	}
}
