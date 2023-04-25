import 'package:flutter/material.dart';

class TimeScapeTabBar extends StatelessWidget {
  const TimeScapeTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(width: 2),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: theme.primaryColorLight, // Selected icon color
        // unselectedLabelColor: theme.primaryColor,
        tabs: const <Widget>[
          Tab(
            child: SizedBox(
              width: 40.0,
              height: 40.0,
              child: Icon(Icons.feed),
            ),
          ),
          Tab(
            child: SizedBox(
              width: 40.0,
              height: 40.0,
              child: Icon(Icons.alarm),
            ),
          ),
          Tab(
            child: SizedBox(
              width: 40.0,
              height: 40.0,
              child: Icon(Icons.event),
            ),
          ),
          Tab(
            child: SizedBox(
              width: 40.0,
              height: 40.0,
              child: Icon(Icons.calendar_today),
            ),
          ),
          Tab(
            child: SizedBox(
              width: 40.0,
              height: 40.0,
              child: Icon(Icons.low_priority),
            ),
          ),
          Tab(
            child: SizedBox(
              width: 40.0,
              height: 40.0,
              child: Icon(Icons.settings),
            ),
          ),
        ],
      ),
    );
  }
}
