import 'package:booking_system_flutter/component/view_all_label_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/screens/category/category_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/component/category_widget.dart';
import 'package:booking_system_flutter/screens/service/search_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CategoryComponent extends StatefulWidget {
  final List<CategoryData>? categoryList;

  CategoryComponent({this.categoryList});

  @override
  CategoryComponentState createState() => CategoryComponentState();
}

class CategoryComponentState extends State<CategoryComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categoryList.validate().isEmpty) return Offstage();

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ViewAllLabel(
            label: language!.category,
            list: widget.categoryList!,
            onTap: () {
              CategoryScreen().launch(context).then((value) {
                setStatusBarColor(Colors.transparent);
              });
            },
          ),
          16.height,
          AnimatedWrap(
            runSpacing: 16,
            spacing: 16,
            columnCount: 1,
            itemCount: widget.categoryList.validate().length,
            listAnimationType: ListAnimationType.Scale,
            scaleConfiguration: ScaleConfiguration(duration: 400.milliseconds, delay: 100.milliseconds),
            itemBuilder: (_, index) {
              CategoryData data = widget.categoryList![index];

              return GestureDetector(
                onTap: () {
                  SearchListScreen(categoryId: data.id.validate(), categoryName: data.name).launch(context);
                },
                child: CategoryWidget(categoryData: data),
              );
            },
          ),
        ],
      ),
    );
  }
}
