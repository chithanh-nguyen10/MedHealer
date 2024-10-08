// ignore_for_file: unused_field
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:tinyhealer/components/my_button.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:tinyhealer/global.dart' as globals;
import 'package:tinyhealer/pages/functional_pages/display_hospital.dart';
import 'package:tinyhealer/pages/functional_pages/loading_page.dart';
import 'dart:math' show cos, sqrt, asin;

class FindHospital extends StatefulWidget {
  final List<String> result;
  FindHospital({super.key, required this.result});

  @override
  _FindHospitalState createState() => _FindHospitalState();
}

double _coordinateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

class _FindHospitalState extends State<FindHospital> with TickerProviderStateMixin{
  late Position _currentPosition;
  String _currentAddress = "";
  late PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  double distance = 0.0;
  late RouteInfo result;
  late TabController _tabController;

  List<List<bool>> checkboxValuesList = [];
  List<String> tabList = [];
  List<List<String>> checkListData = [];
  List<List<String>> checklistItemsList = [];
  List<List<String>> idData = [];
  Map<String, int> mp = {};

  int checknum = 0;
  List<String> checkedData = [];
  List<String> typesList = [];

  List<HospitalInfo> searchResult = [];
  List<RouteInfo> routeResult = [];

  String city = "";

  bool ready = false;
  bool isSearch = false;

  @override
  void initState() {
    super.initState();

    

    fetchNames().then((_){
      checklistItemsList = checkListData;
      _tabController = TabController(length: checklistItemsList.length, vsync: this);
      checkboxValuesList = List.generate(
        checklistItemsList.length,
        (outerIndex) => List.generate(
          checklistItemsList[outerIndex].length,
          (innerIndex) => false,
        ),
      );
      setState(() {
        _getCurrentLocation().then((_) async{
          List<Placemark> p = await placemarkFromCoordinates(
            _currentPosition.latitude, _currentPosition.longitude);
          Placemark place = p[0];
          city = place.administrativeArea.toString();
          print(city);
          setState(() {
            ready = true;
          });
        });
        
        if (widget.result[0] != "null"){
          typesList.clear();
          Set<String> typeSets = {};
          for (int i = 0; i < widget.result.length; ++i){
            if (widget.result[i].startsWith("in")) typeSets.add("in");
            else if (widget.result[i].startsWith("out")) typeSets.add("out");
          }
          typesList = typeSets.toList();
          
          ready = false;
          searchHospitals();
        }
      });
    });
  }

