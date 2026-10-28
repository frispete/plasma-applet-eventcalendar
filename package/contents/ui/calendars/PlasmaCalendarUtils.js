.pragma library

// Plasma 6 identifies calendar plugins by their plugin id (eg: "holidaysevents").
// Older versions of this widget stored the full path (before v72) or the
// filename (eg: "holidaysevents.so") in enabledCalendarPlugins.
function toPluginId(entry) {
	var pluginId = entry.substr(entry.lastIndexOf('/') + 1)
	return pluginId.replace(/\.so$/, '')
}

// Some broken ports treated the stored value as a string and saved its single
// characters as list entries, so a string is split and one-letter entries,
// which are never a valid plugin id, are dropped.
function toPluginIdList(entryList) {
	if (typeof entryList === 'string') {
		entryList = entryList.split(',')
	}
	var pluginIdList = []
	for (var i = 0; i < entryList.length; i++) {
		var pluginId = toPluginId(String(entryList[i]).trim())
		if (pluginId.length > 1 && pluginIdList.indexOf(pluginId) == -1) {
			pluginIdList.push(pluginId)
		}
	}
	return pluginIdList
}
