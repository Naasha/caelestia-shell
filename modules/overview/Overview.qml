import qs.services
import qs.modules
import qs.widgets
import qs.config
import qs.modules
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: overviewScope
    property bool dontAutoCancelSearch: false
    Variants {
        id: overviewVariants
        model: Quickshell.screens
        PanelWindow {
            id: root
            required property var modelData
            property string searchingText: ""
            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor.id)
            screen: modelData
            visible: ModulesStates.overviewOpen

            WlrLayershell.namespace: "quickshell:overview"
            WlrLayershell.layer: WlrLayer.Overlay
            // WlrLayershell.keyboardFocus: ModulesStates.overviewOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            color: "transparent"

            mask: Region {
                item: ModulesStates.overviewOpen ? columnLayout : null
            }
            // HyprlandWindow.visibleMask: Region { // Buggy with scaled monitors
            //     item: ModulesStates.overviewOpen ? columnLayout : null
            // }

            anchors {
                top: true
                bottom: true
            }

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                property bool canBeActive: root.monitorIsFocused
                active: false
                onCleared: () => {
                    if (!active)
                        ModulesStates.overviewOpen = false;
                }
            }

            // Connections {
            //     target: GlobalStates
            //     function onOverviewOpenChanged() {
            //         if (!ModulesStates.overviewOpen) {
            //             searchWidget.disableExpandAnimation();
            //             overviewScope.dontAutoCancelSearch = false;
            //         } else {
            //             if (!overviewScope.dontAutoCancelSearch) {
            //                 searchWidget.cancelSearch();
            //             }
            //             delayedGrabTimer.start();
            //         }
            //     }
            // }

            Timer {
                id: delayedGrabTimer
                interval: Config.hacks.arbitraryRaceConditionDelay
                repeat: false
                onTriggered: {
                    if (!grab.canBeActive)
                        return;
                    grab.active = ModulesStates.overviewOpen;
                }
            }

            implicitWidth: columnLayout.implicitWidth
            implicitHeight: columnLayout.implicitHeight

            // function setSearchingText(text) {
            //     searchWidget.setSearchingText(text);
            //     searchWidget.focusFirstItemIfNeeded();
            // }

            ColumnLayout {
                id: columnLayout
                visible: ModulesStates.overviewOpen
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        ModulesStates.overviewOpen = false;
                    } else if (event.key === Qt.Key_Left) {
                        if (!root.searchingText)
                            Hyprland.dispatch("workspace r-1");
                    } else if (event.key === Qt.Key_Right) {
                        if (!root.searchingText)
                            Hyprland.dispatch("workspace r+1");
                    }
                }

                Item {
                    height: 1 // Prevent Wayland protocol error
                    width: 1 // Prevent Wayland protocol error
                }

                // SearchWidget {
                //     id: searchWidget
                //     Layout.alignment: Qt.AlignHCenter
                //     onSearchingTextChanged: text => {
                //         root.searchingText = searchingText;
                //     }
                // }

                Loader {
                    id: overviewLoader
                    active: ModulesStates.overviewOpen
                    sourceComponent: OverviewWidget {
                        panelWindow: root
                        visible: (root.searchingText == "")
                    }
                }
            }
        }
    }

    // function toggleClipboard() {
    //     if (ModulesStates.overviewOpen && overviewScope.dontAutoCancelSearch) {
    //         ModulesStates.overviewOpen = false;
    //         return;
    //     }
    //     for (let i = 0; i < overviewVariants.instances.length; i++) {
    //         let panelWindow = overviewVariants.instances[i];
    //         if (panelWindow.modelData.name == Hyprland.focusedMonitor.name) {
    //             overviewScope.dontAutoCancelSearch = true;
    //             panelWindow.setSearchingText(Config.options.search.prefix.clipboard);
    //             ModulesStates.overviewOpen = true;
    //             return;
    //         }
    //     }
    // }

    // function toggleEmojis() {
    //     if (ModulesStates.overviewOpen && overviewScope.dontAutoCancelSearch) {
    //         ModulesStates.overviewOpen = false;
    //         return;
    //     }
    //     for (let i = 0; i < overviewVariants.instances.length; i++) {
    //         let panelWindow = overviewVariants.instances[i];
    //         if (panelWindow.modelData.name == Hyprland.focusedMonitor.name) {
    //             overviewScope.dontAutoCancelSearch = true;
    //             panelWindow.setSearchingText(Config.options.search.prefix.emojis);
    //             ModulesStates.overviewOpen = true;
    //             return;
    //         }
    //     }
    // }

    IpcHandler {
        target: "overview"

        function toggle() {
            ModulesStates.overviewOpen = !ModulesStates.overviewOpen;
        }
        function close() {
            ModulesStates.overviewOpen = false;
        }
        function open() {
            ModulesStates.overviewOpen = true;
        }
        function toggleReleaseInterrupt() {
            GlobalStates.superReleaseMightTrigger = false;
        }
        function clipboardToggle() {
            overviewScope.toggleClipboard();
        }
    }

    GlobalShortcut {
        name: "overviewToggle"
        description: "Toggles overview on press"

        onPressed: {
            ModulesStates.overviewOpen = !ModulesStates.overviewOpen;
        }
    }
    GlobalShortcut {
        name: "overviewClose"
        description: "Closes overview"

        onPressed: {
            ModulesStates.overviewOpen = false;
        }
    }
    GlobalShortcut {
        name: "overviewToggleRelease"
        description: "Toggles overview on release"

        onPressed: {
            GlobalStates.superReleaseMightTrigger = true;
        }

        onReleased: {
            if (!GlobalStates.superReleaseMightTrigger) {
                GlobalStates.superReleaseMightTrigger = true;
                return;
            }
            ModulesStates.overviewOpen = !ModulesStates.overviewOpen;
        }
    }
    GlobalShortcut {
        name: "overviewToggleReleaseInterrupt"
        description: "Interrupts possibility of overview being toggled on release. " + "This is necessary because GlobalShortcut.onReleased in quickshell triggers whether or not you press something else while holding the key. " + "To make sure this works consistently, use binditn = MODKEYS, catchall in an automatically triggered submap that includes everything."

        onPressed: {
            GlobalStates.superReleaseMightTrigger = false;
        }
    }
    GlobalShortcut {
        name: "overviewClipboardToggle"
        description: "Toggle clipboard query on overview widget"

        onPressed: {
            overviewScope.toggleClipboard();
        }
    }

    GlobalShortcut {
        name: "overviewEmojiToggle"
        description: "Toggle emoji query on overview widget"

        onPressed: {
            overviewScope.toggleEmojis();
        }
    }
}
