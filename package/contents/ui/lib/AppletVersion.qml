import QtQuick
import QtQuick.Controls
import org.kde.plasma.plasmoid

Label {
	text: i18n("<b>Version:</b> %1", Plasmoid.metaData.version)
}
