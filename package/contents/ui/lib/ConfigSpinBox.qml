// Version 4

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid

// QQC2's SpinBox only handles integers, so values with decimals are
// scaled by 10^decimals internally.
RowLayout {
	id: configSpinBox

	property string configKey: ''
	readonly property var configValue: configKey ? Plasmoid.configuration[configKey] : 0
	property int decimals: 0
	property int horizontalAlignment: Qt.AlignLeft
	property real maximumValue: 2147483647
	property real minimumValue: 0
	property string prefix: ''
	property real stepSize: 1
	property string suffix: ''
	property real value: configValue

	property alias before: labelBefore.text
	property alias after: labelAfter.text

	readonly property real factor: Math.pow(10, decimals)

	Label {
		id: labelBefore
		text: ""
		visible: text
	}

	SpinBox {
		id: spinBox
		editable: true
		from: Math.max(-2147483648, Math.round(configSpinBox.minimumValue * configSpinBox.factor))
		to: Math.min(2147483647, Math.round(configSpinBox.maximumValue * configSpinBox.factor))
		stepSize: Math.max(1, Math.round(configSpinBox.stepSize * configSpinBox.factor))
		value: Math.round(configSpinBox.value * configSpinBox.factor)

		validator: RegularExpressionValidator { regularExpression: /.*/ }
		textFromValue: function(value, locale) {
			var text = Number(value / configSpinBox.factor).toLocaleString(locale, 'f', configSpinBox.decimals)
			return configSpinBox.prefix + text + configSpinBox.suffix
		}
		valueFromText: function(text, locale) {
			text = text.replace(configSpinBox.prefix, '').replace(configSpinBox.suffix, '').trim()
			var value = Number.fromLocaleString(locale, text)
			if (isNaN(value)) {
				return spinBox.value
			}
			return Math.round(value * configSpinBox.factor)
		}

		onValueModified: {
			configSpinBox.value = value / configSpinBox.factor
			serializeTimer.restart()
		}
	}

	Label {
		id: labelAfter
		text: ""
		visible: text
	}

	Timer { // throttle
		id: serializeTimer
		interval: 300
		onTriggered: {
			if (configKey) {
				Plasmoid.configuration[configKey] = configSpinBox.value
			}
		}
	}
}
