import 'package:flutter/material.dart';
import 'package:orange_card/constants/constants.dart';

class DetailTopicSkeletonLoading extends StatelessWidget {
  const DetailTopicSkeletonLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Card(
            color: Colors.grey[300],
            elevation: 5,
            shadowColor: kPrimaryColorBlur,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 80,
                    height: 80,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 20,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)),
                          child: Container(color: Colors.grey[300]),
                        ),
                        SizedBox(height: 5),
                        Container(
                          width: double.infinity,
                          height: 20,
                          child: Container(color: Colors.grey[300]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10, // Number of skeletons for user cards
            itemBuilder: (context, index) {
              return Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 70,
                        height: 90,
                        child: Container(color: Colors.grey[300]),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 8, // Number of skeletons for word items
            itemBuilder: (context, index) {
              return WordItemSkeleton();
            },
          ),
        ),
      ],
    );
  }
}

class WordItemSkeleton extends StatelessWidget {
  const WordItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.grey[300],
      shadowColor: kPrimaryColorBlur,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: Container(color: Colors.white),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 20,
                      child: Container(color: Colors.white),
                    ),
                    const SizedBox(height: 4.0),
                    SizedBox(
                      width: double.infinity,
                      height: 20,
                      child: Container(color: Colors.white),
                    ),
                    const SizedBox(height: 4.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
