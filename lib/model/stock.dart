import 'package:flutter/cupertino.dart';

class Stock {
  static const tblStock = 'stocks';
  static const colId = 'id';
  static const colNamaBarang = 'namaBarang';
  static const colQuantity = 'quantity';
  static const colHarga = 'harga';
  static const colTotalHarga = 'totalHarga';

  Stock({this.id, this.namaBarang, this.quantity, this.harga, this.totalHarga});

  Stock.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    namaBarang = map[colNamaBarang];
    quantity = map[colQuantity];
    harga = map[colHarga];
    totalHarga = map[colTotalHarga];
  }

  int id;
  String namaBarang;
  String quantity;
  String harga;
  String totalHarga;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colId: id,
      colNamaBarang: namaBarang,
      colQuantity: quantity,
      colHarga: harga,
      colTotalHarga: totalHarga
    };
    if (id != null) map[colId] = id;
    return map;
  }
}
