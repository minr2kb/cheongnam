import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'Login.dart';
import 'main.dart';
import 'Bulletin.dart';
import 'BannerSet.dart';
import 'ProfileImgSet.dart';

final _auth = FirebaseAuth.instance;

class Drawers {
  Widget mainDrawer(String profileName, String profileImg, bool isAdmin) {
    Widget tiles() {
      if (isAdmin) {
        return Column(
          children: [
            ListTile(
              onTap: () => Get.to(Bulletin(),
                  transition: Transition.cupertino,
                  arguments: ["관리자 게시판", true]),
              leading: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(Icons.admin_panel_settings_outlined),
              ),
              title: Text(
                '관리자 게시판',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            ListTile(
              onTap: () =>
                  Get.to(BannerSet(), transition: Transition.cupertino),
              leading: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(Icons.image_outlined),
              ),
              title: Text(
                '배너 설정',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            ListTile(
              onTap: () =>
                  Get.to(ProfileImgSet(), transition: Transition.cupertino),
              leading: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(Icons.account_circle_outlined),
              ),
              title: Text(
                '프로필 이미지',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        );
      } else {
        return SizedBox(height: 0);
      }
    }

    return Drawer(
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Container(
                // width: double.infinity,
                height: 270,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(profileImg), fit: BoxFit.cover)),
                child: ClipRRect(
                  // make sure we apply clip it properly
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(60.0),
                child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 40,
                    backgroundImage: NetworkImage(profileImg)),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  profileName,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 20),
          tiles(),
          ListTile(
            onTap: () async {
              await _auth.signOut();
              // Get.back();
              Get.offAll(Home());
            },
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(Icons.logout),
            ),
            title: Text(
              '로그아웃',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      '28721 충청북도 청주시 상당구 \n수영로 105(영운동195-9)\nTel) 043-253-7693,4\nFax) 043-253-0246',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme_grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget noAuthDrawer(String img) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Container(
                // width: double.infinity,
                height: 270,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(img), fit: BoxFit.cover),
                ),
                child: ClipRRect(
                  // make sure we apply clip it properly
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(60.0),
                child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 40,
                    backgroundImage:
                        ExactAssetImage("./assets/images/defaultUser.jpg")),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  "손님",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 20),
          ListTile(
            onTap: () {
              Get.back();
              Get.to(Login(), transition: Transition.cupertino);
            },
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(Icons.verified_user_outlined),
            ),
            title: Text(
              '교인인증',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      '28721 충청북도 청주시 상당구 \n수영로 105(영운동195-9)\nTel) 043-253-7693,4\nFax) 043-253-0246',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme_grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
