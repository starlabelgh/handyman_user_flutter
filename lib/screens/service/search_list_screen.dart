import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/background_component.dart';
import 'package:booking_system_flutter/component/cached_network_image.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/filter/filter_screen.dart';
import 'package:booking_system_flutter/screens/service/component/service_component.dart';
import 'package:booking_system_flutter/screens/service/component/subcategory_component.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class SearchListScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;
  final String isFeatured;
  final bool isFromProvider;
  final bool isFromCategory;
  final int? providerId;

  SearchListScreen({this.categoryId, this.categoryName = '', this.isFeatured = '', this.isFromProvider = true, this.isFromCategory = false, this.providerId});

  @override
  SearchListScreenState createState() => SearchListScreenState();
}

class SearchListScreenState extends State<SearchListScreen> {
  FocusNode myFocusNode = FocusNode();

  ScrollController scrollController = ScrollController();

  TextEditingController searchCont = TextEditingController();

  int page = 1;
  List<ServiceData> mainList = [];

  bool isEnabled = false;
  bool isLastPage = false;
  bool fabIsVisible = true;
  bool isSubCategoryLoaded = false;
  bool isApiCalled = false;

  int? subCategory;

  @override
  void initState() {
    super.initState();

    LiveStream().on(LIVESTREAM_UPDATE_SERVICE_LIST, (p0) {
      subCategory = p0 as int;
      page = 1;

      setState(() {});
      fetchAllServiceData();
    });
    afterBuildCreated(() {
      init();
    });
  }

  void init() async {
    if (filterStore.search.isNotEmpty) {
      filterStore.setSearch('');
    }
    fetchAllServiceData();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (!isLastPage) {
          page++;
          fetchAllServiceData();
        }
      }
    });
  }

  String get setSearchString {
    if (!widget.categoryName.isEmptyOrNull) {
      return widget.categoryName!;
    } else if (widget.isFeatured == "1") {
      return language!.lblFeatured;
    } else {
      return language!.allServices;
    }
  }

  Future<void> fetchAllServiceData() async {
    appStore.setLoading(true);

    if (appStore.isCurrentLocation) {
      filterStore.setLatitude(getDoubleAsync(LATITUDE).toString());
      filterStore.setLongitude(getDoubleAsync(LONGITUDE).toString());
    } else {
      filterStore.setLatitude("");
      filterStore.setLongitude("");
    }

    String categoryId() {
      if (filterStore.categoryId.isNotEmpty) {
        return filterStore.categoryId.join(",");
      } else {
        if (widget.categoryId != null) {
          return widget.categoryId.toString();
        } else {
          return "";
        }
      }
    }

    await getSearchListServices(
      categoryId: categoryId(),
      providerId: widget.providerId != null ? widget.providerId.toString() : filterStore.providerId.join(","),
      handymanId: filterStore.handymanId.join(","),
      isPriceMin: filterStore.isPriceMin,
      isPriceMax: filterStore.isPriceMax,
      search: filterStore.search,
      latitude: filterStore.latitude,
      longitude: filterStore.longitude,
      isFeatured: widget.isFeatured,
      page: page,
      subCategory: subCategory.toString(),
    ).then((value) async {
      appStore.setLoading(false);

      if (page == 1) {
        mainList.clear();
      }
      isLastPage = value.serviceList.validate().length != PER_PAGE_ITEM;
      mainList.addAll(value.serviceList.validate());

      setState(() {});
      if (!isApiCalled && mainList.isNotEmpty) {
        await 1.seconds.delay;
        myFocusNode.requestFocus();
      }
      isApiCalled = true;
    }).catchError((e) {
      isApiCalled = true;
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    filterStore.clearFilters();
    myFocusNode.dispose();
    LiveStream().dispose(LIVESTREAM_UPDATE_SERVICE_LIST);
    filterStore.setSelectedSubCategory(catId: 0);

    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        setSearchString,
        textColor: Colors.white,
        color: context.primaryColor,
        backWidget: BackWidget(),
        actions: [
          commonLocationWidget(
            onTap: () {
              page = 1;
              fetchAllServiceData();
            },
            context: context,
            color: appStore.isCurrentLocation ? Colors.lightGreen : Colors.white,
          ).paddingRight(16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          page = 1;
          return await fetchAllServiceData();
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubCategoryComponent(
                    catId: widget.categoryId != null ? widget.categoryId : null,
                    onDataLoaded: (bool val) async {
                      //appStore.setLoading(false);
                    },
                  ),
                  16.height,
                  if (mainList.isNotEmpty) Text(language!.service, style: boldTextStyle(size: LABEL_TEXT_SIZE)).paddingSymmetric(horizontal: 16),
                  if (mainList.isNotEmpty)
                    AnimatedListView(
                      padding: EdgeInsets.all(8),
                      itemCount: mainList.length,
                      shrinkWrap: true,
                      slideConfiguration: SlideConfiguration(verticalOffset: 400),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (_, index) {
                        return ServiceComponent(serviceData: mainList[index]).paddingAll(8);
                      },
                    ),
                ],
              ),
            ).paddingTop(70),
            Observer(
              builder: (BuildContext context) {
                return BackgroundComponent(size: 150, text: language!.lblNoServicesFound)
                    .center()
                    .paddingTop(!appStore.isLoading ? 180 : 26)
                    .visible(isApiCalled && mainList.isEmpty && !appStore.isLoading);
              },
            ),
            Observer(builder: (BuildContext context) => LoaderWidget().visible(appStore.isLoading.validate())),
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  AppTextField(
                    textFieldType: TextFieldType.OTHER,
                    focus: myFocusNode,
                    controller: searchCont,
                    suffix: CloseButton(
                      onPressed: () {
                        page = 1;
                        searchCont.clear();
                        filterStore.setSearch('');
                        fetchAllServiceData();
                      },
                    ).visible(searchCont.text.isNotEmpty),
                    onFieldSubmitted: (s) {
                      page = 1;

                      filterStore.setSearch(s);
                      fetchAllServiceData();
                    },
                    decoration: inputDecoration(context).copyWith(
                      hintText: "${language!.lblSearchFor} $setSearchString",
                      prefixIcon: ic_search.iconImage(size: 10).paddingAll(14),
                      hintStyle: secondaryTextStyle(),
                    ),
                  ).expand(),
                  16.width,
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: boxDecorationDefault(color: context.primaryColor),
                    child: cachedImage(ic_filter, height: 26, width: 26, color: Colors.white),
                  ).onTap(() {
                    hideKeyboard(context);

                    FilterScreen(isFromProvider: widget.isFromProvider).launch(context).then((value) {
                      if (value != null) {
                        page = 1;
                        fetchAllServiceData();
                      }
                    });
                  }, borderRadius: radius())
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
