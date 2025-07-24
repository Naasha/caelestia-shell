pragma ComponentBehavior: Bound
import qs.config
import qs.services
import qs.utils
import qs.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Hyprland

StyledText {
    id: root
    text: Icons.osIcon
    font.pointSize: Appearance.font.size.smaller
    font.family: Appearance.font.family.mono
    color: mouseArea.containsPress ? Colours.palette.m3primary : Colours.palette.m3tertiary

    StateLayer {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        // onClicked: {
        //     console.log("[Bar] Overview toggle clicked");
        //     Hyprland.dispatch('global quickshell:overviewToggle');
        // }

        function onClicked(): void {
            console.log("[Bar] Overview toggle clicked");
            Hyprland.dispatch('global quickshell:overviewToggle');
        }

        // function onClicked(): void {
        // onClicked: {
        //     console.log("[Bar] Overview toggle clicked");
        //     Quickshell.execDetached(["sh", "-c", "kcmshell6 kcm_bluetooth"]);
        // }
    }
}
