import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Button {
	id: colorTextButton
	property int textPadding: Kirigami.Units.smallSpacing
	implicitWidth: textPadding + colorTextLabel.implicitWidth + textPadding
	implicitHeight: textPadding + colorTextLabel.implicitHeight + textPadding

	property alias label: colorTextLabel.text

	Label {
		id: colorTextLabel
		anchors.centerIn: parent
		color: colorTextButton.palette.buttonText
	}
}
