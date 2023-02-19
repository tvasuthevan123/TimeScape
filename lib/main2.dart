import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isShowing = false;

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height;
    return DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: SafeArea(
          child: Scaffold(
              appBar: null,
              body: Stack(
                children: [
                  Container(
                      color: Colors.greenAccent,
                      child: SizedBox(
                        height: maxHeight,
                        child: TabBarView(
                          physics: _isShowing
                              ? const AlwaysScrollableScrollPhysics()
                              : const NeverScrollableScrollPhysics(),
                          children: const <Widget>[
                            Center(
                              child: Text("It's cloudy here"),
                            ),
                            Center(
                              child: Text("It's rainy here innit"),
                            ),
                            Center(
                              child: Text("It's sunny here"),
                            ),
                          ],
                        ),
                      )),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    width: maxWidth,
                    height: _isShowing ? kToolbarHeight : 0,
                    child: SizedBox(
                        width: maxWidth * 0.75, child: const ExampleTabBar()),
                  ),
                  AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      left: maxWidth * 0.2,
                      right: maxWidth * 0.2,
                      top: _isShowing ? kToolbarHeight : 0,
                      child: Padding(
                          padding: EdgeInsets.zero,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.zero),
                              shape: MaterialStateProperty.resolveWith<
                                  OutlinedBorder>((Set<MaterialState> states) {
                                return const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                );
                              }),
                            ),
                            onPressed: () {
                              setState(() {
                                _isShowing = !_isShowing;
                              });
                            },
                            child: _isShowing
                                ? const Text('Close Menu')
                                : const Text('Open Menu'),
                          ))),
                ],
              )),
        ));
  }
}

class ExampleTabBar extends StatelessWidget {
  const ExampleTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      color: Colors.blue,
      child: const TabBar(
        tabs: <Widget>[
          Tab(
            icon: Icon(Icons.cloud_outlined),
          ),
          Tab(
            icon: Icon(Icons.beach_access_sharp),
          ),
          Tab(
            icon: Icon(Icons.brightness_5_sharp),
          ),
        ],
      ),
    );
  }
}
