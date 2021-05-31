import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'CreatePost.dart';
import 'EditPost.dart';
import 'ReadPost.dart';
import 'main.dart';

class AdminMenu extends StatefulWidget {
  @override
  _AdminMenuState createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminMenu> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  final String _category = Get.arguments[0];
  final bool _isAdmin = Get.arguments[1];

  Widget build(BuildContext context) {
    final addBtn = _isAdmin
        ? FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: theme_blue,
            onPressed: () => Get.to(CreatePost(),
                transition: Transition.cupertino, arguments: _category),
          )
        : null;

    return Scaffold(
        key: _scaffoldkey,
        backgroundColor: theme_white,
        appBar: AppBar(
          toolbarHeight: 80,
          title: Text(
            _category,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: theme_grey),
          ),
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: theme_grey,
                ),
                iconSize: 33,
                onPressed: () => Get.back()),
          ),
          backgroundColor: theme_white,
          elevation: 0,
        ),
        floatingActionButton: addBtn,
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(_category)
              .orderBy("date", descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView(
              children: snapshot.data.docs.map((doc) {
                if (DateTime.now().difference(doc['date'].toDate()).inHours <
                    24) {
                  return _cardBuilder(doc, true);
                }
                return _cardBuilder(doc, false);
              }).toList(),
            );
          },
        ));
  }

  Widget _cardBuilder(var doc, bool isNew) {
    Widget indicator;
    if (isNew) {
      indicator = Padding(
        padding: const EdgeInsets.only(left: 5),
        child: Icon(
          Icons.fiber_manual_record,
          color: Colors.red,
          size: 10,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 3, bottom: 3),
      child: Card(
        elevation: 3,
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
            title: Padding(
              padding: const EdgeInsets.only(top: 13, left: 10),
              child: Row(
                children: [Text(doc['title']), indicator],
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 10, top: 3, bottom: 10),
              child: Row(
                children: [
                  Text(doc['author'] + "  "),
                  Text(DateFormat('yyyy-MM-dd').format(doc['date'].toDate())),
                ],
              ),
            ),
            onTap: () {
              if (_isAdmin) {
                Get.to(EditPost(),
                    transition: Transition.cupertino,
                    arguments: [
                      _category,
                      doc['title'],
                      doc['content'],
                      doc.id
                    ]);
              } else {
                Get.to(ReadPost(),
                    transition: Transition.cupertino,
                    arguments: [doc['title'], doc['content']]);
              }
            }),
      ),
    );
  }
}
