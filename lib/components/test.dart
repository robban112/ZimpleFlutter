// import 'package:flutter/material.dart';
// import 'week_view.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:flutter/rendering.dart';

// void main() {
//   runApp(MaterialApp(home: HomePage()));
// }

// class LimeApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     initializeDateFormatting('sv_SE');
//     return MaterialApp(
//       title: 'Pageview Test',
//       home: Scaffold(
//         body: SafeArea(
//           child: HomePage(),
//         ),
//       ),
//     );
//   }
// }

// class Destination {
//   const Destination(this.title, this.icon, this.color);
//   final String title;
//   final IconData icon;
//   final MaterialColor color;
// }

// const List<Destination> allDestinations = <Destination>[
//   Destination('Home', Icons.home, Colors.teal),
//   Destination('Business', Icons.business, Colors.cyan),
//   Destination('School', Icons.school, Colors.orange),
//   Destination('Flight', Icons.flight, Colors.blue)
// ];

// class RootPage extends StatelessWidget {
//   const RootPage({Key key, this.destination}) : super(key: key);

//   final Destination destination;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(destination.title),
//         backgroundColor: destination.color,
//       ),
//       backgroundColor: destination.color[50],
//       body: SizedBox.expand(
//         child: InkWell(
//           onTap: () {
//             Navigator.pushNamed(context, "/list");
//           },
//         ),
//       ),
//     );
//   }
// }

// class ListPage extends StatelessWidget {
//   const ListPage({Key key, this.destination}) : super(key: key);

//   final Destination destination;

//   @override
//   Widget build(BuildContext context) {
//     const List<int> shades = <int>[
//       50,
//       100,
//       200,
//       300,
//       400,
//       500,
//       600,
//       700,
//       800,
//       900
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(destination.title),
//         backgroundColor: destination.color,
//       ),
//       backgroundColor: destination.color[50],
//       body: SizedBox.expand(
//         child: ListView.builder(
//           itemCount: shades.length,
//           itemBuilder: (BuildContext context, int index) {
//             return SizedBox(
//               height: 128,
//               child: Card(
//                 color: destination.color[shades[index]].withOpacity(0.25),
//                 child: InkWell(
//                   onTap: () {
//                     Navigator.pushNamed(context, "/text");
//                   },
//                   child: Center(
//                     child: Text('Item $index',
//                         style: Theme.of(context).primaryTextTheme.display1),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class TextPage extends StatefulWidget {
//   const TextPage({Key key, this.destination}) : super(key: key);

//   final Destination destination;

//   @override
//   _TextPageState createState() => _TextPageState();
// }

// class _TextPageState extends State<TextPage> {
//   TextEditingController _textController;

//   @override
//   void initState() {
//     super.initState();
//     _textController = TextEditingController(
//       text: 'sample text: ${widget.destination.title}',
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.destination.title),
//         backgroundColor: widget.destination.color,
//       ),
//       backgroundColor: widget.destination.color[50],
//       body: Container(
//         padding: const EdgeInsets.all(32.0),
//         alignment: Alignment.center,
//         child: TextField(controller: _textController),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _textController.dispose();
//     super.dispose();
//   }
// }

// class DestinationView extends StatefulWidget {
//   const DestinationView({Key key, this.destination}) : super(key: key);

//   final Destination destination;

//   @override
//   _DestinationViewState createState() => _DestinationViewState();
// }

// class _DestinationViewState extends State<DestinationView> {
//   @override
//   Widget build(BuildContext context) {
//     return Navigator(
//       onGenerateRoute: (RouteSettings settings) {
//         return MaterialPageRoute(
//           settings: settings,
//           builder: (BuildContext context) {
//             switch (settings.name) {
//               case '/':
//                 return RootPage(destination: widget.destination);
//               case '/list':
//                 return ListPage(destination: widget.destination);
//               case '/text':
//                 return TextPage(destination: widget.destination);
//             }
//           },
//         );
//       },
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage>
//     with TickerProviderStateMixin<HomePage> {
//   int _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         top: false,
//         child: IndexedStack(
//           index: _currentIndex,
//           children: allDestinations.map<Widget>((Destination destination) {
//             return DestinationView(destination: destination);
//           }).toList(),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (int index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: allDestinations.map((Destination destination) {
//           return BottomNavigationBarItem(
//               icon: Icon(destination.icon),
//               backgroundColor: destination.color,
//               title: Text(destination.title));
//         }).toList(),
//       ),
//     );
//   }
// }

