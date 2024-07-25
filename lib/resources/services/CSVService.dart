import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:orange_card/config/app_logger.dart';
import 'package:orange_card/resources/models/word.dart';
import 'package:orange_card/resources/utils/enum.dart';
import 'package:orange_card/ui/message/sucess_message.dart';
import 'package:path_provider/path_provider.dart';
import "package:permission_handler/permission_handler.dart";
import 'package:file_picker/file_picker.dart';

class CSVService {
  CSVService();
  Future<String?> makeFile(
      BuildContext context, List<Word> words, String name) async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
        var result = await Permission.manageExternalStorage.request();
        if (result != PermissionStatus.granted) {
          MessageUtils.showFailureMessage(context, "Permission denied");
          return null;
        }
      }
      List<List<dynamic>> rows = [];
      rows.add(['English', 'Vietnamese']);
      for (var word in words) {
        rows.add([word.english, word.vietnamese]);
      }
      Directory directory;
      if (Platform.isAndroid) {
        directory = Directory("/storage/emulated/0/Download");
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      String appDocumentsPath = directory.path;

      String orangecardPath = '$appDocumentsPath/orangecard';
      Directory orangecardDirectory = Directory(orangecardPath);
      if (!(await orangecardDirectory.exists())) {
        await orangecardDirectory.create(recursive: true);
      }
      String csvFilePath = '$orangecardPath/${name.replaceAll(" ", "")}.csv';
      File csvFile = File(csvFilePath);
      String csvData = const ListToCsvConverter().convert(rows);
      await csvFile.writeAsString(csvData);
      return csvFilePath;
    } catch (e) {
      print('Error saving file: $e');
      return null;
    }
  }

  Future<List<Word>> loadCSV(FilePickerResult filePickerResult) async {
    List<Word> words = [];
    try {
      if (filePickerResult.files.isNotEmpty) {
        PlatformFile csvFile = filePickerResult.files.first;
        if (csvFile.extension == 'csv') {
          final input = File(csvFile.path!).openRead();
          final fields = await input
              .transform(utf8.decoder)
              .transform(const CsvToListConverter())
              .toList();
          logger.d(fields);
          for (var i = 1; i < fields.length; i++) {
            String english = fields[i][0];
            String vietnamese = fields[i][1];
            words.add(Word(
              english: english,
              vietnamese: vietnamese,
              marked: STATUS.NOT_MARKED,
              updatedAt: 0,
              createdAt: 0,
              userMarked: [],
              learnt: STATUS.NOT_LEARN,
            ));
          }
        } else {
          print('Invalid file format. Please select a CSV file.');
        }
      } else {
        print('No file selected.');
      }
    } catch (e) {
      print('Error reading file: $e');
    }

    return words;
  }
}
