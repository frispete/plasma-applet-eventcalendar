import QtQuick

import "./lib"

// Backend agnostic online detection: we're "connected" when the kernel has a
// default route (IPv4 or IPv6). Works with NetworkManager, wicked,
// systemd-networkd or a static setup, as it only asks the kernel.
Item {
	id: networkMonitor

	property bool isConnected: true // Assume we're online until checked
	property int checkInterval: 30 * 1000

	ExecUtil { id: executable }

	readonly property var checkCommand: 'ip route show default; ip -6 route show default'

	function check() {
		executable.exec(checkCommand, function(cmd, exitCode, exitStatus, stdout, stderr) {
			if (exitCode == 127) {
				// 'ip' (iproute2) is not installed, so we can't tell.
				logger.log('NetworkMonitor: ip command not found, assuming we are online')
				checkTimer.stop()
				networkMonitor.isConnected = true
				return
			}
			networkMonitor.isConnected = stdout.trim().length > 0
		})
	}

	Timer {
		id: checkTimer
		running: true
		repeat: true
		triggeredOnStart: true
		interval: networkMonitor.checkInterval
		onTriggered: networkMonitor.check()
	}

	onIsConnectedChanged: logger.debug('NetworkMonitor.isConnected', isConnected)
}
