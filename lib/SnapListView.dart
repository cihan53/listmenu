/*
 * Copyright (c) 2023.
 * Author: Cihan Öztürk
 * E-mail: cihanozturk53@gmail.com
 * web:https://www.cihanozturk.com
 */
library SnapListView;
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SnapListView extends StatefulWidget {
  ///Global key that passed to child ListView. Can be used for PageStorageKey
  final Key? listViewKey;

  ///Global key that's used to call `focusToItem` method to manually trigger focus event.
  final Key? key;

  ///ListView's scrollDirection
  final Axis scrollDirection;

  ///Callback function when list snaps/focuses to an item
  final void Function(int) onItemFocus;
  final void Function(int) onTap;

  ///Allows external controller
  final ScrollController listController;

  ///An optional initial position which will not snap until after the first drag
  final double? initialIndex;

  ///{@macro flutter.material.Material.clipBehavior}
  final Clip clipBehavior;

  ///Reverse scrollDirection
  final bool reverse;
  final bool selectedItemToCenter;
  final bool waveAnimation;
  final bool scrollNotifyEnable;

  ///Animation duration in milliseconds (ms)
  final int duration;

  final double itemSize;

  ///Number of item in this list
  final int itemCount;

  ///Widget builder.
  final Widget Function(BuildContext, int) itemBuilder;

  SnapListView({this.key,
    this.listViewKey,
    this.scrollDirection = Axis.vertical,
    ScrollController? listController,
    this.initialIndex,
    this.clipBehavior = Clip.hardEdge,
    required this.itemSize,
    required this.itemCount,
    required this.itemBuilder,
    this.reverse = false,
    this.duration = 500,
    required this.onItemFocus,
    required this.onTap,
    this.selectedItemToCenter = true,
    this.scrollNotifyEnable = false,
    this.waveAnimation = true})
      : listController = listController ?? ScrollController(),
        super(key: key);

  @override
  State<SnapListView> createState() => _SnapListViewState();
}

class _SnapListViewState extends State<SnapListView> {
  int selectedItemIndex = 0;
  int _focusItemIndex = 0;
  int itemHeight = 50;
  int menuHeight = 300;
  double currentPixel = 500;
  int centerItemIndex = 0;
  bool onKeyUp = false;
  List<GlobalKey> globalKeys = [];

  @override
  void initState() {
    widget.listController.addListener(() {
      getCenterItemIndex();
    });
  }

  @override
  void dispose() {
    widget.listController.dispose();
    super.dispose();
  }

  void getCenterItemIndex() {
    if (widget.scrollNotifyEnable) {
      // ListView'in başlangıç pozisyonunu hesapla
      final initialOffset = widget.listController.position.extentBefore;
      // ListView'in görünür alan yüksekliğini hesapla
      final visibleHeight = widget.listController.position.extentInside;
      // Merkezdeki öğenin index numarasını bul
      centerItemIndex = (initialOffset + visibleHeight / 2) ~/ itemHeight;
      if (_focusItemIndex != centerItemIndex) {
        setState(() {
          _focusItemIndex = centerItemIndex;
        });
        widget.onItemFocus(centerItemIndex);
      }
    }
  }

  void scrollToSelected() {
    final selectedOffset = (_focusItemIndex * itemHeight);
    final goPos = selectedOffset + itemHeight / 2 - (menuHeight / 2);
    widget.listController.animateTo(
      goPos,
      duration: const Duration(milliseconds: 500),
      curve: Curves.bounceInOut,
    );
  }

  double calculateScale(int index) {
    double difference = (_focusItemIndex - (index)).toDouble();
    // print("diffrence $_focusItemIndex ${difference.abs()/10}");
    return 1 - min(difference.abs() / 10, 0.4);
  }

  Widget _buildListItem(BuildContext context, int index) {
    Widget child;
    if (widget.waveAnimation) {
      child = Transform.scale(
        scale: calculateScale(index),
        child: widget.itemBuilder(context, index),
      );
    } else {
      child = widget.itemBuilder(context, index);
    }


    if (widget.scrollNotifyEnable) {
      return GestureDetector(
          child: child,
          onTap: () {
            widget.onTap(index);
            setState(() {
              _focusItemIndex = index;
            });

          }
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            _focusItemIndex = index;
          });
          widget.onTap(index);
        },
        child: Focus(
            canRequestFocus: true,
            onKeyEvent: (node, event) {
              // widget.listController.removeListener(getCenterItemIndex);
              if (event is KeyDownEvent  ) {
                LogicalKeyboardKey keyData = event.logicalKey;
                print('Basılan tuş: ${keyData.keyLabel}');
                if (keyData.keyLabel == "Arrow Up") {
                  node.previousFocus();
                } else if (keyData.keyLabel == "Arrow Down") node.nextFocus();
              }
              return KeyEventResult.handled;
            },
            onFocusChange: (focus) {
              if (focus) {
                setState(() {
                  _focusItemIndex = index;
                });
                scrollToSelected();
              }
              widget.onItemFocus(index);
            },
            child: child),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints constraint) {
          return ListView.builder(
            clipBehavior: widget.clipBehavior,
            reverse: widget.reverse,
            key: widget.listViewKey,
            controller: widget.listController,
            itemBuilder: _buildListItem,
            itemExtent: widget.itemSize,
          );
        },
      ),
    );
  }
}
