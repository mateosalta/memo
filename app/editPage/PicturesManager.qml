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
//import Ubuntu.Thumbnailer 0.1
import Ubuntu.Content 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem

Item {
    id: rootItem

    property alias model: repeater.model

    width: parent.width
    height: childrenRect.height

    signal picsModelChanged()

    function exportModel() {
        var list = []
        for (var i=0; i<picModel.count; i++) {
            list[i] = picModel.get(i)
        }

        return list
    }

    ListItem.Header { id: header; text: i18n.tr("Related pictures:") }

    Flow {
        id: flow

        anchors {
            top: header.bottom; topMargin: units.gu(1)
            left: parent.left
            right: parent.right
            margins: units.gu(2)
        }
        spacing: units.gu(2)

        Repeater {
            id: repeater

            model: ListModel { id: picModel; onRowsRemoved: rootItem.picsModelChanged() }
            delegate: PictureButton {
                image: Image {
                    source: Qt.resolvedUrl(model.url)
                    fillMode: Image.PreserveAspectCrop
                }

                //TODO: Add right click support
                onClicked: pageStack.push(Qt.resolvedUrl("../ui/ImageViewer.qml"), {source: Qt.resolvedUrl(model.url)})
                onPressAndHold: PopupUtils.open(pictureMenuPopover, this, {index: model.index})
            }
        }

        PictureButton {
            Icon {
                anchors.centerIn: parent
                height: parent.height / 2
                width: height
                name: "add"
            }

            onClicked: rootItem.importImageFromContentHub()
        }
    }

    // *** CONTENT HANDLER ***
    //This should be probably moved in main.qml
    property var activeTransfer

    function importImageFromContentHub() {
        pageStack.push(picker)
    }

    Page {
        id: picker
        visible: false

        ContentPeerPicker {
            visible: parent.visible

            contentType: ContentType.Pictures
            handler: ContentHandler.Source

            onPeerSelected: {
                rootItem.activeTransfer = peer.request(appStore);
                pageStack.pop();
            }

            onCancelPressed: {
                pageStack.pop();
            }
        }
    }

    ContentTransferHint {
        id: transferHint
        anchors.fill: parent
        activeTransfer: rootItem.activeTransfer
    }

    ContentStore {
        id: appStore
        scope: ContentScope.App
    }

    Connections {
        target: rootItem.activeTransfer ? rootItem.activeTransfer : null
        onStateChanged: {
            if (rootItem.activeTransfer.state === ContentTransfer.Charged) {
                for (var i=0; i<rootItem.activeTransfer.items.length; i++) {
                    picModel.append({url: rootItem.activeTransfer.items[i].url.toString().replace("file://", "")})
                    console.log("CONTENT IMPORTED:", rootItem.activeTransfer.items[i].url.toString().replace("file://", ""))
                    rootItem.picsModelChanged()
                }
            }
        }
    }

    // *** PICTURE POPOVER ***
    Component {
        id: pictureMenuPopover
        ActionSelectionPopover {
            id: popover
            property int index

            actions: ActionList {
                Action {
                    text: i18n.tr("Remove picture from selection")
                    onTriggered: {
                        PopupUtils.close(popover)
                        rootItem.model.remove(popover.index)
                    }
                }
            }

            delegate: ListItem.Standard {
                // ForegroundColor is not correctly set
                __foregroundColor: Theme.palette.normal.overlayText
                showDivider: false
            }
        }
    }
}
