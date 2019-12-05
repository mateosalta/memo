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
import "../common/dateHelper.js" as DateHelper

AbstractButton {
    id: rootItem

    height: layout.height + layout.anchors.topMargin
    width: parent.width

    property bool selected: false
    property int maxListDelegatesNumber: 3

    // RGB channels from 'shape.color' are in [0; 1] range.
    property color foregroundColor: ((shape.color.r * 0.30 + shape.color.g * 0.59 + shape.color.b * 0.11) > 0.5) ? UbuntuColors.darkGrey : "#F3F3E7"

    UbuntuShape {
        id: shape
        aspect: UbuntuShape.DropShadow
        anchors.fill: parent

        // Add 70% opacity
        color: contents.color.toString().replace("#", "#B3")

        radius: "medium"

        Column {
            id: layout
            anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: units.gu(2) }

            Loader {
                x: units.gu(2)
                width: parent.width - x
                sourceComponent: (contents.title == "") ? undefined : titleComponent

                Component {
                    id: titleComponent

                    Label {
                        width: parent.width
                        fontSize: "large"
                        font.weight: Font.Bold
                        text: contents.title
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        wrapMode: Text.WordWrap
                       // color: rootItem.foregroundColor
                    }
                }
            }

            // A spacer item
            Item {
                width: parent.width
                height: units.gu(1)
            }

            Item {
                x: (column1.width > 0) ? units.gu(2) : 0
                width: parent.width - units.gu(4)
                height: Math.max(column1.height, column2.height)

                Column {
                    id: column1
                    anchors { left: parent.left; top: parent.top }
                    width: ((contents.text == "") && (picsRepeater.count == 0)) ? 0
                                                                                : (listRepeater.count > 0) ? (parent.width * 0.5)
                                                                                                           : parent.width
                    spacing: units.gu(2)

                    Loader {
                        width: parent.width
                        sourceComponent: (contents.text == "") ? undefined : textComponent

                        Component {
                            id: textComponent

                            Label {
                                width: parent.width
                                text: contents.text
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                maximumLineCount: 5
                                //color: rootItem.foregroundColor
                            }
                        }
                    }

                    Item {
                        id: picsItem
                        width: parent.width
                        height: picFlow.height

                        // TODO: As for listDelegates, limit pics to a number of 9
                        Flow {
                            id: picFlow
                            width: parent.width

                            Repeater {
                                id: picsRepeater

                                model: contents.pictures

                                delegate: Image {
                                    id: img
                                    width: parent.width
                                    fillMode: Image.PreserveAspectCrop
                                    source: Qt.resolvedUrl(contents.pictures[index].url)

                                    Connections {
                                        target: picsRepeater
                                        onItemAdded: calculateSize(index)
                                        onItemRemoved: calculateSize(index)
                                    }

                                    Connections {
                                        target: picFlow
                                        onWidthChanged: calculateSize(index)
                                    }

                                    Component.onCompleted: calculateSize(index)

                                     function calculateSize(index) {
                                        var n = picsRepeater.count
                                        var i = n % 3
                                        var m = Math.floor(n / 3)

                                        height = units.gu(6)

                                        // Need to be hardcoded because of an issue.
                                        // FIXME: Think it requires a better solution
                                        var picFlowRealWidth = column1.width  - units.gu(1)

                                        switch(i) {
                                        case 0:
                                            width = picFlowRealWidth / 3
                                            return
                                        case 1:
                                            if (index == 0) {
                                                width = picFlowRealWidth
                                                return
                                            } else {
                                                width = picFlowRealWidth / 3
                                                return
                                            }
                                        case 2:
                                            if (index <= 1) {
                                                width = picFlowRealWidth / 2
                                                return
                                            } else {
                                                width = picFlowRealWidth / 3
                                                return
                                            }
                                        }
                                    }
                                }
                            }

                            Component.onCompleted: picsRepeater.model = contents.pictures
                        }
                    }
                }

                Loader {
                    anchors { right: column2.left; top: parent.top; bottom: parent.bottom; rightMargin: -units.gu(1) }
                    sourceComponent: ((column2.width > 0) && (column1.width > 0)) ? divider : null
                    width: 1

                    Component {
                        id: divider
                        Rectangle {
                            anchors.fill: parent
                            //color: foregroundColor
                            opacity: 0.3
                        }
                    }
                }

                Column {
                    id: column2
                    anchors { left: column1.right; top: parent.top }
                    width: (listRepeater.count > 0) ? ((contents.text == "") && (picsRepeater.count == 0)) ? parent.width
                                                                                                           : (parent.width * 0.5)
                                                    : 0

                    Repeater {
                        id: listRepeater
                        width: parent.width

                        model: contents.list

                        delegate: Loader {
                            width: parent.width
                            sourceComponent: model.index < 4 ? listDelegate : null

                            Component {
                                id: listDelegate

                                Row {
                                    id: rootItem
                                    spacing: units.gu(1)
                                    width: parent.width
                                    height: Math.max(checkBox.height, textArea.height)

                                    Item {
                                        id: checkBox
                                        width: parent.width
                                        height: units.gu(4)

                                        property bool checked: contents.list[index].checked

                                        Icon {
                                            id: tick
                                            anchors {
                                                left: parent.left; leftMargin: units.gu(2.25);
                                                top: parent.top; topMargin: units.gu(0.35)
                                            }
                                            width: (source == "../../graphics/select.svg") ? units.gu(2.25) : units.gu(1.5)
                                            height: (source == "../../graphics/select.svg") ? units.gu(2) : units.gu(1.5)

                                            source: checkBox.checked ? "../../graphics/select.svg" : "../../graphics/unselect.svg"
                                            visible: model.index !== 3
                                            color: theme.palette.normal.foregroundText
                                        }

                                        Label {
                                            id: textArea
                                            anchors { left: tick.right; right: parent.right; margins: units.gu(1) }

                                            font.strikeout: checkBox.checked
                                            text: (model.index == 3) ? ". . ." : contents.list[index].text
                                            elide: Text.ElideRight
                                            maximumLineCount: 2
                                            wrapMode: Text.WordWrap
                                            //color: foregroundColor
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // A spacer item
            Item {
                width: parent.width
                height: units.gu(1)
            }

            Item {
                id: date
                width: parent.width
                height: units.gu(4)

                Label {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter; margins: units.gu(2) }
                    text: Qt.formatDateTime(DateHelper.parseDate(contents.date), "d MMM yyyy, hh:mm")
                    fontSize: "small"
                    //color: rootItem.foregroundColor
                }
            }
        }
    }

    // Visual feedback when pressed. Not listed in official documentation, still useful.
    onPressedChanged: {
        if (pressed)
            shape.borderSource = "radius_pressed.sci"
        else
            shape.borderSource = "radius_idle.sci"
    }

    // Visual feedback when selected.
    onSelectedChanged: {
        if (selected) {
            shape.color = Qt.darker(contents.color)
        } else {
            shape.color = contents.color.toString().replace("#", "#B3")
        }
    }
}
