import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:physio_app/core/utils/colors.dart';
import 'package:physio_app/core/utils/text_styles.dart';

class DietListView extends StatefulWidget {
  const DietListView({super.key});

  @override
  State<DietListView> createState() => _DietListViewState();
}

class _DietListViewState extends State<DietListView> {
  List<String> dietList = [];
  List<bool> _isExpandedList = [];

  @override
  void initState() {
    super.initState();
    loadDietData();
  }

  void loadDietData() {
    var dietBox = Hive.box<List<String>>('diet');
    // Retrieve the stored list or default to an empty list
    List<String> storedList = dietBox.get('list') ?? [];
    setState(() {
      dietList = storedList;
      _isExpandedList = List<bool>.filled(dietList.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet List'),
        backgroundColor: AppColors.secondaryColor,
      ),
      body: dietList.isEmpty
          ? const Center(
              child: Text(
                "No diet items available",
                style: TextStyle(color: Colors.white),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: dietList.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: AppColors.accentColor,
                    child: ExpansionPanelList(
                      elevation: 1,
                      expandedHeaderPadding: EdgeInsets.zero,
                      expansionCallback: (int itemIndex, bool isExpanded) {
                        setState(() {
                          _isExpandedList[index] = !_isExpandedList[index];
                        });
                      },
                      children: [
                        ExpansionPanel(
                          backgroundColor: AppColors.accentColor,
                          headerBuilder:
                              (BuildContext context, bool isExpanded) {
                            return ListTile(
                              title: Text(
                                dietList[index],
                                style: TextStyles.bodyText1.copyWith(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                          body: ListTile(
                            tileColor: AppColors.accentColor,
                            title: Text(
                              'Details about ${dietList[index]}',
                              style: TextStyles.bodyText1.copyWith(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          isExpanded: _isExpandedList[index],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
