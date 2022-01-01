import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import "image_slideshow_fade.dart";
import 'gphotos.dart';
import 'dart:async';
import 'package:logging/logging.dart';

final log = Logger("PhotoGallery");




// TODO: Figure out how to fetch image list async - in initState()?
// Then do that
// And pass the list into the ImageSlideshow widget

void main() {

  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Exctract the environment variables
  Map<String, String> env = Platform.environment;


  // Get an environment variable or throw an exception
  String requiredEnvVariable(String name) {
    var data = env[name] ?? (throw ArgumentError("$name not defined"));
    log.info("Env variable $name is $data");
    return data;
  }

  final albumUrl = requiredEnvVariable("GALLERY_URL");


  final delayS = double.parse(requiredEnvVariable("GALLERY_SLIDESHOW_DELAY"));
  final shuffle = requiredEnvVariable("SHUFFLE_SLIDESHOW").contains("true");

  runApp(PhotoGalleryApp(albumUrl, delayS, shuffle));
}

class PhotoGalleryApp extends StatelessWidget {
  final String albumUrl;
  final ImageBackend imageBackend;
  final double delayS;
  final bool shuffle; 

  PhotoGalleryApp(this.albumUrl, this.delayS, this.shuffle, {Key? key}) :
    imageBackend = GPhotoImageBackend(albumUrl),
    super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PhotoGalleryWidget(imageBackend, delayS, shuffle));
  }


}

class PhotoGalleryWidget extends StatefulWidget {

  final ImageBackend imageBackend;
  final double delayS;
  final bool shuffle;

  const PhotoGalleryWidget(this.imageBackend, this.delayS, this.shuffle, {Key? key}) : super(key: key);


  @override
  State<PhotoGalleryWidget> createState() => _PhotoGalleryWidgetState();

}

class _PhotoGalleryWidgetState extends State<PhotoGalleryWidget> {



  static const int photoHeight = 1024;
  static const int retryTimeS = 10;

  Future<List<Image>> retryGetImages() {
    log.info("Getting a list of photos from ${widget.imageBackend.toString()}");

    return widget.imageBackend.getImages(photoHeight)
    .then((value) {
      log.info("Got ${value.length} photos");
      return value;
    })
    .catchError((error) {
      log.warning("Cannot fetch photo list. Retrying in $retryTimeS s: $error");
      // If we have an error, try to rebuild again to refresh the list
      Timer(const Duration(seconds: retryTimeS), () {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Image>>(
      future: retryGetImages(),
      builder: (context, AsyncSnapshot<List<Image>> images) {
          if (images.hasData) {
            return ImageSlideshowFade(
              children: images.data!,
              autoPlayInterval: (widget.delayS * 1000).round(),
              shuffle: true,
              onSlideshowComplete: () { 
                // refresh the list of photos from Google Photos
                setState(() {});},
            );
          } else {
            return const CircularProgressIndicator();
          }
      });
  }
}