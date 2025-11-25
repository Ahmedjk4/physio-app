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
      // Create a mutable copy to allow modifications
      dietList = List<String>.from(storedList);
      _isExpandedList = List.from(List<bool>.filled(dietList.length, false));
    });
  }

  Future<void> _deleteDietItem(int index) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.accentColor,
        title: Text(
          'حذف خطة النظام الغذائي',
          style: TextStyles.bodyText1.copyWith(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذه الخطة؟',
          style: TextStyles.bodyText1.copyWith(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      var dietBox = Hive.box<List<String>>('diet');
      setState(() {
        dietList.removeAt(index);
        _isExpandedList.removeAt(index);
      });
      await dietBox.put('list', dietList);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف الخطة بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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
                    child: Column(
                      children: [
                        ExpansionPanelList(
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
                                    maxLines: 2,
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade300,
                                    ),
                                    onPressed: () => _deleteDietItem(index),
                                    tooltip: 'حذف',
                                  ),
                                );
                              },
                              body: Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                child: SelectableText(
                                  dietList[index],
                                  style: TextStyles.bodyText1.copyWith(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              isExpanded: _isExpandedList[index],
                            ),
                          ],
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
