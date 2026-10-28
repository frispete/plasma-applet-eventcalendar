// Version 1

import QtQuick
import org.kde.plasma.plasmoid

// The Config* controls write Plasmoid.configuration directly, so changes are
// previewed live. This remembers the values from when the page was opened, so the
// settings dialog can enable Apply (unsavedChanges) and Cancel/Discard can undo them.
//
// Usage in a settings page:
//   property alias unsavedChanges: configTransaction.unsavedChanges
//   function saveConfig() { configTransaction.save() }
//   ConfigTransaction { id: configTransaction; window: page.Window.window }
QtObject {
	id: configTransaction

	property var window: null
	property bool unsavedChanges: false

	property var savedValues: ({}) // key => value when opened or last applied
	property bool reverting: false

	function copyValue(value) {
		// StringList values are array-like, copy them so later changes don't leak in.
		if (value !== null && typeof value === 'object' && typeof value.length === 'number') {
			return Array.prototype.slice.call(value)
		}
		return value
	}

	function compareKey(value) {
		if (value !== null && typeof value === 'object' && typeof value.length === 'number') {
			return JSON.stringify(Array.prototype.slice.call(value))
		}
		return '' + value
	}

	function save() {
		var values = {}
		var keys = Plasmoid.configuration.keys()
		for (var i = 0; i < keys.length; i++) {
			values[keys[i]] = copyValue(Plasmoid.configuration[keys[i]])
		}
		savedValues = values
		unsavedChanges = false
	}

	// Keys the widget writes itself (migrations, pin, last used calendar) become the
	// new saved value instead of an unsaved change.
	function isInternalKey(key) {
		return /^v\d+Migration$/.test(key) || key === 'pin' || key === 'agendaNewEventLastCalendarId'
	}

	function onConfigValueChanged(key, value) {
		if (reverting) {
			return
		}
		if (isInternalKey(key)) {
			savedValues[key] = copyValue(value)
		}
		Qt.callLater(update)
	}

	function changedKeys() {
		return Object.keys(savedValues).filter(function(key) {
			return compareKey(Plasmoid.configuration[key]) !== compareKey(savedValues[key])
		})
	}

	function update() {
		if (!reverting) {
			unsavedChanges = changedKeys().length > 0
		}
	}

	function revert() {
		var keys = changedKeys()
		reverting = true
		for (var i = 0; i < keys.length; i++) {
			Plasmoid.configuration[keys[i]] = copyValue(savedValues[keys[i]])
		}
		reverting = false
		unsavedChanges = false
		if (keys.length > 0) {
			Plasmoid.configuration.writeConfig()
		}
	}

	property Connections configConnection: Connections {
		target: Plasmoid.configuration
		function onValueChanged(key, value) {
			configTransaction.onConfigValueChanged(key, value)
		}
	}

	// The dialog closes on Cancel/Discard without telling the page.
	property Connections windowConnection: Connections {
		target: configTransaction.window
		function onVisibleChanged() {
			if (!configTransaction.window.visible && configTransaction.unsavedChanges) {
				configTransaction.revert()
			}
		}
	}

	Component.onCompleted: save()

	// Switching to another page with "Discard" replaces (destroys) this page.
	Component.onDestruction: {
		if (unsavedChanges) {
			revert()
		}
	}
}
