import 'package:wigg/Authentication/LoginView.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppImages.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/intro/SliderModel.dart';
import 'package:page_view_indicators/page_view_indicators.dart';
import 'package:flutter/material.dart';

class IntroView extends StatefulWidget {
  @override
  _IntroViewState createState() => _IntroViewState();
}

class _IntroViewState extends State<IntroView> {
  List<SliderModel> mySLides = new List<SliderModel>();
  int slideIndex = 0;
  final _currentPageNotifier = ValueNotifier<int>(0);

  PageController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mySLides = getSlides();
    controller = new PageController();
  }

  @override
  Widget build(BuildContext context) {
//    final image = new Container(
//      decoration: BoxDecoration(
//        image: DecorationImage(
//          image: AssetImage(AppImages.app_bg),
//          fit: BoxFit.cover,
//        ),
//      ),
//    );

    Container();
    getPageData(String desc) {
      return Container(
//        padding: EdgeInsets.only(bottom: 20.0),
          child: Align(
        alignment: Alignment.bottomCenter,
        child: Text(
          desc,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ));
    }

    final pgView = PageView(
      controller: controller,
      onPageChanged: (index) {
        setState(() {
          slideIndex = index;
          _currentPageNotifier.value = index;
        });
      },
      children: <Widget>[
        getPageData(mySLides[0].getDesc()),
        getPageData(mySLides[1].getDesc()),
        getPageData(mySLides[2].getDesc())
      ],
    );

    _buildCircleIndicator2() {
      return CirclePageIndicator(
        selectedDotColor: AppColors.appBlueColor,
        dotColor: Colors.grey,
        size: 8.0,
        selectedSize: 9.0,
        itemCount: 3,
        currentPageNotifier: _currentPageNotifier,
      );
    }

    final middleContainer = Center(
      child: Container(
        alignment: AlignmentDirectional(0.0, 0.0),
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height - 310,
            maxWidth: MediaQuery.of(context).size.width - 40,
            minWidth: MediaQuery.of(context).size.width - 40,
            minHeight: MediaQuery.of(context).size.height - 310),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(40)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height - 400,
              width: MediaQuery.of(context).size.width - 40,
              child: pgView,
            ),
            SizedBox(
              height: 20,
            ),
            Container(
                height: 20,
//              color: Colors.pink,
                child: _buildCircleIndicator2()),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );

    final bgImage = new Stack(
      children: [
        CommonFunction.setImage(AppImages.app_bg, BoxFit.cover),
        middleContainer,
        new Positioned(
          bottom: 25,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: new Row(
              mainAxisAlignment: (MainAxisAlignment.spaceBetween),
              children: [
                new Container(
                  child: ClearButton(
                    btnName: "Skip",
                    onPressed: () {
                      print("Skip Tapped");
                      Navigator.of(context)
                          .pushNamed(LoginView.name);
                    },
                  ),
                ),
                new Container(
                  child: YellowThemeButton(
                    btnName: "Next",
                    onPressed: () {
                      if (slideIndex == 2) {
                        print("Redirect to login");
                        Navigator.of(context)
                            .pushNamed(LoginView.name);
                      } else {
                        slideIndex += 1;
                        _currentPageNotifier.value = slideIndex;
                        print(slideIndex.toString());
                        controller.animateToPage(slideIndex,
                            duration: Duration(milliseconds: 400),
                            curve: Curves.linear);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Container(
      color: Colors.red,
      child: Scaffold(
        body: bgImage,
//        bottomSheet: btnNext,
      ),
    );
  }
}

//class SlideTile extends StatelessWidget {
//  String title, desc;
//
//  SlideTile({this.title, this.desc});
//
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      padding: EdgeInsets.symmetric(horizontal: 20),
//      alignment: Alignment.center,
//      child: Column(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
////          Image.asset(imagePath),
//          SizedBox(
//            height: 40,
//          ),
//          Text(
//            title,
//            textAlign: TextAlign.center,
//            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
//          ),
//          SizedBox(
//            height: 20,
//          ),
//          Text(desc,
//              textAlign: TextAlign.center,
//              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14))
//        ],
//      ),
//    );
//  }
//}
