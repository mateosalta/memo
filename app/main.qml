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
import Qt.labs.settings 1.0
import "common"

MainView {
    id: root   

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "quick-memo.mateo-salta"

    width: units.gu(50)
    height: units.gu(75)

    // Use the new header style


    anchorToKeyboard: true

    property color headerBackgroundColor: "#95c253"
    readonly property color defaulteaderBackgroundColor: "#f0f0f0"

    // Use GridView to display data. This setting is used by any page that provides data from models.
    property bool useGridView: true

    Settings {
        property alias useGridView: root.useGridView
    }

    // This is where we manage the pages of the application.
    PageStack { id: pageStack }

    NoteModel {
        id: notes
        onInitialized: pageStack.push(Qt.resolvedUrl("./ui/MainPage.qml"))
    }

    function showNotification(text) {
        var component = Qt.createComponent("./common/Toaster.qml")
        var toast = component.createObject(root, {"text" : text});
    }

    Component.onCompleted: {
        header.style = Qt.createComponent(Qt.resolvedUrl("theme/PageHeadStyle.qml"))
       
    }

/*
 Not now, but in the future:
 TODO: Layout convergence
 TODO: Add audible reminders??? (use Ubuntu.Components.Alarm)
 */
}
