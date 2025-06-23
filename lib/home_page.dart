// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:todoapp/body_widget.dart';

class HomePage extends StatefulWidget{
 
 const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  
 
 @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Center(
          child: 
          Text('Advance Notepad' , 
          style: Theme.of(context).textTheme.titleLarge,         
          )
        ),
      ),
      body: BodyWidget(),
    );
  }
}

