import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/dashboard/component/category_widget.dart';
import 'package:booking_system_flutter/screens/service/search_list_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class CategoryScreen extends StatefulWidget {

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  ScrollController scrollController = ScrollController();
  UniqueKey key = UniqueKey();

  int page = 1;
  List<CategoryData> mainList = [];

  bool isEnabled = false;
  bool isLastPage = false;
  bool fabIsVisible = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    fetchAllCategoryData();
    afterBuildCreated(() {
      setStatusBarColor(context.primaryColor);
    });
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (!isLastPage) {
          page++;
          fetchAllCategoryData();
        }
      }
    });
  }

  Future fetchAllCategoryData() async {
    appStore.setLoading(true);

    await getCategoryList(page.toString()).then((value) {
      if (page == 1) {
        mainList.clear();
        key = UniqueKey();
      }
      mainList.addAll(value.categoryList.validate());

      isLastPage = value.categoryList!.length != PER_PAGE_ITEM;

      setState(() {});
    }).catchError((e) {
      toast(e.toString());
    });

    appStore.setLoading(false);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        page = 1;
        return await fetchAllCategoryData();
      },
      child: Scaffold(
        appBar: appBarWidget(
          language!.lblCategory,
          textColor: Colors.white,
          color: primaryColor,
          showBack: Navigator.canPop(context),
          backWidget: BackWidget(),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: scrollController,
              padding: EdgeInsets.all(16),
              child: AnimatedWrap(
                key: key,
                runSpacing: 16,
                spacing: 16,
                itemCount: mainList.length,
                listAnimationType: ListAnimationType.Scale,
                scaleConfiguration: ScaleConfiguration(duration: 400.milliseconds, delay: 100.milliseconds),
                itemBuilder: (_, index) {
                  CategoryData data = mainList[index];

                  return GestureDetector(
                    onTap: () {
                      SearchListScreen(categoryId: data.id.validate(), categoryName: data.name).launch(context);
                    },
                    child: CategoryWidget(categoryData: data, width: context.width() / 2 - 24),
                  );
                },
              ),
            ),
            Observer(builder: (BuildContext context) => LoaderWidget().visible(appStore.isLoading.validate()))
          ],
        ),
      ),
    );
  }
}
