import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PixabayPage(),
    );
  }
}

class PixabayPage extends StatefulWidget {
  const PixabayPage({Key? key}) : super(key: key);

  @override
  State<PixabayPage> createState() => _PixabayPageState();
}

class _PixabayPageState extends State<PixabayPage> {
  //空のリストとして、定義をする
  List hits = [];

  //Futureの場合は、async~awaitを使う！！
  Future<void> fetchImages(String text) async {
    Response response = await Dio().get(
        'https://pixabay.com/api/?key=29701485-4a0a0f9e3e9d03b43fd6a66b9&q=$text&image_type=photo&per_page=100');
    hits = response.data['hits'];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    //最初の１回だけ呼ばれる！
    fetchImages('花');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: TextFormField(
          initialValue: "花",
          decoration: const InputDecoration(
            fillColor: Colors.white,
            filled: true,
          ),
          onFieldSubmitted: (text) {
            fetchImages(text);
          },
        ),
      ),
      body: GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: hits.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> hit = hits[index];
          return InkWell(
            onTap: () async {
              //1.URL　から画像をダウンロード
              Response response = await Dio().get(hit['webformatURL'],
                  options: Options(responseType: ResponseType.bytes));

              //2.ダウンロードしたデータをファイルに保存
              Directory dir = await getTemporaryDirectory();
              File file = await File('${dir.path}/image.png')
                  .writeAsBytes(response.data);

              //3.Shareパッケージを呼び出して共有
              Share.shareFiles([file.path]);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  hit['previewURL'],
                  fit: BoxFit.cover,
                ),
                Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                        color: Colors.white,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 16,
                              color: Color.fromARGB(255, 206, 38, 38),
                            ),
                            Text(
                              '${hit['likes']}',
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 206, 38, 38),
                                  fontSize: 16),
                            ),
                          ],
                        ))),
              ],
            ),
          );
        },
      ),
    );
  }
}
