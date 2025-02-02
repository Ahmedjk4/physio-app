import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:physio_app/core/helpers/schedule_weekly_notification.dart';
import 'package:physio_app/core/helpers/showSnackBar.dart';
import 'package:physio_app/core/widgets/custom_button.dart';
import 'dart:convert';

import 'package:physio_app/main.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String? _gender;
  String? _diseases;
  String? _medications;

  List<String> diseases = ['Diabetes', 'Hypertension', 'Heart Disease', 'None'];
  List<String> medications = ['Aspirin', 'Metformin', 'None'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dr. Rana Kadry - Diet Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(labelText: 'Height (cm)'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: _gender,
              hint: Text('Select Gender'),
              onChanged: (String? newValue) {
                setState(() {
                  _gender = newValue;
                });
              },
              items: ['Male', 'Female']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: _diseases,
              hint: Text('Any Diseases?'),
              onChanged: (String? newValue) {
                setState(() {
                  _diseases = newValue;
                });
              },
              items: diseases.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: _medications,
              hint: Text('Any Medications?'),
              onChanged: (String? newValue) {
                setState(() {
                  _medications = newValue;
                });
              },
              items: medications.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            CustomButton(
              callback: () {
                sendDataToAI(context);
                scheduleWeeklyNotification();
              },
              text: 'Submit Data',
            ),
          ],
        ),
      ),
    );
  }

  void sendDataToAI(BuildContext context) async {
    // Initialize the OpenAI instance
    OpenAI.apiKey =
        "g4a-mdouFDNFyJCsWCW4VRqUzyTIqd34fkUYfLY"; // Replace with your OpenAI API key
    OpenAI.baseUrl = "https://api.gpt4-all.xyz";

    // Null check for each field, assigning default values if null
    String age = _ageController.text.isNotEmpty ? _ageController.text : "N/A";
    String weight =
        _weightController.text.isNotEmpty ? _weightController.text : "N/A";
    String height =
        _heightController.text.isNotEmpty ? _heightController.text : "N/A";
    String gender = _gender ?? "N/A"; // Assuming _gender could be null
    String diseases = _diseases ?? "N/A"; // Assuming _diseases could be null
    String medications =
        _medications ?? "N/A"; // Assuming _medications could be null

    // Construct the prompt based on the user's input
    String prompt = """
  Age: $age
  Weight: $weight
  Height: $height
  Gender: $gender
  Diseases: $diseases
  Medications: $medications
  
  Generate a personalized diet plan based on the information above and talk in arabic , split your response to parts and don't use any markdown marks
  """;

    // Create a completion request
    try {
      showSnackBar(context, 'Loading');
      OpenAIChatCompletionModel completion = await OpenAI.instance.chat.create(
        model: "gpt-4o-mini", // or any other available model
        messages: [
          OpenAIChatCompletionChoiceMessageModel(content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)
          ], role: OpenAIChatMessageRole.system)
        ],
        maxTokens:
            500, // Adjust maxTokens based on the response length you want
        temperature: 0.7, // Adjust based on creativity needed in the response
      );

      // Get the generated diet plan
      String dietPlan = completion.choices.first.message.content?[0].text ??
          "No plan generated";

      // Show the response in a bottom sheet
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            // Make the content scrollable
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                dietPlan,
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        },
      );
    } catch (e) {
      // Show an error message using Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
