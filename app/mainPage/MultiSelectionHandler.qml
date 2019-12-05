/*
  This file is part of quick-memo
  Copyright (C) 2014 Stefano Verzegnassi

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

PageHeadState {
    id: rootItem

    property string title

    property var indexes: []
    property int count: rootItem.indexes.length
    property Page targetPage

    head: targetPage.head

    backAction: Action {
        text: i18n.tr("Cancel")
        iconName: "back"
        onTriggered: targetPage.state = "default"
    }

    contents: Item {
        anchors.fill: parent

        Connections {
            target: targetPage
            onStateChanged: {
                if (targetPage.state !== "multiSelection") {
                    // Clean the model
                    rootItem.indexes = []
                }
            }
        }

        Label {
            fontSize: "x-large"

            // See LP:1184810
            text: (rootItem.count == 0) ? i18n.tr("No item selected")
                                        : i18n.tr("%1 item selected", "%1 items selected", rootItem.count).arg(rootItem.count)

            anchors.verticalCenter: parent.verticalCenter
        }

        // Provide a visual feedback when active
        Rectangle {
            id: headerBg
            parent: targetPage.header
            z: 10

            width: targetPage.width
            height: targetPage.header.height
            color: "#19B6EE"   // Cyan
            visible: mainPage.state == "multiSelection"
        }
    }

    signal indexAdded(var index)
    signal indexRemoved(var index)

    function selectUnselectItem(index) {
        for (var i=0; i<rootItem.indexes.length; i++) {
            // Search for index in the model
            if (rootItem.indexes[i] === index) {
                // That means it's already in, so remove it.
                rootItem.indexes.splice(i, 1);

                // Update count and header
                rootItem.count = rootItem.indexes.length

                // Return false if the index is removed.
                rootItem.indexRemoved(index)
                return false
            }
        }

        // Otherwise, the item is not in the model, so add it.
        rootItem.indexes.push(index)

        // Update count
        rootItem.count = rootItem.indexes.length

        // Sort indexes, so that it's easier to use the indexes we collect.
        indexes.sort(function(a,b) {return a-b})

        // Return true if the index is added
        rootItem.indexAdded(index)
        return true
    }
}
