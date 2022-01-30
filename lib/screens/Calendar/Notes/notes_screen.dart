import 'package:flutter/material.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/floating_add_button.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingAddButton(
        onPressed: () {},
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: StandardAppBar("Anteckningar"),
      ),
    );
  }
}
