import 'package:dart_openai/dart_openai.dart';
import 'package:dio/dio.dart';
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
  bool _isGenerating = false;

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
            if (_isGenerating)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.secondaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'جاري إنشاء خطة النظام الغذائي...',
                      style: TextStyles.bodyText1.copyWith(
                        color: AppColors.textColorPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            CustomButton(
              callback: _isGenerating
                  ? () {}
                  : () {
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
    setState(() {
      _isGenerating = true;
    });

    // Initialize the OpenAI instance
    var apiKey =
        "AIzaSyCPL2szrIw76fhoBXFTtPzj_CgUe01OcPw"; // Replace with your OpenAI API key
    var baseUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

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
      showSnackBar(context, 'Generating diet plan, please wait...');
      Dio dio = Dio();
      dio.options.headers["x-goog-api-key"] = apiKey;
      dio.options.headers["Content-Type"] = "application/json";
      // Get the generated diet plan
      String dietPlan;
      try {
        final response = await dio.post(baseUrl, data: {
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ],
        });
        if (response.statusCode == 200) {
          dietPlan = response.data['candidates'][0]['content']['parts'][0]
                  ['text'] ??
              "No plan generated";
        } else {
          dietPlan = "API error ${response.statusCode}: ${response.data}";
          print("API error: ${response.statusCode} - ${response.data}");
        }
      } on DioError catch (e) {
        dietPlan = "Request failed: ${e.message}";
        print(
            "DioError: ${e.response?.statusCode} ${e.response?.data} ${e.message}");
      } catch (e) {
        dietPlan = "Unexpected error: $e";
        print("Unexpected error: $e");
      }
      var dietBox = Hive.box<List<String>>('diet');
      List<String> dietList = dietBox.get('list') ?? [];
      dietList.add(dietPlan);
      await dietBox.put('list', dietList);
      // Show the response in a bottom sheet
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        showModalBottomSheet(
          context: mounted ? context : context,
          builder: (BuildContext context) {
            return SingleChildScrollView(
              // Make the content scrollable
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SelectableText(
                  dietPlan,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      // Show an error message using Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