// // typedef Widget WidgetBuilder(int pageNumber);

// // class CustomPageView extends StatefulWidget {
// //   @override
// //   _CustomPageViewState createState() => _CustomPageViewState();
// // }

// // class _CustomPageViewState extends State<CustomPageView> {
// //   double width;

// //   Widget buildContainer(int index) {
// //     //return WeekView(numberOfDays: 7, minuteHeight: 0.5, weekIndex: index);
// //     return Container(
// //       color: index % 2 == 0 ? Colors.red : Colors.yellow,
// //       height: 100,
// //       width: width,
// //       child: Center(
// //         child: Text(
// //           index.toString(),
// //           style: TextStyle(color: Colors.white, fontSize: 25.0),
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     width = MediaQuery.of(context).size.width;
// //     return TestPage(
// //       screenWidth: width,
// //       widgetBuilder: buildContainer,
// //     );
// //   }
// // }

// // int _lowerCount = -1;
// // int _upperCount = 1;

// // class TestPage extends StatefulWidget {
// //   final double screenWidth;
// //   final WidgetBuilder widgetBuilder;
// //   TestPage({this.screenWidth, this.widgetBuilder});
// //   @override
// //   _TestPageState createState() => _TestPageState();
// // }

// // class _TestPageState extends State<TestPage> {
// //   List<Widget> pages = [];
// //   ScrollController sc;
// //   int lowerCount;
// //   int upperCount;
// //   double pageScrollOffset;

// //   @override
// //   void initState() {
// //     super.initState();
// //     pages = [
// //       widget.widgetBuilder(-1),
// //       widget.widgetBuilder(0),
// //       widget.widgetBuilder(1),
// //     ];
// //     lowerCount = -1;
// //     upperCount = 1;

// //     sc = ScrollController(
// //         initialScrollOffset: widget.screenWidth * ((pages.length - 1) / 2));
// //     pageScrollOffset = widget.screenWidth * pages.length;
// //   }

// //   void _addLeftChild() {
// //     Future.delayed(Duration(milliseconds: 1), () {
// //       setState(() {
// //         pages.insert(0, widget.widgetBuilder(lowerCount - 1));
// //         sc.jumpTo(sc.offset + widget.screenWidth);
// //         lowerCount--;
// //       });
// //     });
// //   }

// //   void _addRightChild() {
// //     Future.delayed(Duration(milliseconds: 1), () {
// //       setState(() {
// //         pages.add(widget.widgetBuilder(upperCount + 1));
// //         upperCount++;
// //       });
// //     });
// //   }

