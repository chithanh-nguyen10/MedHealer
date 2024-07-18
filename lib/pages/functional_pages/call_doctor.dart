import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tinyhealer/components/circle_button.dart';
import 'package:tinyhealer/pages/functional_pages/loading_page.dart';
import 'package:url_launcher/url_launcher.dart';

class CallDoctor extends StatefulWidget {
  @override
  _CallDoctorState createState() => _CallDoctorState();
}

class _CallDoctorState extends State<CallDoctor> {
  bool ready = false;
  List<DoctorInfo> doctorList = [];

  @override
  void initState() {
    super.initState();
    fetchNames().then((_) {
      print(doctorList);
      setState(() {
        ready = true;
      });
    });
  }

  Future<void> fetchNames() async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('doctors');
    QuerySnapshot querySnapshot = await collectionReference.get();

    // ignore: unused_local_variable
    final List<List<String>> names = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      String name = data["name"];
      // print(name);
      String type = data["type"];
      String work_place = data["work-place"];
      String phone = data["phone"];
      String award = data["award"];
      String position = data["position"];
      String image = data["image"];
      DoctorInfo newData = DoctorInfo(name, type, work_place, phone, award, position, image);
      doctorList.add(newData);

      return ["a", "a"];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (ready)
      return Column(
        children: [
          const SizedBox(height: 5),
          Expanded(
              child: ListView.builder(
                  itemCount: doctorList.length,
                  itemBuilder: (context, index) {
                    DoctorInfo current = doctorList[index];
                    return Column(children: [
                      Row(children: [
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.black,
                          child: CircleAvatar(
                            radius: 53.5,
                            backgroundImage: NetworkImage(
                              current.image,)
                          )
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                current.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontFamily: "Google Sans",
                                ),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                              Text(
                                current.type,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff70757a),
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "Đơn vị công tác: " +
                                            current.work_place,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff70757a),
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "Chức vụ: " + current.position,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff70757a),
                                ),
                              ),
                              if (current.award != "") Text(
                                "Danh hiệu: " + current.award,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff70757a),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleButton(
                            onTap: () async {
                              final Uri telLaunchUri = Uri(
                                scheme: 'tel',
                                path: current.phone,
                                );
                              await launchUrl(telLaunchUri);
                            },
                            icon: Icons.call,
                            text: ""
                          ),
                          const SizedBox(width: 10),
                          CircleButton(
                            onTap: () {
                              final Uri smssLaunchUri = Uri(
                                scheme: 'sms',
                                path: current.phone,
                                );
                              launchUrl(smssLaunchUri);
                            },
                            icon: Icons.message,
                            text: ""
                          )
                        ],
                      ),
                      Divider()
                    ]);
                  }))
        ],
      );
    else
      return LoadingPage();
  }
}

class DoctorInfo {
  String name, type, work_place, phone, award, position, image;

  DoctorInfo(this.name, this.type, this.work_place, this.phone, this.award, this.position, this.image);

  @override
  String toString() {
    return "name: $name, type: $type, work_place: $work_place, phone: $phone, award: $award";
  }
}
