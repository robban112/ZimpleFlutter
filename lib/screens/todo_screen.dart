// import 'package:zimple/model/todo.dart';
// import 'package:zimple/network/firebase_todo_manager.dart';
// import 'package:zimple/screens/todo_detail_screen.dart';
// import 'package:flutter/material.dart';
// import '../utils/date_utils.dart';
// import '../model/destination.dart';

// class TodoScreen extends StatefulWidget {
//   static const String routeName = "todo_screen";
//   String company;

//   TodoScreen({required this.company});

//   @override
//   _TodoScreenState createState() => _TodoScreenState();
// }

// class _TodoScreenState extends State<TodoScreen>
//     with AutomaticKeepAliveClientMixin<TodoScreen> {
//   @override
//   bool get wantKeepAlive => true;
//   late FirebaseTodoManager firebaseTodoManager;
//   String message = "";
//   late Future<List<Todo>> _todoData;

//   @override
//   void initState() {
//     // TODO: implement initState
//     firebaseTodoManager = FirebaseTodoManager(company: widget.company);
//     _todoData = firebaseTodoManager.getTodos();
//     firebaseTodoManager.getTodos().then((value) => {print(value)});
//     super.initState();
//     print("init state called");
//   }

//   // Future<List<Todo>> fetchData() async {
//   //   List<Todo> result = await ;
//   //   return result;
//   // }

//   Widget _buildTodoComponent({Todo todo}) {
//     return GestureDetector(
//       onTap: () => {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TodoDetailScreen(todo: todo),
//           ),
//         )
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Text(
//             todo.title,
//             style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.bold),
//           ),
//           Text(
//             todo.todo,
//             style: TextStyle(color: Colors.black, fontSize: 16.0),
//           ),
//           Text(dateToYearMonthDay(todo.date),
//               style: TextStyle(color: Colors.grey, fontSize: 12.0))
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Todo>>(
//       future: firebaseTodoManager.getTodos(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return Scaffold(
//             body: Padding(
//               padding: EdgeInsets.only(left: 15.0, top: 25.0),
//               child: ListView.separated(
//                 itemBuilder: (context, index) {
//                   var todo = snapshot.data[index];
//                   return _buildTodoComponent(todo: todo);
//                 },
//                 itemCount: 2,
//                 separatorBuilder: (context, index) =>
//                     Divider(color: Colors.black),
//               ),
//             ),
//           );
//         } else {
//           return Center(
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
//             ),
//           );
//         }
//       },
//     );
//   }
// }
