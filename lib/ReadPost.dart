import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zefyr/zefyr.dart';

import 'main.dart';

class ReadPost extends StatefulWidget {
  @override
  _ReadPostState createState() => new _ReadPostState();
}

class _ReadPostState extends State<ReadPost> {
  ZefyrController _controller;
  final FocusNode _focusNode = new FocusNode();
  var data = Get.arguments;

  void initState() {
    super.initState();
    setState(() {
      _controller = ZefyrController(NotusDocument.fromJson(jsonDecode(data[1])))
        ..addListener(linkListener);
    });
  }

  linkListener() {
    // check if any link is clicked
    final _url =
        _controller.getSelectionStyle().get(NotusAttribute.link)?.value;

    // if url found launch it
    if (_url != null) {
      _launchURL(_url);
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
    return Scaffold(
      backgroundColor: theme_white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          data[0],
          overflow: TextOverflow.fade,
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
      body: ZefyrEditor(
        padding: EdgeInsets.symmetric(horizontal: 30),
        controller: _controller,
        focusNode: _focusNode,
        readOnly: true,
        showCursor: false,
      ),
    );
  }
}
