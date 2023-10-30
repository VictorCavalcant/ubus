import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget {
  const SearchInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 96),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Que ônibus deseja encontrar?',
          hintStyle: const TextStyle(fontWeight: FontWeight.bold),
          fillColor: const Color(0xFFD7D7D7),
          suffixIconColor: const Color.fromARGB(189, 51, 51, 51),
          suffixIcon: const Icon(
            Icons.search,
            size: 40,
          ),
          border: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFD7D7D7)),
              borderRadius: BorderRadius.circular(25)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFD7D7D7)),
              borderRadius: BorderRadius.circular(25)),
        ),
      ),
    );
  }
}
