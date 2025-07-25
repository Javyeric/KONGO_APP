import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/product.dart';

class ReceiptGenerator {
  static Future<void> generateReceipt({
    required Map<Product, int> cartItems,
    required double total,
    required String date,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Date: $date'),
              pw.Divider(),

              ...cartItems.entries.map((entry) {
                final product = entry.key;
                final qty = entry.value;
                final subtotal = product.price * qty;

                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${product.name} (${product.size}) x$qty'),
                    pw.Text('KES ${subtotal.toStringAsFixed(2)}'),
                  ],
                );
              }),

              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('KES ${total.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Center(child: pw.Text('THANK YOU!', style: pw.TextStyle(fontSize: 18))),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
