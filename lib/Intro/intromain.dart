import 'package:flutter/material.dart';
import 'package:smart_ac/Intro/intro_page_1.dart';
import 'package:smart_ac/Intro/intro_page_2.dart';
import 'package:smart_ac/Intro/intro_page_3.dart';
import 'package:smart_ac/initConnection.dart';
import 'package:smart_ac/login_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroMain extends StatefulWidget {
  const IntroMain({Key? key}) : super(key: key);
  @override
  State<IntroMain> createState() => _IntroMainState();
}

class _IntroMainState extends State<IntroMain> {

  final PageController _controller2 = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller2,
            onPageChanged: (index){
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
            ],
          ),
          Container(
            alignment: Alignment(0,0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: (){
                    _controller2.jumpToPage(2);
                    },
                  child: Text('Skip', style: TextStyle(color: Colors.grey[400], fontSize: 16),),
                ),

                SmoothPageIndicator(controller: _controller2, count: 3, effect: ExpandingDotsEffect(activeDotColor: Colors.black),),

                onLastPage
                ?GestureDetector(
                  onTap: (){
                    savePrefs('intro', '1');
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
                  },
                  child: Text('Done', style: TextStyle(color: Colors.grey[400], fontSize: 16),),
                )
                :GestureDetector(
                  onTap: (){
                    _controller2.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                  },
                  child: Text('Next', style: TextStyle(color: Colors.grey[400], fontSize: 16),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
