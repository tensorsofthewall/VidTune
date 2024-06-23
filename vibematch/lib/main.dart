import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

// Audio Player
import 'package:audioplayers/audioplayers.dart';

// Import methods and constants
import 'package:vibematch/resources/file_handling.dart';
import 'util/constants.dart' show extension2MimeType, geminiSystemInstructions, type2MimeTypes;
import 'package:vibematch/resources/musicgen_api.dart';


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
  // late;

  dynamic inputFile;
  dynamic inputExt;

  Map<String, dynamic> geminiOutput = {};
  bool shouldShowExplanationWidget = false;
  bool shouldShowAudioWidget = false;

  Uint8List? audioBytes;

  final GenerativeModel model = FirebaseVertexAI.instance.generativeModel(
    model: 'gemini-1.5-flash', 
    systemInstruction: Content.system(geminiSystemInstructions),
    generationConfig: GenerationConfig(responseMimeType: 'application/json'
  ));
  final FirebaseStorage storage = FirebaseStorage.instance;
  late AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();

    player.setReleaseMode(ReleaseMode.stop);
    // await player.setSource(BytesSource(response.bodyBytes));
    // await player.resume();
  }

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
      // print(inputFile);

      inputFile = inputFile.files.first;

    } while(!(extension2MimeType.containsKey(inputFile.path.split(".").last)));

    setState(() {
      inputExt = inputFile.path.split(".").last.toString();
    });
  }

  // void _openFile(PlatformFile file) {
  //   OpenFile.open(file.path);
  // }

  void sendToGoogle() async {
    if (inputFile != null) {
      final file = await File(inputFile.path).readAsBytes();
      late dynamic fileParts;
      
      // Decide fileParts based on file size (>7MB => Upload to Cloud Storage and use as FilePart)
      if (file.lengthInBytes >= 7*1024*1024) {
        fileParts = await uploadMedia(inputFile, storage.ref());
        // print(fileParts)
      } else {
        fileParts = DataPart(extension2MimeType[inputExt].toString(),file);
      }
      
      // videoParts = FileData('video/mp4', 'gs://vibematch-6ddcd.appspot.com/test_reel_video.mp4');
      // videoParts = FileData('image/jpeg', 'gs://vibematch-6ddcd.appspot.com/test.jpg');
      
      
      final prompt = TextPart(
        '''
        Describe this ${type2MimeTypes.entries.firstWhere((k) => k.value.contains(inputExt)).key} and generate a prompt for music generation.
        '''
      );

      print(prompt.text);
      
      
      // print("Sending to Gemini");
      final response = await model.generateContent([
        Content.multi([prompt, fileParts])
      ]);
      // print("Received from gemini");

      // print(response.text);

      final responseText = json.decode(response.text.toString());
      setState(() {
        geminiOutput = responseText;
        shouldShowExplanationWidget = true;
        inputFile = null;
        inputExt = null;
      });
    } else {
      // print("No file was selected.");
    }
  }

  void vibeMatch(String musicPrompt) async{
    List<String> prompts = [];
    prompts.add(musicPrompt);
    final response = await generateMusic(prompts);
    await player.setSource(BytesSource(response.bodyBytes));
    setState(() {
      audioBytes = response.bodyBytes;
      shouldShowAudioWidget = true;
    });
  }

  // Map<String, dynamic> convertStringToJson(String str) {
  //   // Replace single quotes with double quotes to match JSON format
  //   String jsonString = str.replaceAll("'", '"');
  //   print(jsonString);

  //   // Decode the JSON string
  //   return json.decode(jsonString);
  // }

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
            Visibility(
              visible: shouldShowExplanationWidget,
              child: shouldShowExplanationWidget == true ? Text("Description: ${geminiOutput['Content Description']}") : const Text(""),
            ),
            Visibility(
              visible: shouldShowExplanationWidget,
              child: shouldShowExplanationWidget == true ? Text("Prompt: ${geminiOutput['Music Prompt']}") : const Text(""),
            ),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headlineMedium,
            // ),
            IconButton(
            onPressed: () {_pickFile(); },
            tooltip: 'Upload File (image/video only)',
            icon: const Icon(Icons.upload_file_rounded),
            ),
            IconButton(
            onPressed: () {sendToGoogle();},
            tooltip: 'Ask Gemini to explain',
            icon: const Icon(Icons.send_sharp),
            ), 
            IconButton(
              onPressed: () {deleteAllMedia(storage.ref());},
              tooltip: 'Delete all uploaded media',
              icon: const Icon(Icons.delete_forever),
            ),
            Visibility(
              visible: shouldShowExplanationWidget,
              child: IconButton(
                onPressed: () { vibeMatch(geminiOutput['Music Prompt']);},//"Lofi Music for Coding"
                tooltip: 'Generate music',
                icon: const Icon(Icons.create_outlined),
              ),
            ),
            Visibility(
              visible: shouldShowAudioWidget,
              child: IconButton(
                onPressed: () async => {await player.resume()},
                icon: const Icon(Icons.play_arrow),
              ),
            ),
            Visibility(
              visible: shouldShowAudioWidget,
              child: IconButton(
                onPressed: () async => {await player.stop()},
                icon: const Icon(Icons.stop_circle),
              ),
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


