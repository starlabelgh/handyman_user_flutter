import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/contact_model.dart';
import 'package:booking_system_flutter/screens/chat/component/user_item_builder.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class UserChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language!.lblchat,
        textColor: white,
        showBack: Navigator.canPop(context),
        elevation: 3.0,
        backWidget: BackWidget(),
        color: context.primaryColor,
      ),
      body: PaginateFirestore(
        itemBuilder: (context, snap, index) {
          ContactModel contact = ContactModel.fromJson(snap[index].data() as Map<String, dynamic>);
          return UserItemBuilder(userUid: contact.uid.validate());
        },
        options: GetOptions(source: Source.serverAndCache),
        isLive: false,
        padding: EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 0),
        itemsPerPage: PER_PAGE_CHAT_LIST_COUNT,
        separator: Divider(height: 0, indent: 82),
        shrinkWrap: true,
        query: chatMessageService.fetchChatListQuery(userId: appStore.uid),
        onEmpty: noDataFound(context),
        initialLoader: LoaderWidget(),
        itemBuilderType: PaginateBuilderType.listView,
        onError: (e) => noDataFound(context),
      ),
    );
  }
}
