import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';

class PdfRentalInvoiceService {
  static Future<Uint8List> generateRentalInvoicePdf(Map<String, dynamic> rentalData) async {
    final pdf = pw.Document();

    final dateFormatter = DateFormat('yyyy-MM-dd');
    final currencyFormat = NumberFormat.simpleCurrency(name: 'USD');

    final createdAt = (rentalData['createdAt'] as Timestamp).toDate();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Rental Invoice',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(createdAt)}'),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),

              pw.Text(
                'Customer Details:',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Name: ${rentalData['customerName']}'),
              pw.Text('Contact: ${rentalData['customerContact']}'),
              pw.Text('Payment Number: ${rentalData['paymentNumber']}'),
              pw.SizedBox(height: 20),

              pw.Text(
                'Rental Details:',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Apartment: ${rentalData['apartmentName']}'),
              pw.Text('Rental Price per Day: ${currencyFormat.format(rentalData['rentPrice'])}'),
              pw.Text(
                  'Rental Period: ${dateFormatter.format((rentalData['startDate'] as Timestamp).toDate())} - ${dateFormatter.format((rentalData['endDate'] as Timestamp).toDate())}'),
              pw.Text('Number of Days: ${rentalData['days']}'),
              pw.SizedBox(height: 20),

              pw.Text(
                'Payment Details:',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Payment Reference: ${rentalData['paymentReference']}'),
              pw.Text('Amount Paid: ${currencyFormat.format(rentalData['totalPrice'])}'),
              pw.SizedBox(height: 30),

              pw.Center(
                child: pw.Text(
                  'Thank you for your rental!',
                  style: pw.TextStyle(fontSize: 18, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
