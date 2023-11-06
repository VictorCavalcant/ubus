import 'package:flutter/material.dart';
import 'package:ubus/misc/consts.dart';

class HomePageButton extends StatelessWidget {
  const HomePageButton(this.title, this.icon, this.function);

  final String title;
  final IconData icon;
  final Function() function;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width / 2.5,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.fromLTRB(5, 8, 8, 8)),
        onPressed: function,
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
