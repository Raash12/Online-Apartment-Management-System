import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class Payment {
  static String waafiUrl = 'https://api.waafipay.net/asm';

  static Future<Map<String, dynamic>> paymentProcessing({
    required String phoneNumber,
    required String amount,
    required String referenceId,
    required String description,
  }) async {
    try {
      // Generate unique 11-digit requestId
      String requestId = List.generate(11, (index) => Random().nextInt(10)).join();

      // Use current timestamp as invoiceId
      String invoice = DateTime.now().millisecondsSinceEpoch.toString();

      var paymentBody = {
        'schemaVersion': "1.0",
        "requestId": requestId,
        'timestamp': DateTime.now().toIso8601String(),
        'channelName': "WEB",
        'serviceName': "API_PURCHASE",
        'serviceParams': {
          'merchantUid': "M0910291",        // Your merchant ID (int or string based on API)
          'apiUserId': 1000416,             // Must be int (not string)
          'apiKey': "API-675418888AHX",    // Your API key
          'paymentMethod': "mwallet_account",
          'payerInfo': {
            'accountNo': phoneNumber,
          },
          'transactionInfo': {
            'referenceId': referenceId,
            'invoiceId': invoice,
            'amount': double.parse(amount),
            'currency': "USD",
            'description': description,
          },
        },
      };

      final response = await http.post(
        Uri.parse(waafiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(paymentBody),
      );

      final responseData = json.decode(response.body);

      if (responseData['responseCode'] == "2001") {
        return {
          'success': true,
          'message': responseData['responseMsg'],
          'invoiceRef': invoice,
        };
      } else {
        return {
          'success': false,
          'message': '${responseData['responseCode']}: ${responseData['responseMsg']}',
          'invoiceRef': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Payment processing failed: ${e.toString()}',
        'invoiceRef': null,
      };
    }
  }
}
