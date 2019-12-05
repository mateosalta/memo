/*
  This file is part of quick-memo
  Copyright (C) 2014, 2015 Stefano Verzegnassi

    This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License 3 as published by
  the Free Software Foundation.

    This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
  along with this program. If not, see http://www.gnu.org/licenses/.
*/

import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3

import "../common"
import "../mainPage"
import "../ubuntucomponents"

PageWithBottomEdge {
    id: mainPage
    title: i18n.tr("Memo")
    flickable: mainPage.state === "multiSelection" ? null
                                                   : useGridView ? null
                                                                 : (notes.model.count == 0) ? null
                                                                                            : viewLoader.item

    // Used for switching from HorizontalFlowListView to ListView, and vice versa.
    Loader {
        id: viewLoader
        anchors.fill: parent

        sourceComponent: (notes.model.count == 0) ? emptyModelItem
                                                  : useGridView ? horizontalFlowListView
                                                                : listView
    }

    Component {
        id: emptyModelItem

        Item {
            anchors.fill: parent

            EmptyState {
                anchors.centerIn: parent
                iconName: "note"
                title: i18n.tr("No stored memos")
                subTitle: i18n.tr("Swipe the bottom edge to add a new memo.")
            }
        }
    }

    /* A sort of GridView that scrolls horizontally, wrapping delegates to create rows or columns of items.
       Items are positioned next to each other from top to bottom
       until the height of the Flow is exceeded, then wrapped to the next column.
       http://qt-project.org/doc/qt-5/qml-qtquick-flow.html */
    Component {
        id: horizontalFlowListView

        HorizontalFlowListView {
            id: memoView
            anchors { fill: parent; topMargin: units.gu(2) }
            clip: false

            spacing: units.gu(1)

            model: notes.model
            delegate: Delegate {
                id: viewDelegate
                width: (memoView.width * 0.5) - (memoView.spacing * 3)

                onClicked: {
                    if (mainPage.state === "multiSelection") {
                        selected = multiSelection.selectUnselectItem(model.index)
                    } else {
                        /* Workaround: clear the pageStack before pushing memoPage.
                            We do this because when we remove an item from memoPage, the whole
                            application freezes. We take also another advantage: less memory usage
                            (no delagates images to keep loaded). */
                        /* UPDATE: That was true with the earlier code. After switching to SortFilterModel,
                           the issue does not live anymore. We save anyway memory, and that's good. */
                        pageStack.clear()
                        pageStack.push(Qt.resolvedUrl("./EditMemoPage.qml"), {editMemo: true, index: model.index})
                    }
                }

                onPressAndHold: {
                    if (mainPage.state !== "multiSelection") {
                        mainPage.state = "multiSelection"
                        selected = multiSelection.selectUnselectItem(model.index)
                    }
                }
                Connections {
                    target: mainPage
                    onStateChanged: if (mainPage.state !== "multiSelection") viewDelegate.selected = false
                }
            }
        }
    }

    // The classic and boring ListView...
    Component {
        id: listView

        ListView {
            id: memoView
            anchors {
                fill: parent
                margins: units.gu(2)
                // Fix wrong topMargin when switching to multiSelection state.
                topMargin: (mainPage.state === "multiSelection") ? (units.gu(2) - mainPage.header.height)
                                                                 : units.gu(2)
            }
            clip: false

            spacing: units.gu(1)

            // Indipendent GU flickable speed workaround
            flickDeceleration: 1500 * units.gridUnit / 8
            maximumFlickVelocity: 2500 * units.gridUnit / 8

            model: notes.model
            delegate: ListViewDelegate {
                id: viewDelegate
                width: memoView.width

                onClicked: {
                    if (mainPage.state === "multiSelection") {
                        selected = multiSelection.selectUnselectItem(model.index)
                    } else {
                        /* Workaround: clear the pageStack before pushing memoPage.
                            We do this because when we remove an item from memoPage, the whole
                            application freezes. We take also another advantage: less memory usage
                            (no delagates images to keep loaded). */
                        /* UPDATE: That was true with the earlier code. After switching to SortFilterModel,
                           the issue does not live anymore. We save anyway memory, and that's good. */
                        pageStack.clear()
                        pageStack.push(Qt.resolvedUrl("./EditMemoPage.qml"), {editMemo: true, index: model.index})
                    }
                }

                onPressAndHold: {
                    if (mainPage.state !== "multiSelection") {
                        mainPage.state = "multiSelection"
                        selected = multiSelection.selectUnselectItem(model.index)
                    }
                }
                Connections {
                    target: mainPage
                    onStateChanged: if (mainPage.state !== "multiSelection") viewDelegate.selected = false
                }

                /* According to Qt-Project docs, "delegates are instantiated as needed and may be destroyed at any time".
                   We need to restore 'selected' property when this happens. (this issue does not affect FlowListView,
                   since Repeater does not destroy delegates). */
                Component.onCompleted: {
                    if (mainPage.state === "multiSelection") {
                        for (var i=0; i<multiSelection.indexes.length; i++) {
                            if (multiSelection.indexes[i] === index) {
                                selected = true
                            }
                        }
                    }
                }
            }
        }
    }

    state: "default"
    states: [
        PageHeadState {
            name: "default"
            head: mainPage.head
            actions: [openAbout, switchView]
        },

        // Used to manage multi-selection in ListViews
        MultiSelectionHandler {
            id: multiSelection

            name: "multiSelection"
            targetPage: mainPage

            actions: [changeNoteColor, deleteMemo]
        }
    ]

    // DEFAULT PAGEHEAD ACTIONS
    Action {
        id: openAbout
        text: i18n.tr("About...")
        iconName: "help"
        onTriggered: pageStack.push(Qt.resolvedUrl("./AboutPage.qml"))
    }

    Action {
        id: switchView
        text: useGridView ? i18n.tr("Switch to one-column list") : i18n.tr("Switch to grid")
        iconName: useGridView ? "view-list-symbolic" : "view-grid-symbolic"
        onTriggered: useGridView = !useGridView
    }

    // MULTISELECTIONHANDLER ACTIONS
    Action {
        id: changeNoteColor
        text: i18n.tr("Change memo color")
        iconSource: "../../graphics/palette.svg"
        onTriggered: PopupUtils.open(colorNotePopover)
    }

    Action {
        id: deleteMemo
        text: i18n.tr("Delete memo")
        iconName: "delete"
        onTriggered: {
            PopupUtils.open(deleteDialog)
        }
    }

    Component {
        id: colorNotePopover

        ColorDialog {
            id: colorDialog
            showTick: false
            // A color not listed in 'colors' property, just to avoid that oldColor and selectedColor result the same.
            // TODO: If there's just a single element selected, we can import the right color of the memo.
            selectedColor: "#ababab"

            onColorPicked: {
                if (isChanged) {
                    for (var i=0; i<multiSelection.indexes.length; i++) {
                        notes.setNoteProperty(multiSelection.indexes[i], "color", selectedColor)
                    }
                } else {
                    console.log("Color not changed")
                }

                PopupUtils.close(colorDialog)

                root.showNotification(i18n.tr("Memo updated!", "Memos updated!", multiSelection.indexes.length))

                mainPage.state = "default"
            }
        }
    }

    Component {
        id: deleteDialog
        Dialog {
            id: deleteDialogue
            title: i18n.tr("Delete memo", "Delete memos", multiSelection.indexes.length)
            text: i18n.tr("Are you sure?")
   Button {
                text: i18n.tr("Delete")
                color: theme.palette.normal.negative
                onClicked: {
                    notes.deleteNotes(multiSelection.indexes)
                    mainPage.state = "default"
                    PopupUtils.close(deleteDialogue)

                    root.showNotification(i18n.tr("Memo deleted!", "Memos deleted!", multiSelection.indexes.length))
                }
            }
            Button {
                text: i18n.tr("Cancel")
               // gradient: UbuntuColors.greyGradient
                onClicked: PopupUtils.close(deleteDialogue)
            }
         
        }
    }

    //bottomEdgeTitle: i18n.tr("New memo")
    bottomEdgeIconName: "note-new"
    bottomEdgeColor: "#95c253"
    bottomEdgePageComponent: EditMemoPage {}
    // Disable bottomEdge when MultiSelectionHandler is active
    bottomEdgeEnabled: mainPage.state !== "multiSelection"

    onVisibleChanged: {
        if (visible) {
            // Restore default color
            root.headerBackgroundColor = root.defaulteaderBackgroundColor
        }
    }
}
