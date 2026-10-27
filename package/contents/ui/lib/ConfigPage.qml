// Version 5

import QtQuick
import QtQuick.Layouts
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
	id: page
	default property alias _contentChildren: content.data

	ColumnLayout {
		id: content
		width: page.availableWidth
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
