import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'chat_room_page.dart';

class LoginRegisterPage extends StatefulWidget {
  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final PageController _pageController = PageController(initialPage: 0);
  int currentPage = 0;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.18.26:3000/register'),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 201) {
      print('Registration successful');
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.18.26:3000/login'),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', username);
      final token = jsonDecode(response.body)['token'];
      return token;
    } else {
      throw Exception('Failed to login');
    }
  }

  @override
  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue, Colors.indigo],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        SizedBox(height: 40.0),
        Icon(
          Icons.send,
          color: Colors.white,
          size: 128,
        ),
        _buildPageIndicator(),
        Expanded(
          child: PageView(
            controller: _pageController,
            children: [
              _buildCard(
                'Login',
                _buildForm(
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final token = await login(
                            usernameController.text, passwordController.text);
                        print('Logged in with token: $token');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRoomPage(token),
                          ),
                        );
                      } catch (e) {
                        print('Login failed: $e');
                      }
                    },
                    child: Text('Login'),
                  ),
                ),
              ),
              _buildCard(
                'Register',
                _buildForm(
                  ElevatedButton(
                    onPressed: () async {
                      print(usernameController.text);
                      print(passwordController.text);
                      try {
                        await register(
                            usernameController.text, passwordController.text);
                        print('Registration successful');
                      } catch (e) {
                        print('Registration failed: $e');
                      }
                    },
                    child: Text('Register'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(String title, Widget content) {
    return Card(
      margin: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 16.0),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildForm(Widget button) {
    return Column(
      children: [
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            labelText: 'Username',
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 16.0),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            filled: true,
            fillColor: Colors.white,
          ),
          obscureText: true,
        ),
        SizedBox(height: 16.0),
        button,
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 4.0,
            backgroundColor: currentPage == 0 ? Colors.white : Colors.grey,
          ),
          SizedBox(width: 8.0),
          CircleAvatar(
            radius: 4.0,
            backgroundColor: currentPage == 1 ? Colors.white : Colors.grey,
          ),
        ],
      ),
    );
  }
}
