import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timescape/category_setup.dart';
import 'package:timescape/database_helper.dart';
import 'package:timescape/eisenhower_display.dart';
import 'package:timescape/entry_manager.dart';
import 'package:timescape/list_view.dart';
import 'package:timescape/scheduler.dart';
import './sliding_app_bar.dart';
import './custom_tab_bar.dart';
import './day_view.dart';

const double buttonHeight = 50;

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(255, 235, 254, 255)),
  );
  // Initialize the database.

  WidgetsFlutterBinding.ensureInitialized();
  await (DatabaseHelper().database);

  // Create an instance of the EntryManager and load items from the database.
  final itemManager = EntryManager();
  await itemManager.loadEntriesFromDatabase();
  runApp(TimeScape(itemManager: itemManager));
}

class TimeScape extends StatefulWidget {
  TimeScape({Key? key, required this.itemManager}) : super(key: key);

  final EntryManager itemManager;
  final _primaryColor = const Color.fromRGBO(0, 39, 41, 1);
  final _secondaryColor = const Color.fromARGB(255, 11, 136, 143);
  @override
  State<TimeScape> createState() => _TimeScapeState();
}

class _TimeScapeState extends State<TimeScape> {
  bool _isCategoriesSet = false;

  void setupCallback() {
    setState(() => _isCategoriesSet = true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemManager.categories.isNotEmpty) {
      setState(() => _isCategoriesSet = true);
    }
    return ChangeNotifierProvider<EntryManager>.value(
      value: widget.itemManager,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          textTheme: GoogleFonts.lexendDecaTextTheme(),
          primarySwatch: MaterialColor(
            widget._primaryColor.value,
            <int, Color>{
              50: Color.lerp(
                  widget._primaryColor, widget._secondaryColor, 0.1)!,
              100: Color.lerp(
                  widget._primaryColor, widget._secondaryColor, 0.2)!,
              200: Color.lerp(
                  widget._primaryColor, widget._secondaryColor, 0.3)!,
              300: Color.lerp(
                  widget._primaryColor, widget._secondaryColor, 0.4)!,
              400: Color.lerp(
                  widget._primaryColor, widget._secondaryColor, 0.5)!,
              500: Color.lerp(
                  widget._primaryColor, widget._secondaryColor, 0.6)!,
              600: Color.lerp(
                  widget._primaryColor, widget._secondaryColor, 0.7)!,
              700: Color.lerp(
                  widget._primaryColor, widget._secondaryColor, 0.8)!,
              800: Color.lerp(
                  widget._primaryColor, widget._secondaryColor, 0.9)!,
              900: Color.lerp(
                  widget._primaryColor, widget._secondaryColor, 1.0)!,
            },
          ),
          primaryColor: const Color.fromARGB(255, 235, 254, 255),
          platform: TargetPlatform.android,
        ),
        home: _isCategoriesSet
            ? const MainApp()
            : SetupCategoriesPage(setupCallback),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
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
      length: 5,
      child: SafeArea(
        child: Material(
          child: Stack(
            children: [
              Container(
                  color: const Color.fromARGB(255, 235, 254, 255),
                  child: SizedBox(
                    height: maxHeight,
                    child: TabBarView(
                      physics: _isShowing
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        Center(
                          child: AnimatedPadding(
                            duration: const Duration(milliseconds: 400),
                            padding: EdgeInsets.only(
                              top: _isShowing ? 40 + buttonHeight : 40,
                            ),
                            child: const EntryListView(
                              entryType: EntryType.task,
                            ),
                          ),
                        ),
                        Center(
                          child: AnimatedPadding(
                            duration: const Duration(milliseconds: 400),
                            padding: EdgeInsets.only(
                              top: _isShowing ? 40 + buttonHeight : 40,
                            ),
                            child: const EntryListView(
                              entryType: EntryType.reminder,
                            ),
                          ),
                        ),
                        Center(
                          child: AnimatedPadding(
                            duration: const Duration(milliseconds: 400),
                            padding: EdgeInsets.only(
                              top: _isShowing ? 40 + buttonHeight : 40,
                            ),
                            child: const EntryListView(
                              entryType: EntryType.event,
                            ),
                          ),
                        ),
                        Center(
                          child: AnimatedPadding(
                            duration: const Duration(milliseconds: 400),
                            padding: EdgeInsets.only(
                              top: _isShowing ? 40 + buttonHeight : 40,
                            ),
                            child: DayView(),
                          ),
                        ),
                        Center(
                          child: AnimatedPadding(
                            duration: const Duration(milliseconds: 400),
                            padding: EdgeInsets.only(
                              top: _isShowing ? 40 + buttonHeight : 40,
                            ),
                            child: EisenhowerMatrix(),
                          ),
                        ),
                      ],
                    ),
                  )),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                left: maxWidth * 0.4,
                right: maxWidth * 0.4,
                top: _isShowing ? buttonHeight : 0,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(
                      width: 3.0,
                    ),
                    padding: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isShowing = !_isShowing;
                    });
                  },
                  child: const Icon(
                    Icons.menu_rounded,
                  ),
                ),
              ),
              SlidingAppBar(
                controller: _controller,
                visible: _isShowing,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTabBar(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
