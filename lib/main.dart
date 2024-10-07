import 'package:flutter/material.dart';
import 'package:fuel_efficiency_prediction/gen/assets.gen.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() {
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Interpreter interpreter;

  TextEditingController displacementController = TextEditingController();
  TextEditingController cylindersController = TextEditingController();
  TextEditingController horsepowerController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController accelrationController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController originController = TextEditingController();

  ScrollController scrollController = ScrollController();

  var result = "";

  final mean = [
    5.477707,
    195.318471,
    104.869427,
    2990.251592,
    15.559236,
    75.898089,
    1.573248,
    0.624204,
    0.178344,
    0.197452
  ];

  final std = [
    1.699788,
    104.331589,
    38.096214,
    843.898596,
    2.789230,
    3.675642,
    0.800988,
    0.485101,
    0.383413,
    0.398712
  ];

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  dispose() {
    displacementController.dispose();
    cylindersController.dispose();
    horsepowerController.dispose();
    weightController.dispose();
    accelrationController.dispose();
    modelController.dispose();
    originController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  loadModel() async {
    interpreter = await Interpreter.fromAsset(Assets.models.automobileTflite);
  }

  performAction() {
    double cylinders = double.parse(cylindersController.text);
    double displacement = double.parse(displacementController.text);
    double horsePower = double.parse(horsepowerController.text);
    double weight = double.parse(weightController.text);
    double accelration = double.parse(accelrationController.text);
    double modelYear = double.parse(modelController.text);
    double originA = 1;
    double originB = 0;
    double originC = 0;
    if (originValue == "USA") {
      originA = 1;
      originB = 0;
      originC = 0;
    } else if (originValue == "Europe") {
      originA = 0;
      originB = 1;
      originC = 0;
    } else if (originValue == "Japan") {
      originA = 0;
      originB = 0;
      originC = 1;
    }

    cylinders = (cylinders - mean[0]) / std[0];
    displacement = (displacement - mean[1]) / std[1];
    horsePower = (horsePower - mean[2]) / std[2];
    weight = (weight - mean[3]) / std[3];
    accelration = (accelration - mean[4]) / std[4];
    modelYear = (modelYear - mean[5]) / std[5];
    originA = (originA - mean[6]) / std[6];
    originB = (originB - mean[7]) / std[7];
    originC = (originC - mean[8]) / std[8];
    // For ex: if input tensor shape [1,5] and type is float32
    var input = [
      cylinders,
      displacement,
      horsePower,
      weight,
      accelration,
      modelYear,
      originA,
      originB,
      originC
    ];

    // if output tensor shape [1,1] and type is float32
    var output = List.filled(1, 0).reshape([1, 1]);

    // inference
    interpreter.run(input, output);

    // print the output

    setState(() {
      result = output[0][0].toStringAsFixed(2);

      scrollController.jumpTo(0);
    });
  }

  String originValue = 'USA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          controller: scrollController,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 250,
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        '$result MPG',
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  color: Colors.green,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 50, right: 50),
                        child: Image.asset(
                          Assets.icons.icon.path,
                          width: 100,
                          height: 100,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: displacementController,
                          decoration: const InputDecoration(
                              hintText: 'Displacement',
                              border: InputBorder.none,
                              hintStyle:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  color: Colors.red,
                  padding: const EdgeInsets.only(left: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: cylindersController,
                          decoration: const InputDecoration(
                              hintText: 'Cylinders',
                              border: InputBorder.none,
                              hintStyle:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 50, right: 50),
                        child: Image.asset(
                          Assets.icons.icon.path,
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  color: Colors.yellow,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 50, right: 50),
                        child: Image.asset(
                          Assets.icons.icon.path,
                          width: 100,
                          height: 100,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: horsepowerController,
                          decoration: const InputDecoration(
                              hintText: 'Horsepower',
                              border: InputBorder.none,
                              hintStyle:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  color: Colors.blueAccent,
                  padding: const EdgeInsets.only(left: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: weightController,
                          decoration: const InputDecoration(
                              hintText: 'Weight',
                              border: InputBorder.none,
                              hintStyle:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 50, right: 50),
                        child: Image.asset(
                          Assets.icons.icon.path,
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  color: Colors.deepOrange,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 50, right: 50),
                        child: Image.asset(
                          Assets.icons.icon.path,
                          width: 100,
                          height: 100,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: accelrationController,
                          decoration: const InputDecoration(
                              hintText: 'Acceleration',
                              border: InputBorder.none,
                              hintStyle:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  color: Colors.greenAccent,
                  padding: const EdgeInsets.only(left: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: modelController,
                          decoration: const InputDecoration(
                              hintText: 'Model Year',
                              border: InputBorder.none,
                              hintStyle:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 50, right: 50),
                        child: Image.asset(
                          Assets.icons.icon.path,
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  color: Colors.brown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 50, right: 50),
                        child: Image.asset(
                          Assets.icons.icon.path,
                          width: 100,
                          height: 100,
                        ),
                      ),
                      DropdownButton(
                          // Initial Value
                          value: originValue,
                          // Down Arrow Icon
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),

                          // Array list of items
                          items: ['USA', 'Europe', 'Japan'].map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(
                                items,
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          // After selecting the desired option,it will
                          // change button value to selected value
                          onChanged: (String? newValue) {
                            setState(() {
                              originValue = newValue!;
                            });
                          }),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      performAction();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: const Text(
                      'Get',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
