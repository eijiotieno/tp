import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Text(
                      'Wallet',
                      style: TextStyle(),
                    ),
                    Text(
                      'Total funds',
                      style: TextStyle(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: SizedBox(
                        height: 250.0,
                        width: double.infinity,
                        child: Carousel(
                          boxFit: BoxFit.cover,
                          autoplay: false,
                          animationCurve: Curves.fastOutSlowIn,
                          animationDuration: Duration(milliseconds: 1000),
                          dotSize: 6.0,
                          dotIncreasedColor: Color(0xFFFF335C),
                          dotBgColor: Colors.transparent,
                          dotPosition: DotPosition.bottomCenter,
                          dotVerticalPadding: 10.0,
                          showIndicator: true,
                          indicatorBgPadding: 7.0,
                          images: [
                            Container(
                              color: Colors.tealAccent,
                              child: Column(
                                children: [
                                  Text(
                                    'Balance',
                                    style: TextStyle(),
                                  ),
                                  Text(
                                    'Totsl funds',
                                    style: TextStyle(),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.blueAccent,
                              child: Column(
                                children: [
                                  Text(
                                    'Balance',
                                    style: TextStyle(),
                                  ),
                                  Text(
                                    'Totsl funds',
                                    style: TextStyle(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                      Text(
                      'Logs',
                      style: TextStyle(),
                    ),
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
