import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DrawerController extends Notifier<GlobalKey<ScaffoldState>> {
  @override
  GlobalKey<ScaffoldState> build() => GlobalKey<ScaffoldState>();

  void openDrawer() {
    state.currentState?.openDrawer();
  }

  void closeDrawer() {
    state.currentState?.closeDrawer();
  }
}

final drawerProvider =
    NotifierProvider<DrawerController, GlobalKey<ScaffoldState>>(
  DrawerController.new,
);
