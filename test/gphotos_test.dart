// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:flutter_frame/gphotos.dart';


void main() {
  test('Extracts the image URLs from a Google Photos request', () async {
    final gphoto = GPhotoImageBackend(["https://photos.app.goo.gl/CPJJWHjNNupzPXA8A"]);

    gphoto.client = MockClient((request) async {
      var data = await File("test/gphoto_example_source.html").readAsString();

      return Response(data, 200, headers: {
          HttpHeaders.contentTypeHeader: 'text/html; charset=utf-8',
      }
      );
    });

    var urls = await gphoto.getPhotoUrls(1024);
    
    // Some of the URLs we're expecting - manually extracted from our test data
    expect(urls.first, "https://lh3.googleusercontent.com/uFAMUnB_wD991ez6rvobB4qW6Xd2t4oFH0kCvMtKbDgiLQd8OrpdqWfz96m5XdRcyjQWS6BCDpd_Uxvu_5E8-_jWkFfZFqCAUS2dhK-FYOO3sKRZBDpfywR9UF2zRpcfcBtwQIguiA=h1024");
    expect(urls.elementAt(1), "https://lh3.googleusercontent.com/h4l_on6gaklgXew4lciz2eW4cduGwfgObjDv2g1glKm9k_4IvTokOazdni2my08K0Dj9dax5FLHp0x-M5kFEBu5eV0y5DxSgSOmTetMHV9GYGcuCZX2ztFuIDCXn2M0vnzY3Utb9LA=h1024");
    expect(urls.last, "https://lh3.googleusercontent.com/CPo6tx3LERwGkt67BnGHlU3mLub-Ehq4rqn1fMj3zS1kdr0PhXPr3RcXruAZAaXW_u09jZVnlGjkgaT31nqYf0cHWBXABQkKLUFkv6gLwgWLVPYPncfFdtkWe-XhZCTcumNMFx5oZi4=h1024");

  });
}
