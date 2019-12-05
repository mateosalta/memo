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
import U1db 1.0 as U1db
import Ubuntu.Components 1.3

Item {
    id: rootItem
    property alias model: model

    signal initialized()

    // *** functions
    function addNote(noteTitle, noteText, noteColor, noteList, notePictures) {
        // Get the current date
        var dateString = new Date().valueOf()

        db.putDoc(JSON.stringify({memos: {title: noteTitle, text: noteText, color: noteColor, date: dateString, list: noteList, pictures: notePictures}}))
    }

    // Function used for changing a single value of the note
    function setNoteProperty(index, field, value) {
        var obj = JSON.parse(JSON.stringify(model.get(index)))

        // Edit the required property
        switch(field) {
        case "title":
            obj.contents.title = value
            break
        case "text":
            obj.contents.text = value
            break
        case "color":
            // The char '#' from the hex color is not correctly parse by JSON. We add an empty string, so that it works well.
            obj.contents.color = "" + value
            break
        case "list":
            obj.contents.list = value
            break
        case "pictures":
            obj.contents.pictures = value
        }

        // Get the current date and update the time of the last update
        obj.contents.date = new Date().valueOf()

        db.putDoc(JSON.stringify({memos: obj.contents}), obj.docId)
    }

    // Function used for rewriting the whole content of the note. json variant is a JSON object.
    function editNote(index, json) {
        var obj = json

        // Get the current date and update the time of the last update
        obj.contents.date = new Date().valueOf()

        console.log(JSON.stringify({memos: obj.contents}))
        db.putDoc(JSON.stringify({memos: obj.contents}), obj.docId)
    }


    function deleteNote(index) {
        db.deleteDoc(model.get(index).docId)
    }

    function deleteNotes(indexes) {
        var deletedItemNumber = 0;
        for (var i=0; i<indexes.length; i++) {
            db.deleteDoc(model.get(indexes[i] - deletedItemNumber).docId)
            deletedItemNumber++
        }
    }

    // *** U1db database
    U1db.Database {
        id: db
        path: "quick-memo"
        Component.onCompleted: {
            // TODO: Delete pictures that are not used by the notes at startup.
            rootItem.initialized()
        }
    }

    // TODO: More queries, more pages, a more powerful app.
    // TODO: Search feature. Use "filter" from SortFilterModel?
    SortFilterModel {
        id: model
        sort {
            property: "date"
            order: Qt.DescendingOrder
        }

        model: U1db.Query {
            id: query
            index: U1db.Index {
                database: db
                expression: ["memos.docId", "memos.title", "memos.text", "memos.color", "memos.date", "memos.list", "memos.pictures"]
            }
            query: ["*", "*", "*", "*", "*", "*", "*"]
        }
    }


}
