import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sort_photos_by_month/FolderEntry.dart';
import 'package:sort_photos_by_month/MyHomePage.dart';

void main() {
  testWidgets('FolderEntry', (WidgetTester tester) async {
    var f = FolderEntry(Directory('/'), update: () {
      print('update');
    });
    print(f.folder);
  });

  testWidgets('MyHomePage', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
        MaterialApp(home: MyHomePage(title: 'Sort photos by month')));
    expect(find.byType(MaterialApp), matchesGoldenFile("MyHomePage1.png"));

    var mhp = find.byType(MyHomePage);
    var state = tester.state<MyHomePageState>(mhp);
    print([state, state.permissionGranted, state.dirs]);
    expect(state.permissionGranted, isFalse);

//    if (!state.permissionGranted) {
//      await tester.runAsync(() {
//        tester.tap(find.byType(RaisedButton));
//      });
//      await tester.pumpAndSettle();
//      expect(find.byType(MaterialApp), matchesGoldenFile("MyHomePage2.png"));
//    } else {
//      expect(find.text('Move by month'), findsOneWidget);
//      await tester.pumpAndSettle();
//      expect(find.byType(MaterialApp), matchesGoldenFile("MyHomePage3.png"));
//      expect(find.byType(CircularProgressIndicator), findsOneWidget);
//    }
  });
}
