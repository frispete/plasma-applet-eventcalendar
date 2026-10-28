// Version 7

import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import "../Shared.js" as Shared

RowLayout {
	id: configSound
	property alias label: sfxEnabledCheckBox.text
	property alias sfxEnabledKey: sfxEnabledCheckBox.configKey
	property alias sfxPathKey: sfxPath.configKey

	property alias sfxEnabled: sfxEnabledCheckBox.checked
	property alias sfxPathValue: sfxPath.value
	property alias sfxPathDefaultValue: sfxPath.defaultValue

	// Preview with the same script (libcanberra) that plays the notification sounds.
	// Importing QtMultimedia used to segfault plasmashell, see
	// https://github.com/Zren/plasma-applet-eventcalendar/issues/84
	property bool sfxPlaying: false

	ExecUtil {
		id: executable
	}

	function playSfx() {
		var cmd = [
			'python3',
			Shared.urlToPath(Qt.resolvedUrl("../../scripts/notification.py")),
			'--sound-only',
			'--sound', sfxPath.value,
		]
		sfxPlaying = true
		executable.exec(cmd, function(cmd, exitCode, exitStatus, stdout, stderr) {
			sfxPlaying = false
			if (stderr) {
				console.log('[eventcalendar] ConfigSound.playSfx', stderr)
			}
		})
	}

	spacing: 0
	ConfigCheckBox {
		id: sfxEnabledCheckBox
	}
	Button {
		icon.name: "media-playback-start-symbolic"
		enabled: sfxEnabled && !!sfxPath.value && !sfxPlaying
		onClicked: configSound.playSfx()
	}
	ConfigString {
		id: sfxPath
		enabled: sfxEnabled
		Layout.fillWidth: true
	}
	Button {
		icon.name: "folder-symbolic"
		enabled: sfxEnabled
		onClicked: sfxPathDialog.open()

		FileDialog {
			id: sfxPathDialog
			title: i18n("Choose a sound effect")
			currentFolder: 'file:///usr/share/sounds'
			nameFilters: [
				i18n("Sound files (%1)", "*.wav *.mp3 *.oga *.ogg"),
				i18n("All files (%1)", "*"),
			]
			onAccepted: {
				sfxPathValue = decodeURIComponent(('' + selectedFile).replace(/^file:\/\//, ''))
			}
		}
	}
}
