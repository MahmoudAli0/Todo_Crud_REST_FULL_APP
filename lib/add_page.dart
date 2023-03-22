import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Add_Page_Screen extends StatefulWidget {
  final Map? todo;

  const Add_Page_Screen({super.key, this.todo});

  @override
  State<Add_Page_Screen> createState() => _Add_Page_ScreenState();
}

class _Add_Page_ScreenState extends State<Add_Page_Screen> {
  var titleController =TextEditingController();
  var descriptionController =TextEditingController();

  bool isEdit=false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final todo =widget.todo;
    if(todo !=null){
      isEdit=true;
      final title=todo['title'];
      final descraption=todo['description'];
      titleController.text=title;
      descriptionController.text=descraption;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isEdit?  Text('Edit Task '):Text('Add Task '),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: 'Title'),
          ),
          SizedBox(height: 20,),
          TextField(
            controller: descriptionController,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(hintText: 'Description '),
            maxLines: 8,
            minLines: 5,
          ),
          SizedBox(height: 20,),
          ElevatedButton(
            onPressed: isEdit? updateTask : submitData,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(isEdit? 'Update': 'ADD'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateTask() async{
    final title=titleController.text;
    final descrption=descriptionController.text;
    final todo=widget.todo;

    if(todo ==null){
      print('You can not call updated eith out update todo');
    }
    final id=todo!['_id'];
    final body={
      'title':title,
      'description':descrption,
      'is_completed':false,
    };

    final url= 'https://api.nstack.in/v1/todos/$id';
    final uri=Uri.parse(url);
    final response= await http.put(uri,body: jsonEncode(body),headers: {
      'Content-Type':'application/json'
    } );


    if(response.statusCode ==200){
      print('Updation Completed ');
      showSucessMessage('Updation Completed ');
    }else{
      print('Update Failed');
      showErorrMessage('Updation Failed ');
    }
  }
  Future<void> submitData() async{
    final title=titleController.text;
    final descrption=descriptionController.text;

    final body={
      'title':title,
      'description':descrption,
      'is_completed':false,
    };
    final url= 'https://api.nstack.in/v1/todos';
    final uri=Uri.parse(url);
   final response= await http.post(uri,body: jsonEncode(body),headers: {
     'Content-Type':'application/json'
   } );

   if(response.statusCode ==201){
     titleController.text='';
     descriptionController.text='';
     print('Creation Completed ');
     showSucessMessage('Creation Completed');
   }else{
     print('Creation Failed');
     showErorrMessage('Creation Failed ');
   }
    }

    void showSucessMessage(String message){
    final snakbar=SnackBar(content: Text(message,style: TextStyle(color: Colors.white)),backgroundColor: Colors.green,);
    ScaffoldMessenger.of(context).showSnackBar(snakbar);
    }

    void showErorrMessage(String message){
    final snakbar=SnackBar(content: Text(message,style: TextStyle(color: Colors.white),),backgroundColor: Colors.red,);
    ScaffoldMessenger.of(context).showSnackBar(snakbar);
    }
}
