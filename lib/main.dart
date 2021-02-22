import 'dart:typed_data';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';
import 'package:string_validator/string_validator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iEsnaad - Printing Module',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController portController;
  TextEditingController ipController;

  Future<void> testReceipt() async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final profiles = await CapabilityProfile.getAvailableProfiles();
    for (var printer in profiles) {
      print('key: ${printer['key']}');
      print('model: ${printer['model']} ');
      print('vendor: ${printer['vendor']} ');
      print('vedescriptionndor: ${printer['description']} ');
    }
    final printer = NetworkPrinter(paper, profile);

    if (isIP(ipController.text)) {
      print('IP: ${ipController.text}');
      print('Port: ${portController.text}');
      final PosPrintResult res = await printer.connect(ipController.text,
          port: int.parse(portController.text), timeout: Duration(seconds: 60));
      if (res == PosPrintResult.success) {
        await printDemoReceipt(printer);
        printer.disconnect();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(
          content: new Text('Enter a valid IP'),
        ),
      );
    }
  }

  printDemoReceipt(NetworkPrinter printer) async {
    printer.text('ا ب ت ث ج ح خ د ذ ر ز س ش ص ض ف ق ك ل م ن ه و ي');
    // printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
    //     styles: PosStyles(codeTable: 'CP1252'));
    // printer.text('Special 2: blåbærgrød',
    //     styles: PosStyles(codeTable: 'CP1252'));

    printer.text('أحمد الحاج', styles: PosStyles(bold: true));
    printer.text('عمار', styles: PosStyles(reverse: true));
    printer.text('محمد السيد',
        styles: PosStyles(underline: true), linesAfter: 1);
    printer.text('عبدالرحيم - شمال', styles: PosStyles(align: PosAlign.left));
    printer.text('اسامة - منتصف', styles: PosStyles(align: PosAlign.center));
    printer.text('قاسم - يمين',
        styles: PosStyles(align: PosAlign.right), linesAfter: 1);

    printer.row([
      PosColumn(
        text: 'العمود ٣',
        width: 3,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'العمود ٢',
        width: 6,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'العمود ١',
        width: 3,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
    ]);

    printer.text('الاسناد الرقمي 200%',
        styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    final ByteData data = await rootBundle.load('assets/esnaad.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final Image image = decodeImage(bytes);
    printer.image(image);

    printer.feed(2);
    printer.cut();

    printer.text('خضروات',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    printer.text('السبهاني، طريق الليث',
        styles: PosStyles(align: PosAlign.center));
    printer.text('مكة المكرمة - المملكةالعربية السعودية',
        styles: PosStyles(align: PosAlign.center));
    printer.text('966125305363', styles: PosStyles(align: PosAlign.center));
    printer.text('http://www.i-Esnaad.com',
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    printer.hr();
    printer.row([
      PosColumn(
          text: 'الاجمالي', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'السعر', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(text: 'العنصر', width: 7),
      PosColumn(text: 'كمية', width: 1),
    ]);

    printer.row([
      PosColumn(
          text: '1.98', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '0.99', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(text: 'بصل', width: 7),
      PosColumn(text: '2', width: 1),
    ]);
    printer.row([
      PosColumn(
          text: '3.45', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '3.45', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(text: 'بيتزا', width: 7),
      PosColumn(text: '1', width: 1),
    ]);
    printer.row([
      PosColumn(
          text: '2.99', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '2.99', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(text: 'طماطم', width: 7),
      PosColumn(text: '1', width: 1),
    ]);
    printer.row([
      PosColumn(
          text: '2.55', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '0.85', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(text: 'خيار', width: 7),
      PosColumn(text: '3', width: 1),
    ]);
    printer.hr();

    printer.row([
      PosColumn(
          text: '\$10.97',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: 'الاجمالي',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);

    printer.hr(ch: '=', linesAfter: 1);

    printer.row([
      PosColumn(
          text: '\$15.00',
          width: 4,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      PosColumn(
          text: 'مدفوع كاش',
          width: 8,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    ]);
    printer.row([
      PosColumn(
          text: '\$4.03',
          width: 4,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      PosColumn(
          text: 'الباقي',
          width: 8,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    ]);

    printer.feed(2);
    printer.text('شكرا لك!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    printer.text(timestamp,
        styles: PosStyles(align: PosAlign.center), linesAfter: 2);

    printer.feed(1);
    printer.cut();
  }

  @override
  void initState() {
    portController = TextEditingController(text: '91000');
    ipController = TextEditingController(text: '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('iEsnaad - Printing Module'),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: ipController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'IP Address',
                  hintText: 'Enter IP Address',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: portController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Default Printers Port',
                  hintText: 'Port',
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await testReceipt();
          },
          tooltip: 'طباعة فاتورة تجريبية',
          child: Icon(Icons.print),
        ));
  }
}
