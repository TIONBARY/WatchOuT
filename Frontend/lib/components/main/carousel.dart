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
        .fetchChannel(channelId: 'UCko7BQbSQ53GYzhFw2K1pZg');
    setState(() {
      _channel = channel;
    });
    imageSliders = _channel.videos
        .map(
          (video) => Container(
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
                        image: NetworkImage(video.thumbnailUrl),
                      ),
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
            return Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text(
              'Error: ${snapshot.error}',
              style: TextStyle(fontSize: 12.5.sp),
            );
          } else {
            return Container(
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
