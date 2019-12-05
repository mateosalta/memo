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
import Ubuntu.Keyboard 0.1
import Ubuntu.Components.ListItems 1.3 as ListItem

import "../common"

Column {
    id: rootItem

    width: parent.width
    spacing: units.gu(0.25)

    property Flickable flickable
    property alias model: repeater.model
    property alias delegate: repeater.delegate
    property alias footer: footerLoader.sourceComponent
    readonly property bool focusOnLastItem: (model.focusedIndex === -1) || (model.focusedIndex === (model.count - 1))

    signal listChanged()

    ListItem.Header {
        text: i18n.tr("List:")
    }

    Repeater {
        id: repeater
        width: parent.width

        model: ListModel {
            id: dataModel

            property int focusedIndex: -1
        }

        delegate: delegate
    }

    // TODO: When user adds an element in the list, the new element should gain focus.
    Loader {
        id: footerLoader
        width: parent.width

        sourceComponent: ListItem.Empty {
            width: parent.width
            opacity: enabled ? 1.0 : 0.5
            showDivider: false

            enabled: {
                if (rootItem.model.count > 0) {
                    if (rootItem.model.get(rootItem.model.count - 1).text !== "") {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return true
                }
            }

            Row {
                spacing: units.gu(2)
                anchors {
                    left: parent.left; leftMargin: units.gu(2);
                    right: parent.right;
                    verticalCenter: parent.verticalCenter
                }

                Item {
                    id: addListBtnImage
                    implicitWidth: units.gu(4.25)
                    implicitHeight: units.gu(4)

                    Icon {
                        anchors { fill: parent; margins: units.gu(0.5) }
                        name: "add"
                    }
                }

                Label {
                    id: addListBtnLabel
                    // TRANSLATORS: Text of a button used for add an item in the To-do list.
                    text: i18n.tr("Add item")
                    anchors.verticalCenter: addListBtnImage.verticalCenter
                }
            }

            onClicked: {
                rootItem.addItem({"checked": false, "text": ""})
                // Here we don't send listChanged signal, since it is an empty item that should not be saved
            }
        }
    }


    function exportModel() {
        var list = []

        if (rootItem.model.count > 0 && rootItem.model.get(0).text !== "") {
            for (var i=0; i<rootItem.model.count; i++) {
                if (i != rootItem.model.count && rootItem.model.get(i).text != "") {
                    list[i] = rootItem.model.get(i)
                }
            }
        }

        return list
    }

    function addItem(args) {
        rootItem.model.append(args)
        var newItem = repeater.itemAt(repeater.count - 1)
        newItem.textArea.forceActiveFocus()
        autoScrollAnimation.makeMeVisible(newItem)
    }

    SequentialAnimation {
        id: autoScrollAnimation

        property var targetItem: null
        alwaysRunToEnd: true

        // wait item be moved to correct place
        PauseAnimation {
            duration: 100
        }
        // scroll to new item position
        ScriptAction {
            script: {
                if (autoScrollAnimation.targetItem) {
                    autoScrollAnimation.makeMeVisibleImpl(autoScrollAnimation.targetItem)
                    autoScrollAnimation.targetItem = null
                }
            }
        }

        function makeMeVisible(newItem) {
            autoScrollAnimation.targetItem = newItem
            autoScrollAnimation.restart()
        }

        function makeMeVisibleImpl(newItem) {
            if (!newItem) {
                return
            }

            var positionY = rootItem.y + repeater.y + newItem.y

            // check if the item is already visible
            var bottomY = flickable.contentY + flickable.height
            var itemBottom = positionY + (newItem.height *3) // margin
            if (positionY >= flickable.contentY && itemBottom <= bottomY) {
                return;
            }

            // if it is not, try to scroll and make it visible
            var targetY = itemBottom - flickable.height
            if (targetY >= 0 && positionY) {
                flickable.contentY = targetY
            } else if (positionY < flickable.contentY) {
                // if it is hidden at the top, also show it
                flickable.contentY = positionY
            }
            flickable.returnToBounds()
        }
    }


    // *** DELEGATE ***
    Component {
        id: delegate

        ListItem.Empty {
            id: item
            width: parent ? parent.width : undefined
            height: (layoutDelegate.height > item.__height) ? layoutDelegate.height : item.__height

            showDivider: false

            property alias textArea: textArea

            Rectangle {
                anchors.fill: parent
                opacity: 0.1
                visible: textArea.activeFocus
                color: "black"
            }

            backgroundIndicator: Rectangle {
                anchors.fill: parent
                color: "red"

                Icon {
                    anchors.centerIn: parent
                    name: "delete"
                    color: Theme.palette.selected.field
                    height: units.gu(3)
                    width: units.gu(3)
                }
            }

            // ListItem is removable for all items, except the first when the text field is empty.
            //confirmRemoval: true
            removable: rootItem.model.count > 1 || (rootItem.model.get(0).text !== "")
            confirmRemoval: true
            onItemRemoved: {
                // Send the signal before removing the item. This avoids a ReferenceError.
                rootItem.listChanged()
                rootItem.model.remove(model.index)
            }

            Row {
                id: layoutDelegate

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }

                spacing: units.gu(1)
                height: Math.max(checkBox.height, textArea.height)

                CheckBox {
                    id: checkBox

                    checked: model.checked
                    onCheckedChanged: layoutDelegate.updateModel()
                    
                     style: Item {
                        implicitWidth: units.gu(4.25)
                        implicitHeight: units.gu(4)

                        Icon {
                            anchors { fill: parent; margins: units.gu(0.5) }
                                                color: theme.palette.normal.foregroundText
                            source: checkBox.checked ? "../../graphics/select.svg" : "../../graphics/unselect.svg"
                        }
                    }


                  
                }

                NoteTextField {
                    id: textArea

                    width: parent.width - (checkBox.width + (parent.spacing * 2))
                    anchors.verticalCenter: parent.verticalCenter

                    font.strikeout: checkBox.checked

                    onFocusReceived: {
                       rootItem.model.focusedIndex = model.index
                    }

                    text: model.text
                    onTextChanged: {
                        layoutDelegate.updateModel()

                        /* This requires some test. No problem when TextField is used, but it seems to break dataModel when
                            TextArea is used. Could be related to NoteTextArea.qml, line 39.*/
                        if (text === "") {
                            rootItem.model.remove(model.index)
                        }
                    }

                    //hasClearButton: false
                    focus: true

                    // Ubuntu Keyboard
                    // TODO: Disable Enter key if model.text is empty.
                    InputMethod.extensions: {
                        "enterKeyText": rootItem.focusOnLastItem ? i18n.tr("Add") : i18n.tr("Next")
                    }

                    Keys.onReturnPressed: {
                        if (rootItem.focusOnLastItem && (model.text !== "")) {
                            // Create a new item.
                            rootItem.addItem({"checked": false, "text": ""})
                        } else if (!rootItem.focusOnLastItem) {
                            var nextItem = repeater.itemAt(model.index + 1)
                            if (nextItem) {
                                nextItem.textArea.forceActiveFocus()
                                autoScrollAnimation.makeMeVisible(nextItem)
                            }
                        }
                    }
                }

                function updateModel() {
                    rootItem.model.set(model.index, {"checked": checkBox.checked, "text": textArea.text})
                    rootItem.listChanged()
                }
            }
        }
    }
}
