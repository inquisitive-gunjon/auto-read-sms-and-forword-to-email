import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:async';
import 'package:telephony/telephony.dart';
import 'package:telephony_example/service.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = "";
  int? id;
  String? address;
  String? body;
  int? date;
  int? dateSent;
  bool? read;
  bool? seen;
  String? subject;
  int? subscriptionId;
  int? threadId;
  SmsType? type;
  SmsStatus? status;
  String? serviceCenterAddress;
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
      id = message.id;
      address = message.address;
      date = message.date;
      dateSent = message.dateSent;
      read = message.read;
      seen = message.seen;
      subject = message.subject;
      subscriptionId = message.subscriptionId;
      threadId = message.threadId;
      type = message.type;
      status = message.status;
      serviceCenterAddress = message.serviceCenterAddress;
    });
    await senEmail(_message);
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }
  Future senEmail(String sms)async{
    final user= await GoogleAuthApi.signIn();
    if(user==null)return;

    //final email = 'gunjon.cse@gmail.com';
    final email = user.email;
    final auth = await user.authentication;
    final accessToken=auth.accessToken!;
    final smtpServer = gmailSaslXoauth2(email, accessToken);

    final message = Message()
    ..from=Address(email,'Gunjon')
    ..recipients=['gunjon.cse@gmail.com']
    ..subject='from sms'
    ..text=sms;

    try{
      await send(message, smtpServer);
      print("success");
    }on MailerException catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
      // String _message = "";
      // int? id;
      // String? address;
      // String? body;
      // int? date;
      // int? dateSent;
      // bool? read;
      // bool? seen;
      // String? subject;
      // int? subscriptionId;
      // int? threadId;
      // SmsType? type;
      // SmsStatus? status;
      // String? serviceCenterAddress;
          Center(child: Text("Latest received SMS id: $id")),
          Center(child: Text("Latest received SMS address: $address")),
          Center(child: Text("Latest received SMS message: $_message")),
          Center(child: Text("Latest received SMS date: ${DateTime.now()}")),
          Center(child: Text("Latest received SMS dateSent: $dateSent")),
          Center(child: Text("Latest received SMS read: $read")),
          Center(child: Text("Latest received SMS subject: $subject")),
          Center(child: Text("Latest received SMS subscriptionId: $subscriptionId")),
          Center(child: Text("Latest received SMS type: $type")),
          Center(child: Text("Latest received SMS status: $status")),
          Center(child: Text("Latest received SMS serviceCenterAddress: $serviceCenterAddress")),
          TextButton(
              onPressed: () async {
                await telephony.openDialer("123413453");
              },
              child: Text('Open Dialer'))
        ],
      ),
    ));
  }
}
