import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:physio_app/core/helpers/showSnackBar.dart';
import 'package:physio_app/core/utils/colors.dart';
import 'package:physio_app/core/utils/text_styles.dart';
import 'package:physio_app/core/widgets/custom_button.dart';

class DietView extends StatefulWidget {
  const DietView({super.key});

  @override
  State<DietView> createState() => _DietViewState();
}

class _DietViewState extends State<DietView> {
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String? _gender;
  String? _diseases;
  String? _medications;
  String? _goal;

  List<String> diseases = ['السكري', 'ارتفاع ضغط الدم', 'مرض قلبي', 'None'];
  List<String> medications = ['Aspirin', 'Metformin', 'None'];
  List<String> goal = ['Gain Weight', 'Lose Weight'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. Rana Kadry - Diet Plan'),
        backgroundColor: AppColors.secondaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              style: TextStyles.bodyText1.copyWith(color: Colors.black),
              controller: _ageController,
              decoration: InputDecoration(
                labelText: 'العمر',
                labelStyle: TextStyles.bodyText1
                    .copyWith(color: AppColors.textColorPrimary),
                hintStyle: TextStyles.bodyText1
                    .copyWith(color: AppColors.textColorPrimary),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              style: TextStyles.bodyText1.copyWith(color: Colors.black),
              controller: _weightController,
              decoration: InputDecoration(
                labelText: '(kg) الوزن',
                labelStyle: TextStyles.bodyText1
                    .copyWith(color: AppColors.textColorPrimary),
                hintStyle: TextStyles.bodyText1
                    .copyWith(color: AppColors.textColorPrimary),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              style: TextStyles.bodyText1.copyWith(color: Colors.black),
              controller: _heightController,
              decoration: InputDecoration(
                labelText: '(cm) الطول',
                labelStyle: TextStyles.bodyText1
                    .copyWith(color: AppColors.textColorPrimary),
                hintStyle: TextStyles.bodyText1
                    .copyWith(color: AppColors.textColorPrimary),
              ),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              dropdownColor: Colors.white,
              iconEnabledColor: AppColors.textColorPrimary,
              value: _gender,
              hint: Text(
                'اختر النوع',
                style: TextStyle(color: AppColors.textColorPrimary),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _gender = newValue;
                });
              },
              items:
                  ['ذكر', 'أنثى'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: AppColors.textColorPrimary),
                  ),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              dropdownColor: Colors.white,
              iconEnabledColor: AppColors.textColorPrimary,
              value: _diseases,
              hint: Text(
                'أي أمراض؟',
                style: TextStyle(color: AppColors.textColorPrimary),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _diseases = newValue;
                });
              },
              items: diseases.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: AppColors.textColorPrimary),
                  ),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              dropdownColor: Colors.white,
              iconEnabledColor: AppColors.textColorPrimary,
              value: _medications,
              hint: Text(
                'أي أدوية؟',
                style: TextStyle(color: AppColors.textColorPrimary),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _medications = newValue;
                });
              },
              items: medications.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: AppColors.textColorPrimary),
                  ),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              dropdownColor: Colors.white,
              iconEnabledColor: AppColors.textColorPrimary,
              value: _goal,
              hint: Text(
                'الهدف ؟',
                style: TextStyle(color: AppColors.textColorPrimary),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _goal = newValue;
                });
              },
              items: goal.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: AppColors.textColorPrimary),
                  ),
                );
              }).toList(),
            ),
            CustomButton(
              callback: () {
                sendDataToAI(context);
              },
              text: 'Submit Data',
            ),
            CustomButton(
                text: 'See Previous Data',
                callback: () {
                  context.push('/diet-list');
                }),
          ],
        ),
      ),
    );
  }

  void sendDataToAI(BuildContext context) async {
    // Initialize the OpenAI instance
    OpenAI.apiKey =
        "g4a-rxzdjOvQPtsVK6oqqrZ2zgWRANPPAElS7NT"; // Replace with your OpenAI API key
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
    String goals = _goal ?? "Lose Weight";

    // Construct the prompt based on the user's input
    String prompt = """
  Age: $age
  Weight: $weight
  Height: $height
  Gender: $gender
  Diseases: $diseases
  Medications: $medications
  Goal: $goals

  Based on the information provided, generate a personalized diet plan in Arabic. Please structure your response in clear sections without using any markdown formatting. Ensure the plan is detailed and easy to follow.
  And show needed calories, protein, carbohydrates, etc.. per day.
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
        temperature: 0.7, // Adjust based on creativity needed in the response
      );

      // Get the generated diet plan
      String dietPlan = completion.choices.first.message.content?[0].text ??
          "No plan generated";
      var dietBox = Hive.box<List<String>>('diet');
      List<String> dietList = dietBox.get('list') ?? [];
      dietList.add(dietPlan);
      await dietBox.put('list', dietList);
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
