class Payment {
  static Future<Map<String, dynamic>> processPayment(Map<String, dynamic> paymentData) async {
    try {
      final accountNo = paymentData['accountNo']?.toString() ?? '';
      if (accountNo.isEmpty || !RegExp(r'^[0-9]{9}$').hasMatch(accountNo)) {
        return _buildErrorResponse('Invalid EVC number format (9 digits required)');
      }

      // Properly parse amount to double from string
      double amount;
      final rawAmount = paymentData['amount'];

      if (rawAmount is String) {
        amount = double.tryParse(rawAmount) ?? 0.0;
      } else if (rawAmount is num) {
        amount = rawAmount.toDouble();
      } else {
        return _buildErrorResponse('Invalid amount format');
      }

      if (amount <= 0) {
        return _buildErrorResponse('Payment amount must be greater than 0');
      }

      final description = paymentData['description']?.toString() ?? '';
      if (description.isEmpty) {
        return _buildErrorResponse('Missing payment description');
      }

      await Future.delayed(const Duration(seconds: 2)); // Simulate payment delay

      return _buildSuccessResponse(
        amount: amount,
        accountNo: accountNo,
        referenceId: paymentData['referenceId']?.toString(),
      );
    } catch (e) {
      return _buildErrorResponse('Payment processing failed: ${e.toString()}');
    }
  }

  static Map<String, dynamic> _buildSuccessResponse({
    required double amount,
    required String accountNo,
    String? referenceId,
  }) {
    return {
      'success': true,
      'message': 'Payment processed successfully',
      'transactionId': 'TXN${referenceId ?? DateTime.now().millisecondsSinceEpoch}',
      'invoiceRef': 'INV${DateTime.now().millisecondsSinceEpoch}',
      'amount': amount,
      'accountNo': accountNo,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> _buildErrorResponse(String message) {
    return {
      'success': false,
      'message': message,
      'transactionId': '',
      'invoiceRef': '',
      'amount': 0.0,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
