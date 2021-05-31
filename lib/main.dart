import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Bulletin.dart';
import 'Drawers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    // if(kReleaseMode) exit(1);
  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: '청남교회',
      home: Home(),
    );
  }
}

final Color theme_white = Color(0xffefefef);
final Color theme_grey = Color(0xff5c5d5e);
final Color theme_beige = Color(0xffc9b8a9);
final Color theme_blue = Color(0xff2776e0);

final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
final FirebaseAuth _auth = FirebaseAuth.instance;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _index = 0;
  User user = _auth.currentUser;

  @override
  void initState() {
    super.initState();
    firebaseCloudMessaging_Listeners();
  }

  // Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  //   if (message.containsKey('page')) {
  //     final route = message['page'];
  //     if (isVerified()) {
  //       if (isLeader()||route!="구역공지") {
  //         Get.to(Bulletin(),
  //             transition: Transition.cupertino,
  //             arguments: [route, isAdmin()]);
  //       }
  //       else {
  //         _alertDialog("이 게시판은 구역장만 열람 가능합니다");
  //       }
  //     } else {
  //       _alertDialog("먼저 교인인증을 해주십시오");
  //     }
  //   }
  // }

  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();
    _firebaseMessaging.getToken().then((token) {
      print('token:' + token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message["notification"]["title"]),
              subtitle: Text(message["notification"]["body"]),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () => Get.back(),
              )
            ],
          ),
        );
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        if (message.containsKey('page')) {
          final route = message['page'];
          if (isVerified()) {
            if (isLeader() || route != "구역공지") {
              Get.to(Bulletin(),
                  transition: Transition.cupertino,
                  arguments: [route, isAdmin()]);
            } else {
              _alertDialog("이 게시판은 구역장만 열람 가능합니다");
            }
          } else {
            _alertDialog("먼저 교인인증을 해주십시오");
          }
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        if (message.containsKey('page')) {
          final route = message['page'];
          if (isVerified()) {
            if (isLeader() || route != "구역공지") {
              Get.to(Bulletin(),
                  transition: Transition.cupertino,
                  arguments: [route, isAdmin()]);
            } else {
              _alertDialog("이 게시판은 구역장만 열람 가능합니다");
            }
          } else {
            _alertDialog("먼저 교인인증을 해주십시오");
          }
        }
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  Future<String> profilePic() {
    if (user != null) {
      return FirebaseFirestore.instance
          .collection("profiles")
          .doc(user.displayName)
          .get()
          .then((doc) => doc['url']);
    } else {
      return FirebaseFirestore.instance
          .collection("profiles")
          .doc('손님')
          .get()
          .then((doc) => doc['url']);
    }
  }

  Drawer selectDrawer(String url) {
    print(user);
    if (user == null) {
      return Drawers().noAuthDrawer(url);
    } else {
      if (user.displayName == '관리자') {
        return Drawers().mainDrawer(user.displayName, url, true);
      } else {
        return Drawers().mainDrawer(user.displayName, url, false);
      }
    }
  }

  bool isAdmin() {
    if (user != null) {
      if (user.displayName == "관리자") {
        return true;
      }
    }
    return false;
  }

  bool isLeader() {
    if (user != null) {
      if (user.displayName == "관리자" || user.displayName == "구역장") {
        return true;
      }
    }
    return false;
  }

  bool isVerified() {
    if (user == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors
              .white60, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: FutureBuilder(
            future: profilePic(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData == false) {
                return CircularProgressIndicator();
              } else {
                return selectDrawer(snapshot.data.toString());
              }
            }),
      ),
      appBar: AppBar(
        toolbarHeight: 80,
        title:
            SizedBox(height: 55, child: Image.asset('assets/images/logo.png')),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: IconButton(
              icon: Icon(
                Icons.menu,
                color: theme_grey,
              ),
              iconSize: 28,
              onPressed: () => _scaffoldkey.currentState.openDrawer()),
        ),
        backgroundColor: theme_white,
        elevation: 0,
      ),
      backgroundColor: theme_white,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3, // card height
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('banners')
                  .where('active', isEqualTo: true)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data.docs;
                  return PageView.builder(
                    itemCount: documents.length,
                    controller: PageController(viewportFraction: 0.87),
                    onPageChanged: (int index) =>
                        setState(() => _index = index),
                    itemBuilder: (_, i) {
                      return Transform.scale(
                        scale: i == _index ? 1 : 0.93,
                        transformHitTests: false,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Card(
                            elevation: 6,
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                              child: Image.network(documents[i]['url'],
                                  width: 1000, height: 1000, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width, // card height
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                  // return Text("이미지를 불러오는 중입니다");
                }
              },
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.24,
            width: MediaQuery.of(context).size.width * 0.87,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                menuCard(
                    title: "교회소식",
                    titleEng: "News",
                    color: theme_blue,
                    route: "교회소식",
                    isVerified: isVerified()),
                menuCard(
                    title: "예배공지",
                    titleEng: "Worship Notice",
                    color: theme_beige,
                    route: "예배공지",
                    isVerified: isVerified()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.24,
              width: MediaQuery.of(context).size.width * 0.87,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  menuCard(
                      title: "구역공지",
                      titleEng: "District Notice",
                      color: theme_beige,
                      route: "구역공지",
                      isLeader: isLeader(),
                      isVerified: isVerified()),
                  menuCard(
                      title: "골방예배",
                      titleEng: "Individual Worship",
                      color: theme_beige,
                      route: "골방예배",
                      isVerified: isVerified())
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget menuCard({
    String title,
    String titleEng,
    Color color,
    String route,
    bool isLeader = true,
    bool isVerified,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.41,
      child: GestureDetector(
        onTap: () {
          if (isVerified) {
            if (isLeader) {
              Get.to(Bulletin(),
                  transition: Transition.cupertino,
                  arguments: [route, isAdmin()]);
            } else {
              _alertDialog("이 게시판은 구역장만 열람 가능합니다");
            }
          } else {
            _alertDialog("먼저 교인인증을 해주십시오");
          }
        },
        child: Card(
            shadowColor: color,
            elevation: 6,
            color: color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Stack(alignment: Alignment.bottomCenter, children: [
              Padding(
                padding: const EdgeInsets.only(right: 25, top: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      titleEng,
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 13, right: 10),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: const Offset(3.0, 3.0),
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                          ),
                        ]),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_forward,
                        color: theme_grey,
                      ),
                      onPressed: null,
                    ),
                  ),
                ),
              ]),
            ])),
      ),
    );
  }

  void _alertDialog(String content) {
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
              new Text("권한이 없습니다"),
            ],
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                content,
              ),
            ],
          ),
          actions: <Widget>[
            new TextButton(
              child: new Text("확인"),
              onPressed: () => Get.back(),
            ),
          ],
        );
      },
    );
  }
}
