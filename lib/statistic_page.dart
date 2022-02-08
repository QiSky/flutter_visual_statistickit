import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:visual_statistic/statistic_data_source.dart';
import 'package:web_socket_channel/html.dart';

class StatisticPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _packageController = TextEditingController();
  final TextEditingController _identifyController = TextEditingController();

  final List<Map<String, dynamic>>? data = [];

  StatisticDataSource _source = StatisticDataSource();

  bool isConnected = false;

  HtmlWebSocketChannel? channel;

  StreamSubscription? socketStream;

  String? _package;

  @override
  void initState() {
    _source.data = data;
    super.initState();
  }

  void connectBtn() {
    if (_packageController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: '包名不能为空', webPosition: "center");
      return;
    }
    if (!isConnected) {
      try {
        channel = HtmlWebSocketChannel.connect(Uri.parse(_controller.text));
      } catch (e) {
        Fluttertoast.showToast(msg: '连接地址错误', webPosition: "center");
        return;
      }
      _package = _packageController.text;
      channel?.sink.add(jsonEncode({
        "type": "add",
        "package": _packageController.text,
        "identify": _identifyController.text
      }));
      socketStream = channel?.stream.listen((message) {
        setState(() {
          _source = StatisticDataSource();
          _source.data = data;
          var res = jsonDecode(message);
          if(res['packages'] == _package) {
            res['time'] = DateTime.fromMillisecondsSinceEpoch(res['time']).toString();
            data?.insert(0, res);
          }
        });
      });
      setState(() {
        isConnected = !isConnected;
      });
    }
  }

  void disconnectBtn() {
    if (isConnected) {
      socketStream?.cancel();
      channel?.sink.close();
      setState(() {
        isConnected = !isConnected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('在线实时统计'),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          SizedBox(
            height: 10,
          ),
          Row(children: [
            Spacer(),
            Text('地址'),
            SizedBox(
              width: 10,
            ),
            Container(
              width: 200,
              child: CupertinoTextField(
                controller: _controller,
                placeholder: "ws://ip:port",
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text('包名'),
            SizedBox(
              width: 10,
            ),
            Container(
              width: 200,
              child: CupertinoTextField(
                controller: _packageController,
                placeholder: "包名",
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text('标识'),
            SizedBox(
              width: 10,
            ),
            Container(
              width: 200,
              child: CupertinoTextField(
                controller: _identifyController,
                placeholder: "标识",
              ),
            ),
            SizedBox(
              width: 10,
            ),
            RaisedButton(
                color: Colors.blue,
                onPressed: !isConnected
                    ? () {
                        connectBtn();
                      }
                    : null,
                child: Center(
                    child: Text(
                  '连接',
                  style: TextStyle(color: Colors.white),
                ))),
            SizedBox(
              width: 10,
            ),
            RaisedButton(
                color: Colors.red,
                onPressed: isConnected
                    ? () {
                        disconnectBtn();
                      }
                    : null,
                child: Center(
                    child: Text(
                  '断开',
                  style: TextStyle(color: Colors.white),
                ))),
            Spacer()
          ]),
          SizedBox(
            height: 10,
          ),
          PaginatedDataTable(
            source: _source,
            columnSpacing: 120.0,
            columns: <DataColumn>[
              DataColumn(label: const Text('包名'), numeric: false),
              DataColumn(label: const Text('标识'), numeric: false),
              DataColumn(label: const Text('事件'), numeric: false),
              DataColumn(label: const Text('时间'), numeric: false),
              DataColumn(label: const Text('数据'), numeric: false),
            ],
          )
        ])));
  }
}
