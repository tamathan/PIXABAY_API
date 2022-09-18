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
  List<PixabayImage> pixabayImages = [];

  //Futureの場合は、async~awaitを使う！！
  //finalは、ここから変数に代入することがないときに使用する。（コードを読みやすくするため）
  //finalを使用すると、変数の型は省略することが可能。
  Future<void> fetchImages(String text) async {
    final Response response = await Dio().get(
      'https://pixabay.com/api',
      queryParameters: {
        'key': '29701485-4a0a0f9e3e9d03b43fd6a66b9',
        'q': text,
        'image_type': 'photo',
        'per_page': '100'
      },
    );

    final List hits = response.data['hits'];
    pixabayImages = hits.map(
      (e) {
        return PixabayImage.fromMap(e);
      },
    ).toList();

    setState(() {});
  }

  //画像をshareする。
  Future<void> shareImages(url) async {
    //1.URL　から画像をダウンロード
    final Response response = await Dio()
        .get(url, options: Options(responseType: ResponseType.bytes));

    //2.ダウンロードしたデータをファイルに保存
    final Directory dir = await getTemporaryDirectory();
    final File file =
        await File('${dir.path}/image.png').writeAsBytes(response.data);

    //3.Shareパッケージを呼び出して共有
    Share.shareFiles([file.path]);
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
        itemCount: pixabayImages.length,
        itemBuilder: (context, index) {
          final pixabayImage = pixabayImages[index];
          return InkWell(
            onTap: () async {
              shareImages(pixabayImage.webformatURL);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  pixabayImage.previewURL,
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
                              '${pixabayImage.likes}',
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

//クラスを作成する。
class PixabayImage {
  final String webformatURL;
  final String previewURL;
  final int likes;

  PixabayImage({
    required this.webformatURL,
    required this.previewURL,
    required this.likes,
  });

  factory PixabayImage.fromMap(Map<String, dynamic> map) {
    return PixabayImage(
      webformatURL: map['webformatURL'],
      previewURL: map['previewURL'],
      likes: map['likes'],
    );
  }
}
