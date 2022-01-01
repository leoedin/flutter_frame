import 'dart:async';


import 'package:flutter/material.dart';

class ImageSlideshowFade extends StatefulWidget {
  ImageSlideshowFade({
    Key? key,
    children,
    this.autoPlayInterval,
    this.shuffle,
    this.onSlideshowComplete
    }) : 
    displayedChildren = List.from(children),
    super(key: key) {
      if (shuffle!) {
        displayedChildren.shuffle();
      }
    }

  // The actual list to show, in order
  final List<Widget> displayedChildren; 
  final int? autoPlayInterval;
  final bool? shuffle;
  final VoidCallback? onSlideshowComplete;

  @override
  State<ImageSlideshowFade> createState() => _ImageSlideshowFadeState();
}

class _ImageSlideshowFadeState extends State<ImageSlideshowFade> {
  int _firstIndex = 0;
  int _secondIndex = 1;
  bool showingFirst = true;

  static const fadeDuration = Duration(seconds: 1);

  _ImageSlideshowFadeState();

  @override
  void initState() {
    if (widget.autoPlayInterval != 0) {
     _autoPlayTimerStart();
    }

    super.initState();
  }

  void advance() {
    int getNext(int other) {
      int idx = other + 1;
      if (idx >= widget.displayedChildren.length) idx = 0;
      return idx;
    }

    if (showingFirst) {
      _secondIndex = getNext(_firstIndex);
    } else {
      _firstIndex = getNext(_secondIndex);
    }
  }

  void _autoPlayTimerStart() {
    Timer.periodic(
      Duration(milliseconds: widget.autoPlayInterval!),
      (timer) {
        setState(() {
          // Change which image is shown
          showingFirst = !showingFirst;

          // If we've just wrapped around, notify the parent
          if ((showingFirst && (_firstIndex == 0))
              || (!showingFirst && (_secondIndex == 0))) {
                  widget.onSlideshowComplete!();
              }
        });

        // And schedule flipping over the images
        Timer(fadeDuration * 2, () {
            advance();
        });
      });
  }

 // It's all working but it's not animatedCrossFading...
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: fadeDuration,
      firstChild: widget.displayedChildren[_firstIndex],
      secondChild: widget.displayedChildren[_secondIndex],
      crossFadeState: showingFirst ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      );
  }
}

/*
class ImageSlideshowFade extends StatefulWidget {
  List<Widget> children;
  final double delayS;
  final bool shuffle;

  ImageSlideshowFade({List<Widget> children, Key? key}) : 
  children = children ?? [],
  super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container()
  }
}*/