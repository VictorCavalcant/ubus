import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'package:ubus/misc/consts.dart';
import 'package:ubus/providers/StopProvider.dart';

class StopInfoButton extends StatelessWidget {
  StopInfoButton({this.title, this.icon, this.image, this.function});

  String? title;
  Function()? function;
  IconData? icon;
  String? image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          child: ClipOval(
            child: Material(
              color: primaryColor, // Button color
              child: InkWell(
                onTap: () {
                  function!();
                },
                child: SizedBox(
                    width: 56,
                    height: 56,
                    child: image != null
                        ? Image.asset(image!)
                        : Icon(
                            icon,
                            color: Colors.white,
                            size: 30,
                          )),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          title != null ? title! : '',
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        )
      ],
    );
  }
}
