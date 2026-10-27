import QtQuick 2.0

import "./calendars/PlasmaCalendarUtils.js" as PlasmaCalendarUtils

QtObject {
	signal migrate()

	function copy(oldKey, newKey) {
		if (typeof plasmoid.configuration[oldKey] === 'undefined') return
		if (typeof plasmoid.configuration[newKey] === 'undefined') return
		if (plasmoid.configuration[oldKey] === plasmoid.configuration[newKey]) return
		plasmoid.configuration[newKey] = plasmoid.configuration[oldKey]
		console.log('[eventcalendar:migrate] copy ' + oldKey + ' => ' + newKey + ' (value: ' + plasmoid.configuration[oldKey] + ')')
	}

	Component.onCompleted: migrate()
	onMigrate: {
		// Modified in: v72
		if (!plasmoid.configuration.v72Migration) {
			var oldValue = plasmoid.configuration.enabledCalendarPlugins
			var newValue = PlasmaCalendarUtils.pluginPathToFilenameList(plasmoid.configuration.enabledCalendarPlugins)
			plasmoid.configuration.enabledCalendarPlugins = newValue
			console.log('[eventcalendar:migrate] convert enabledCalendarPlugins (' + oldValue + ' => ' + newValue + ')')

			plasmoid.configuration.v72Migration = true
		}

	}

}

