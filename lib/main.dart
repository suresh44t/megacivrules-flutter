import 'dart:async' show Future;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';

// Ours
import 'package:mega_civ_rules/models/chapter.dart';
import 'package:mega_civ_rules/widgets/tableofcontent/tableofcontent.dart';
import 'package:mega_civ_rules/widgets/wikipedia/wikipedia.dart';
import 'package:mega_civ_rules/widgets/progress/progress.dart';
import 'package:mega_civ_rules/services/chapterservice.dart';
import 'package:mega_civ_rules/services/themeservice.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(new MegaCivRules());
}

class MegaCivRules extends StatefulWidget {
  MegaCivRules({Key key}) : super(key: key);

//  @override
//  Widget build(BuildContext context) {
//    return new MaterialApp(
//      title: 'Mega Civilizaton Rules',
//      theme:
//      home: new MegaCivPage(),
//    );
//  }

  @override
  _MegaCivRulesState createState() => new _MegaCivRulesState();
}

//class MegaCivPage extends StatefulWidget {
//  MegaCivPage({Key key}) : super(key: key);
//
//  @override
//  _MegaCivPageState createState() => new _MegaCivPageState();
//}

class _MegaCivRulesState extends State<MegaCivRules> {
  bool darkThemeEnabled = false;
  int sliderColor = 0;

  List<Chapter> chapters = [];
  int selectedIndex = 0;
  SearchBar searchBar;
  String searchString = "";

  @override
  void initState() {
    super.initState();
    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        clearOnSubmit: false,
        onSubmitted: onSubmitted,
        onChanged: onChange,
        onClosed: () {
          setState(() => searchString = "");
        });
    ChapterService.get().then((chapters) {
      this.setState(() {
        this.chapters = chapters;
      });
    });
  }

  ThemeData getThemeData() {
    return ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
//           counter didn't reset back to zero; the application is not restarted.
        brightness: darkThemeEnabled ? Brightness.dark : Brightness.light,
        primarySwatch: ThemeService.getColor(sliderColor),
        primaryColor: ThemeService.getColor(sliderColor)[700],
        accentColor: ThemeService.getColor(sliderColor)[800],
        backgroundColor: ThemeService.getColor(sliderColor)[100]);
  }

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Text('Mega Civilization Rules'),
        actions: [searchBar.getSearchAction(context)]);
  }

  void onChange(String value) {
    setState(() => searchString = value);
  }

  void onSubmitted(String value) {
    setState(() => searchString = value);
  }

  Widget getNavBar() {
    return Theme(
        data: Theme.of(context).copyWith(
            canvasColor: ThemeService.getColor(sliderColor),
            primaryColor: ThemeService.getColor(sliderColor)[700],
            textTheme: Theme.of(context).textTheme.copyWith(
                caption:
                    TextStyle(color: ThemeService.getColor(sliderColor)[700]))),
        child: BottomNavigationBar(
            currentIndex: this.selectedIndex,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.book), title: const Text('Rules')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.keyboard), title: const Text('Wikipedia')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.insert_chart),
                  title: const Text('Progress')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.border_all), title: const Text('Cards'))
            ],
            onTap: _onBottomNavigationBarTapped));
  }

  void _onBottomNavigationBarTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _onSwitchValueChange(bool newValue) {
    setState(() {
      darkThemeEnabled = newValue;
    });
  }

  void _onColorSliderValueChange(double newValue) {
    setState(() {
      sliderColor = newValue.round();
    });
  }

  Widget getBody() {
    switch (this.selectedIndex) {
      case 0:
        return new TableOfContents(
          chapters: this.chapters,
          searchString: this.searchString,
        );
      case 1:
        return new Wikipedia();
      case 2:
        return new Progress();
      case 3:
        return Text('Cards');
      default:
        return Text('Not implemented');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body = getBody();

    return MaterialApp(
        theme: getThemeData(),
        home: Scaffold(
          appBar: searchBar.build(context),
          body: body,
          drawer: Drawer(
              child: ListView(
            children: <Widget>[
              ListTile(
                title: const Text('Dark Theme'),
                trailing: Switch(
                    value: darkThemeEnabled, onChanged: _onSwitchValueChange),
              ),
              ListTile(
                title: const Text('Color'),
                trailing: Slider(
                    min: 0.0,
                    label: "lel",
                    max: ThemeService.presetColors.length + .0,
                    value: sliderColor + .0,
                    onChanged: _onColorSliderValueChange),
              )
            ],
          )),
          bottomNavigationBar:
              getNavBar(), // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }
}
