import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/base_scaffold_body.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class AppScaffold extends StatelessWidget {
  final String? appBarTitle;
  final List<Widget>? actions;

  final Widget child;
  final Color? scaffoldBackgroundColor;

  AppScaffold({this.appBarTitle, required this.child, this.actions, this.scaffoldBackgroundColor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        appBarTitle.validate(),
        textColor: white,
        elevation: 0.0,
        color: context.primaryColor,
        backWidget: BackWidget(),
        actions: actions,
      ),
      backgroundColor: scaffoldBackgroundColor,
      body: Body(child: child),
    );
  }
}
