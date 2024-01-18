import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodie/utils/app-constant.dart';
import 'package:foodie/views/auth-ui/welcome-screen.dart';
import 'package:foodie/widgets/banner-widget.dart';
import 'package:foodie/widgets/custom-drawer-widget.dart';
import 'package:foodie/widgets/flash-sale-widget.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../widgets/category-widget.dart';
import '../../widgets/heading-widget.dart';

class MainScreens extends StatefulWidget {
  const MainScreens({super.key});

  @override
  State<MainScreens> createState() => _MainScreensState();
}

class _MainScreensState extends State<MainScreens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppConstant.appTextColor),
        centerTitle: true,
        backgroundColor: AppConstant.appSecondaryColor,
        title: Text("Dashboard",style: TextStyle(color: AppConstant.appTextColor),),
        actions: [
          IconButton(
              onPressed: () {
                //FirebaseAuth.instance.signOut();
              }, icon: Icon(Icons.shopping_cart,color: Colors.white70,)),
        ],
      ),
      drawer: DrawerWidget(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: Get.height/90.0,
              ),
              //banners
              BannerWidget(),

              //heading
             HeadingWidget(
                 headingTitle: "Categories",
                 headingSubTitle: "According to your budget",
                 onTap: (){},
                 buttonText: "See more >"
             ),
              CategoriesWidget(),
              HeadingWidget(
                  headingTitle: "Flash Sale",
                  headingSubTitle: "According to your budget",
                  onTap: (){},
                  buttonText: "See more >"
              ),
              FlashSaleWidget(),
              SizedBox(
                height: 100.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
