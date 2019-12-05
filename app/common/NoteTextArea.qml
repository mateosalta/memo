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
import Ubuntu.Components.Themes.Ambiance 0.1

TextArea {
    id: rootItem
    width: parent.width

    autoSize: true
    maximumLineCount: 0

    // Prevent data loss
    inputMethodHints: Qt.ImhNoPredictiveText

    opacity: 1.0

    signal focusLost()
    signal textReallyChanged

    property string __oldText: ""
    onTextChanged: {
        //WORKAROUND: textChanged seems to be emitted also when TextArea has the activeFocus (and text does not change).
        if (__oldText !== text) {
            rootItem.textReallyChanged()
            __oldText = text;
        }
    }

    InverseMouseArea {
        visible: parent.activeFocus
        anchors.fill: parent
        onClicked: {
            rootItem.focusLost()
            mouse.accepted = false
        }
    }

    style: TextAreaStyle {
        frameSpacing: 0
        background: Item { anchors.fill: parent }
    }
}
