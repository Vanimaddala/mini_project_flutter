import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendSMS(String accountSid, String authToken, String from,
    String to, String body) async {
  final url =
      'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json';
  final headers = {
    'Authorization':
        'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  final bodyData = {
    'From': from,
    'To': to,
    'Body': body,
  };

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: bodyData,
  );

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 201 || response.statusCode == 200) {
    print('SMS sent successfully');
  } else {
    print('Failed to send SMS: ${response.statusCode} - ${response.body}');
    throw Exception('Failed to send SMS');
  }
}
