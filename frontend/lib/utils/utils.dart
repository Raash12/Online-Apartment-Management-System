import 'dart:math';

class Utils {
  static String generateInvoiceId() {
    final now = DateTime.now();
    final random = Random().nextInt(99999).toString().padLeft(5, '0');
    return 'INV-${now.millisecondsSinceEpoch}-$random';
  }
}
