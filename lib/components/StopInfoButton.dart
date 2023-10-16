import 'package:flutter/material.dart';
import 'package:ubus/misc/consts.dart';

class StopInfoButton extends StatelessWidget {
  StopInfoButton({this.title, this.function, this.icon, this.image});

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
                onTap: function != null ? function : () {},
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
