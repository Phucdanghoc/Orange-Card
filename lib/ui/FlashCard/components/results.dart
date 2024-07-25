import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ResultFlashCard extends StatelessWidget {
  final int masterWord;
  final int notmasterWord;
  final VoidCallback onReuse;
  final VoidCallback onComplete;
  final VoidCallback onLearnNotMaster;
  const ResultFlashCard({
    super.key,
    required this.masterWord,
    required this.notmasterWord,
    required this.onReuse,
    required this.onComplete,
    required this.onLearnNotMaster,
  });

  static Widget _buildCard(String title, int numberWord, Color colorNumber) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                numberWord.toString(),
                style: TextStyle(fontSize: 20, color: colorNumber),
              ),
              const SizedBox(
                  width: 8), // Add some spacing between the text and the title
              Text(
                title,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text(
          'Congratulation',
          style: TextStyle(fontSize: 20),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularPercentIndicator(
              radius: 30.0,
              animation: true,
              animationDuration: 500,
              lineWidth: 5.0,
              percent: masterWord / (masterWord + notmasterWord),
              center: notmasterWord != 0
                  ? Text(
                      "$masterWord/${masterWord + notmasterWord}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : const Text(
                      "Great",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color.fromARGB(255, 110, 255, 115),
                      ),
                    ),
              circularStrokeCap: CircularStrokeCap.butt,
              backgroundColor: const Color.fromARGB(188, 218, 218, 218),
              progressColor: notmasterWord == 0
                  ? const Color.fromARGB(255, 110, 255, 115)
                  : masterWord != (masterWord + notmasterWord)
                      ? const Color.fromARGB(255, 255, 123, 0)
                      : Colors.red,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCard('Learned', masterWord, Colors.green),
              _buildCard('Not Learn', notmasterWord, Colors.red),
            ],
          )
        ],
      ),
      actions: [
        Column(
          children: [
            notmasterWord != 0
                ? Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        onLearnNotMaster();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Learn unfamiliar words'),
                    ),
                  )
                : Container(),
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onReuse();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Redo'),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.blue), // Thay đổi màu nền ở đây
                      ),
                      onPressed: () {
                        onComplete();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Complete'),
                    ),
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}
