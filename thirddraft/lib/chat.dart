import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirddraft/darkcubit/cubit.dart';
import 'package:thirddraft/darkcubit/states.dart';
import 'package:thirddraft/page_one.dart';
import 'package:http/http.dart' as http;

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _messageController = TextEditingController();
  late int userId;
  late String userName;
  late String message;
  late int selectedMessageId;

  @override
  void initState() {
    super.initState();
    var cubit = AppCubit.get(context);
    if (cubit.userInfo != null) {
      userId = cubit.userInfo!['userDto']['userId'];
      userName = cubit.userInfo!['userDto']['userName'];
    }

      fetchMessages();
  }

  String formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat.jm().format(dateTime);
  }

  Future<void> fetchMessages() async {
    var apiUrl =
        'http://192.168.1.9:8000/api/chat/messages'; // Replace with your API endpoint
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> responseData =
            List<Map<String, dynamic>>.from(
                json.decode(utf8.decode(response.bodyBytes)));
        if (mounted) {
          var cubit = AppCubit.get(context);
          cubit.listSaveMessageData(
              responseData); // Update the cubit with fetched data
        }
      } else {
        log('Failed to fetch messages: ${response.body}');
      }
    } catch (e) {
      log('Error fetching messages: $e');
    }
  }

  Future<void> postMessage(String message) async {
    var apiUrl =
        'http://192.168.1.9:8000/api/chat/$userId/message'; // Replace with your API endpoint
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final uri =
          Uri.parse(apiUrl).replace(queryParameters: {'message': message});
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        log('Message sent successfully');
        fetchMessages(); // Fetch messages again after sending
      } else {
        log('Failed to send message: ${response.body}');
      }
    } catch (e) {
      log('Error sending message: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

  Future<void> postMessageReport(
      userId, int messageId, String reportReason) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    const apiUrl = 'http://192.168.1.9:8000/api/message-reports';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(
          {
            "userId": userId,
            "messageId": messageId,
            "reportReason": reportReason,
          },
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 201) {
        showToast(
          'Your report is being reviewed by a admins',
          context: context,
          animation: StyledToastAnimation.scale,
          reverseAnimation: StyledToastAnimation.fade,
          position: const StyledToastPosition(
              offset: 140, align: Alignment.bottomCenter),
          animDuration: const Duration(seconds: 1),
          duration: const Duration(seconds: 4),
          curve: Curves.elasticOut,
          reverseCurve: Curves.linear,
        );
      } else {
        log('Failed to send report message to the API ${response.body}');
      }
    } catch (e) {
      log('Error in report message: $e');
    }
    return;
  }

  void _showPopupMenu(
      BuildContext context, Offset offset, int messageId) async {
    final result = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, 0),
      items: [
        const PopupMenuItem<String>(
          value: 'Bad Word',
          child: Text('Bad Word'),
        ),
        const PopupMenuItem<String>(
          value: 'Fake News',
          child: Text('Fake News'),
        ),
      ],
      elevation: 8.0,
    );

    // Handle the menu selection
    switch (result) {
      case 'Bad Word':
        postMessageReport(userId, messageId, 'Bad Word');
        log('Bad Word selected');
        break;
      case 'Fake News':
        postMessageReport(userId, messageId, 'Fake News');

        log('Fake News selected');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var cubit = AppCubit.get(context);

    return BlocConsumer<AppCubit, AppState>(
      builder: (BuildContext context, AppState state) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Chat'),
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
                    MaterialPageRoute(builder: (context) => const PageOne()),
                  );
                  return true; // Return true to allow back navigation
                },
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          reverse: true, // Add this line to reverse the order

                          itemCount: cubit.saveMessage?.length ?? 0,
                          itemBuilder: (context, index) {
                            var message = cubit.saveMessage![index];
                            bool isSender =
                                message!['userDto']['userId'] == userId;

                            return Align(
                              alignment: isSender
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: IntrinsicWidth(
                                child: Container(
                                  
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSender
                                        ? Colors.green[100]
                                        : Colors.grey[300],
                                    borderRadius: isSender
                                        ? const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.zero,
                                            bottomLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                          )
                                        : const BorderRadius.only(
                                            topLeft: Radius.zero,
                                            topRight: Radius.circular(15),
                                            bottomLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                          ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isSender
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            message['userDto']['userName'],
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          if (!isSender) ...[
                                            Spacer(),
                                            GestureDetector(
                                              onTapDown:
                                                  (TapDownDetails details) {
                                                selectedMessageId =
                                                    message['messageId'];
                                                _showPopupMenu(
                                                    context,
                                                    details.globalPosition,
                                                    selectedMessageId);
                                              },
                                              child: const Icon(
                                                Icons.more_horiz,
                                                color:
                                                    Color.fromRGBO(8, 15, 44, 1),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        message['messageContent'],
                                        style:
                                            const TextStyle(color: Colors.black),
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        formatTimestamp(message['messageDate']),
                                        style: const TextStyle(
                                            color: Colors.black54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 1, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _messageController,
                              keyboardType: TextInputType.text,
                              autocorrect: true,
                              enableSuggestions: true,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: 'Send Message ...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      MediaQuery.of(context).size.width * .04,
                                    ),
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.width * .01,
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            .04),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final enteredMessage = _messageController.text;
                              if (enteredMessage.trim().isEmpty) {
                                return;
                              }
                              log('Sending message...');
                              FocusManager.instance.primaryFocus?.unfocus();
                              await postMessage(enteredMessage);

                              log(DateTime.now().toIso8601String());

                              _messageController.clear();
                            },
                            icon: const Icon(
                              Icons.send,
                              color: Color.fromRGBO(8, 15, 44, 1),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )),
          ),
        );
      },
      listener: (BuildContext context, AppState state) {},
    );
  }
}
