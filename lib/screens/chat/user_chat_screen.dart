import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/chat_item_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/chat_message_model.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/services/chat_messages_service.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class UserChatScreen extends StatefulWidget {
  final UserData receiverUser;

  UserChatScreen({required this.receiverUser});

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  TextEditingController messageCont = TextEditingController();
  FocusNode messageFocus = FocusNode();

  late final UserData senderUser;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (widget.receiverUser.uid!.isEmpty) {
      await userService.getUser(email: widget.receiverUser.email.validate()).then((value) {
        widget.receiverUser.uid = value.uid;
      }).catchError((e) {
        log(e.toString());
      });
    }
    senderUser = await userService.getUser(email: appStore.userEmail.validate());
    setState(() {});

    chatMessageService = ChatMessageService();
    await chatMessageService.setUnReadStatusToTrue(senderId: appStore.uid, receiverId: widget.receiverUser.uid!);
  }

  //region Methods
  Future<void> sendMessages() async {
    // If Message TextField is Empty.
    if (messageCont.text.trim().isEmpty) {
      messageFocus.requestFocus();
      return;
    }

    // Making Request for sending data to firebase
    ChatMessageModel data = ChatMessageModel();

    data.receiverId = widget.receiverUser.uid;
    data.senderId = appStore.uid;
    data.message = messageCont.text;
    data.isMessageRead = false;
    data.createdAt = DateTime.now().millisecondsSinceEpoch;
    data.messageType = MessageType.TEXT.name;

    messageCont.clear();

    await chatMessageService.addMessage(data).then((value) async {
      log("--Message Successfully Added--");

      /// Send Notification
      notificationService.sendPushNotifications(getStringAsync(DISPLAY_NAME), messageCont.text, receiverPlayerId: widget.receiverUser.playerId).catchError((e) {
        log("Notification Error ${e.toString()}");
      });

      await chatMessageService.addMessageToDb(senderRef: value, chatData: data, sender: senderUser, receiverUser: widget.receiverUser).then((value) {
        //
      }).catchError((e) {
        log(e.toString());
      });

      /// Save receiverId to Sender Doc.
      userService.saveToContacts(senderId: appStore.uid, receiverId: widget.receiverUser.uid.validate()).then((value) => log("---ReceiverId to Sender Doc.---")).catchError((e) {
        log(e.toString());
      });

      /// Save senderId to Receiver Doc.
      userService.saveToContacts(senderId: widget.receiverUser.uid.validate(), receiverId: appStore.uid).then((value) => log("---SenderId to Receiver Doc.---")).catchError((e) {
        log(e.toString());
      });
    }).catchError((e) {
      log(e.toString());
    });
  }

  //endregion

  //region Widget
  Widget _buildChatFieldWidget() {
    return Row(
      children: [
        AppTextField(
          textFieldType: TextFieldType.OTHER,
          controller: messageCont,
          textStyle: primaryTextStyle(),
          minLines: 1,
          onFieldSubmitted: (s) {
            sendMessages();
          },
          focus: messageFocus,
          cursorHeight: 20,
          maxLines: 5,
          cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          decoration: inputDecoration(context, borderRadius: 30).copyWith(
            hintText: language!.writeMsg,
            hintStyle: secondaryTextStyle(),
          ),
        ).expand(),
        8.width,
        Container(
          decoration: boxDecorationDefault(borderRadius: radius(80), color: primaryColor),
          child: IconButton(
            icon: Icon(Icons.send, color: Colors.white, size: 24),
            onPressed: () {
              sendMessages();
            },
          ),
        )
      ],
    );
  }

  //endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "",
        color: context.primaryColor,
        backWidget: BackWidget(),
        titleWidget: Hero(
          tag: widget.receiverUser.uid.validate(),
          child: Text(widget.receiverUser.displayName.validate(), style: TextStyle(color: whiteColor)),
        ),
      ),
      body: SizedBox(
        height: context.height(),
        width: context.width(),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset(chat_default_wallpaper).image,
                  fit: BoxFit.cover,
                  colorFilter: appStore.isDarkMode ? ColorFilter.mode(Colors.black54, BlendMode.luminosity) : ColorFilter.mode(primaryColor, BlendMode.overlay),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 80),
              child: PaginateFirestore(
                reverse: true,
                isLive: true,
                padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
                physics: BouncingScrollPhysics(),
                query: chatMessageService.chatMessagesWithPagination(senderId: appStore.uid, receiverUserId: widget.receiverUser.uid.validate()),
                initialLoader: LoaderWidget(),
                itemsPerPage: PER_PAGE_CHAT_COUNT,
                onEmpty: Text(language!.lblNoChatsFound, style: boldTextStyle(size: 20)).center(),
                shrinkWrap: true,
                onError: (e) {
                  return noDataFound(context);
                },
                itemBuilderType: PaginateBuilderType.listView,
                itemBuilder: (context, snap, index) {
                  ChatMessageModel data = ChatMessageModel.fromJson(snap[index].data() as Map<String, dynamic>);
                  data.isMe = data.senderId == appStore.uid;
                  return ChatItemWidget(chatItemData: data);
                },
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: _buildChatFieldWidget(),
            )
          ],
        ),
      ),
    );
  }
}
