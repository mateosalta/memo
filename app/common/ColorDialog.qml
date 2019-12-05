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
import Ubuntu.Components.Popups 1.3

Dialog {
    id: rootItem

    title: i18n.tr("Pick a color")

    property var colors: ["#f0f0f0", "#ed3146", "#d4326b", "#e95420", "#f89b0f", "#f5d412", "#46c54f", "#14cfa8", "#19b6ee", "#4e46c5", "#9542c4", "#c343bf"
    ]
    property color selectedColor: colors[0]

    property bool showTick: true
    property bool askConfirmation: false

    signal colorPicked(bool isChanged)

    onSelectedColorChanged: view.setCurrentColor()
    Component.onCompleted: internal.oldColor = rootItem.selectedColor

    QtObject {
        id: internal

        property color oldColor
    }

    Grid {
        id: grid
        width: parent.width

        columns: (width / cellWidth).toFixed(0)

        property int cellHeight: units.gu(5)
        property int cellWidth: units.gu(5)

        Repeater {
            id: view

            width: parent.width

            Component.onCompleted: setCurrentColor()

            function setCurrentColor() {
                if (rootItem.colors) {
                    for (var i=0; i<rootItem.colors.length; i++) {
                        if (rootItem.colors[i] == rootItem.selectedColor) {
                            view.currentIndex = i
                        }
                    }
                }
            }

            model: rootItem.colors

            property int currentIndex: 0

            delegate: AbstractButton {
                id: delegate

                height: grid.cellHeight
                width: grid.cellWidth

                onClicked: {
                    view.currentIndex = model.index

                    if (!rootItem.askConfirmation) {
                        rootItem.selectedColor = rootItem.colors[view.currentIndex]

                        console.log ("Old color:", internal.oldColor, "New color:", rootItem.selectedColor)
                        if (internal.oldColor == rootItem.selectedColor) {
                            rootItem.colorPicked(false)
                        } else {
                            rootItem.colorPicked(true)
                        }

                        rootItem.hide()
                    }
                }

                UbuntuShape {
                    anchors { fill: parent; margins: units.gu(0.5)}
                    color: modelData
                    clip: true

                    Icon {
                        id: tick
                        anchors { fill: parent; margins: units.gu(0.5) }
                        name: "tick"
                        visible: view.currentIndex == model.index && rootItem.showTick
                        color: getColor()

                        function getColor() {
                            return Qt.rgba(1 - parseInt(modelData.substr(1,2), 16) / 255, 1 - parseInt(modelData.substr(3,2), 16) / 255, 1 - parseInt(modelData.substr(5,2), 16) / 255)
                        }
                    }
                }
            }
        }
    }

    Column {
        width: parent.width
        spacing: units.gu(2)

        Loader {
            width: parent.width
            sourceComponent: if (askConfirmation) return confirmationButtons

            Component {
                id: confirmationButtons
                Button {
                    width: parent.width
                    text: i18n.tr("OK")
                    color: UbuntuColors.orange

                    onClicked: {
                        rootItem.selectedColor = rootItem.colors[view.currentIndex]

                        console.log ("Old color:", internal.oldColor, "New color:", rootItem.selectedColor)
                        if (internal.oldColor == rootItem.selectedColor) {
                            rootItem.colorPicked(false)
                        } else {
                            rootItem.colorPicked(true)
                        }

                        rootItem.hide()
                    }
                }
            }
        }

        Button {
            width: parent.width
            text: i18n.tr("Cancel")

            onClicked: {
                rootItem.hide()

                for (var i=0; i<rootItem.colors.length; i++) {
                    if (rootItem.colors[i] == internal.oldColor) {
                        view.currentIndex = i
                    }
                }
                rootItem.selectedColor = internal.oldColor
            }
        }
    }



}
