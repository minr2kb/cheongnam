import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';

class BannerSet extends StatefulWidget {
  @override
  _BannerSetState createState() => _BannerSetState();
}

class _BannerSetState extends State<BannerSet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme_white,
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          "배너설정",
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("banners")
            .orderBy("order")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data.docs.map((doc) {
              return _cardBuilder(doc);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _cardBuilder(var doc) {
    Widget bannner() {
      if (doc['active']) {
        return Image.network(
          doc['url'],
        );
      } else {
        return Center(
          child: IconButton(
            iconSize: 30,
            icon: Icon(Icons.add),
            onPressed: null,
          ),
        );
      }
    }

    void action() {
      if (doc['active']) {
        _editAlertDialog(doc['order']);
      } else {
        _addAlertDialog(doc['order']);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 3, bottom: 3),
      child: GestureDetector(
        onTap: action,
        child: Card(
          elevation: 3,
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: bannner(),
          ),
        ),
      ),
    );
  }

  void _addAlertDialog(int order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              new Text("$order번 배너 설정"),
            ],
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "어떤 작업을 하시겠습니까?",
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
                child: new Text("이전배너사용"),
                onPressed: () {
                  _reuse(order);
                  Get.back();
                }),
            TextButton(
              child: new Text("추가"),
              onPressed: () {
                Get.back();
                _uploadImageToStorage(order);
              },
            ),
          ],
        );
      },
    );
  }

  void _editAlertDialog(int order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              new Text("$order번 배너 수정"),
            ],
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "어떤 작업을 하시겠습니까?",
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
                child: new Text("변경"),
                onPressed: () {
                  Get.back();
                  _uploadImageToStorage(order);
                }),
            TextButton(
              child: new Text("삭제"),
              onPressed: () {
                Get.back();
                _deleteAlertDialog(order);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAlertDialog(int order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              new Text("배너 삭제"),
            ],
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "$order번 배너를 삭제하시겠습니까?",
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
                child: new Text("예"),
                onPressed: () {
                  _delete(order);
                  Get.back();
                }),
            TextButton(
              child: new Text("아니오"),
              onPressed: () => Get.back(),
            ),
          ],
        );
      },
    );
  }

  void _delete(int order) {
    FirebaseFirestore.instance
        .collection('banners')
        .doc('img$order')
        .update({'active': false});
  }

  void _reuse(int order) {
    FirebaseFirestore.instance
        .collection('banners')
        .doc('img$order')
        .update({'active': true});
  }

  void _uploadImageToStorage(int order) async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    Reference reference = FirebaseStorage.instance.ref("banners/img$order");
    UploadTask uploadTask = reference.putFile(image);
    await uploadTask.whenComplete(() async {
      String downloadURL = await reference.getDownloadURL();
      FirebaseFirestore.instance
          .collection('banners')
          .doc('img$order')
          .update({'active': true, 'url': downloadURL});
    });
  }
}
