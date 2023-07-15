import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/todo.dart';
import '../constants/colors.dart';
import '../widgets/todo_item.dart';

GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todosList = ToDo.todoList();
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();

  String? email;
  String? displayName;
  _fetch() async {
    final firebaseUser = (await FirebaseAuth.instance.currentUser!).uid;
    print(firebaseUser);
    if (firebaseUser != null) {
      await FirebaseFirestore.instance
          .collection('ToDoList')
          .doc(firebaseUser)
          .get()
          .then((ds) {
        displayName = ds.get('displayName');
        email = ds.get('email');
      }).catchError((e) {
        print(e);
      });
    }
  }

  @override
  void initState() {
    _foundToDo = todosList;
    super.initState();
  }

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      drawer: Drawer(
        child: ListView(
          // Remove padding
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder(
              future: _fetch(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                return UserAccountsDrawerHeader(
                  accountName: Text(displayName.toString()),
                  accountEmail: Text(email.toString()),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/img.png',
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: NetworkImage(
                            'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')),
                  ),
                );
              },
              // child:
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              // leading: Icon(Icons.favorite),
              title: Text('Favorites'),
              onTap: () => null,
            ),
            ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text('History'),
              onTap: () => null,
            ),
            // ListTile(
            //   leading: Icon(Icons.share),
            //   title: Text('Share'),
            //   onTap: () => null,
            // ),
            // ListTile(
            //   leading: Icon(Icons.notifications),
            //   title: Text('Request'),
            // ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => null,
            ),
            ListTile(
              leading: Icon(Icons.contact_page),
              title: Text('Policies'),
              onTap: () => null,
            ),
            Divider(),
            ListTile(
              title: Text('Exit'),
              leading: Icon(Icons.logout),
              onTap: () async {
                _auth.signOut();

                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Home()));
              },
            ),
          ],
        ),
      ),
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Column(
              children: [
                searchBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          top: 50,
                          bottom: 20,
                        ),
                        child: Text(
                          'All ToDos',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      for (ToDo todoo in _foundToDo.reversed)
                        ToDoItem(
                          todo: todoo,
                          onToDoChanged: _handleToDoChange,
                          onDeleteItem: _deleteToDoItem,
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                    left: 20,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                        hintText: 'Add a new todo item',
                        border: InputBorder.none),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  bottom: 20,
                  right: 20,
                ),
                child: ElevatedButton(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                  onPressed: () {
                    _addToDoItem(_todoController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: tdBlue,
                    minimumSize: Size(60, 60),
                    elevation: 10,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void _deleteToDoItem(String id) {
    setState(() {
      todosList.removeWhere((item) => item.id == id);
    });
  }

  void _addToDoItem(String toDo) {
    setState(() {
      todosList.add(ToDo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        todoText: toDo,
      ));
    });
    _todoController.clear();
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        IconButton(
          onPressed: () {
            _scaffoldState.currentState?.openDrawer();
          },
          icon: Icon(
            Icons.menu,
            color: tdBlack,
            size: 30,
          ),
        ),
        Container(
          height: 40,
          width: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset('assets/images/avatar.jpeg'),
          ),
        ),
      ]),
    );
  }
}
