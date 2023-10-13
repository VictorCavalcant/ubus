import 'package:flutter/material.dart';

class HomePageButton extends StatelessWidget {
  const HomePageButton(this.title, this.image_path, this.function);

  final String title;
  final String image_path;
  final Function() function;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(70))),
        onPressed: function,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              image_path,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.clip,
            ),
          ],
        ),
      ),
    );
  }
}
