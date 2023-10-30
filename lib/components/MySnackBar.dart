import "package:flutter/material.dart";

showSnackBar(
    {required BuildContext context,
    required String text,
    bool isError = true}) {
  SnackBar snackBar = SnackBar(
    content: Text(
      text,
      style:const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    backgroundColor:
        !isError ? Colors.green : const Color.fromARGB(255, 255, 17, 0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
    ),
    duration: const Duration(seconds: 5),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
