import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loadmore/loadmore.dart';
import 'package:news_app/news_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<NewsModel> dataList = List();
  List<NewsModel> newsList = List();
  bool loading;

  @override
  void initState() {
    getNewsData();
    super.initState();
  }

  void getNewsData() async {
    if(mounted)
    setState(() {
      loading= true;
    });
    String url =
        "http://newsapi.org/v2/top-headlines?country=in&category=sports&apiKey=aa67d8d98c8e4ad1b4f16dbd5f3be348";
    final response = await http.get(url);
    if(mounted)
      setState(() {
        loading= false;
      });
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      responseData = responseData['articles'];
      print(responseData);
      for(var data in responseData){
        dataList.add(NewsModel.fromJson(data));
      }
      addDataToList(0);
    } else {
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text("Failed to load data")));
      throw Exception('Failed to load data');
    }
  }
  String formatDate(String date){
    DateTime newDate = new DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").parse(date);
     DateFormat formatter = DateFormat('dd-MMM-yyyy HH:mm a');
     String formatted = formatter.format(newDate);
    return formatted;
}

  launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  addDataToList(int index){
    for(int i=index;i<5;i++){
      setState(() {
        newsList.add(dataList[i]);
      });
    }
  }

  Future<bool> _loadMore() async {
    print("onLoadMore");
    await Future.delayed(Duration(seconds: 0, milliseconds: 100));
    addDataToList(5);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFedf2f6),
      appBar: AppBar(
        title: Text("Sports News",
          style: TextStyle(
            fontSize: 18,
            fontFamily: "Mon-Semibold",
          ),),
      ),
      body: Center(
        child:loading?Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[200],
            enabled: true,
            child: ListView.builder(
              itemBuilder: (_, __) => Container(
                margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                padding: EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  border: Border.all(color: Colors.black)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: width,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.grey[300],
                        ),
                      ),
                    ),Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: width*0.4,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 8,
                            width: width*0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: Colors.grey[300],
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 30,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Colors.grey[300],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )): LoadMore(
          isFinish: newsList.length >= dataList.length,
          onLoadMore: _loadMore,
          child: ListView.builder(
            itemBuilder: (BuildContext context, int i) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                padding: EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image:newsList[i].urlToImage==null?
                            NetworkImage("https://www.engenome.com/wp-content/uploads/2017/10/news-placeholder.jpg"):
                            NetworkImage(newsList[i].urlToImage),
                            fit: BoxFit.fill
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text("${newsList[i].title}",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Mon-Semibold",
                        ),),
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text("${newsList[i].source.name}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontFamily: "Mon-Semibold",
                        ),),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("${formatDate(newsList[i].publishedAt)}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontFamily: "Mon-Regular",
                            ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: (){
                              launchURL(newsList[i].url);
                            },
                            child: Container(
                              width: 70,
                              height: 30,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.all(Radius.circular(20))
                              ),
                              child: Center(
                                child: Text("Website",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontFamily: "Mon-Regular",
                                  ),),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              );
            },
            itemCount: newsList.length,
          ),
        ),
      ),
    );
  }
}
