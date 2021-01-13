import 'package:flutter/material.dart';
import 'package:giphy_picker/src/model/giphy_client.dart';
import 'package:giphy_picker/src/widgets/giphy_image.dart';

/// Presents a Giphy preview image.
class GiphyPreviewPage extends StatelessWidget {
  final GiphyGif gif;
  final Widget title;
  final ValueChanged<GiphyGif> onSelected;

  const GiphyPreviewPage({@required this.gif, @required this.onSelected, this.title});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
        appBar: AppBar(
            title: title,
            toolbarHeight: 55),
        body: SafeArea(
            child: Container(
                color: Colors.black,
                child: Center(
                    child: GiphyImage.original(
                  gif: gif,
                  width: media.orientation == Orientation.portrait ? double.maxFinite : null,
                  height: media.orientation == Orientation.landscape ? double.maxFinite : null,
                  fit: BoxFit.contain,
                ))),
            bottom: false),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            onSelected(gif);
          },
          child: Icon(Icons.check),
          backgroundColor: Color.fromARGB(255, 44, 149, 215),
        ));
  }
}
