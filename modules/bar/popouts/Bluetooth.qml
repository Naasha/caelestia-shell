pragma ComponentBehavior: Bound

import qs.widgets
import qs.services
import qs.config
import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    spacing: Appearance.spacing.small / 2

    RowLayout {
        Layout.fillWidth: true
        Layout.bottomMargin: Appearance.spacing.small
        spacing: Appearance.spacing.small

        StyledText {
            Layout.fillWidth: true
            elide: Text.ElideRight
            text: qsTr("Bluetooth %1").arg(BluetoothAdapterState.toString(Bluetooth.defaultAdapter.state).toLowerCase())
        }

        Item {
            id: toggleBtn
            implicitWidth: implicitHeight
            implicitHeight: toggleIcon.implicitHeight + Appearance.padding.small * 2

            StyledRect {
                anchors.fill: parent
                implicitWidth: child.implicitWidth + Appearance.padding.normal * 2
                implicitHeight: child.implicitHeight + Appearance.padding.smaller * 2

                color: Bluetooth.defaultAdapter.enabled ? Colours.palette.m3primary : Colours.palette.m3surface
                radius: Appearance.rounding.normal

                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.anim.durations.short
                    }
                }
            }

            MaterialIcon {
                id: toggleIcon
                anchors.centerIn: parent
                text: Bluetooth.defaultAdapter.enabled ? "bluetooth" : "bluetooth_disabled"
                color: Bluetooth.defaultAdapter.enabled ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface

                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.anim.durations.short
                    }
                }
            }

            StateLayer {
                anchors.fill: parent
                radius: Appearance.rounding.full
                function onClicked(): void {
                    Quickshell.execDetached(["rfkill", "toggle", "bluetooth"]);
                }
            }
        }

        Item {
            id: settingsBtn
            implicitWidth: implicitHeight
            implicitHeight: settingsIcon.implicitHeight + Appearance.padding.small * 2

            MaterialIcon {
                id: settingsIcon
                color: Colours.palette.m3onSurface
                anchors.centerIn: parent
                text: "settings"
            }

            StateLayer {
                anchors.fill: parent
                radius: Appearance.rounding.full
                function onClicked(): void {
                    Quickshell.execDetached(["sh", "-c", "kcmshell6 kcm_bluetooth"]);
                }
            }
        }
    }

    StyledText {
        text: qsTr("%n connected device(s)", "", Bluetooth.devices.values.filter(d => d.connected).length)
    }

    Repeater {
        model: ScriptModel {
            values: [...Bluetooth.devices.values].sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired))
        }

        RowLayout {
            id: device

            required property var modelData
            readonly property bool loading: device.modelData.state === BluetoothDeviceState.Connecting || device.modelData.state === BluetoothDeviceState.Disconnecting

            Layout.fillWidth: true
            spacing: Appearance.spacing.small / 2

            opacity: 0
            scale: 0.7

            Component.onCompleted: {
                opacity = 1;
                scale = 1;
            }

            Behavior on opacity {
                Anim {}
            }

            Behavior on scale {
                Anim {}
            }

            MaterialIcon {
                Layout.rightMargin: Appearance.spacing.small
                text: Icons.getBluetoothIcon(device.modelData.icon)
            }

            StyledText {
                Layout.fillWidth: true
                text: device.modelData.name
            }

            Item {
                id: connectBtn

                implicitWidth: implicitHeight
                implicitHeight: connectIcon.implicitHeight + Appearance.padding.small * 2

                StyledBusyIndicator {
                    anchors.centerIn: parent

                    implicitWidth: implicitHeight
                    implicitHeight: connectIcon.implicitHeight

                    running: opacity > 0
                    opacity: device.loading ? 1 : 0

                    Behavior on opacity {
                        Anim {}
                    }
                }

                StateLayer {
                    radius: Appearance.rounding.full
                    disabled: device.loading

                    function onClicked(): void {
                        device.modelData.connected = !device.modelData.connected;
                    }
                }

                MaterialIcon {
                    id: connectIcon

                    anchors.centerIn: parent
                    animate: true
                    text: device.modelData.connected ? "link_off" : "link"

                    opacity: device.loading ? 0 : 1

                    Behavior on opacity {
                        Anim {}
                    }
                }
            }

            Loader {
                asynchronous: true
                active: device.modelData.paired
                sourceComponent: Item {
                    implicitWidth: connectBtn.implicitWidth
                    implicitHeight: connectBtn.implicitHeight

                    StateLayer {
                        radius: Appearance.rounding.full

                        function onClicked(): void {
                            device.modelData.forget();
                        }
                    }

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "delete"
                    }
                }
            }
        }
    }

    component Anim: NumberAnimation {
        duration: Appearance.anim.durations.normal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.anim.curves.standard
    }
}
