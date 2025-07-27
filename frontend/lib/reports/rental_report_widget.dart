import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RentalReportWidget extends StatefulWidget {
  const RentalReportWidget({super.key});

  @override
  State<RentalReportWidget> createState() => _RentalReportWidgetState();
}

class _RentalReportWidgetState extends State<RentalReportWidget> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _pdfDateFormat = DateFormat('d/M/yyyy');
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<QueryDocumentSnapshot> _allDocs = [];
  List<QueryDocumentSnapshot> _filteredDocs = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text);
    _applyFilterAndSort();
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: Colors.deepPurple),
          textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.deepPurple)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _applyFilterAndSort();
    }
  }

  String _formatCurrency(num? value) {
    return value?.toStringAsFixed(2) ?? '0.00';
  }

  String _formatTimestamp(Timestamp? ts) {
    return ts != null ? _dateFormat.format(ts.toDate()) : '-';
  }

  void _applyFilterAndSort() {
    List<QueryDocumentSnapshot> docs = _allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['startDate'] as Timestamp?)?.toDate();

      if (_startDate != null && date != null && date.isBefore(_startDate!)) return false;
      if (_endDate != null && date != null && date.isAfter(_endDate!)) return false;
      return true;
    }).toList();

    if (_sortColumnIndex != null) {
      docs.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;

        switch (_sortColumnIndex) {
          case 0:
            return _sortAscending ? (aData['apartmentName'] ?? '').compareTo(bData['apartmentName'] ?? '') : (bData['apartmentName'] ?? '').compareTo(aData['apartmentName'] ?? '');
          case 3:
            return _sortAscending ? ((aData['paymentAmount'] as num?) ?? 0).compareTo((bData['paymentAmount'] as num?) ?? 0) : ((bData['paymentAmount'] as num?) ?? 0).compareTo((aData['paymentAmount'] as num?) ?? 0);
          case 4:
            return _sortAscending ? ((aData['days'] as num?) ?? 0).compareTo((bData['days'] as num?) ?? 0) : ((bData['days'] as num?) ?? 0).compareTo((aData['days'] as num?) ?? 0);
          case 5:
            return _sortAscending ? ((aData['totalPrice'] as num?) ?? 0).compareTo((bData['totalPrice'] as num?) ?? 0) : ((bData['totalPrice'] as num?) ?? 0).compareTo((aData['totalPrice'] as num?) ?? 0);
          case 6:
            return _sortAscending ? ((aData['startDate'] as Timestamp?) ?? Timestamp(0, 0)).compareTo((bData['startDate'] as Timestamp?) ?? Timestamp(0, 0)) : ((bData['startDate'] as Timestamp?) ?? Timestamp(0, 0)).compareTo((aData['startDate'] as Timestamp?) ?? Timestamp(0, 0));
          case 7:
            return _sortAscending ? ((aData['endDate'] as Timestamp?) ?? Timestamp(0, 0)).compareTo((bData['endDate'] as Timestamp?) ?? Timestamp(0, 0)) : ((bData['endDate'] as Timestamp?) ?? Timestamp(0, 0)).compareTo((aData['endDate'] as Timestamp?) ?? Timestamp(0, 0));
          default:
            return 0;
        }
      });
    }

    setState(() => _filteredDocs = docs);
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    _applyFilterAndSort();
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final currentDate = _pdfDateFormat.format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Rental Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.purple,
                    ),
                  ),
                  pw.Text(
                    'Date: $currentDate',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Text(
                    'Date Range: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    _startDate != null ? _pdfDateFormat.format(_startDate!) : 'All',
                  ),
                  pw.Text(' - '),
                  pw.Text(
                    _endDate != null ? _pdfDateFormat.format(_endDate!) : 'All',
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.purple),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(color: PdfColors.purple),
                headers: [
                  'Apartment',
                  'Rent/Day',
                  'Days',
                  'Total',
                  'Start Date',
                  'End Date'
                ],
                data: _filteredDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return [
                    data['apartmentName'] ?? '-',
                    _formatCurrency(data['paymentAmount'] as num?),
                    '${data['days'] ?? 0}',
                    _formatCurrency(data['totalPrice'] as num?),
                    _pdfDateFormat.format((data['startDate'] as Timestamp).toDate()),
                    _pdfDateFormat.format((data['endDate'] as Timestamp).toDate()),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total Records: ${_filteredDocs.length}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade700,
        title: const Text('Rental Report', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        color: Colors.blueGrey[50],
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 5,
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.deepPurple,
                              side: BorderSide(color: Colors.deepPurple.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.date_range),
                            label: Text(
                              _startDate != null ? _dateFormat.format(_startDate!) : 'Start Date',
                              style: TextStyle(
                                color: _startDate != null ? Colors.deepPurple.shade900 : Colors.deepPurple.shade400,
                              ),
                            ),
                            onPressed: () => _pickDate(context, true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.deepPurple,
                              side: BorderSide(color: Colors.deepPurple.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.date_range),
                            label: Text(
                              _endDate != null ? _dateFormat.format(_endDate!) : 'End Date',
                              style: TextStyle(
                                color: _endDate != null ? Colors.deepPurple.shade900 : Colors.deepPurple.shade400,
                              ),
                            ),
                            onPressed: () => _pickDate(context, false),
                          ),
                        ),
                      ],
                    ),
                   
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('rent_now').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.black)));
                  }

                  _allDocs = snapshot.data?.docs ?? [];
                  if (_filteredDocs.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _applyFilterAndSort());
                  }

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.deepPurple.shade100),
                        dataRowColor: MaterialStateProperty.all(Colors.white),
                        columnSpacing: 28,
                        columns: [
                          DataColumn(label: _header('Apartment'), onSort: (i, asc) => _onSort(i, asc)),
                          DataColumn(label: _header('Rent/Day'), numeric: true, onSort: (i, asc) => _onSort(i, asc)),
                          DataColumn(label: _header('Days'), numeric: true, onSort: (i, asc) => _onSort(i, asc)),
                          DataColumn(label: _header('Total'), numeric: true, onSort: (i, asc) => _onSort(i, asc)),
                          DataColumn(label: _header('Start Date'), onSort: (i, asc) => _onSort(i, asc)),
                          DataColumn(label: _header('End Date'), onSort: (i, asc) => _onSort(i, asc)),
                        ],
                        rows: _filteredDocs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return DataRow(
                            cells: [
                              DataCell(Text(data['apartmentName'] ?? '-', style: TextStyle(color: Colors.deepPurple.shade900))),
                              DataCell(Text(_formatCurrency(data['paymentAmount'] as num?), style: TextStyle(color: Colors.deepPurple.shade900))),
                              DataCell(Text('${data['days'] ?? 0}', style: TextStyle(color: Colors.deepPurple.shade900))),
                              DataCell(Text(_formatCurrency(data['totalPrice'] as num?), style: TextStyle(color: Colors.deepPurple.shade900))),
                              DataCell(Text(_formatTimestamp(data['startDate'] as Timestamp?), style: TextStyle(color: Colors.deepPurple.shade900))),
                              DataCell(Text(_formatTimestamp(data['endDate'] as Timestamp?), style: TextStyle(color: Colors.deepPurple.shade900))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.deepPurple,
        fontSize: 14,
      ),
    );
  }
}