import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key});

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
        tabs: <Widget>[
          Tab(
            child: SizedBox(
              width: 40.0,
              height: 40.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    width: 2.0,
                  ),
                ),
                child: const Icon(Icons.feed),
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
                    width: 2.0,
                  ),
                ),
                child: const Icon(Icons.alarm),
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
                    width: 2.0,
                  ),
                ),
                child: const Icon(Icons.event),
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
                    width: 2.0,
                  ),
                ),
                child: const Icon(Icons.calendar_today),
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
                    width: 2.0,
                  ),
                ),
                child: const Icon(Icons.low_priority),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
