import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../youtube/models/channel_model.dart';
import '../youtube/services/api_service.dart';

class Carousel extends StatefulWidget {
  // final String id;

  // Carousel({required this.id});
  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late Channel _channel;
  bool _isLoading = false;
  late List<Widget> imageSliders;
  late final Future? myFuture = _initChannel();

  @override
  void initState() {
    super.initState();
  }

  Future _initChannel() async {
    Channel channel = await APIService.instance
        .fetchChannel(channelId: 'UCLNhdQhyGlmdudmRGRdcYdQ');
    setState(() {
      _channel = channel;
    });
    imageSliders = _channel.videos
        .map((video) => Container(
              child: Container(
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    child: Stack(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            await launch(
                                'http://www.youtube.com/watch?v=${video.id}');
                          },
                          child: Image(
                            width: 200.0,
                            image: NetworkImage(video.thumbnailUrl),
                          ),
                        ),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            // child: Text(
                            //   'No. image',
                            //   style: TextStyle(
                            //     color: Colors.white,
                            //     fontSize: 12.5.sp,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                          ),
                        ),
                      ],
                    )),
              ),
            ))
        .toList();
    return _channel;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: myFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData == false) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text(
              'Error: ${snapshot.error}',
              style: TextStyle(fontSize: 15),
            );
          } else {
            return Container(
              margin: EdgeInsets.fromLTRB(0, 1.25.h, 0, 1.25.h),
              child: CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                ),
                items: imageSliders,
                // items
              ),
            );
          }
        });
  }
}
