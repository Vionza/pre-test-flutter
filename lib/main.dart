import 'package:flutter/material.dart';
import 'package:pretestflutter/model/stock.dart';
import 'package:pretestflutter/utils/database_helper.dart';

const darkBlueColor = Color(0xff486579);
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Apps',
      theme: ThemeData(
        primaryColor: darkBlueColor,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Stock Apps'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Stock _stock = Stock();
  List<Stock> _listStock = [];
  DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();
  final _ctrlNamaBarang = TextEditingController();
  final _ctrlQuantity = TextEditingController();
  final _ctrlHarga = TextEditingController();
  final _ctrlTotalHarga = TextEditingController();
  final _ctrlSumTotal = TextEditingController();
  int total;

  @override
  void initState() {
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
      _refreshStockList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
            child: Text(
          widget.title,
          style: TextStyle(color: darkBlueColor),
        )),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[_form(), _list()],
        ),
      ),
    );
  }

  _form() => Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _ctrlNamaBarang,
                decoration: InputDecoration(labelText: 'Nama Barang'),
                onSaved: (val) => setState(() => _stock.namaBarang = val),
                validator: (val) =>
                    (val.length == 0 ? 'Field Tidak Boleh Kosong' : null),
              ),
              TextFormField(
                controller: _ctrlQuantity,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                onSaved: (val) => setState(() => _stock.quantity = val),
                validator: (val) =>
                    (val.length == 0 ? 'Field Tidak Boleh Kosong' : null),
              ),
              TextFormField(
                controller: _ctrlHarga,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Harga'),
                onChanged: (val) {
                  total = int.parse(val) * int.parse(_ctrlQuantity.text);
                  _ctrlTotalHarga.text = total.toString();
                },
                onSaved: (val) => setState(() => _stock.harga = val),
                validator: (val) =>
                    (val.length == 0 ? 'Field Tidak Boleh Kosong' : null),
              ),
              TextFormField(
                controller: _ctrlTotalHarga,
                decoration: InputDecoration(labelText: 'Total Harga'),
                onSaved: (val) => setState(() => _stock.totalHarga = val),
                enabled: false,
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: RaisedButton(
                  onPressed: () => _onSubmit(),
                  child: Text('Submit'),
                  color: darkBlueColor,
                  textColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      );

  _refreshStockList() async {
    List<Stock> x = await _dbHelper.fetchStocks();
    _listStock = x;
  }

  _onSubmit() async {
    var form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      if (_stock.id == null)
        await _dbHelper.insertStock(_stock);
      else
        await _dbHelper.updateStock(_stock);
      _refreshStockList();
      _resetForm();
    }
  }

  _resetForm() {
    setState(() {
      _formKey.currentState.reset();
      _stock.id = null;
      _ctrlNamaBarang.clear();
      _ctrlQuantity.clear();
      _ctrlHarga.clear();
      _ctrlTotalHarga.clear();
    });
  }

  _list() => Expanded(
        child: Card(
          margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.account_circle,
                        color: darkBlueColor, size: 40.0),
                    title: Text(
                      _listStock[index].namaBarang.toUpperCase(),
                      style: TextStyle(
                          color: darkBlueColor, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Quantity :' +
                        _listStock[index].quantity +
                        '\nHarga : ' +
                        _listStock[index].harga +
                        '\nTotal Harga : ' +
                        _listStock[index].totalHarga),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_sweep, color: darkBlueColor),
                      onPressed: () async {
                        await _dbHelper.deleteStock(_listStock[index].id);
                        _resetForm();
                        _refreshStockList();
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _stock = _listStock[index];
                        _ctrlNamaBarang.text = _listStock[index].namaBarang;
                        _ctrlQuantity.text = _listStock[index].quantity;
                        _ctrlHarga.text = _listStock[index].harga;
                        _ctrlTotalHarga.text = _listStock[index].totalHarga;
                      });
                    },
                  ),
                  Divider(
                    height: 5.0,
                  )
                ],
              );
            },
            itemCount: _listStock.length,
          ),
        ),
      );
}
