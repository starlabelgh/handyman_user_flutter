import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/cached_network_image.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/screens/auth/sign_in_screen.dart';
import 'package:booking_system_flutter/screens/gallery/gallery_component.dart';
import 'package:booking_system_flutter/screens/gallery/gallery_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceDetailHeaderComponent extends StatefulWidget {
  final ServiceData serviceDetail;

  const ServiceDetailHeaderComponent({required this.serviceDetail, Key? key}) : super(key: key);

  @override
  State<ServiceDetailHeaderComponent> createState() => _ServiceDetailHeaderComponentState();
}

class _ServiceDetailHeaderComponentState extends State<ServiceDetailHeaderComponent> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 475,
      width: context.width(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (widget.serviceDetail.attachments.validate().isNotEmpty)
            SizedBox(
              height: 400,
              width: context.width(),
              child: cachedImage(widget.serviceDetail.attachments!.first, fit: BoxFit.cover, height: 400),
            ),
          Positioned(top: context.statusBarHeight, child: BackWidget()),
          Positioned(
            top: context.statusBarHeight + 8,
            child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(right: 8),
              decoration: boxDecorationWithShadow(boxShape: BoxShape.circle, backgroundColor: context.cardColor),
              child: widget.serviceDetail.isFavourite == 1 ? ic_fill_heart.iconImage(color: favouriteColor, size: 24) : ic_heart.iconImage(color: unFavouriteColor, size: 24),
            ).onTap(() async {
              if (appStore.isLoggedIn) {
                if (widget.serviceDetail.isFavourite == 1) {
                  widget.serviceDetail.isFavourite = 0;
                  setState(() {});

                  await removeToWishList(serviceId: widget.serviceDetail.id.validate()).then((value) {
                    if (!value) {
                      widget.serviceDetail.isFavourite = 1;
                      setState(() {});
                    }
                  });
                } else {
                  widget.serviceDetail.isFavourite = 1;
                  setState(() {});

                  await addToWishList(serviceId: widget.serviceDetail.id.validate()).then((value) {
                    if (!value) {
                      widget.serviceDetail.isFavourite = 0;
                      setState(() {});
                    }
                  });
                }
              } else {
                push(SignInScreen()).then((value) {
                  setStatusBarColor(transparentColor, delayInMilliSeconds: 1000);
                });
              }
            }),
            right: 8,
          ),
          Positioned(
            bottom: 0,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: List.generate(
                        widget.serviceDetail.attachments!.take(2).length,
                        (i) => Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: white, width: 2),
                            borderRadius: radius(),
                          ),
                          child: GalleryComponent(
                            images: widget.serviceDetail.attachments!,
                            index: i,
                            padding: 32,
                            height: 60,
                            width: 60,
                          ),
                        ),
                      ),
                    ),
                    16.width,
                    if (widget.serviceDetail.attachments!.length > 2)
                      Blur(
                        borderRadius: radius(),
                        padding: EdgeInsets.zero,
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: white, width: 2),
                            borderRadius: radius(),
                          ),
                          alignment: Alignment.center,
                          child: Text('+' '${widget.serviceDetail.attachments!.length - 2}', style: boldTextStyle(color: white)),
                        ),
                      ).onTap(
                        () {
                          GalleryScreen(
                            serviceName: widget.serviceDetail.name.validate(),
                            attachments: widget.serviceDetail.attachments.validate(),
                          ).launch(context, pageRouteAnimation: PageRouteAnimation.Fade, duration: 400.milliseconds);
                        },
                      ),
                  ],
                ),
                16.height,
                Container(
                  width: context.width(),
                  padding: EdgeInsets.all(16),
                  decoration: boxDecorationDefault(
                    color: context.scaffoldBackgroundColor,
                    border: Border.all(color: context.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.serviceDetail.subCategoryName.validate().isNotEmpty)
                        Marquee(
                          child: Row(
                            children: [
                              Text('${widget.serviceDetail.categoryName}', style: boldTextStyle(size: 14, color: textSecondaryColorGlobal)),
                              Text('  >  ', style: boldTextStyle(size: 14, color: textSecondaryColorGlobal)),
                              Text('${widget.serviceDetail.subCategoryName}', style: boldTextStyle(size: 14, color: primaryColor)),
                            ],
                          ),
                        )
                      else
                        Text('${widget.serviceDetail.categoryName}', style: boldTextStyle(size: 14, color: primaryColor)),
                      4.height,
                      Marquee(
                        child: Text('${widget.serviceDetail.name.validate()}', style: boldTextStyle(size: 20)),
                        directionMarguee: DirectionMarguee.oneDirection,
                      ),
                      4.height,
                      Row(
                        children: [
                          PriceWidget(
                            price: widget.serviceDetail.price.validate(),
                            isHourlyService: widget.serviceDetail.isHourlyService,
                            size: 24,
                            hourlyTextColor: textSecondaryColorGlobal,
                          ),
                          4.width,
                          if (widget.serviceDetail.discount.validate() != 0)
                            Text(
                              '(${widget.serviceDetail.discount.validate()}% ${language!.lblOff})',
                              style: boldTextStyle(color: Colors.green),
                            ),
                        ],
                      ),
                      4.height,
                      TextIcon(
                        edgeInsets: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                        text: '${language!.duration}',
                        textStyle: secondaryTextStyle(size: 16),
                        expandedText: true,
                        suffix: Text("${widget.serviceDetail.duration.validate()} ${language!.lblHour}", style: boldTextStyle(color: primaryColor)),
                      ),
                      TextIcon(
                        text: '${language!.lblRating}',
                        textStyle: secondaryTextStyle(size: 16),
                        edgeInsets: EdgeInsets.symmetric(vertical: 4),
                        expandedText: true,
                        suffix: Row(
                          children: [
                            Image.asset('assets/icons/ic_star_fill.png', height: 18),
                            4.width,
                            Text("${widget.serviceDetail.totalRating.validate().toStringAsFixed(1)}", style: boldTextStyle()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
