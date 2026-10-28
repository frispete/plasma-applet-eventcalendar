import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

import ".."
import "../lib"
import "../lib/Requests.js" as Requests

Dialog {
	id: chooseCityDialog
	title: i18n("Select city")

	parent: Overlay.overlay
	anchors.centerIn: parent
	width: Math.min(Kirigami.Units.gridUnit * 30, parent ? parent.width : Kirigami.Units.gridUnit * 30)
	height: Math.min(Kirigami.Units.gridUnit * 30, parent ? parent.height : Kirigami.Units.gridUnit * 30)
	modal: true
	standardButtons: Dialog.Ok | Dialog.Cancel
	property bool loadingCityList: false

	Logger {
		id: logger
		showDebug: Plasmoid.configuration.debugging
	}

	ListModel { id: cityListModel }

	property string selectedCityId: ''

	onOpened: cityNameInput.forceActiveFocus()

	Timer {
		id: debouceApplyFilter
		interval: 1000
		onTriggered: chooseCityDialog.applyCityListSearch()
	}

	ColumnLayout {
		anchors.fill: parent
		LinkText {
			text: i18n("Fetched from <a href=\"%1\">%1</a>", "https://openweathermap.org/find")
		}
		TextField {
			id: cityNameInput
			Layout.fillWidth: true
			text: ''
			placeholderText: i18n("Search")
			onTextChanged: debouceApplyFilter.restart()
		}
		ScrollView {
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.minimumHeight: Kirigami.Units.gridUnit * 10

			ListView {
				id: cityListView
				clip: true
				model: cityListModel
				currentIndex: -1

				delegate: ItemDelegate {
					id: cityDelegate
					width: ListView.view.width
					highlighted: ListView.isCurrentItem
					onClicked: {
						cityListView.currentIndex = index
						chooseCityDialog.selectedCityId = model.id
					}
					onDoubleClicked: chooseCityDialog.accept()

					contentItem: RowLayout {
						Label {
							Layout.fillWidth: true
							text: model.name
							elide: Text.ElideRight
						}
						Label {
							text: model.id
							opacity: 0.7
						}
						LinkText {
							text: '<a href="https://openweathermap.org/city/' + model.id + '">' + i18n("Open Link") + '</a>'
						}
					}
				}

				BusyIndicator {
					anchors.centerIn: parent
					running: visible
					visible: chooseCityDialog.loadingCityList
				}
			}
		}
	}

	function clearCityList() {
		cityListView.currentIndex = -1
		chooseCityDialog.selectedCityId = ''
		cityListModel.clear()
	}

	function parseCityList(data) {
		for (var i = 0; i < data.list.length; i++) {
			var item = data.list[i]
			var city = {
				id: item.id,
				name: item.name + ', ' + item.sys.country,
			}
			cityListModel.append(city)
		}
	}

	function applyCityListSearch() {
		searchCityList(cityNameInput.text)
	}

	function searchCityList(q) {
		logger.debug('searchCityList', q)
		clearCityList()
		if (q) {
			chooseCityDialog.loadingCityList = true
			fetchCityList({
				appId: Plasmoid.configuration.openWeatherMapAppId,
				q: q,
			}, function(err, data, xhr) {
				chooseCityDialog.loadingCityList = false
				if (err) return console.log('searchCityList.err', err, xhr && xhr.status, data)
				logger.debug('searchCityList.response')
				logger.debugJSON('searchCityList.response', data)

				parseCityList(data)

				chooseCityDialog.loadingCityList = false
			})
		}
	}

	function fetchCityList(args, callback) {
		if (!args.appId) return callback('OpenWeatherMap AppId not set')
		
		var url = 'https://api.openweathermap.org/data/2.5/'
		url += 'find?q=' + encodeURIComponent(args.q)
		url += '&type=like'
		url += '&sort=population'
		url += '&cnt=30'
		url += '&appid=' + args.appId
		Requests.getJSON(url, callback)
	}
}
