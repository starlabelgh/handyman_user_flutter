import 'package:booking_system_flutter/component/background_component.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/model/booking_status_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/booking/booking_detail_screen.dart';
import 'package:booking_system_flutter/screens/booking/component/booking_item_component.dart';
import 'package:booking_system_flutter/screens/booking/component/status_dropdown_component.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingFragment extends StatefulWidget {
  @override
  _BookingFragmentState createState() => _BookingFragmentState();
}

class _BookingFragmentState extends State<BookingFragment> {
  ScrollController scrollController = ScrollController();

  int page = 1;
  List<BookingData> mainList = [];

  String selectedValue = 'All';
  String errorMessage = '';

  bool isEnabled = false;
  bool isApiCalled = false;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    afterBuildCreated(() {
      if (appStore.isLoggedIn) {
        setStatusBarColor(context.primaryColor);
      }
      return fetchAllBookingList(status: selectedValue);
    });

    LiveStream().on(LIVESTREAM_UPDATE_BOOKING_LIST, (p0) {
      page = 1;
      fetchAllBookingList(status: selectedValue);
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (!isLastPage) {
          page++;
          fetchAllBookingList(status: selectedValue);
        }
      }
    });
  }

  Future<void> fetchAllBookingList({required String status}) async {
    appStore.setLoading(true);
    errorMessage = '';

    await getBookingList(page, status: status).then((value) {
      if (page == 1) mainList.clear();

      mainList.addAll(value.data.validate());
      isApiCalled = true;
      selectedValue = status;
      isLastPage = value.data!.length != PER_PAGE_ITEM;

      if (mainList.isEmpty) {
        errorMessage = language!.lblNoData;
      }
    }).catchError((e) {
      isApiCalled = true;
      errorMessage = e.toString();
    });
    setState(() {});

    appStore.setLoading(false);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    scrollController.dispose();
    LiveStream().dispose(LIVESTREAM_UPDATE_BOOKING_LIST);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language!.booking,
        textColor: white,
        showBack: false,
        elevation: 3.0,
        color: context.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          page = 1;
          return await fetchAllBookingList(status: selectedValue);
        },
        child: Stack(
          children: [
            if (mainList.isNotEmpty)
              AnimatedListView(
                controller: scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: mainList.length,
                shrinkWrap: true,
                listAnimationType: ListAnimationType.Slide,
                slideConfiguration: SlideConfiguration(verticalOffset: 400),
                itemBuilder: (_, index) {
                  BookingData? data = mainList[index];

                  return GestureDetector(
                    onTap: () {
                      BookingDetailScreen(bookingId: data.id.validate()).launch(context);
                    },
                    child: BookingItemComponent(bookingData: data),
                  );
                },
              ).paddingOnly(left: 0, right: 0, bottom: 0, top: 76)
            else
              (mainList.validate().isEmpty && !appStore.isLoading && isApiCalled)
                  ? BackgroundComponent(
                      text: errorMessage.isNotEmpty ? errorMessage : language!.lblNoBookingsFound,
                      isError: errorMessage.isNotEmpty,
                    ).center()
                  : Offstage(),
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: StatusDropdownComponent(
                isValidate: false,
                onValueChanged: (BookingStatusResponse value) {
                  page = 1;
                  scrollController.animateTo(0, duration: 1.seconds, curve: Curves.easeOutQuart);
                  fetchAllBookingList(status: value.value.toString());
                },
              ),
            ),
            Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading))
          ],
        ),
      ),
    );
  }
}
