import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
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
  late List<Widget> imageSliders;
  late final Future? myFuture = _initChannel();

  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  void initState() {
    super.initState();
  }

  Future _initChannel() async {
    Channel channel = await APIService.instance
        .fetchChannel(channelId: 'UCko7BQbSQ53GYzhFw2K1pZg');
    setState(() {
      _channel = channel;
    });
    imageSliders = _channel.videos
        .map(
          (video) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: b25Color,
                  offset: Offset(0, 3),
                  blurRadius: 7.5,
                ),
              ],
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        await launch(
                            'http://www.youtube.com/watch?v=${video.id}');
                      },
                      child: Image(
                          image: NetworkImage(video.thumbnailUrl),
                          fit: BoxFit.cover,
                          width: 1000),
                    ),
                  ],
                )),
          ),
        )
        .toList();
    return _channel;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: myFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData == false) {
          return Expanded(
            child: Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: TextStyle(fontSize: 12.5.sp),
          );
        } else {
          return Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: CarouselSlider(
                  items: imageSliders,
                  carouselController: _controller,
                  options: CarouselOptions(
                    autoPlay: true,
                    aspectRatio: 2.23,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(
                        () {
                          _current = index;
                        },
                      );
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _channel.videos.asMap().entries.map(
                  (entry) {
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(entry.key),
                      child: Container(
                        height: 8,
                        width: 8,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                              .withOpacity(_current == entry.key ? 0.8 : 0.4),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ],
          );
        }
      },
    );
  }
}
