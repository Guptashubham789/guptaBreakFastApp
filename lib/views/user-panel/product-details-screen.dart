import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodie/models/cart-model.dart';
import 'package:foodie/models/product-model.dart';
import 'package:foodie/utils/app-constant.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'cart-screen/cart-screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  ProductModel productModel;
   ProductDetailsScreen({super.key, required this.productModel});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  User? user=FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appSecondaryColor,
        iconTheme: IconThemeData(color: AppConstant.appTextColor),
        title: Text('Products Details',style: TextStyle(color: AppConstant.appTextColor),),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () {
                  //ssg();
                  Get.to(()=>CartScreen());
                }, icon: Icon(Icons.shopping_cart,color: Colors.white70,)),
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(height: Get.height/60,),
             CarouselSlider(
        items: widget.productModel.productImages.map(
            (imageUrl) => ClipRRect(
          borderRadius:BorderRadius.circular(10.0),

      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: Get.width-10,
        placeholder: (context,url)=>ColoredBox(
          color: Colors.white,
          child:Center(
            child: CupertinoActivityIndicator(),
          ),
        ),
        errorWidget: (context,url,error)=>Icon(Icons.error),
      ),
    ),
    ).toList(),
    options: CarouselOptions(
    height: 200.0,
    scrollDirection: Axis.horizontal,
    autoPlay: true,
    aspectRatio: 2.5,
    viewportFraction: 1,
    ),
    ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          alignment: Alignment.topLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(widget.productModel.productName),
                              Icon(Icons.favorite_outline)
                            ],
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: [
                              widget.productModel.isSale==true && widget.productModel.salePrice !=''?
                              Text("Price : "+widget.productModel.salePrice):Text("Price : "+widget.productModel.fullPrice),
                            ],
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          alignment: Alignment.topLeft,
                          child: Text("Category : "+widget.productModel.categoryName)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          alignment: Alignment.topLeft,
                          child: Text(widget.productModel.productDescription)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Material(
                            child: Container(
                                width: Get.width/3.0,
                                height: Get.height/16,
                                decoration: BoxDecoration(
                                  color: AppConstant.appSecondaryColor,
                                  borderRadius: BorderRadius.circular(20),

                                ),
                                child: TextButton(
                                    child: Text('Add to cart',style: TextStyle(color: AppConstant.appTextColor,fontSize: 16),),
                                    onPressed: () async{
                                      await checkProductAddToCart(uId:user!.uid);
                                    }
                                )
                            ),
                          ),
                          SizedBox(width: Get.width/5.0,),
                          Material(
                            child: Container(
                                width: Get.width/3.0,
                                height: Get.height/16,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20),

                                ),
                                child: TextButton(
                                    child: Text('WhatsApp',style: TextStyle(color: AppConstant.appTextColor,fontSize: 16),),
                                    onPressed: () {
                                      //   Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                      //       SignInScreen()));
                                      // },
                                    }
                                )
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> checkProductAddToCart({
    required String uId,
    int quantityIncrement=1
  }) async{
    final DocumentReference documentReference=FirebaseFirestore.instance
        .collection('cart')
        .doc(uId)
        .collection('cartOrders') //jo bhi apne cart ke ander product store honge usko apni id ke base par insert karenge
        .doc(widget.productModel.productId.toString() );

    //jitne bhi doc aapko milenge use hum snapshot me store kr lenge
    DocumentSnapshot snapshot=await documentReference.get();

    //agr humara ek bar koi product add ho jayega to use hum phir se add nhi karenge
    //and uski qnty ko hum bs increase karenge and price ko
    if(snapshot.exists){
      int currentQuantity=snapshot['productQuantity'];
      int updatedQuantity=currentQuantity+quantityIncrement;
      double totalPrice=
          double.parse(widget.productModel.isSale?widget.productModel.salePrice:widget.productModel.fullPrice)*updatedQuantity;
          await documentReference.update({
            'productQuantity': updatedQuantity,
            'productTotalPrice':totalPrice,
          });
      Get.snackbar(
        "Product exist in cart!!",
        "",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppConstant.appSecondaryColor,
        colorText: AppConstant.appTextColor,
      );
    }else{
      //else ke andr ek baar product add ho jayega to dubara se vhi product add nhi karega
      //us product ki qnty ko increase kar dega database me and if ki condition chalega usme
      await FirebaseFirestore.instance.collection('cart').doc(uId).set(
        {
          'uId':uId,
          'createdAt':DateTime.now()
        }
      );
      CartModel cartModel=CartModel(
          productId: widget.productModel.productId,
          categoryId: widget.productModel.categoryId,
          productName: widget.productModel.productName,
          categoryName: widget.productModel.categoryName,
          salePrice: widget.productModel.salePrice,
          fullPrice: widget.productModel.fullPrice,
          productImages: widget.productModel.productImages,
          deliveryTime: widget.productModel.deliveryTime,
          isSale: widget.productModel.isSale,
          productDescription: widget.productModel.productDescription,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          productQuantity: 1,
          productTotalPrice: double.parse(widget.productModel.isSale?widget.productModel.salePrice:widget.productModel.fullPrice),
      );
      await documentReference.set(cartModel.toMap());
      Get.snackbar(
        "",
        "Product add to cart!!!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstant.appSecondaryColor,
        colorText: AppConstant.appTextColor,
        icon: Icon(Icons.shopping_cart)
        
      );
    }
  }

}


