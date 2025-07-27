import 'dart:convert';
import 'dart:math';
import 'package:frontend/utils/utils.dart';
import 'package:http/http.dart' as http;

class Payment {
  static String waafiUrl = 'https://api.waafipay.net/asm';

  static Future<Map<String, dynamic>> paymentProcessing(
      Map<String, dynamic> paymentData) async {
    try {
      String invoice = Utils.generateInvoiceId();
      // Generate unique 11-digit requestId
      String requestId = List.generate(11, (index) => Random().nextInt(10)).join();

      var paymentBody = {
        'schemaVersion': "1.0",
        "requestId": requestId,  // Dynamic requestId
        'timestamp': DateTime.now().toIso8601String(),  // ISO formatted timestamp
        'channelName': "WEB",
        'serviceName': "API_PURCHASE",
        'serviceParams': {
          'merchantUid': "M0910291",  // Correct merchant ID
          'apiUserId': "1000416",     // Correct API user ID
          'apiKey': "API-675418888AHX",  // Correct API key
          'paymentMethod': "mwallet_account",
          'payerInfo': {
            'accountNo': paymentData['accountNo'],
          },
          'transactionInfo': {
            'referenceId': paymentData['referenceId'],
            'invoiceId': invoice,
            'amount': paymentData['amount'].toDouble(),  // Ensure double value
            'currency': "USD",
            'description': paymentData['description'],
          },
        },
      };

      final response = await http.post(
        Uri.parse(waafiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(paymentBody),
      );

      final responseData = json.decode(response.body);
      if (responseData['responseCode'] == "200") {  // Waafi uses String status codes
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