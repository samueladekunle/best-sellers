import "package:flutter/material.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:url_launcher/url_launcher.dart";

class BooksListItem extends StatefulWidget {
  final String rank, weeksOnList, title, contributor, bookImage, description;
  final List<dynamic> buyLinks;

  BooksListItem({
    Key key,
    @required this.rank,
    @required this.weeksOnList,
    @required this.title,
    @required this.contributor,
    @required this.bookImage,
    @required this.description,
    @required this.buyLinks,
  }) : super(key: key);

  @override
  _BooksListItem createState() => _BooksListItem();
}

class _BooksListItem extends State<BooksListItem> {
  String rank, weeksOnList, title, contributor, bookImage, description;
  List<dynamic> buyLinks;
  double width = 200.0;

  @override
  initState() {
    super.initState();
    rank = widget.rank;
    weeksOnList = widget.weeksOnList;
    title = widget.title;
    contributor = widget.contributor;
    bookImage = widget.bookImage;
    description = widget.description;
    buyLinks = widget.buyLinks;
  }

  Widget build(BuildContext context) {
    Widget upperSection(String rank, String bookImage) {
      final double height = 150.0, width = 100.0;
      final Rank = Container(
        height: height,
        alignment: Alignment.topLeft,
        child: Text(
          rank,
          style: Theme.of(context).textTheme.display1,
        ),
      );

      final BookImage = CachedNetworkImage(
          imageUrl: bookImage,
          placeholder: Container(width: width, height: height, child: Center(child: RefreshProgressIndicator(),),),
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorWidget: Container(width: width, height: height, child: Center(child: Icon(Icons.image, color: Color(0xFFCCCCCC), size: 30.0,),),),
        );

      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Rank,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [BookImage,],
              ),
            ),
          ],
        )
      );
    }

    Widget middleSection(String title, String contributor, String weeksOnList, String description) {
      final weeks = int.parse(weeksOnList);
      if (weeks == 0) {
        weeksOnList = "NEW THIS WEEK";
      } else if (weeks > 0) {
        weeksOnList = "$weeksOnList ${weeks == 1 ? "WEEK" : "WEEKS"} ON THE LIST";
      }

      final Title = Align(
        alignment: Alignment.topLeft,
        child: Text(title, style: Theme.of(context).textTheme.body2),
      );

      final Contributor = Align(
        alignment: Alignment.topLeft,
        child: Text(contributor, style: Theme.of(context).textTheme.body1,),
      );

      final WeeksOnList = Align(
        alignment: Alignment.topLeft,
        child: Text(weeksOnList, style: Theme.of(context).textTheme.caption,),
      );

      return Column(
        children: [
          WeeksOnList,
          Title,
          Contributor,
          Padding(padding: EdgeInsets.all(2.0),),
          Text(description, textAlign: TextAlign.justify,),
        ],
      );
    }

    Widget lowerSection(List<dynamic> buyLinks) {
      Future<Null> onSelected(String url) async => await launch(url);

      return ButtonTheme.bar(
        child: ButtonBar(
          alignment: MainAxisAlignment.start,
          children: [
            DropdownButton(
              items: buyLinks.map((buyLink) => DropdownMenuItem(
                value: buyLink["url"],
                child: Text(buyLink["name"]),
              )).toList(),
              hint: Text("BUY"),
              onChanged: (url) {
                onSelected(url);
              },
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: width,
      child: Card(
        child: Container(
          padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              upperSection(rank, bookImage),
              Padding(padding: EdgeInsets.all(7.0)),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    middleSection(title, contributor, weeksOnList, description),
                    lowerSection(buyLinks),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}