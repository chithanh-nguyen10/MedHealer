import 'package:flutter/material.dart';
import 'package:tinyhealer/components/my_button.dart';
import 'package:tinyhealer/global.dart' as globals;

class DisplayDiagnostic extends StatefulWidget {
  final List<dynamic> results;
  final Function()? onTap;
  final Function(List<String>)? searchMap;
  DisplayDiagnostic({super.key, required this.results, required this.onTap, required this.searchMap});

  @override
  _DisplayDiagnosticState createState() => _DisplayDiagnosticState();
}

class _DisplayDiagnosticState extends State<DisplayDiagnostic> {
  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(height: 15),
        Text(
          "Bạn có thể đã bị các bệnh sau",
          style: TextStyle(fontSize: currentWidth >= 600 ? 22 + 22 * ((currentWidth - 600)/600)  : 22, fontWeight: FontWeight.bold),
          softWrap: true,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 25.0, top: 5.0),
          child: SingleChildScrollView(
            child: Column(
              children: widget.results.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('- ', style: TextStyle(fontSize: currentWidth >= 600 ? 18 + 18 * ((currentWidth - 600)/600)  : 18)),
                      Expanded(
                        child: Text(
                          // item,
                          globals.healthMatch[item]!,
                          style: TextStyle(fontSize: currentWidth >= 600 ? 18 + 18 * ((currentWidth - 600)/600)  : 18),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.0),
          child: Text(
            '*Lưu ý: Kết quả của TinyHealer chỉ mang tính chất tham khảo, bạn nên hỏi ý kiến của các chuyên gia y khoa để có kết quả chính xác hơn!',
            style: TextStyle(color: Color(0xff6a6a6a), fontSize: currentWidth >= 600 ? 15 + 15 * ((currentWidth - 600)/350)  : 15),
            softWrap: true,
            overflow: TextOverflow.visible,
          )
        ),

        Padding(
          padding: EdgeInsets.only(bottom: 10, top: 15),
          child: MyButton(
            text: "Tìm bệnh viện phù hợp",
            onTap: () {
              List<String> stringRes = [];
              for (int i = 0; i < widget.results.length; i++) {
                stringRes.add(widget.results[i]);
              };
              print(stringRes);
              widget.searchMap!(stringRes);
            },
          )
        ),

        Expanded(child: Container(),),

        Padding(
          padding: EdgeInsets.only(bottom: 10, top: 15),
          child: MyButton(
            text: "Quay về trang chủ",
            onTap: widget.onTap,
          )
        )
      ]
    );
  }
}