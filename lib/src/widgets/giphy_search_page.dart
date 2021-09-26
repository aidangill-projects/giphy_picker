import 'package:flutter/material.dart';
import 'package:giphy_picker/src/widgets/giphy_search_view.dart';
import 'giphy_context.dart';

class GiphySearchPage extends StatelessWidget {
  final Widget? title;

  const GiphySearchPage({this.title});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final giphyDecorator = GiphyContext.of(context).decorator;
      return Theme(
        data: giphyDecorator.giphyTheme ?? Theme.of(context),
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            actions: <Widget>[
              Container(padding: EdgeInsets.fromLTRB(10, 10, 15, 10), child: Image(image: AssetImage("assets/giffy_logo.png"))),
            ],
          ),
          body: SafeArea(
            child: GiphySearchView(),
            bottom: false,
          ),
        ),
      );
    });
  }
}
