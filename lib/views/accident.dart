import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import '../models/transaction.dart';
import '../models/userData.dart';
import '../viewmodels/homeViewModel.dart';

class Accident extends StatefulWidget {
  late final Transaction trans;
  BuildContext originalContext;
  Accident({super.key, required this.trans, required this.originalContext});

  @override
  State<Accident> createState() => _AccidentState();
}

class _AccidentState extends State<Accident> {
  List allPlaces = [];

  final uname = 'AC96b4506f501e53c0423b938c8cb5ac0c';
  final pword = '9a70b3d8f348e099f7c68ef08876f81e';

  final url = Uri.parse(
      'https://api.twilio.com/2010-04-01/Accounts/AC96b4506f501e53c0423b938c8cb5ac0c/Messages.json');

  late Map<MarkerId, Marker> markers;
  late gmaps.GoogleMapController mapController;

  void _onMapCreated(gmaps.GoogleMapController controller) {
    mapController = controller;
  }

  Future<http.Response> fetchAlbum(LatLng latlng) {
    return http.get(Uri.parse(
        'https://api.mapbox.com/v4/gorzal.clngp6f8r019j2aob4mj5en7l-653pw/tilequery/${latlng.longitude},${latlng.latitude}.json?limit=50&radius=10000&dedupe=true&access_token=pk.eyJ1IjoiZ29yemFsIiwiYSI6ImNsbmZrdmhsczBpamwybW41a2RpdWVmamwifQ.tN4dbRps4k4PG7tTh_CjWg&session_token=sk.eyJ1IjoiZ29yemFsIiwiYSI6ImNsbmc1dHFxbjEzaGYyam1udTFxZDhlcHIifQ.Uyah9f_J_xGauRaowRBNeQ&country=PH'));
  }

