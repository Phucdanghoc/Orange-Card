import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "WELCOME TO ORANGE CARD",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // const SizedBox(height: defaultPadding * 0.1),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: SvgPicture.asset(
                "assets/icons/welcome.svg",
              ),
            ),
            const Spacer(),
          ],
        ),
        // const SizedBox(height: defaultPadding * 0.1),
      ],
    );
  }
}
