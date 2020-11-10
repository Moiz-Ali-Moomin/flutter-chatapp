import 'package:chatapp/services/functions.dart';
import 'package:chatapp/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class Chat extends StatefulWidget {
  final String chatRoomId;

  Chat({this.chatRoomId});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data.documents[index].data["message"],
                    sendByMe: Constants.myName ==
                        snapshot.data.documents[index].data["sendBy"],
                  );
                })
            : Container();
      },
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "message": messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  TextStyle simpleTextStyle() {
    return TextStyle(color: Colors.white, fontSize: 20);
  }

  TextStyle biggerTextStyle() {
    return TextStyle(color: Colors.white, fontSize: 21);
  }

  @override
  void initState() {
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var addresses;
    var first;

    Future<Map<String, String>> _getPlaceMark(Position position) async {
      final CameraPosition _myLocation = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
      );
      final coordinates =
          new Coordinates(position.latitude, position.longitude);
      addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      first = addresses.first;
      return {
        'featureName': first.featureName,
        'countryName': first.countryName,
        'postalCode': first.postalCode,
        'state': first.adminArea,
        'district': first.subAdminArea
      };
    }

    void showToast(message) {
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    _address() async {
      Position position = await Geolocator().getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          locationPermissionLevel: GeolocationPermission.location);
      Future<Map<String, String>> placeMark = _getPlaceMark(position);
      String featureName;
      String countryName;
      String postalCode;
      String state;
      String district;
      await placeMark.then((value) => {
            featureName = value['featureName'],
            countryName = value['countryName'],
            postalCode = value['postalCode'],
            state = value['state'],
            district = value['district'],
          });
      Navigator.pushNamed(context, 'addressPage', arguments: {
        'location': position,
        'featureName': featureName,
        'countryName': countryName,
        'postalCode': postalCode,
        'state': state,
        'district': district,
      });
    }

    Future<void> getLocation() async {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.location);

      if (permission == PermissionStatus.denied) {
        await PermissionHandler()
            .requestPermissions([PermissionGroup.locationAlways]);
      }

      var geolocator = Geolocator();

      GeolocationStatus geolocationStatus =
          await geolocator.checkGeolocationPermissionStatus();

      switch (geolocationStatus) {
        case GeolocationStatus.denied:
          showToast('denied');
          break;
        case GeolocationStatus.disabled:
          showToast('disabled');
          break;
        case GeolocationStatus.restricted:
          showToast('restricted');
          break;
        case GeolocationStatus.unknown:
          showToast('unknown');
          break;
        case GeolocationStatus.granted:
          showToast('Access granted');
          _address();
      }
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
              onTap: () {
                getLocation();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.location_history),
              ))
        ],
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.all(20),
                color: Colors.black45,
                child: Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                      controller: messageEditingController,
                      style: simpleTextStyle(),
                      decoration: InputDecoration(
                          hintText: "Message ...",
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          border: InputBorder.none),
                    )),
                    SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        addMessage();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    const Color(0x36FFFFFF),
                                    Colors.black45
                                  ],
                                  begin: FractionalOffset.topLeft,
                                  end: FractionalOffset.bottomRight),
                              borderRadius: BorderRadius.circular(40)),
                          padding: EdgeInsets.all(12),
                          child: Image.asset(
                            "assets/images/Send-512.png",
                            height: 28,
                            width: 28,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;

  MessageTile({@required this.message, @required this.sendByMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
            sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: sendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23),
                    bottomRight: Radius.circular(23))
                : BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23),
                    bottomRight: Radius.circular(23)),
            gradient: LinearGradient(
              colors: sendByMe
                  ? [Colors.indigo[600], const Color(0xff2A75BC)]
                  : [Colors.black26, Colors.grey],
            )),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300)),
      ),
    );
  }
}