  Future<http.Response> fetchDetails(String name) {
    return http.get(Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${name}.json?proximity=ip&access_token=pk.eyJ1IjoiZ29yemFsIiwiYSI6ImNsbmZrdmhsczBpamwybW41a2RpdWVmamwifQ.tN4dbRps4k4PG7tTh_CjWg'));
  }

  Future<http.Response> fetchImage(LatLng coord) {
    return http.get(Uri.parse(
        'https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/${coord.longitude},${coord.latitude},18.14,10,1/300x200?access_token=pk.eyJ1IjoiZ29yemFsIiwiYSI6ImNsbmZrdmhsczBpamwybW41a2RpdWVmamwifQ.tN4dbRps4k4PG7tTh_CjWg'));
  }

// make sure to initialize before map loading

  void initState() {
    super.initState();

    markers = <MarkerId, Marker>{
      MarkerId("Rider"): Marker(
        markerId: MarkerId("Rider"),
        position: LatLng(widget.trans.location[0], widget.trans.location[1]),
        infoWindow: InfoWindow(
            title: "Rider ${widget.trans.userData!.nickname}",
            snippet: "Name: \n Relation:"),
        onTap: () async {},
      )
    };
    fetchAlbum(LatLng(widget.trans.location[0], widget.trans.location[1]))
        .then((r) {
      var dataRes = json.decode(r.body) as Map<String, dynamic>;

      List places = dataRes['features'] as List;
      setState(() {
        allPlaces = places;
      });
    });
  }

  void _add(LatLng coords, String name, String contactNumner) {
    final MarkerId markerId = MarkerId("hospitalID");

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: coords,
      infoWindow:
          InfoWindow(title: name, snippet: "Contact Number: ${contactNumner}"),
      onTap: () async {
        fetchDetails(name).then((value) {
          Map<String, dynamic> data =
              json.decode(value.body) as Map<String, dynamic>;

          List dataList = data["features"] as List;
          if (dataList.isNotEmpty) {
            print(dataList.first['properties']['address']);
          }
        });
      },
    );
    mapController.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(coords.latitude, coords.longitude), 20));

    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.white,
          child: Column(children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        child: Image.asset(
                            "assets/avatars/${widget.trans.userData!.userAvatar}"),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          color: Colors.black,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.trans.userData?.nickname.toUpperCase() ??
                                  "",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              widget.trans.userData?.contactNumber ?? "",
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                      ),
                      Visibility(
                          visible:
                              widget.trans.userData?.nickname.toUpperCase() !=
                                  widget.originalContext
                                      .read<UserData>()
                                      .nickname
                                      .toUpperCase(),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 56, 56, 56),
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0),
                                  ),
                                ),
                                onPressed: () {
                                  final Uri launchUri = Uri(
                                    scheme: 'tel',
                                    path: widget.trans.userData!.contactNumber,
                                  );
                                  UrlLauncher.launchUrl(launchUri);
                                },
                                child: Text("Call",
                                    style: TextStyle(color: Colors.white))),
                          ))
                    ],
                  )),
            ),
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: gmaps.GoogleMap(
                    markers: Set<Marker>.of(markers.values),
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: gmaps.CameraPosition(
                      target: LatLng(
                          widget.trans.location[0], widget.trans.location[1]),
                      zoom: 14,
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.trans.userData?.nickname.toUpperCase() ==
                      widget.originalContext
                          .read<UserData>()
                          .nickname
                          .toUpperCase(),
                  child: Positioned(
                    left: (MediaQuery.of(context).size.width / 2) -
                        (MediaQuery.of(context).size.width * 0.25),
                    top: 20,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 56, 56, 56),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () async {
                          if (widget.originalContext
                                      .read<UserData>()
                                      .relatives !=
                                  null &&
                              widget.originalContext
                                  .read<UserData>()
                                  .relatives!
                                  .isNotEmpty) {
                            List<UserData>? rel = widget.originalContext
                                .read<UserData>()
                                .relatives;
                            final authn =
                                'Basic ${base64Encode(utf8.encode('$uname:$pword'))}';

                            final headers = {
                              'Content-Type':
                                  'application/x-www-form-urlencoded',
                              'Authorization': authn,
                            };
                            List<String> numbers = [];

                            rel!.forEach((element) {
                              if (element.contactNumber != null &&
                                  element.contactNumber != "") {
                                numbers.add(element.contactNumber!
                                    .replaceFirst(RegExp(r'0'), '+63'));
                              }
                            });
                            final data = {
                              'To': numbers.join(","),
                              'From': '+12295751207',
                              'Body':
                                  "THE RIDER ${widget.trans.userData!.nickname.toUpperCase()} MARKED THE ALARM AS FALSE ALARM",
                            };
                            final res = await http.post(url,
                                headers: headers, body: data);
                            final status = res.statusCode;
                            if (status != 201)
                              throw Exception(
                                  'http.post error: statusCode= $status');
                          }

                          // final data = {
                          //   //'To': numbers.join(","),
                          //   'To': "",
                          //   'From': '+12295751207',
                          //   'Body':
                          //       "THE RIDER ${widget.trans.userData!.nickname.toUpperCase()} MARKED THE ALARM AS FALSE ALARM",
                          // };
                          // final res = await http.post(url,
                          //     headers: headers, body: data);
                          // final status = res.statusCode;
                          // if (status != 201)
                          //   throw Exception(
                          //       'http.post error: statusCode= $status');

                          Provider.of<HomeViewModel>(widget.originalContext,
                                  listen: false)
                              .taggedAsFalseAlarm(widget.trans);
                          Navigator.of(context).pop();
                        },
                        child: Text("Marked as false alarm",
                            style: TextStyle(color: Colors.white))),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Text("List of nearest police stations and hospitals",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.18,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: allPlaces.map((e) {
                    Map<String, dynamic> map = e as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        _add(
                            new LatLng(e['geometry']['coordinates'][1],
                                e['geometry']['coordinates'][0]),
                            map['properties']['name'] ?? "",
                            map['properties']['contact_num'] ?? "");
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              color: Colors.white,
                              child: Column(children: [
                                Text(
                                  map['properties']['name'] ?? "",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 56, 56, 56),
                                      shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(30.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      final Uri launchUri = Uri(
                                        scheme: 'tel',
                                        path: map['properties']
                                                ['contact_num'] ??
                                            "911",
                                      );
                                      UrlLauncher.launchUrl(launchUri);
                                    },
                                    child: Text("Call",
                                        style: TextStyle(color: Colors.white))),
                              ]),
                            ),
                          ],
                        ),
                        width: 200,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 217, 217, 217),
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                                image: NetworkImage(
                              'https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v12/static/${e['geometry']['coordinates'][0]},${e['geometry']['coordinates'][1]},17.85,0/200x200?access_token=pk.eyJ1IjoiZ29yemFsIiwiYSI6ImNsbmZrdmhsczBpamwybW41a2RpdWVmamwifQ.tN4dbRps4k4PG7tTh_CjWg',
                            ))),
                        height: 200,
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
