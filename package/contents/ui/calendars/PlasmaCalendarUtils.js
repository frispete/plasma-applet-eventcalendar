.pragma library

// Plasma 6 identifies calendar plugins by their plugin id (eg: "holidaysevents").
// Older versions of this widget stored the full path (before v72) or the
// filename (eg: "holidaysevents.so") in enabledCalendarPlugins.
function toPluginId(entry) {
	var pluginId = entry.substr(entry.lastIndexOf('/') + 1)
	return pluginId.replace(/\.so$/, '')
}

function toPluginIdList(entryList) {
	var pluginIdList = []
	for (var i = 0; i < entryList.length; i++) {
		var pluginId = toPluginId(entryList[i])
		if (pluginIdList.indexOf(pluginId) == -1) {
			pluginIdList.push(pluginId)
		}
	}
	return pluginIdList
}
