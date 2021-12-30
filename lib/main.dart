import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

import 'gphotos.dart';

void logger(String data) {
  print(data);
}

// TODO: Figure out how to fetch image list async - in initState()?
// Then do that
// And pass the list into the ImageSlideshow widget

void main() {

  // Exctract the environment variables
  Map<String, String> env = Platform.environment;


  // Get an environment variable or throw an exception
  String requiredEnvVariable(String name) {
    var data = env[name] ?? (throw ArgumentError("$name not defined"));
    logger("Env variable $name is $data");
    return data;
  }

  final albumUrl = requiredEnvVariable("GALLERY_URL");


  final delayS = double.parse(requiredEnvVariable("GALLERY_SLIDESHOW_DELAY"));
  final shuffle = requiredEnvVariable("SHUFFLE_SLIDESHOW").contains("true");

  runApp(PhotoGalleryApp(albumUrl, delayS, shuffle));
}

class PhotoGalleryApp extends StatelessWidget {
  final String albumUrl;
  ImageBackend imageBackend;
  final double delayS;
  final bool shuffle; 

  PhotoGalleryApp(this.albumUrl, this.delayS, this.shuffle, {Key? key}) :
    imageBackend = GPhotoImageBackend(albumUrl),
    super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Demo'),
        ),
        body: PhotoGalleryWidget(imageBackend, delayS, shuffle)));
  }


}

class PhotoGalleryWidget extends StatelessWidget {
  final ImageBackend imageBackend;
  final double delayS;
  final bool shuffle;

  const PhotoGalleryWidget(this.imageBackend, this.delayS, this.shuffle, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Image>>(
      future: imageBackend.getImages(1024),
      builder: (context, AsyncSnapshot<List<Image>> images) {
          if (images.hasData) {
            return ImageSlideshow(
            /// Width of the [ImageSlideshow].
            width: double.infinity,

            /// Height of the [ImageSlideshow].
            height: 200,

            /// The page to show when first creating the [ImageSlideshow].
            initialPage: 0,

            /// The color to paint the indicator.
            indicatorColor: Colors.blue,

            /// The color to paint behind th indicator.
            indicatorBackgroundColor: Colors.grey,

            /// The widgets to display in the [ImageSlideshow].
            /// Add the sample image file into the images folder
            children: images.data!,

            /// Called whenever the page in the center of the viewport changes.
            onPageChanged: (value) {
              print('Page changed: $value');
            },

            /// Auto scroll interval.
            /// Do not auto scroll with null or 0.
            autoPlayInterval: 3000,

            /// Loops back to first slide.
            isLoop: true,
          );
          } else {
            return const CircularProgressIndicator();
          }
      });
  }
}