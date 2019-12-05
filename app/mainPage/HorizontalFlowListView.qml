/*
 *  Copyright 2012 Ruediger Gad
 *  Copyright 2014 Stefano Verzegnassi <stefano92.100@gmail.com>
 *
 *  This file is part of FlowListView.
 *
 *  FlowListView is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License (LGPL)
 *  as published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  FlowListView is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with FlowListView.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

// A derivative version of FlowListView.qml
import QtQuick 2.9
import Ubuntu.Components 1.3

Flickable {
    id: flowListView

    contentWidth: flow.childrenRect.width

    property alias count: repeater.count
    property int currentIndex: -1
    property variant currentItem;
    property alias delegate: repeater.delegate
    property alias model: repeater.model

    property alias spacing: flow.spacing

    property alias add: flow.add
    property alias populate: flow.populate
    property alias move: flow.move

    // Indipendent GU flickable speed workaround
    flickDeceleration: 1500 * units.gridUnit / 8
    maximumFlickVelocity: 2500 * units.gridUnit / 8

    onCurrentIndexChanged: {
        currentItem = repeater.itemAt(currentIndex)
    }

    Flow {
        id: flow

        height: parent.height
        flow: Flow.TopToBottom

        Item { width: units.gu(1); height: parent.height }

        Repeater {
            id: repeater

            onCountChanged: {
                if (flowListView.currentIndex === -1 && count > 0) {
                    flowListView.currentIndex = 0
                    return
                }
                if (flowListView.currentIndex >= count) {
                    flowListView.currentIndex = count - 1
                    return
                }

                flowListView.currentIndex = -1
            }
        }

        Item { width: units.gu(1); height: parent.height }
    }
}
