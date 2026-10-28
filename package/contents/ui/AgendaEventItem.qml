import QtQuick
import QtQuick.Controls
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

import "LocaleFuncs.js" as LocaleFuncs
import "Shared.js" as Shared

LinkRect {
	id: agendaEventItem
	readonly property int eventItemIndex: index
	Layout.fillWidth: true
	implicitHeight: contents.implicitHeight

	property bool eventItemInProgress: false
	function checkIfInProgress() {
		if (model.startDateTime && timeModel.currentTime && model.endDateTime) {
			eventItemInProgress = model.startDateTime <= timeModel.currentTime && timeModel.currentTime <= model.endDateTime
		} else {
			eventItemInProgress = false
		}
		// console.log('checkIfInProgress()', model.start, timeModel.currentTime, model.end)
	}
	Connections {
		target: timeModel
		function onLoaded() { agendaEventItem.checkIfInProgress() }
		function onMinuteChanged() { agendaEventItem.checkIfInProgress() }
	}
	Component.onCompleted: agendaEventItem.checkIfInProgress()

	readonly property string eventTimestamp: LocaleFuncs.formatEventDuration(model, {
		relativeDate: agendaItemDate,
		clock24h: appletConfig.clock24h,
	})
	readonly property bool isAllDay: eventTimestamp === i18n("All Day") // TODO: Remove string comparison.
	readonly property bool isCondensed: Plasmoid.configuration.agendaCondensedAllDayEvent && isAllDay


	//---


	QQC2.ToolTip {
		id: eventToolTip
		x: 0
		y: agendaEventItem.height + Kirigami.Units.smallSpacing
		width: agendaEventItem.width
		delay: 1000

		contentItem: Loader {
			active: eventToolTip.visible
			sourceComponent: GridLayout {
				columns: 2

				EventPropertyIcon {
					visible: toolTipDescriptionLabel.showProperty
					source: "x-shape-text"
					Layout.fillHeight: false
					Layout.alignment: Qt.AlignTop
				}
				Text {
					id: toolTipDescriptionLabel
					readonly property bool showProperty: eventDescription.showInTooltip && text
					visible: showProperty
					text: Shared.renderText(model.description)
					color: eventToolTip.palette.text
					font: eventToolTip.font
					wrapMode: Text.Wrap
					Layout.fillWidth: true
				}

				EventPropertyIcon {
					source: "view-calendar-day"
				}
				Text {
					text: {
						var event = events.get(eventItemIndex)
						var calendar = eventModel.getCalendar(event.calendarId)
						return calendar.summary
					}
					color: eventToolTip.palette.text
					font: eventToolTip.font
					wrapMode: Text.Wrap
					Layout.fillWidth: true
				}
			}
		}
	}


	//---
	RowLayout {
		id: contents
		anchors.left: parent.left
		anchors.right: parent.right
		spacing: 4

		Rectangle {
			implicitWidth: appletConfig.eventIndicatorWidth
			Layout.fillHeight: true
			color: model.backgroundColor || Kirigami.Theme.textColor
		}

		ColumnLayout {
			id: eventColumn
			Layout.fillWidth: true
			spacing: 0

			PlasmaComponents3.Label {
				id: eventSummary
				text: {
					if (isCondensed && model.location) {
						return model.summary + " | " + model.location
					} else {
						return model.summary
					}
				}
				color: eventItemInProgress ? inProgressColor : Kirigami.Theme.textColor
				font.pointSize: -1
				font.pixelSize: appletConfig.agendaFontSize
				font.weight: eventItemInProgress ? inProgressFontWeight : Font.Normal
				Layout.fillWidth: true

				// The Following doesn't seem to be applicable anymore (left comment just in case).
				// Wrapping causes reflow, which causes scroll to selection to miss the selected date
				// since it reflows after updateUI/scrollToDate is done.
				wrapMode: Text.Wrap
			}

			PlasmaComponents3.Label {
				id: eventDateTime
				text: {
					if (model.location) {
						return eventTimestamp + " | " + model.location
					} else {
						return eventTimestamp
					}
				}
				color: eventItemInProgress ? inProgressColor : Kirigami.Theme.textColor
				opacity: eventItemInProgress ? 1 : 0.75
				font.pointSize: -1
				font.pixelSize: appletConfig.agendaFontSize
				font.weight: eventItemInProgress ? inProgressFontWeight : Font.Normal
				visible: !isCondensed
			}

			Item {
				id: eventDescriptionSpacing
				visible: eventDescription.visible
				implicitHeight: 4
			}

			PlasmaComponents3.Label {
				id: eventDescription
				readonly property bool showProperty: Plasmoid.configuration.agendaShowEventDescription && text
				visible: showProperty
				text: Shared.renderText(model.description)
				color: Kirigami.Theme.textColor
				opacity: 0.75
				font.pointSize: -1
				font.pixelSize: appletConfig.agendaFontSize
				Layout.fillWidth: true
				wrapMode: Text.Wrap // See warning at eventSummary.wrapMode

				readonly property bool showInTooltip: !showProperty || truncated
				maximumLineCount: Plasmoid.configuration.agendaMaxDescriptionLines
				elide: Text.ElideRight

				linkColor: Kirigami.Theme.highlightColor
				onLinkActivated: function(link) { Qt.openUrlExternally(link) }
				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
					cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
				}
			}


		} // eventColumn
	}
	
	onLeftClicked: {
		if (model.htmlLink) {
			Qt.openUrlExternally(model.htmlLink)
		}
	}

	onLoadContextMenu: function(contextMenu) {
		var event = events.get(eventItemIndex)

		var menuItem = contextMenu.newMenuItem()
		menuItem.text = i18n("Open in browser")
		menuItem.icon = "internet-web-browser"
		menuItem.enabled = !!event.htmlLink
		menuItem.clicked.connect(function() {
			Qt.openUrlExternally(event.htmlLink)
		})
		contextMenu.addMenuItem(menuItem)
	}
}
