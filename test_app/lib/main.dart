// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:test_app/resources/file_handling.dart';
import 'util/constants.dart' show extension2MimeType;

// Initialize Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import Vertex AI for Firebase
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:firebase_storage/firebase_storage.dart';


// const String _apiKey = String.fromEnvironment('API_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<String> imgExts = ['.jpg','jpeg','.png','.heic','.tiff'];
  List<String> videoExts = ['.avi','.m4v','.mkv','.mmv','.mov','.mpg','.mp4'];

  dynamic inputFile, inputExt;

  final GenerativeModel model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');
  final FirebaseStorage storage = FirebaseStorage.instance;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _pickFile() async {
    do {
      inputFile = await FilePicker.platform.pickFiles(type: FileType.any, allowedExtensions: null,allowMultiple: false, allowCompression: true);
    
      if (inputFile == null) return ;
      print(inputFile);

      inputFile = inputFile.files.first;
      
      inputExt = inputFile.path.split(".").last;
      // print("Ext in map: ${extension2MimeType.containsKey(inputExt)}, $inputExt");
      // print("APIKEY: $_apiKey");
    } while(!(extension2MimeType.containsKey(inputExt)));
    inputExt = inputExt.replaceAll(".","");
  }

  // void _openFile(PlatformFile file) {
  //   OpenFile.open(file.path);
  // }

  void sendToGoogle() async {
    // final video = await File(inputFile.path).readAsBytes();
    // Decide videoParts based on file size (>7MB => Upload to Cloud Storage and use as FilePart)
    late FileData videoParts;
    // if (video.lengthInBytes >= 7*1024*1024) {
    //   videoParts = await uploadMedia(inputFile, storage.ref());
    //   // print(videoParts)
    // } else {
    //   videoParts = DataPart('video/mp4',video);
    // }
    videoParts = FileData('video/mp4', 'gs://vibematch-6ddcd.appspot.com/test_reel_video.mp4');
    print("File Data ready");
    final prompt = TextPart("You're a multimodal language model that can analyze images and videos and understand the content. Given an image or video, you will describe and explain what is happening, and will then summarize your explanation into a single sentence that will be used as a prompt for music generation models such as 'MusicLM', 'MusicGen', and 'MuseGAN'. You must return your response in JSON format consisting of the keys 'Content Explanation' and 'Music Prompt' only. No other response format is acceptable.");
    print("Prompt readyy");
    
    print("Sending to Gemini");
    final response = await model.generateContent([
      Content.multi([prompt, videoParts])
    ]);
    print("Received from gemini");
    
    print(response.text);
    // fetchAvailableModels();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have clicked the button this many times: $_counter',
            ),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headlineMedium,
            // ),
            FloatingActionButton(
            onPressed: () {_pickFile(); },
            tooltip: 'Increment',
            child: const Icon(Icons.upload_file_rounded),
            ),
            FloatingActionButton(
            onPressed: () {sendToGoogle();},
            tooltip: 'Send Data to Google',
            child: const Icon(Icons.send_sharp),
            ), 
            FloatingActionButton(
              onPressed: () {deleteAllMedia(storage.ref());},
              tooltip: 'Delete all uploaded media',
              child: const Icon(Icons.delete_forever),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