// //   void scrollToOffset(double offset) {
// //     Future.delayed(Duration(milliseconds: 1), () {
// //       sc.animateTo(pageScrollOffset,
// //           duration: Duration(milliseconds: 300), curve: Curves.decelerate);
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: NotificationListener<ScrollNotification>(
// //         onNotification: (notification) {
// //           if (notification is ScrollEndNotification) {
// //             double lastPageOffset = widget.screenWidth * (pages.length - 1);
// //             double offsetLastPageDiff = sc.offset - lastPageOffset;
// //             if (sc.offset == 0.0) {
// //               print("first page");
// //               _addLeftChild();
// //             } else if (offsetLastPageDiff < 0.5 && offsetLastPageDiff > -0.5) {
// //               print("last page");
// //               _addRightChild();
// //             }
// //           }
// //         },
// //         child: ListView.builder(
// //           controller: sc,
// //           physics: PageScrollPhysics(),
// //           scrollDirection: Axis.horizontal,
// //           itemBuilder: (context, index) {
// //             return pages[index];
// //           },
// //           itemCount: pages.length,
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class MainPage extends StatefulWidget {
// //   @override
// //   MainPageState createState() {
// //     return new MainPageState();
// //   }
// // }

// // class MainPageState extends State<MainPage> {
// //   List<Widget> _pages = <Widget>[
// //     new Center(child: new Text("-1", style: new TextStyle(fontSize: 60.0))),
// //     new Center(child: new Text("0", style: new TextStyle(fontSize: 60.0))),
// //     new Center(child: new Text("1", style: new TextStyle(fontSize: 60.0)))
// //   ];

// //   int _pageNum = 1;

// //   PageController pageController;

// //   @override
// //   void initState() {
// //     // TODO: implement initState
// //     super.initState();
// //     pageController = PageController(initialPage: _pageNum, keepPage: true);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         margin: EdgeInsets.symmetric(
// //           vertical: 50.0,
// //         ),
// //         child: NotificationListener<ScrollNotification>(
// //           onNotification: (ScrollNotification scrollInfo) {
// //             if (scrollInfo is ScrollEndNotification) {
// //               print("SCROLL ENDED");
// //             }
// //             if (scrollInfo.metrics.pixels ==
// //                 scrollInfo.metrics.maxScrollExtent) {
// //               print("MAX EXTENT!");
// //             }

// //             //print(scrollInfo.metrics.pixels);
// //           },
// //           child: Container(),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class HomePage extends StatefulWidget {
// //   @override
// //   _HomePageState createState() {
// //     return _HomePageState();
// //   }
// // }

// // class _HomePageState extends State<HomePage> {
// //   List<Widget> left_pages = [];
// //   List<Widget> pages = [];
// //   int lowerCount = 0;

// //   @override
// //   initState() {
// //     super.initState();
// //     pages = [
// //       ScrollContainer(
// //         pageNumber: 0,
// //       ),
// //       ScrollContainer(
// //         pageNumber: 1,
// //       ),
// //       ScrollContainer(
// //         pageNumber: 2,
// //       )
// //     ];
// //     left_pages = [
// //       ScrollContainer(
// //         pageNumber: -1,
// //       ),
// //       ScrollContainer(
// //         pageNumber: -2,
// //       ),
// //       ScrollContainer(
// //         pageNumber: -3,
// //       )
// //     ];
// //   }

// //   void _addPage() {
// //     Widget newScrollContainer = ScrollContainer(pageNumber: lowerCount - 1);
// //     lowerCount--;
// //     setState(() {
// //       left_pages.insert(0, newScrollContainer);
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       floatingActionButton: FloatingActionButton(
// //         child: Icon(Icons.add),
// //         onPressed: _addPage,
// //         backgroundColor: Colors.purple,
// //       ),
// //       body: SafeArea(
// //         child: ListView.builder(
// //           scrollDirection: Axis.horizontal,
// //           itemBuilder: (context, index) {
// //             return pages[index];
// //           },
// //           itemCount: pages.length,
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class ScrollContainer extends StatefulWidget {
// //   final int pageNumber;
// //   const ScrollContainer({this.pageNumber});

// //   @override
// //   _ScrollContainerState createState() => _ScrollContainerState();
// // }

// // class _ScrollContainerState extends State<ScrollContainer> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return SingleChildScrollView(
// //       child: Column(
// //         children: List.generate(8, (index) {
// //           return Container(
// //               decoration: BoxDecoration(
// //                   color: index % 2 == 0 ? Colors.red : Colors.blue,
// //                   border: Border.all(
// //                     width: 2.0,
// //                   )),
// //               height: 200,
// //               width: MediaQuery.of(context).size.width,
// //               child: index == 0
// //                   ? Center(
// //                       child: Text(
// //                         widget.pageNumber.toString(),
// //                         style: TextStyle(fontSize: 30.0),
// //                       ),
// //                     )
// //                   : null);
// //         }),
// //       ),
// //     );
// //   }
// // }
