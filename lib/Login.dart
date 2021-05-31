import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'main.dart';
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _scaffoldkey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  var email = "";

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldkey,
      backgroundColor: theme_white,
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          '교인인증',
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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 100),
              child: CustomRadioButton(
                elevation: 3,
                unSelectedColor: Theme.of(context).canvasColor,
                height: 50,
                width: 90,
                enableButtonWrap: true,
                customShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                enableShape: true,
                buttonLables: [
                  '관리자',
                  '구역장',
                  '교인',
                ],
                buttonValues: [
                  "admin@cheongnam.com",
                  "leader@cheongnam.com",
                  "christian@cheongnam.com",
                ],
                buttonTextStyle: ButtonTextStyle(
                    selectedColor: theme_white,
                    unSelectedColor: theme_grey,
                    textStyle: TextStyle(fontSize: 16)),
                radioButtonValue: (value) {
                  email = value;
                },
                selectedColor: theme_blue,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 70, right: 70, top: 40, bottom: 40),
              child: TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '인증코드',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return '인증코드를 입력해주십시오';
                  }
                  return null;
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: theme_blue,
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _signInWithEmailAndPassword();
                }
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
                child: Text(
                  '인증',
                  style: TextStyle(color: theme_white, fontSize: 17),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _alertDialog(String result, bool isSuccess) {
    showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              new Text("인증 결과"),
            ],
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                result,
              ),
            ],
          ),
          actions: <Widget>[
            new TextButton(
              child: new Text("확인"),
              onPressed: () {
                if (isSuccess) {
                  Get.offAll(Home());
                } else {
                  Get.back();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _alertDialog2(String result) {
    showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              new Text("인증정보 확인중"),
            ],
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                result,
              ),
            ],
          ),
        );
      },
    );
  }

  void _signInWithEmailAndPassword() async {
    try {
      _alertDialog2("잠시만 기다려주십시오");
      final User user = (await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      ))
          .user;
      if (email == "admin@cheongnam.com") {
        await user.updateProfile(displayName: "관리자").then((value) {
          Get.back();
          _alertDialog("${user.displayName}(으)로 인증되었습니다", true);
        });
      } else if (email == "leader@cheongnam.com") {
        await user.updateProfile(displayName: "구역장").then((value) {
          Get.back();
          _alertDialog("${user.displayName}(으)로 인증되었습니다", true);
        });
      } else if (email == "christian@cheongnam.com") {
        await user.updateProfile(displayName: "교인").then((value) {
          Get.back();
          _alertDialog("${user.displayName}(으)로 인증되었습니다", true);
        });
      }
    } catch (e) {
      Get.back();
      _alertDialog("인증에 실패하였습니다: "+e.toString(), false);
      // _alertDialog(e.toString(), false);
    }
  }
}
