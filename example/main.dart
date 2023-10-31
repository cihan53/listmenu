import 'package:flutter/material.dart';
import 'package:listmenu/SnapListView.dart';

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> items = List.generate(200, (index) => 'Öğe $index');
  final double itemHeight = 50.0;
  final double menuHeight = 300.0;

  int selectedItemIndex = 50;
  int _focusItemIndex = 50;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // _scrollController.addListener(() {
    //   final offset = _scrollController.offset;
    //   final maxOffset = itemHeight * items.length - menuHeight;
    //   final centerOffset = itemHeight / 2;
    //   final goPos = offset + itemHeight / 2 - (menuHeight / 2);
    //   print("Focust Elemenet $goPos $itemHeight ${(offset + centerOffset) ~/ itemHeight}");
    // });
  }

  // void scrollToSelected() {
  //   final selectedOffset = (_focusItemIndex * itemHeight);
  //   final goPos = selectedOffset + itemHeight / 2 - (menuHeight / 2);
  //   _scrollController.animateTo(
  //     goPos,
  //     duration: const Duration(milliseconds: 500),
  //     curve: Curves.easeInOut,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    print("$selectedItemIndex $_focusItemIndex");

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: ClipRect(
          child: Column(
            children: [
              Container(height: 100, color: Colors.white),
              Container(
                color: Colors.black,
                height: menuHeight,
                child: Center(
                  child: SnapListView(
                    // semanticChildCount: 5,
                    listController: _scrollController,
                    itemCount: items.length,
                    // shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    selectedItemToCenter: true,
                    waveAnimation: true,
                    scrollNotifyEnable: false,
                    // physics: const ClampingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        color: selectedItemIndex == index ? Colors.blue : Colors.transparent,
                        child: ListTile(
                          selectedColor: Colors.red,
                          title: Text(items[index]),
                          textColor: Colors.white,
                        ),
                      );
                    },
                    itemSize: itemHeight,
                    onTap: (index) {
                      setState(() {
                        selectedItemIndex = index;
                      });
                    },
                    onItemFocus: (index) {
                      setState(() {
                        selectedItemIndex = index;
                      });
                    }, // Öğelerin yüksekliği
                  ),
                ),
              ),
              Expanded(child: Container(height: 100, color: Colors.white)),
            ],
          ),
        ),
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
