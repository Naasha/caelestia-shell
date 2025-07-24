import qs.services
import qs.widgets
import qs.utils
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Item { // Window
    id: root
    property var toplevel
    property var windowData
    property var monitorData
    property var scale
    property var availableWorkspaceWidth
    property var availableWorkspaceHeight
    property bool restrictToWorkspace: true
    property real initX: Math.max((windowData?.at[0] - (monitorData?.x ?? 0) - monitorData?.reserved[0]) * root.scale, 0) + xOffset
    property real initY: Math.max((windowData?.at[1] - (monitorData?.y ?? 0) - monitorData?.reserved[1]) * root.scale, 0) + yOffset
    property real xOffset: 0
    property real yOffset: 0

    property var targetWindowWidth: windowData?.size[0] * scale
    property var targetWindowHeight: windowData?.size[1] * scale
    property bool hovered: false
    property bool pressed: false

    property var iconToWindowRatio: 0.35
    property var xwaylandIndicatorToIconRatio: 0.35
    property var iconToWindowRatioCompact: 0.6
    property var iconPath: Quickshell.iconPath(AppSearch.guessIcon(windowData?.class), "image-missing")

    // TODO-nasha: Appearance.font.pixelSize.smaller = 12
    property bool compactMode: 12 * 4 > targetWindowHeight || 12 * 4 > targetWindowWidth

    property bool indicateXWayland: windowData?.xwayland ?? false

    x: initX
    y: initY
    width: windowData?.size[0] * root.scale
    height: windowData?.size[1] * root.scale

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            // TODO-nasha: Appearance.rounding.windowRounding = 18
            radius: 18 * root.scale
        }
    }

    // TODO-nasha : trouver une "alternative" pour faire fonctionner cette animation
    // Behavior on x {
    //     animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    // }
    // Behavior on y {
    //     animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    // }
    // Behavior on width {
    //     animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    // }
    // Behavior on height {
    //     animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    // }

    ScreencopyView {
        id: windowPreview
        anchors.fill: parent
        captureSource: ModulesStates.overviewOpen ? root.toplevel : null
        live: true

        Rectangle {
            anchors.fill: parent
            // TODO-nasha : Appearance.rounding.windowRounding = 18
            radius: 18 * root.scale
            // TODO-nasha : Appearance.colors.colLayer2Active = "red"
            // TODO-nasha : Appearance.m3colors.m3outline = "pink"
            // TODO-nasha : Appearance.colors.colLayer2Hover = "green"
            // TODO-nasha : Appearance.colors.colLayer2 = "yellow"
            color: pressed ? ColourUtils.transparentize("red", 0.5) : hovered ? ColourUtils.transparentize("green", 0.7) : ColourUtils.transparentize("yellow")
            border.color: ColourUtils.transparentize("pink", 0.7)
            border.width: 1
        }

        ColumnLayout {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            // TODO-nasha : Appearance.font.pixelSize.smaller = 12
            spacing: 12 * 0.5

            Image {
                id: windowIcon
                property var iconSize: {
                    // console.log("-=-=-", root.toplevel.title, "-=-=-")
                    // console.log("Target window size:", targetWindowWidth, targetWindowHeight)
                    // console.log("Icon ratio:", root.compactMode ? root.iconToWindowRatioCompact : root.iconToWindowRatio)
                    // console.log("Scale:", root.monitorData.scale)
                    // console.log("Final:", Math.min(targetWindowWidth, targetWindowHeight) * (root.compactMode ? root.iconToWindowRatioCompact : root.iconToWindowRatio) / root.monitorData.scale)
                    return Math.min(targetWindowWidth, targetWindowHeight) * (root.compactMode ? root.iconToWindowRatioCompact : root.iconToWindowRatio) / root.monitorData.scale;
                }
                // mipmap: true
                Layout.alignment: Qt.AlignHCenter
                source: root.iconPath
                width: iconSize
                height: iconSize
                sourceSize: Qt.size(iconSize, iconSize)

                // TODO-nasha : trouver une "alternative" pour faire fonctionner cette animation
                // Behavior on width {
                //     animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
                // }
                // Behavior on height {
                //     animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
                // }
            }
        }
    }
}
