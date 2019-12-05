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

import "../ubuntucomponents" as UbuntuComponents

// WORKAROUND: We need a 'custom' version of TextField in wait of LP:1376510 to be fixed.
// FIXME: Some issue with InputHandler (e.g. Keys.Down or Keys.PgDown) but we don't care it, since at the moment the main focus is not desktop.
TextField {
    id: textArea
    width: parent.width - (checkBox.width + (parent.spacing * 2))

    // Dynamic height: units.gu(3) = implicitHeight - (frameSpacing * 2)
    height: (contentHeight > units.gu(3)) ? contentHeight : units.gu(3)

    //wrapMode: TextInput.Wrap

    // Prevent data loss
    inputMethodHints: Qt.ImhNoPredictiveText

    signal focusLost()
    signal focusReceived()

    onActiveFocusChanged: {
        if (activeFocus) {
            focusReceived()
        } else {
            focusLost()
        }
    }

    style: TextFieldStyle {
        frameSpacing: 0
        background: Item { anchors.fill: parent }
    }
}
