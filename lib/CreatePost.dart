import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zefyr/zefyr.dart';

import 'main.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => new _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  ZefyrController _controller = ZefyrController(NotusDocument.fromJson(
      jsonDecode(
          r'[{"insert":"내용입력"},{"insert":"\n","attributes":{"heading":3}}]')));
  final FocusNode _focusNode = new FocusNode();
  final TextEditingController _titleController = TextEditingController();
  var data = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme_white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 80,
        title: new TextField(
          controller: _titleController,
          decoration: InputDecoration(hintText: '제목'),
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
        actions: [new TextButton(onPressed: _save, child: Text('SAVE'))],
        backgroundColor: theme_white,
        elevation: 0,
      ),
      body: Column(
        children: [
          ZefyrToolbar.basic(controller: _controller),
          Expanded(
            child: ZefyrEditor(
              padding: EdgeInsets.symmetric(horizontal: 25),
              controller: _controller,
              focusNode: _focusNode,
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final contents = jsonEncode(_controller.document);
    var post = {
      'title': _titleController.text,
      'author': "청남교회",
      'content': contents,
      "date": Timestamp.fromDate(new DateTime.now())
    };
    FirebaseFirestore.instance.collection(data).add(post);
    _alertDialog("게시물을 업로드했습니다");
  }

  void _alertDialog(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              new Text("작업결과"),
            ],
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                text,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: new Text("확인"),
              onPressed: () {
                Get.back();
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }
}
