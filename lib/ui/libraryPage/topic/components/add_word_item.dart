import 'package:flutter/material.dart';
import 'package:orange_card/resources/models/word.dart';
import 'package:orange_card/constants/constants.dart';

class AddWordItem extends StatefulWidget {
  final void Function() onDelete; // Specify function type directly
  final Word word;
  final Function(Word) onUpdateWord;
  final int number;
  const AddWordItem({
    super.key, // Fix the syntax for specifying the key
    required this.word,
    required this.onDelete,
    required this.onUpdateWord,
    required this.number,
  }); // Fix the syntax for calling super constructor

  @override
  State<AddWordItem> createState() => _AddWordItemState();
}

class _AddWordItemState extends State<AddWordItem> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _english;
  late String _vietnamese;

  @override
  void initState() {
    super.initState();
    _english = widget.word.english!;
    _vietnamese = widget.word.vietnamese;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: kPrimaryColor, width: 2), // Add border
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: kPrimaryColor,
                    ),
                    child: Center(
                      child: Text(
                        widget.number
                            .toString(), // Render the number inside the Container
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ), // Render an empty Container if widget.number is not null
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () {
                      widget.onDelete(); // Call the function directly
                    },
                  ),
                ],
              ),
              TextFormField(
                initialValue: _english,
                decoration: const InputDecoration(
                  labelText: 'Word',
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: kPrimaryColor),
                  border: OutlineInputBorder(),
                  focusColor: kPrimaryColor,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter English word';
                  }
                  return null;
                },
                onSaved: (value) {
                  _english = value!;
                },
                onChanged: (value) {
                  _english = value;
                  widget.onUpdateWord(widget.word.copyWith(english: value));
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _vietnamese,
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  labelText: 'Define',
                  labelStyle: TextStyle(color: kPrimaryColor),
                  border: OutlineInputBorder(),
                  focusColor: kPrimaryColorBlur,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Vietnamese word';
                  }
                  return null;
                },
                onSaved: (value) {
                  _vietnamese = value!;
                },
                onChanged: (value) {
                  widget.onUpdateWord(widget.word.copyWith(vietnamese: value));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
