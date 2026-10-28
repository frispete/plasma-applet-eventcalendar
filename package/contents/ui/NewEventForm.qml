import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Loader {
	id: newEventForm
	active: false
	visible: active

	sourceComponent: Component {
		RowLayout {
			spacing: 4

			Rectangle {
				Layout.preferredWidth: appletConfig.eventIndicatorWidth
				Layout.fillHeight: true
				color: calendarSelector.selectedCalendar && calendarSelector.selectedCalendar.backgroundColor || Kirigami.Theme.textColor
			}

			ColumnLayout {
				spacing: 10

				Component.onCompleted: {
					newEventText.forceActiveFocus()
					newEventFormOpened(model, calendarSelector)
				}
				CalendarSelector {
					id: calendarSelector
					Layout.fillWidth: true
				}

				RowLayout {
					PlasmaComponents3.TextField {
						id: newEventText
						Layout.fillWidth: true
						placeholderText: i18n("Eg: 9am-5pm Work")
						onAccepted: {
							var calendarEntry = calendarSelector.model[calendarSelector.currentIndex]
							// calendarId = calendarId.calendarId ? calendarId.calendarId : calendarId
							var calendarId = calendarEntry.calendarId
							if (calendarId && date && text) {
								submitNewEventForm(calendarId, date, text)
								text = ''
							}
						}
						Keys.onEscapePressed: newEventForm.active = false
					}
				}
			}

		}
	}
}
