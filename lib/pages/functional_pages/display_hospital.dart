import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tinyhealer/components/circle_button.dart';
import 'package:tinyhealer/pages/functional_pages/find_hospital.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

// ignore: must_be_immutable
class DisplayHospital extends StatefulWidget {
  final List<HospitalInfo> searchResult;
  final List<RouteInfo> routeResult;
  double currlat, currlon;
  DisplayHospital({
    super.key,
    required this.searchResult,
    required this.routeResult,
    required this.currlat,
    required this.currlon,
  });

  @override
  _DisplayHospitalState createState() => _DisplayHospitalState();
}

class _DisplayHospitalState extends State<DisplayHospital> {
  late bool isEnough;

  @override
  void initState() {
    super.initState();
    // Navigator.pop(context);x
    isEnough = widget.searchResult.length == widget.routeResult.length;
    print(isEnough);
  }

  List<int> rate2star(double rating) {
    List<int> res = [0, 0, 0, 0, 0];
    for (int i = 0; i < 5; ++i) {
      if (rating > i + 1) res[i] = 1;
      else if ((i + 1) - rating < 1) res[i] = -1;
      else res[i] = 0;
    }
    return res;
  }

  void launchMapsDirections(double startLatitude, double startLongitude, double endLatitude, double endLongitude) async {
    if (Platform.isIOS) {
      launchAppleMapsDirections(startLatitude, startLongitude, endLatitude, endLongitude);
    } else if (Platform.isAndroid) {
      launchGoogleMapsDirections(startLatitude, startLongitude, endLatitude, endLongitude);
    } else {
      throw 'Unsupported platform';
    }
  }

  void launchGoogleMapsDirections(double startLatitude, double startLongitude, double endLatitude, double endLongitude) async {
    Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=$startLatitude,$startLongitude&destination=$endLatitude,$endLongitude&travelmode=driving');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  void launchAppleMapsDirections(double startLatitude, double startLongitude, double endLatitude, double endLongitude) async {
    Uri appleMapsUrl = Uri.parse('https://maps.apple.com/?saddr=$startLatitude,$startLongitude&daddr=$endLatitude,$endLongitude');
    if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl);
    } else {
      throw 'Could not launch $appleMapsUrl';
    }
  }

  String rank2text(int rank) {
    if (rank == 1) return "Hạng I";
    else if (rank == 2) return "Hạng II";
    else if (rank == 3) return "Hạng III";
    else return "";
  }

  Image toStar(int value) {
    String path;
    if (value == 1) path = "lib/images/fullstar.png";
    else if (value == -1) path = "lib/images/halfstar.png";
    else path = "lib/images/grey_star.png";

    return Image.asset(
      path,
      height: 16,
    );
  }

  String rcr(String text) {
    int lastCommaIndex = text.lastIndexOf(',');

    String truncatedText = text.substring(0, lastCommaIndex);
    int secondCommaIndex = truncatedText.lastIndexOf(',');
    truncatedText = text.substring(0, secondCommaIndex);

    return truncatedText;
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        const SizedBox(height: 10),
        Center(
          child: Text(
            "Bạn có thể đến khám ở một trong những bệnh viện sau đây",
            style: TextStyle(
              fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/600)  : 22,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
          )
        ),
        const SizedBox(height: 5),
        Expanded(
          child: ListView.builder(
          itemCount: widget.searchResult.length,
          itemBuilder: (context, index) {
            final hospital = widget.searchResult[index];
            RouteInfo route = RouteInfo(-1, -1);
            if (isEnough) route = widget.routeResult[index];
            List<int> star = rate2star(hospital.rating);

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Container(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    hospital.name,
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontFamily: "Google Sans",
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: [
                                Text(
                                  hospital.rating.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xff70757a),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                toStar(star[0]),
                                toStar(star[1]),
                                toStar(star[2]),
                                toStar(star[3]),
                                toStar(star[4]),
                                const SizedBox(width: 5),
                                Text(
                                  rank2text(hospital.rank),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xff70757a),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: [
                                Text(
                                  hospital.type,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xff70757a),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Color(0xff1a73e7),
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    rcr(hospital.address),
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
                          if (isEnough) Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: [
                                Text(
                                  route.distance.toString() + " km",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff70757a),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    CircleButton(
                      onTap: () {
                        launchMapsDirections(
                          widget.currlat,
                          widget.currlon,
                          hospital.lat,
                          hospital.lon
                        );
                      },
                      icon: Icons.directions,
                      text: "Đường đi",
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                if (index != widget.searchResult.length - 1)
                  const Divider(),
              ],
            );
          },
        ))
      ]
    );
  }
}
