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
// Following are used by the custom header
import Ubuntu.Components.ListItems 1.0 as ListItem
import QtGraphicalEffects 1.0

Page {
    id: imageViewer

    property alias source: image.source

    // Don't use Ubuntu header. Use a custom one.
    Item {
        id: header

        anchors { left: parent.left; top: parent.top; right: parent.right }
        height: units.gu(6)

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.3

            ListItem.Divider {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            }
        }

        AbstractButton {
            id: backButton
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom; leftMargin: units.gu(2);  }
            width: backImg.width + title.width + title.anchors.margins

            onClicked: pageStack.pop()

            Icon {
                id: backImg
                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                height: units.gu(2)
                width: height
                visible: false
                name: "back"
            }

            ColorOverlay {
                id: co
                anchors.fill: backImg
                source: backImg
                color: backButton.pressed ? UbuntuColors.orange : "white"
                Behavior on color {
                    ColorAnimation { duration: UbuntuAnimation.SnapDuration }
                }
            }

            Label {
                id: title
                anchors { left: co.right; verticalCenter: parent.verticalCenter; margins: units.gu(1) }
                text: i18n.tr("Back")

                fontSize: "large"
                font.weight: Font.DemiBold
                color: backButton.pressed ? UbuntuColors.orange : "white"

                Behavior on color {
                    ColorAnimation { duration: UbuntuAnimation.SnapDuration }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        z:-10
    }

    Flickable {
        id: flickable
        anchors { left: parent.left; top: header.bottom; right: parent.right; bottom: parent.bottom }

        contentWidth: Math.max(container.width, width)
        contentHeight: Math.max(container.height, height)

        // Indipendent GU flickable speed workaround
        flickDeceleration: 1500 * units.gridUnit / 8
        maximumFlickVelocity: 2500 * units.gridUnit / 8

        Item {
            id: container
            anchors.centerIn: parent
            width: image.paintedWidth * image.scale
            height: image.paintedHeight * image.scale

            Image {
                id: image
                anchors.centerIn: parent
                width: flickable.width
                height: flickable.height
                fillMode: Image.PreserveAspectFit
            }
        }

        PinchArea {
            anchors.fill: parent
            pinch.target: image
            pinch.minimumScale: 1.0
            pinch.maximumScale: 5.0
        }

        // Go below the custom header
        z: -1
    }
}
