import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timescape/entry_manager.dart';

class FocusMode extends StatefulWidget {
  final Task task;

  const FocusMode({super.key, required this.task});

  @override
  State<FocusMode> createState() => _FocusModeState();
}

class _FocusModeState extends State<FocusMode> {
  int secondsElapsed = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsElapsed++;
        widget.task.incrementTimeSpent();
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int hours = secondsElapsed ~/ 3600;
    int minutes = secondsElapsed ~/ 60;
    int seconds = secondsElapsed % 60;
    return Consumer<EntryManager>(
      builder: (context, itemManager, child) {
        return SafeArea(
          child: Material(
            color: const Color.fromARGB(255, 235, 254, 255),
            child: Stack(children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: screenWidth * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: const Color.fromRGBO(0, 39, 41, 1),
                            width: 2.0,
                          ),
                          color: const Color.fromRGBO(0, 78, 82, 1),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Center(
                        child: Container(
                          width: screenWidth * 0.8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: const Color.fromRGBO(0, 39, 41, 1),
                              width: 2.0,
                            ),
                            color: const Color.fromRGBO(0, 78, 82, 1),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            widget.task.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 16.0,
                right: 16.0,
                child: FloatingActionButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: const Color.fromRGBO(0, 39, 41, 1),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
