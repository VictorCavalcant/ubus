import 'package:flutter/material.dart';

class NearStops extends StatelessWidget {
  const NearStops(this.hideNS);

  final Function() hideNS;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("OPA EAE"),
        TextButton(
          onPressed: hideNS,
          child: Text(
            'VOLTAR',
            style: TextStyle(color: Colors.white),
          ),
        )
      ],
    ));
  }
}
