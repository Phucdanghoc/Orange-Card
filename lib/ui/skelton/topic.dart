import 'package:flutter/material.dart';
import 'package:orange_card/constants/constants.dart';

class TopicCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
      child: Card(
        elevation: 4.0,
        color: Colors.white,
        shadowColor: kPrimaryColorBlur,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(color: Colors.grey, width: 2),
        ),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Skeleton(),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Skeleton(width: 150),
                            SizedBox(height: 4.0),
                            Skeleton(
                              width: 150,
                              height: 20,
                            ),
                            SizedBox(height: 4.0),
                            Skeleton(
                              width: 120,
                              height: 13,
                            ),
                            SizedBox(height: 4.0),
                            Skeleton(
                              width: 50,
                              height: 13,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Skeleton extends StatefulWidget {
  final double? width;
  final double? height;

  const Skeleton({Key? key, this.width, this.height}) : super(key: key);

  @override
  _SkeletonState createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _colorAnimation = ColorTween(
      begin: Colors.grey[300],
      end: Colors.grey[400], // Adjust the end color as needed
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: _colorAnimation.value,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
