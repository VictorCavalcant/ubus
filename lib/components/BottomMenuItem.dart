import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  const MenuItem(this.title, this.image, this.function);

  final String title;

  final Function() function;

  final String image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            image,
            width: 70,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
