// Version 6

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
	id: page
	default property alias _contentChildren: content.data

	ColumnLayout {
		id: content
		width: page.availableWidth
	}

	// Lets the settings dialog enable Apply and undo changes on Cancel/Discard.
	// Older dialogs (and plasmoidviewer) only know the configurationChanged signal.
	property alias unsavedChanges: configTransaction.unsavedChanges
	signal configurationChanged()
	function saveConfig() {
		configTransaction.save()
	}
	property ConfigTransaction configTransaction: ConfigTransaction {
		id: configTransaction
		window: page.Window.window
		onUnsavedChangesChanged: {
			if (unsavedChanges) {
				page.configurationChanged()
			}
		}
	}

	property alias showAppletVersion: appletVersionLoader.active
	actions: []
	footer: Loader {
		id: appletVersionLoader
		active: false
		visible: active
		source: "AppletVersion.qml"
	}
}
