

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' show Client;


abstract class ImageBackend {
  Future<List<Image>> getImages(int width);
}

class GPhotoImageBackend implements ImageBackend {
  String albumUrl;

  // An HTTP client - can be replaced for mocking tests
  Client client = Client();

  GPhotoImageBackend(this.albumUrl) {
    // Check the URL includes the right domains
    if (!(["photos.app.goo.gl", "goo.gl"].contains(_getHostname(albumUrl)))) {
      throw ArgumentError("Google Photos Album Link $albumUrl does not contain correct domain");
    }
  }


  String? _getHostname(String url) {
    RegExp exp = RegExp(r":\/\/(www[0-9]?\.)?(.[^/:]+)", caseSensitive: false);
    var match = exp.firstMatch(url);
    if (match != null) {
      return match.group(2);
    } else {
      return null;
    }
  }

  // A function to get the phots from an album
  Future<Iterable<String>> getPhotoUrls(int height) async {
    // Go to the album URL and fetch its contents
    var body = await client.get(Uri.parse(albumUrl));

    // Parse everything with a regex and extract the base URLs for the images
    RegExp imrx = RegExp(r'\["(https:\/\/[^\.]+.googleusercontent\.com\/[^"]+)",([0-9]+),([0-9]+)[,\]]');
    var matches = imrx.allMatches(body.body).map((match) {
      // For reference
      //var nativeWidth = match.group(2);
      //var nativeHeight = match.group(3);
      var baseUrl = match.group(1);
      return "$baseUrl=h$height";
    });
    return matches;
  }

  @override
  Future<List<Image>> getImages(int height) async {
    return getPhotoUrls(height).then((result) => result.map((url) => Image.network(url)).toList());
  }

}

