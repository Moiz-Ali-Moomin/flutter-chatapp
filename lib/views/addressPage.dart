import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, Object> data = {};
  Future<Map<String, String>> place;
  Position position;
  String featureName;
  String countryName;
  String postalCode;
  String state;
  String district;

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context).settings.arguments;
    position = data['location'];
    featureName = data['featureName'];
    postalCode = data['postalCode'];
    district = data['district'];
    state = data['state'];
    countryName = data['countryName'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Address'),
        backgroundColor: Colors.indigo[500],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 300,
                  ),
                  Icon(
                    Icons.location_on,
                    size: 20,
                  ),
                  Center(
                    child: Text('$postalCode, $district, $state',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  RaisedButton(
                    child: Text('Show on map',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pushNamed(context, 'map',
                          arguments: {'location': position});
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
