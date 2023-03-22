import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:todo/add_page.dart';

class Todo_List extends StatefulWidget {
  const Todo_List({Key? key}) : super(key: key);

  @override
  State<Todo_List> createState() => _Todo_ListState();
}

class _Todo_ListState extends State<Todo_List> {
  List items = [];
  bool isLoading = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List App '),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(child: Text('No Todo Tasks Yet ',style: TextStyle(color: Colors.grey,fontSize: 20),),),
            child: ListView.builder(
                itemCount: items.length,
                padding: EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final item = items[index] as Map;
                  final id= item['_id'] as String;
                  print(id);
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      trailing: PopupMenuButton(
                        onSelected: (value){
                          if(value == 'edit'){
                            navigateToEditPage(item);
                          }else if(value =='delete'){
                            deleteById(id);
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              child: Text('Edit'),
                              value: 'edit',
                            ),
                            PopupMenuItem(
                              child: Text('Delete '),
                              value: 'delete',
                            )
                          ];
                        },
                      ),
                      title: Text(item['title']),
                      subtitle: Text(item['description']),
                    ),
                  );
                }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage, label: Text('ADD TODO')),
    );
  }

  Future<void> navigateToAddPage() async{
    final route = MaterialPageRoute(builder: (context) => Add_Page_Screen());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Navigator.push(context, route);
    });
    setState(() {
      isLoading=true;
    });
    fetchTodo();
  }

  Future<void> navigateToEditPage(Map item) async{
    final route = MaterialPageRoute(builder: (context) => Add_Page_Screen(todo:item));
    
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Navigator.push(context, route);
    });

    setState(() {
      isLoading=true;
    });
    fetchTodo();
  }

  Future<void> fetchTodo() async {
    final url ='https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;

      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteById(String id) async{
    final url ='https://api.nstack.in/v1/todos/$id';
    final uri=Uri.parse(url);
    final response= await http.delete(uri);
    print(response.statusCode);

    if(response.statusCode ==200){
      final filterd= items.where((element) => element['_id']!=id).toList();
      setState(() {
        items= filterd;
      });
      showSucessMessage('Task Deleted Successfully');
    }else{
      print(response.body);
      showSucessMessage('Couldn\'t Delete The Task ');
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
