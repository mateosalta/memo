/*
  This file is part of quick-memo
  Copyright (C) 2014-2015 Stefano Verzegnassi

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
import Ubuntu.Keyboard 0.1
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem

import "../common"
import "../editPage"
import "../common/dateHelper.js" as DateHelper

Page {
    id: memoPage
    title: editMemo ? i18n.tr("Details") : i18n.tr("Add a new memo")

    /* This page has two modes: NewMemo and EditMemo.
       Following properties are used to load the right mode.
    */
    property bool editMemo: false
    property int index

    property bool canSave: (title.text != "") || (desc.text != "") || (listManager.model.count > 0) || (picsView.model.count > 0)
    property bool contentChanged: false

    // Load an existent memo if required
    Component.onCompleted: { if (editMemo) loadNote() }

    head.backAction: editMemo ? backEditMemo : backNewMemo
    head.actions: [colorToolAction, deleteMemo, saveMemo]

    // flickable property needs to be explicitly set, to avoid a binding loop for memoPage.height
    flickable: flickable
    Flickable {
        id: flickable
        anchors.fill: parent

        // Indipendent GU flickable speed workaround
        flickDeceleration: 1500 * units.gridUnit / 8
        maximumFlickVelocity: 2500 * units.gridUnit / 8

        // Could this be an SDK-related issue?
        contentHeight: layout.height + root.header.height
        interactive: contentHeight > height

        Column {
            id: layout
            anchors { left: parent.left; right: parent.right }
            spacing: units.gu(1)

            // Spacing
            Item { width: parent.width; height: units.gu(1) }

            NoteTextField {
                id: title
                x: units.gu(2); width: parent.width - units.gu(4)

                font.weight: Font.Bold
                font.pixelSize: FontUtils.sizeToPixels("large")

                placeholderText: i18n.tr("No title")
                onFocusLost: flickable.forceActiveFocus()

                // Ubuntu Keyboard
                /* TRANSLATORS: This is a custom text for the "enter" key of
                  the on-screen keyboard (max 4 char, so it's not elided)  */
                InputMethod.extensions: { "enterKeyText": i18n.tr("Next") }
                Keys.onReturnPressed: desc.forceActiveFocus()
            }

            NoteTextArea {
                id: desc
                x: units.gu(2); width: parent.width - units.gu(4)

                placeholderText: i18n.tr("No description")
                onFocusLost: flickable.forceActiveFocus()
            }

            ListManager {
                id: listManager

                width: parent.width
                flickable: flickable
            }

            PicturesManager { id: picsView; width: parent.width }

            Label {
                id: updateLabel
                anchors { right: parent.right; rightMargin: units.gu(2) }

                fontSize: "x-small"
                visible: editMemo

                function refresh() {
                    updateLabel.text = i18n.tr("Last update: %1").arg(Qt.formatDateTime(DateHelper.parseDate(notes.model.get(index).contents.date), "d MMM yyyy, hh:mm:ss"))
                }
            }
        }
    }

    // Used for auto saving while editing fields
    Timer {
        id: autoSaveTimer
        interval: 1000   // Is this a good timing?

        onTriggered: {
            if (!canSave) { // Change timer inteval if can't save?
                deleteDialog.emptyMemo = true;
                deleteDialog.show();
            } else {
                console.log("autoSaveTimer triggered... updating the note!")
                saveNote()
            }
        }
    }

    function loadNote() {
        var memoObj = notes.model.get(index)

        title.text = memoObj.contents.title
        desc.text = memoObj.contents.text
        root.headerBackgroundColor = memoObj.contents.color

        // Append list items provided by NoteModel
        listManager.model.clear()
        for (var i=0; i<memoObj.contents.list.length; i++) {
            listManager.model.append(JSON.parse(JSON.stringify(memoObj.contents.list[i])))
        }

        // Append pictures items provided by NoteModel
        picsView.model.clear()
        for (var i=0; i<memoObj.contents.pictures.length; i++) {
            picsView.model.append(JSON.parse(JSON.stringify(memoObj.contents.pictures[i])))
        }

        // Connect signals for auto-saving
        title.textChanged.connect(updateNote)
        desc.textReallyChanged.connect(updateNote)
        listManager.listChanged.connect(updateNote)
        picsView.picsModelChanged.connect(updateNote)
        root.headerBackgroundColorChanged.connect(updateNote)

        updateLabel.refresh()
    }

    function updateNote() {
        autoSaveTimer.restart()
    }

    function saveNote() {
        var obj = JSON.parse(JSON.stringify(notes.model.get(index)))

        obj.contents.title = title.text
        obj.contents.text = desc.text
        // The char '#' from the hex color is not correctly parse by JSON. We add an empty string, so that it works well.
        obj.contents.color = "" +  root.headerBackgroundColor
        obj.contents.list = listManager.exportModel()
        obj.contents.pictures = picsView.exportModel()

        notes.editNote(memoPage.index, obj)
        updateLabel.refresh()

        memoPage.contentChanged = true;
    }

    function addNote() {
        notes.addNote(title.text,
                      desc.text,
                      "" + root.headerBackgroundColor,    // The char '#' from the hex color is not correctly parse by JSON. We add an empty string, so that it works well.
                      listManager.exportModel(),
                      picsView.exportModel())
        pageStack.pop()

        root.showNotification(i18n.tr("Memo saved!"))
    }

    // *** ACTIONS ***
    Action {
        id: saveMemo
        text: i18n.tr("Save")
        iconName: "ok"
        onTriggered: addNote()

        visible: !editMemo
        enabled: canSave
    }
    Action {
        id: deleteMemo
        text: i18n.tr("Delete memo")
        iconName: "delete"
        onTriggered: deleteDialog.show()
        visible: editMemo
    }
    Action {
        id: colorToolAction
        text: i18n.tr("Change memo color")
        iconSource: "../../graphics/palette.svg"
        onTriggered: PopupUtils.open(colorNotePopover)
    }

    // *** BACK ACTIONS ***
    Action {
        id: backEditMemo
        iconName: "back"
        onTriggered: {
            if (!canSave) {
                deleteDialog.emptyMemo = true;
                deleteDialog.show();
            } else {
                // Check if a saveNote request was made. If so, stop the timer and save before exiting the page.
                if (autoSaveTimer.running) {
                    console.log("It's ok. Saving the note before closing the page...")
                    autoSaveTimer.running = false
                    saveNote()
                }
                pageStack.pop()

                pageStack.push(Qt.resolvedUrl("./MainPage.qml"))

                if (memoPage.contentChanged)
                    root.showNotification(i18n.tr("Memo updated!"))
            }
        }
    }

    Action {
        id: backNewMemo
        iconName: "close"
        onTriggered: {
            if (canSave)
                PopupUtils.open(dataLosingOnBackDialog)
            else {
                // Just a pop() because this is called only when the page is loaded through bottomEdge.
                pageStack.pop()

                root.showNotification(i18n.tr("Memo aborted!"))
            }
        }
    }

    //  *** DIALOGS ***
    Dialog {
        id: deleteDialog

        property bool emptyMemo: false

        title: emptyMemo ? i18n.tr("Empty memo") : i18n.tr("Delete memo")
        text: emptyMemo ? i18n.tr("This memo has no content.") : i18n.tr("Are you sure?")
 Button {
            text: i18n.tr("Delete")
            color: UbuntuColors.red
            onClicked: {
                deleteDialog.hide()
                pageStack.pop();
                pageStack.push(Qt.resolvedUrl("MainPage.qml"))
                notes.deleteNote(index)

                root.showNotification(i18n.tr("Memo deleted!"))
            }
        }
        Button {
            text: i18n.tr("Cancel")
            //gradient: UbuntuColors.greyGradient
            onClicked: deleteDialog.hide()
            visible: !deleteDialog.emptyMemo
        }
       
    }

    Component {
        id: dataLosingOnBackDialog
        Dialog {
            id: dataLosingOnBackDialogue

            title: i18n.tr("Discard changes?")
            text: i18n.tr("Your memo will be PERMANENTLY lost.")
 Button {
                text: i18n.tr("Discard")
                color: theme.palette.normal.negative
                onClicked: {
                    PopupUtils.close(dataLosingOnBackDialogue)
                    pageStack.pop();
                }
            }
            Button {
                text: i18n.tr("Cancel")
                //gradient: UbuntuColors.greyGradient
                onClicked: PopupUtils.close(dataLosingOnBackDialogue)
            }
           
        }
    }

    Component {
        id: colorNotePopover

        ColorDialog {
            id: colorDialog

            selectedColor: root.headerBackgroundColor
            onColorPicked: {
                if (isChanged)
                    root.headerBackgroundColor = selectedColor

                PopupUtils.close(colorDialog)
            }
        }
    }
}
