import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zefyr/zefyr.dart';
import 'main.dart';

class EditPost extends StatefulWidget {
  @override
  _EditPostState createState() => new _EditPostState();
}

class _EditPostState extends State<EditPost> {
  ZefyrController _controller;
  final FocusNode _focusNode = new FocusNode();
  bool _readOnly = true;
  final TextEditingController _titleController = TextEditingController();
  var data = Get.arguments;

  @override
  void initState() {
    super.initState();
    setState(() {
      _controller = ZefyrController(NotusDocument.fromJson(jsonDecode(data[2])))
        ..addListener(linkListener);
    });
  }

  linkListener() {
    // check if any link is clicked
    final _url =
        _controller.getSelectionStyle().get(NotusAttribute.link)?.value;

    // if url found launch it
    if (_readOnly) {
      if (_url != null) {
        _launchURL(_url);
      }
    }
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final editBtn = _readOnly
        ? [
            new IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: theme_grey,
                ),
                onPressed: _startEditing),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                  icon: Icon(
                    Icons.delete_forever_outlined,
                    color: theme_grey,
                  ),
                  onPressed: () => _alertDialog()),
            ),
          ]
        : [new TextButton(onPressed: _stopEditing, child: Text('DONE'))];

    _titleController.text = data[1];
    final titleBar = _readOnly
        ? new Text(
            data[1],
            overflow: TextOverflow.fade,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: theme_grey),
          )
        : new TextField(
            controller: _titleController,
            decoration: InputDecoration(hintText: '제목'),
          );

    final editor = _readOnly
        ? new ZefyrEditor(
            padding: EdgeInsets.symmetric(horizontal: 25),
            controller: _controller,
            focusNode: _focusNode,
            readOnly: _readOnly,
            showCursor: !_readOnly,
          )
        : new Column(
            children: [
              ZefyrToolbar.basic(controller: _controller),
              Expanded(
                child: ZefyrEditor(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: _readOnly,
                  showCursor: !_readOnly,
                ),
              )
            ],
          );

    return Scaffold(
      backgroundColor: theme_white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 80,
        title: titleBar,
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
        actions: editBtn,
        backgroundColor: theme_white,
        elevation: 0,
      ),
      body: editor,
    );
  }

  void _startEditing() {
    setState(() {
      _readOnly = false;
    });
  }

  void _stopEditing() {
    final contents = jsonEncode(_controller.document);
    var updated = {
      'title': _titleController.text,
      'content': contents,
    };
    FirebaseFirestore.instance.collection(data[0]).doc(data[3]).update(updated);
    setState(() {
      _readOnly = true;
    });
  }

  void _alertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              new Text("게시글 삭제"),
            ],
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "이 글을 삭제하시겠습니까?",
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
                child: new Text("예"),
                onPressed: () {
                  Get.back();
                  try {
                    FirebaseFirestore.instance
                        .collection(data[0])
                        .doc(data[3])
                        .delete();
                    Get.back();
                  } catch (e) {
                    _alertDialog2("삭제에 실패했습니다");
                  }
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

  void _alertDialog2(String text) {
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
              onPressed: () => Get.back(),
            ),
          ],
        );
      },
    );
  }
}