  Future<void> fetchNames() async {
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('health-problems');
    QuerySnapshot querySnapshot = await collectionReference.get();

    int index = 0;
    // ignore: unused_local_variable
    final List<List<String>> names = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      String id = data['id'] as String;
      String name = data['name'] as String;
      String type = id.substring(0, ffnci(id));
      if (mp[type] == null){
        mp[type] = index;
        index++;
        checkListData.add([]);
        idData.add([]);
        tabList.add(globals.healthTypes[type]!);
      }
      checkListData[mp[type]!].add(toTitle(name));
      idData[mp[type]!].add(id);
      return [id, name];
    }).toList();
  }

  int ffnci(String str) {
    for (int i = 0; i < str.length; i++) {
      if (isDigit(str[i])) {
        return i;
      }
    }
    return -1;
  }

  bool isDigit(String character) {
    return RegExp(r'^[0-9]$').hasMatch(character);
  }

  String toTitle(String text) {
    if (text.isEmpty) {
      return '';
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  void readData(){
    checknum = 0;
    checkedData = [];
    typesList.clear();

    Set<String> typeSets = {};
    for (int i = 0;i<checkListData.length;++i){
      for (int j = 0;j<checkListData[i].length;++j){
        if (checkboxValuesList[i][j] == true){
          ++checknum;checkedData.add(idData[i][j]);
          if(i == 0) typeSets.add("in");
          else if(i == 1) typeSets.add("out");
        }
      }
    }
    typesList = typeSets.toList();
    // print(checkedData);
  }

  void searchHospitals() {
    _getCurrentLocation().then((_) async {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent user from dismissing the dialog
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await _firestore
        .collection('hospitals')
        .get();
      List<DocumentSnapshot> documents = querySnapshot.docs;
      searchResult.clear();

      for (int i = 0; i < documents.length; ++i) {
        var data = documents[i].data() as Map<String, dynamic>;
        List<String> skills = data["skills"].split(",");
        if (checkSubList(typesList, skills)){
          HospitalInfo newItem = HospitalInfo(
            data["name"],
            data["type"],
            data["addr"],
            data["rank"],
            data["rating"],
            data["lat"],
            data["lon"],
            skills,
            data["website"],
          );
          searchResult.add(newItem);
          
        }
      }
      searchResult.sort(compare);
      print(searchResult);
      searchResult = searchResult.sublist(0, 25);
      routeResult.clear();
      print(searchResult);
      List<Map<String, double>> destinations = [];
      for (int i = 0; i < searchResult.length;++i){
        destinations.add({"lat": searchResult[i].lat, "lon": searchResult[i].lon});
      }

      var apiKey = 'AIzaSyAzHaeKsHTM0NCxTe1KLFo7l4bPppra6tM';
      var url = 'https://maps.googleapis.com/maps/api/distancematrix/json?';

      url += 'origins=${_currentPosition.latitude},${_currentPosition.longitude}';

      var destinationParams = '';
      destinations.forEach((dest) {
        destinationParams += '${dest['lat']},${dest['lon']}|';
      });
      destinationParams = destinationParams.substring(0, destinationParams.length - 1);
      url += "&destinations=";
      url += destinationParams;
      print(destinationParams);
      url += '&mode=driving';
      url += '&language=vi';
      url += '&key=$apiKey';

      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        for (var v in data["rows"][0]["elements"]){
          double distance = 1.0*v["distance"]["value"]/1000;
          distance = double.parse(distance.toStringAsFixed(1));
          double duration = 1.0*v["duration"]["value"]/60;
          duration = double.parse(distance.toStringAsFixed(0));
          print(duration);
          routeResult.add(RouteInfo(distance, duration));
        }
      } else {
        print('Error: ${response.reasonPhrase}');
      }
      Navigator.pop(context);
      setState(() {
        ready = true;
        isSearch = true;
      });
    });
  }

  void searchHospitalsHN() {
    _getCurrentLocation().then((_) async {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent user from dismissing the dialog
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await _firestore
        .collection('hospitals-hn')
        .get();
      List<DocumentSnapshot> documents = querySnapshot.docs;
      searchResult.clear();

      for (int i = 0; i < documents.length; ++i) {
        var data = documents[i].data() as Map<String, dynamic>;
        List<String> skills = data["skills"].split(",");
        if (checkSubList(typesList, skills)){
          HospitalInfo newItem = HospitalInfo(
            data["name"],
            data["type"],
            data["addr"],
            data["rank"],
            data["rating"],
            data["lat"],
            data["lon"],
            skills,
            data["website"],
          );
          searchResult.add(newItem);
          
        }
      }
      searchResult.sort(compare);
      print(searchResult);
      searchResult = searchResult.sublist(0, 25);
      routeResult.clear();
      print(searchResult);
      List<Map<String, double>> destinations = [];
      for (int i = 0; i < searchResult.length;++i){
        destinations.add({"lat": searchResult[i].lat, "lon": searchResult[i].lon});
      }

      var apiKey = 'AIzaSyAzHaeKsHTM0NCxTe1KLFo7l4bPppra6tM';
      var url = 'https://maps.googleapis.com/maps/api/distancematrix/json?';

      url += 'origins=${_currentPosition.latitude},${_currentPosition.longitude}';

      var destinationParams = '';
      destinations.forEach((dest) {
        destinationParams += '${dest['lat']},${dest['lon']}|';
      });
      destinationParams = destinationParams.substring(0, destinationParams.length - 1);
      url += "&destinations=";
      url += destinationParams;
      print(destinationParams);
      url += '&mode=driving';
      url += '&language=vi';
      url += '&key=$apiKey';

      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        for (var v in data["rows"][0]["elements"]){
          double distance = 1.0*v["distance"]["value"]/1000;
          distance = double.parse(distance.toStringAsFixed(1));
          double duration = 1.0*v["duration"]["value"]/60;
          duration = double.parse(distance.toStringAsFixed(0));
          print(duration);
          routeResult.add(RouteInfo(distance, duration));
        }
      } else {
        print('Error: ${response.reasonPhrase}');
      }
      Navigator.pop(context);
      setState(() {
        ready = true;
        isSearch = true;
      });
    });
  }
  

  int compare(HospitalInfo a, HospitalInfo b){
    const double ESP = 0.8;

    double dista = _coordinateDistance(
      a.lat,
      a.lon,
      _currentPosition.latitude, _currentPosition.longitude
    );
    double distb = _coordinateDistance(
      b.lat,
      b.lon,
     _currentPosition.latitude, _currentPosition.longitude
    );

    if (dista + ESP < distb) return -1;
    else if (dista - ESP > distb) return 1;

    int ranka = a.rank;
    int rankb = b.rank;
    if (ranka == -1) ranka = 4;
    if (rankb == -1) rankb = 4;
    return ranka.compareTo(rankb);
  }

  bool checkSubList(List<String> a, List<String> b){
    for (String v in a){
      if (!b.contains(v)) return false;
    }
    return true;
  }

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
        _currentPosition = position;
        print(_currentPosition);
    }).catchError((e) {
      print(e);
    });
  }

  void showMessage(String mess){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 20, 80, 139),
          title: Center(
            child: Text(
              mess,
              style: const TextStyle(color: Colors.white, fontSize: 18)
            )
          )
        );
      }
    );
  }

  void toggleCheckbox(int tabIndex, int itemIndex, bool value) {
    setState(() {
      checkboxValuesList[tabIndex][itemIndex] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;

    if (!ready) return LoadingPage();
    else if (!isSearch) {return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        
        Center(
          child: Text(
            "Chọn các bệnh mà bạn (có thể) đang mắc phải",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/600)  : 22,
              fontFamily: "Roboto",
            ),
            textAlign: TextAlign.center,
          )
        ),

        Container(
        child: Align(
          alignment: Alignment.centerLeft,
          child: TabBar(
            controller: _tabController,
            labelStyle: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1800)  : 17),
            isScrollable: true,
            tabs: List.generate(
              checklistItemsList.length,
              (index) => Tab(text: tabList[index]),
            ),
          ),
          ),
        ),

        Expanded(child:Container(
          width: double.maxFinite,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBarView(
              controller: _tabController,
              children: List.generate(
                checklistItemsList.length,
                (tabIndex) => ListView.builder(
                  itemCount: checklistItemsList[tabIndex].length,
                  itemBuilder: (context, itemIndex) {
                    return CheckboxListTile(
                      value: checkboxValuesList[tabIndex][itemIndex],
                      onChanged: (value) {
                        toggleCheckbox(tabIndex, itemIndex, value ?? false);
                      },
                      title: Text(
                        checklistItemsList[tabIndex][itemIndex],
                        style: TextStyle(fontSize: currentWidth >= 600 ? 17 + 17 * ((currentWidth - 600)/1000)  : 17),
                        softWrap: true,
                      ),
                    );
                  },
                ),
              )
              
            ),
            ),
          )),
        
        Padding(
          padding: EdgeInsets.only(bottom: 10, top: 15),
          child: MyButton(
            text: "Tìm kiếm bênh viện phù hợp",
            onTap: (){
              readData();
              if (checknum == 0) showMessage("Bạn chưa chọn bệnh!");
              else if (checknum > 10) showMessage("Bạn chỉ được chọn tối đa 10 bệnh");
              else{
                if (city == "Ho Chi Minh City") searchHospitals();
                else if (city == "Ha Noi") searchHospitalsHN();
                else searchHospitals();
              }
            },
          )
        )
      ]
    );} else if (isSearch) return DisplayHospital(
      searchResult: searchResult.reversed.toList(),
      routeResult: routeResult.toList(),
      currlat: _currentPosition.latitude,
      currlon: _currentPosition.longitude
    );
    else return LoadingPage();
  }

}

class RouteInfo{
  double distance, time;

  RouteInfo(this.distance, this.time);
}

class HospitalInfo{
  String name, type, address;
  int rank;
  double rating;
  double lat, lon;
  List<String> skills;
  String website;

  HospitalInfo(
    this.name,
    this.type,
    this.address,
    this.rank,
    this.rating,
    this.lat,
    this.lon,
    this.skills,
    this.website
  );

  @override
  String toString() {
    return name;
    // return _coordinateDistance(lat, lon, 10.712246374400461, 106.64551431534352).toString() + " " + rank.toString();
  }
}