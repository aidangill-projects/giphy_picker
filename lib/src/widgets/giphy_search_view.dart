import 'dart:async';
import 'package:flutter/material.dart';
import 'package:giphy_picker/src/model/giphy_repository.dart';
import 'package:giphy_picker/src/utils/debouncer.dart';
import 'package:giphy_picker/src/widgets/giphy_context.dart';
import 'package:giphy_picker/src/widgets/giphy_thumbnail_grid.dart';

/// Provides the UI for searching Giphy gif images.
class GiphySearchView extends StatefulWidget {
  @override
  _GiphySearchViewState createState() => _GiphySearchViewState();
}

class _GiphySearchViewState extends State<GiphySearchView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _repoController = StreamController<GiphyRepository>();
  late Debouncer _debouncer;

  @override
  void initState() {
    // initiate search on next frame (we need context)
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final giphy = GiphyContext.of(context);
      _debouncer = Debouncer(
        delay: giphy.searchDelay,
      );
      _search(giphy);
    });
    super.initState();
  }

  @override
  void dispose() {
    _repoController.close();
    _debouncer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final giphy = GiphyContext.of(context);
    final giphyDecorator = giphy.decorator;

    final inputDecoration = InputDecoration(
      hintText: giphy.searchText,
    );
    if (giphyDecorator.giphyTheme != null) {
      inputDecoration
          .applyDefaults(giphyDecorator.giphyTheme!.inputDecorationTheme);
    }

    return Column(children: <Widget>[
      Material(
        elevation: giphyDecorator.searchElevation,
        color: giphyDecorator.giphyTheme?.scaffoldBackgroundColor,
        child: Row(
          children: [
            if (!giphyDecorator.showAppBar) BackButton(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(15, 6, 15, 5),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: giphy.searchText,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ).applyDefaults(
                    giphyDecorator.giphyTheme!.inputDecorationTheme,
                  ),
                  onChanged: (value) => _delayedSearch(giphy, value),
                ),
              ),
            ),
          ],
        ),
      ),
      Expanded(
          child: StreamBuilder(
              stream: _repoController.stream,
              builder: (BuildContext context,
                  AsyncSnapshot<GiphyRepository> snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!.totalCount > 0
                      ? NotificationListener(
                          child: RefreshIndicator(
                              child: GiphyThumbnailGrid(
                                  key: Key('${snapshot.data.hashCode}'),
                                  repo: snapshot.data!,
                                  scrollController: _scrollController),
                              onRefresh: () =>
                                  _search(giphy, term: _textController.text)),
                          onNotification: (n) {
                            // hide keyboard when scrolling
                            if (n is UserScrollNotification) {
                              FocusScope.of(context).requestFocus(FocusNode());
                              return true;
                            }
                            return false;
                          },
                        )
                      : Center(child: Text('No results'));
                } else if (snapshot.hasError) {
                  return Center(child: Text('An error occurred'));
                }
                return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 44, 149, 215)),));
              }))
    ]);
  }

  void _delayedSearch(GiphyContext giphy, String term) =>
      _debouncer.call(() => _search(giphy, term: term));

  Future _search(GiphyContext giphy, {String term = ''}) async {
    // skip search if term does not match current search text
    if (term != _textController.text) {
      return;
    }

    try {
      // search, or trending when term is empty
      final repo = await (term.isEmpty
          ? GiphyRepository.trending(
              apiKey: giphy.apiKey,
              rating: giphy.rating,
              sticker: giphy.sticker,
              previewType: giphy.previewType,
              onError: giphy.onError)
          : GiphyRepository.search(
              apiKey: giphy.apiKey,
              query: term,
              rating: giphy.rating,
              lang: giphy.language,
              sticker: giphy.sticker,
              previewType: giphy.previewType,
              onError: giphy.onError,
            ));

      // scroll up
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      if (mounted) {
        _repoController.add(repo);
      }
    } catch (error) {
      if (mounted) {
        _repoController.addError(error);
      }
      giphy.onError?.call(error);
    }
  }
}
