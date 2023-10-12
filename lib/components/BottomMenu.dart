import 'package:flutter/material.dart';
import 'package:ubus/components/BottomMain.dart';
import 'package:ubus/components/NearStops.dart';

class BottomMenu extends StatelessWidget {
  const BottomMenu(
    this.NP_visible,this.showNS, this.hideNS
  );

  final bool NP_visible;
  final Function() showNS;
  final Function() hideNS;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      padding: EdgeInsets.all(6),
      color: Color(0xFF0057DA),
      child: Center(
        child: NP_visible ? NearStops(hideNS) : MainMenu(showNS),
      ),
    );
  }
}
