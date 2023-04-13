import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      labelColor: Colors.black,
      indicatorColor: Colors.transparent,
      tabs: <Widget>[
        Tab(
          child: SizedBox(
            width: 40.0,
            height: 40.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
              child: const Icon(Icons.cloud_outlined),
            ),
          ),
        ),
        Tab(
          child: SizedBox(
            width: 40.0,
            height: 40.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
              child: const Icon(Icons.beach_access_sharp),
            ),
          ),
        ),
        Tab(
          child: SizedBox(
            width: 40.0,
            height: 40.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
              child: const Icon(Icons.brightness_5_sharp),
            ),
          ),
        ),
      ],
    );
  }
}
