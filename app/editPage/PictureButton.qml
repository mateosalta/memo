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

AbstractButton {
    id: rootItem
    width: units.gu(8)
    height: units.gu(8)

    property alias image: shape.image
    default property alias contentsItem: shape.data

    onPressedChanged: {
        if (pressed)
            shape.borderSource = "radius_pressed.sci"
        else
            shape.borderSource = "radius_idle.sci"
    }

    UbuntuShape {
        id: shape
        anchors.fill: parent
    }
}
