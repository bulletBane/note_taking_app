import 'dart:convert';
import 'package:flutter/material.dart';

class Note {
  int id;
  String title;
  String content;
  DateTime dateCreated;
  DateTime dateLastEdited;
  Color noteColor;
  int isArchived = 0;

  Note(this.id, this.title, this.content, this.dateCreated, this.dateLastEdited,
      this.noteColor);

  Map<String, dynamic> toMap(bool forUpdate) {
    var data = {
//      'id': id,  since id is auto incremented in the database we don't need to send it to the insert query.
      'title': utf8.encode(title),
      'content': utf8.encode(content),
      'date_created': epochFromDate(dateCreated),
      'date_last_edited': epochFromDate(dateLastEdited),
      'note_color': noteColor.value,
      'is_archived': isArchived //  for later use for integrating archiving
    };
    if (forUpdate) {
      data["id"] = this.id;
    }
    return data;
  }

// Converting the date time object into int representing seconds passed after midnight 1st Jan, 1970 UTC
  int epochFromDate(DateTime dt) {
    return dt.millisecondsSinceEpoch ~/ 1000;
  }

  void archiveThisNote() {
    isArchived = 1;
  }

// overriding toString() of the note class to print a better debug description of this custom class
  @override
  toString() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date_created': epochFromDate(dateCreated),
      'date_last_edited': epochFromDate(dateLastEdited),
      'note_color': noteColor.toString(),
      'is_archived': isArchived
    }.toString();
  }
}
