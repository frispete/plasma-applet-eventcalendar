import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.private.digitalclock as DigitalClock
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils

import "./lib"

PlasmoidItem {
	id: root

	Logger {
		id: logger
		name: 'eventcalendar'
		showDebug: Plasmoid.configuration.debugging
		// showDebug: true
	}

	ConfigMigration { id: configMigration }
	AppletConfig { id: appletConfig }
	NotificationManager { id: notificationManager }
	NetworkMonitor { id: networkMonitor }

	property alias eventModel: eventModel
	property alias agendaModel: agendaModel
	
	TimeModel { id: timeModel }
	TimerModel { id: timerModel }
	EventModel { id: eventModel }
	UpcomingEvents { id: upcomingEvents }
	AgendaModel {
		id: agendaModel
		eventModel: eventModel
		timeModel: timeModel
		Component.onCompleted: logger.debug('AgendaModel.onCompleted')
	}
	Logic { id: logic }

	FontLoader {
		source: "../fonts/weathericons-regular-webfont.ttf"
	}

	toolTipItem: Loader {
		id: tooltipLoader

		Layout.minimumWidth: item ? item.width : 0
		Layout.maximumWidth: item ? item.width : 0
		Layout.minimumHeight: item ? item.height : 0
		Layout.maximumHeight: item ? item.height : 0

		source: "TooltipView.qml"
	}

	ExecUtil { id: executable }

	property Component clockComponent: ClockView {
		id: clock

		currentTime: timeModel.currentTime

		MouseArea {
			id: mouseArea
			anchors.fill: parent

			property int wheelDelta: 0

			onClicked: function(mouse) {
				if (mouse.button == Qt.LeftButton) {
					root.expanded = !root.expanded
				}
			}

			onWheel: function(wheel) {
				var delta = wheel.angleDelta.y || wheel.angleDelta.x
				wheelDelta += delta

				// Magic number 120 for common "one click"
				// See: https://doc.qt.io/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
				while (wheelDelta >= 120) {
					wheelDelta -= 120
					onScrollUp()
				}
				while (wheelDelta <= -120) {
					wheelDelta += 120
					onScrollDown()
				}
			}

			function onScrollUp() {
				if (Plasmoid.configuration.clockMouseWheel === 'RunCommands') {
					executable.exec(Plasmoid.configuration.clockMouseWheelUp)
				}
			}
			function onScrollDown() {
				if (Plasmoid.configuration.clockMouseWheel === 'RunCommands') {
					executable.exec(Plasmoid.configuration.clockMouseWheelDown)
				}
			}
		}
	}

	property Component popupComponent: PopupView {
		id: popup

		eventModel: root.eventModel
		agendaModel: root.agendaModel

		// If pin is enabled, we need to add some padding around the popup unless
		// * we're a desktop widget (no need)
		// * the timer widget is enabled since there's room in the top right
		property bool isPinVisible: {
			// Plasmoid.location == PlasmaCore.Types.Floating when using plasmawindowed and when used as a desktop widget.
			return Plasmoid.location != PlasmaCore.Types.Floating // && Plasmoid.configuration.widget_show_pin
		}
		padding: {
			if (isPinVisible && !(Plasmoid.configuration.widgetShowTimer || Plasmoid.configuration.widgetShowMeteogram)) {
				return pinButton.height
			} else {
				return 0
			}
		}

		property bool isExpanded: root.expanded
		onIsExpandedChanged: {
			logger.debug('isExpanded', isExpanded)
			if (isExpanded) {
				updateToday()
				logic.updateWeather()
			}
		}

		function updateToday() {
			setToday(timeModel.currentTime)
		}

		function setToday(d) {
			logger.debug('setToday', d)
			today = d
			// console.log(root.timezone, dataSource.data[root.timezone]["DateTime"])
			logger.debug('currentTime', timeModel.currentTime)
			monthViewDate = today
			selectedDate = today
			scrollToSelection()
		}

		Connections {
			target: timeModel
			function onDateChanged() {
				popup.updateToday()
				logger.debug('root.onDateChanged', timeModel.currentTime, popup.today)
			}
		}

		// Allows the user to keep the calendar open for reference
		PlasmaComponents3.ToolButton {
			id: pinButton
			visible: isPinVisible
			anchors.right: parent.right
			width: Math.round(Kirigami.Units.gridUnit * 1.25)
			height: width
			checkable: true
			icon.name: "window-pin"
			checked: Plasmoid.configuration.pin
			onCheckedChanged: Plasmoid.configuration.pin = checked
		}

	}

	hideOnWindowDeactivate: !Plasmoid.configuration.pin

	Plasmoid.backgroundHints: Plasmoid.configuration.showBackground ? PlasmaCore.Types.DefaultBackground : PlasmaCore.Types.NoBackground

	property bool isDesktopContainment: Plasmoid.location == PlasmaCore.Types.Floating
	preferredRepresentation: isDesktopContainment ? fullRepresentation : compactRepresentation
	compactRepresentation: clockComponent
	fullRepresentation: popupComponent

	readonly property bool canChangeSystemSettings: Plasmoid.immutability !== PlasmaCore.Types.SystemImmutable

	Plasmoid.contextualActions: [
		PlasmaCore.Action {
			id: clipboardAction
			text: i18nd("plasma_applet_org.kde.plasma.digitalclock", "Copy to Clipboard")
			icon.name: "edit-copy"
		},
		PlasmaCore.Action {
			text: i18nd("plasma_applet_org.kde.plasma.digitalclock", "Adjust Date and Time…")
			icon.name: "clock"
			visible: root.canChangeSystemSettings
			onTriggered: KCMUtils.KCMLauncher.openSystemSettings("kcm_clock")
		},
		PlasmaCore.Action {
			text: i18n("Set Language…")
			icon.name: "preferences-desktop-locale"
			visible: root.canChangeSystemSettings
			onTriggered: KCMUtils.KCMLauncher.openSystemSettings("kcm_regionandlang")
		}
	]

	Component.onCompleted: {
		DigitalClock.ClipboardMenu.setupMenu(clipboardAction)
	}
}
