import 'package:flutter/material.dart';
import 'package:giphy_picker/src/model/giphy_client.dart';
import 'package:giphy_picker/src/widgets/giphy_image.dart';

/// Presents a Giphy preview image.
class GiphyPreviewPage extends StatelessWidget {
  final GiphyGif gif;
  final Widget? title;
  final ValueChanged<GiphyGif>? onSelected;

  const GiphyPreviewPage({required this.gif, @required this.onSelected, this.title});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          actions: <Widget>[
            Container(padding: EdgeInsets.fromLTRB(10, 10, 15, 10), child: Image(image: AssetImage("assets/giffy_logo.png"))),
          ],
        ),
        body: SafeArea(
            child: Container(
                color: Colors.black,
                child: Center(
                    child: GiphyImage.downsized(
                  gif: gif,
                  width: media.orientation == Orientation.portrait ? double.maxFinite : null,
                  height: media.orientation == Orientation.landscape ? double.maxFinite : null,
                  fit: BoxFit.contain,
                  renderGiphyOverlay: false,
                ))),
            bottom: false),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            onSelected!(gif);
          },
          child: Icon(Icons.check),
          backgroundColor: Color.fromARGB(255, 44, 149, 215),
        ));
  }
}
