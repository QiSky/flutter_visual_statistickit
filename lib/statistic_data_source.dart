import 'package:flutter/material.dart';

class StatisticDataSource extends DataTableSource {
  List<Map<String, dynamic>>? data;

  StatisticDataSource({this.data});

  @override
  DataRow? getRow(int index) {
    if (data?.isEmpty == true) {
      return null;
    } else {
      return DataRow.byIndex(index: index, cells: <DataCell>[
        DataCell(Text('${data?[index]['package']}')),
        DataCell(Text('${data?[index]['identify']}')),
        DataCell(Text('${data?[index]['event']}')),
        DataCell(Text('${data?[index]['time']}')),
        DataCell(Text('${data?[index]['data'].toString()}')),
      ]);
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
