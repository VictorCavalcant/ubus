import 'package:flutter/material.dart';
import 'package:ubus/misc/consts.dart';

class StopInfoButton extends StatefulWidget {
  StopInfoButton({this.title, this.icon, this.image, this.function});

  String? title;
  Function()? function;
  IconData? icon;
  String? image;

  @override
  State<StopInfoButton> createState() => _StopInfoButtonState();
}

class _StopInfoButtonState extends State<StopInfoButton> {
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
                  widget.function!();
                },
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: widget.image != null
                      ? Image.asset(widget.image!)
                      : Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 30,
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.title != null ? widget.title! : '',
          style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        )
      ],
    );
  }
}
