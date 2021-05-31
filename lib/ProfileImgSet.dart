import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'main.dart';

class ProfileImgSet extends StatefulWidget {
  @override
  _ProfileImgSetState createState() => _ProfileImgSetState();
}

class _ProfileImgSetState extends State<ProfileImgSet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme_white,
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          "프로필 이미지 설정",
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
            .collection("profiles")
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
    Widget profile() {
      if (doc['active']) {
        return Column(
          children: [
            Image.network(
              doc['url'],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                doc['user'],
                style: TextStyle(
                    color: theme_grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
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

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 3, bottom: 3),
      child: GestureDetector(
        onTap: () => _editAlertDialog(doc['user']),
        child: Card(
          elevation: 3,
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: profile(),
          ),
        ),
      ),
    );
  }

  void _editAlertDialog(String user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              new Text("$user의 프로필 사진 수정"),
            ],
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "수정하시겠습니까?",
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
                child: new Text("예"),
                onPressed: () {
                  Get.back();
                  _uploadImageToStorage(user);
                }),
            TextButton(
              child: new Text("아니오"),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  void _uploadImageToStorage(String user) async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    Reference reference = FirebaseStorage.instance.ref("profiles/$user");
    UploadTask uploadTask = reference.putFile(image);
    await uploadTask.whenComplete(() async {
      String downloadURL = await reference.getDownloadURL();
      FirebaseFirestore.instance
          .collection('profiles')
          .doc(user)
          .update({'active': true, 'url': downloadURL});
    });
    // File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    // if (image == null) return;
    // Reference reference = FirebaseStorage.instance.ref("profiles/defaultBG");
    // UploadTask uploadTask = reference.putFile(image);
    // await uploadTask.whenComplete(() async {
    //   String downloadURL = await reference.getDownloadURL();
    //   FirebaseFirestore.instance
    //       .collection('profiles')
    //       .doc('default').update({'bg': downloadURL});
    // });
  }
}
