import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Center(
              child: LoadingIndicator(
                  indicatorType: Indicator.audioEqualizer,
                  colors: [Colors.deepOrange],
                  strokeWidth: 10,
                  backgroundColor: Colors.transparent,
                  pathBackgroundColor: Colors.transparent)),
          Text(
            'Lütfen Bekleyin',
          ),
        ],
      ),
    );
  }
}