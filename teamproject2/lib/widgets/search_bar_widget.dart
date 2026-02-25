import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final List<Map<String, dynamic>> locations; 
  final Function(Map<String, dynamic>) onSelected;

  const SearchBarWidget({
    Key? key, 
    required this.locations, 
    required this.onSelected
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2)
          ],
        ),
        child: Autocomplete<Map<String, dynamic>>(
          displayStringForOption: (option) => option['name'],
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Map<String, dynamic>>.empty();
            }
            return locations.where((element) => element['name']
                .toString()
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (option) {
            FocusScope.of(context).unfocus();
            onSelected(option);
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: 'ค้นหาอุโมงค์',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            );
          },
        ),
      ),
    );
  }
}