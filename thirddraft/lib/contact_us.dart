import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirddraft/darkcubit/cubit.dart';
import 'package:thirddraft/page_one.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _isTextFieldEmpty = ValueNotifier(true);
  late int userId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_textFieldListener);
    var cubit = AppCubit.get(context);

    if (cubit.userInfo != null) {
      userId = cubit.userInfo!['userDto']['userId'];
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _isTextFieldEmpty.dispose();
    super.dispose();
  }

  void _textFieldListener() {
    setState(() {
      _isTextFieldEmpty.value = _controller.text.isEmpty;
    });
  }

 Future<void> sendDataToApi(String text) async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  var apiUrl = 'http://192.168.1.9:8000/api/reports';
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: json.encode(
        {
          'content': text,
        },
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 201) {
      showToast(
        ' ${response.body}',
        context: context,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.fade,
        position: const StyledToastPosition(
          align: Alignment.bottomCenter,
          offset: 40,
        ),
        animDuration: const Duration(seconds: 1),
        duration: const Duration(seconds: 3),
        curve: Curves.elasticOut,
        reverseCurve: Curves.linear,
      );
      log('Data sent successfully ${response.body}');
    } else {
      log('Failed to send data to the API ${response.body}');
    }
  } catch (e) {
    log('Error in Text: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

@override
Widget build(BuildContext context) {
  return SafeArea(
    child: Listener(
      onPointerDown: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contact Us'),
          toolbarHeight: 100,
          leadingWidth: 70,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color.fromRGBO(8, 15, 44, 1),
              size: 40,
            ),
            hoverColor: Colors.grey,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const PageOne()));
            },
          ),
        ),
        body: WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const PageOne()),
            );
            return true; // Return true to allow back navigation
          },
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Could you describe your issue or suggestion?',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 15.0),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Don\'t share passwords and personal details.'),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Text(
                            'Please don\'t include sensitive information',
                            style: TextStyle(fontSize: 14.0),
                          ),
                          SizedBox(width: 5.0),
                          Icon(Icons.help_outline, size: 18.0),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: 100,
                        maxHeight: 250,
                      ),
                      child: SingleChildScrollView(
                        child: TextFormField(
                          controller: _controller,
                          keyboardType: TextInputType.multiline,
                          maxLines: 8,
                          decoration: const InputDecoration(
                            hintText: 'Tell us how we can improve our product',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 15.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isTextFieldEmpty,
                        builder: (context, isEmpty, child) {
                          return IconButton(
                            onPressed: _isLoading
                                ? null
                                : isEmpty
                                    ? null
                                    : () {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        String text = _controller.text;
                                        sendDataToApi(text);
                                      },
                            icon: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : const Icon(Icons.send_outlined),
                            color: isEmpty
                                ? Colors.grey
                                : const Color.fromRGBO(8, 15, 44, 1),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}