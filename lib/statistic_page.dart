import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:visual_statistic/statistic_data_source.dart';
import 'package:web_socket_channel/io.dart';

class StatisticPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>>? data = [];

  StatisticDataSource _source = StatisticDataSource();

  bool isConnected = false;

  IOWebSocketChannel? channel;

  StreamSubscription? socketStream;

  @override
  void initState() {
    _source.data = data;
    super.initState();
  }

  void connectBtn() {
    if (!isConnected) {
      try {
        channel = IOWebSocketChannel.connect(Uri.parse(_controller.text));
      }catch(e) {
        Fluttertoast.showToast(msg: '连接地址错误', webPosition: "center");
        return;
      }
      socketStream = channel?.stream.listen((message) {
        setState(() {
          data?.add(jsonDecode(message));
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
