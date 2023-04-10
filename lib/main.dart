import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timescape/item_manager.dart';
import 'package:timescape/list_view.dart';
import './sliding_app_bar.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.greenAccent),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ItemManager(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          platform: TargetPlatform.iOS,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool _isShowing = false;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height;
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: SafeArea(
        child: Material(
          child: Stack(
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
                          child: ItemListView(),
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
                duration: const Duration(milliseconds: 400),
                left: maxWidth * 0.2,
                right: maxWidth * 0.2,
                top: _isShowing ? 48 : 0,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: Colors.blueGrey,
                      padding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      )),
                  onPressed: () {
                    setState(() {
                      _isShowing = !_isShowing;
                    });
                  },
                  child: _isShowing
                      ? const Text('Close Menu')
                      : const Text('Open Menu'),
                ),
              ),
              SlidingAppBar(
                controller: _controller,
                visible: _isShowing,
                child: const ExampleTabBar(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ExampleTabBar extends StatelessWidget {
  const ExampleTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.amber,
        child: const TabBar(
          indicatorColor: Colors.transparent,
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
        ));
  }
}
