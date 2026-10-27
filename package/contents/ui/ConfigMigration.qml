import QtQuick
import org.kde.plasma.plasmoid

import "./calendars/PlasmaCalendarUtils.js" as PlasmaCalendarUtils

QtObject {
	signal migrate()

	function copy(oldKey, newKey) {
		if (typeof Plasmoid.configuration[oldKey] === 'undefined') return
		if (typeof Plasmoid.configuration[newKey] === 'undefined') return
		if (Plasmoid.configuration[oldKey] === Plasmoid.configuration[newKey]) return
		Plasmoid.configuration[newKey] = Plasmoid.configuration[oldKey]
		console.log('[eventcalendar:migrate] copy ' + oldKey + ' => ' + newKey + ' (value: ' + Plasmoid.configuration[oldKey] + ')')
	}

	Component.onCompleted: migrate()
	onMigrate: {
		// Modified in: v77 (Plasma 6 uses plugin ids instead of filenames)
		if (!Plasmoid.configuration.v77Migration) {
			var oldValue = Plasmoid.configuration.enabledCalendarPlugins
			var newValue = PlasmaCalendarUtils.toPluginIdList(oldValue)
			Plasmoid.configuration.enabledCalendarPlugins = newValue
			console.log('[eventcalendar:migrate] convert enabledCalendarPlugins (' + oldValue + ' => ' + newValue + ')')

			Plasmoid.configuration.v77Migration = true
		}

	}

}

