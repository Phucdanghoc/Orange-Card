import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:orange_card/resources/models/word.dart';
import 'package:orange_card/resources/services/CSVService.dart';
import 'package:orange_card/resources/utils/enum.dart';
import 'package:orange_card/constants/constants.dart';
import 'package:orange_card/ui/libraryPage/topic/components/add_word_item.dart';

import '../../../../resources/viewmodels/TopicViewmodel.dart';
import '../../../message/sucess_message.dart';

class AddTopicScreen extends StatefulWidget {
  const AddTopicScreen({super.key});

  @override
  State<AddTopicScreen> createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  late List<Word> _words = [createEmptyWord()];
  String _topicName = '';
  final TopicViewModel _topicViewModel = TopicViewModel();
  final _formKey = GlobalKey<FormState>();
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
  }

  Word createEmptyWord() {
    return Word(
        english: '',
        vietnamese: '',
        userMarked: [],
        createdAt: DateTime.now().microsecondsSinceEpoch,
        learnt: STATUS.NOT_LEARN,
        updatedAt: DateTime.now().microsecondsSinceEpoch,
        marked: STATUS.NOT_MARKED);
  }

  void removeWordItem(int index) {
    setState(() {
      _words.removeAt(index);
    });
  }

  void updateWord(int index, Word updatedWord) {
    setState(() {
      _words[index] = updatedWord;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Topic"),
        backgroundColor: kPrimaryColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildTopicNameField(),
              const SizedBox(height: 16),
              Expanded(child: buildWordList()),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildAddListByCSVButton(),
                  buildAddWordButton(),
                  buildSaveButton(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTopicNameField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            onChanged: (value) {
              _topicName = value;
            },
            decoration: const InputDecoration(
              labelText: 'Tên',
              labelStyle: TextStyle(color: kPrimaryColor),
              fillColor: Colors.white,
              focusColor: kPrimaryColor,
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor),
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please , enter your topic title';
              }
              return null;
            },
          ),
        ),
        buildPublicSwitch(),
      ],
    );
  }

  Widget buildPublicSwitch() {
    return Column(
      children: [
        Switch(
          value: _isPublic,
          activeColor: Colors.orange,
          onChanged: (bool value) {
            setState(() {
              _isPublic = value;
            });
          },
        ),
        Text(_isPublic ? 'Public' : 'Private'),
      ],
    );
  }

  Widget buildWordList() {
    return ListView.builder(
      itemCount: _words.length,
      itemBuilder: (context, index) {
        return AddWordItem(
          word: _words[index],
          onDelete: () => removeWordItem(index),
          onUpdateWord: (updatedWord) => updateWord(index, updatedWord),
          number: index + 1,
        );
      },
    );
  }

  Widget buildAddWordButton() {
    return Flexible(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(90),
          color: kPrimaryColor,
        ),
        child: IconButton(
          onPressed: () {
            setState(() {
              _words.add(createEmptyWord());
            });
          },
          constraints: const BoxConstraints.tightFor(width: 50, height: 50),
          icon: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildAddListByCSVButton() {
    return Flexible(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(90),
          color: kPrimaryColor,
        ),
        child: IconButton(
          onPressed: () async {
            _words += await _FilePicker();
            setState(() {});
          },
          constraints: const BoxConstraints.tightFor(width: 50, height: 50),
          icon: const Icon(
            Icons.file_upload,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildSaveButton() {
    return Flexible(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(90),
          color: kPrimaryColor,
        ),
        child: IconButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await _addTopic();
            }
          },
          constraints: const BoxConstraints.tightFor(width: 50, height: 50),
          icon: const Icon(
            Icons.check,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _addTopic() async {
    await _topicViewModel.addTopic(
      _topicName,
      _words,
      _isPublic,
    );
    MessageUtils.showSuccessMessage(context, "Add new topic : ${_topicName} !");
    Navigator.pop(context);
  }

  Future<List<Word>> _FilePicker() async {
    final file = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    List<Word> words = await CSVService().loadCSV(file!);
    return words;
  }
}
