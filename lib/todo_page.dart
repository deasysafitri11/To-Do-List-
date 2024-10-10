import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model for Todo item
class TodoItem {
  String title;
  bool isDone;

  TodoItem({required this.title, this.isDone = false});
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<TodoItem> _todoList = [];
  final TextEditingController _todoController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }

  Future<void> _loadTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? todos = prefs.getStringList("todos");

    if (todos != null) {
      setState(() {
        _todoList = todos.map((item) {
          final data = item.split('|');
          return TodoItem(title: data[0], isDone: data[1] == 'true');
        }).toList();
      });
    }
  }

  Future<void> _saveTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> todos = _todoList.map((item) {
      return '${item.title}|${item.isDone}';
    }).toList();
    await prefs.setStringList("todos", todos);
  }

  void _addTodo() {
    if (_todoController.text.isNotEmpty) {
      setState(() {
        _todoList.add(TodoItem(title: _todoController.text));
        _todoController.clear();
      });
      _saveTodoList();
      // Scroll to the bottom after adding a new item
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  void _removeTodoAt(int index) {
    setState(() {
      _todoList.removeAt(index);
    });
    _saveTodoList();
  }

  void _editTodoAt(int index) {
    _todoController.text = _todoList[index].title;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit To-Do'),
          content: TextField(
            controller: _todoController,
            decoration: const InputDecoration(hintText: 'Enter updated to-do'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _todoList[index].title = _todoController.text;
                  _todoController.clear();
                });
                _saveTodoList();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _toggleTodoCompletion(int index) {
    setState(() {
      _todoList[index].isDone = !_todoList[index].isDone;
    });
    _saveTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 249, 204, 190),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "To-Do List",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _todoList.length.toString(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _todoController,
                        decoration: InputDecoration(
                          hintText: 'Enter a new to-do',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addTodo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                      child: const Icon(Icons.add, color: Color.fromARGB(255, 87, 36, 16)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    itemCount: _todoList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading: Icon(Icons.fastfood, color: Colors.orange), // Ikon makanan
                          title: Text(
                            _todoList[index].title,
                            style: TextStyle(
                              decoration: _todoList[index].isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color.fromARGB(255, 78, 42, 33)),
                                onPressed: () => _editTodoAt(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeTodoAt(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // You can implement another functionality here if needed
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          size: 40,
          color: Colors.white24,
        ),
      ),
    );
  }
}
