import 'dart:io';

import 'package:epub_everwise/ui/epub_provider/epub_book_provider.dart';
import 'package:epub_everwise_example/read_book_cubit.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show SystemChrome, SystemUiOverlayStyle, Uint8List, rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _setSystemUIOverlayStyle();
  }

  Brightness get platformBrightness =>
      MediaQueryData.fromView(WidgetsBinding.instance.window)
          .platformBrightness;

  void _setSystemUIOverlayStyle() {
    if (platformBrightness == Brightness.light) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.grey[50],
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.grey[850],
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Epub demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
        ),
        debugShowCheckedModeBanner: false,
        home: FilePickerScreen(),
      );
}

class FilePickerScreen extends StatefulWidget {
  const FilePickerScreen({super.key});

  @override
  State<FilePickerScreen> createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  final list = [
    'assets/alice_adventures.epub',
    'assets/bajo_la_luz.epub',
    'assets/lion_king.epub',
    'assets/los-miserables.epub',
    'assets/cook.epub',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Epub demo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                  'Select one epub from the default list or pick one from your device', textAlign: TextAlign.center,),
              SizedBox(height: 20),
              ...List.generate(
                list.length,
                (index) => CupertinoButton(
                  onPressed: () async {
                    final loadBook = await rootBundle.load(list[index]);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookProvider(
                          bookData: loadBook.buffer.asUint8List(),
                        ),
                      ),
                    );

                  },
                  child: Text(
                    list[index].replaceAll(
                      "assets/",
                      "",
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();

                    if (result != null) {
                      File file = File(result.files.single.path!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookProvider(
                            bookData: file.readAsBytesSync(),
                          ),
                        ),
                      );
                    } else {
                      // User canceled the picker
                    }
                  },
                  child: Text('Pick From device')),
            ],
          ),
        ),
      ),
    );
  }
}

class BookProvider extends StatelessWidget {
  const BookProvider({super.key, required this.bookData});
  final Uint8List bookData;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReadBookCubit()..initBook(bookData),
      child: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ReadBookCubit, ReadBookState>(builder: (context, state) {
        return state.status == ReadStatus.loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : AnimatedSwitcher(
                duration: Duration(milliseconds: 1000),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: state.status == ReadStatus.bookReady
                    ? EpubBookProvider(
                        epubBook: state.epubBook!,
                      )
                    : Container(
                        constraints: const BoxConstraints.expand(),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                              Color(0xFF0F172A),
                              Color(0xFF450A0A)
                            ])),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ExtendedImage.memory(
                                    state.bookCover!.buffer.asUint8List()),
                              ),
                              const Center(
                                child: CircularProgressIndicator(),
                              )
                            ],
                          ),
                        ),
                      ),
              );
      });




}
