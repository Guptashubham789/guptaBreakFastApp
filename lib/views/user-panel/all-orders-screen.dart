import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:foodie/models/cart-model.dart';
import 'package:foodie/models/order-model.dart';
import 'package:foodie/utils/app-constant.dart';
import 'package:foodie/views/user-panel/cart-screen/checkout-screen.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_card/image_card.dart';

import '../../../controllers/cart-price-controller.dart';
class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  User? user=FirebaseAuth.instance.currentUser;
  final ProductPriceController priceController=Get.put(ProductPriceController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppConstant.appTextColor),
        backgroundColor: AppConstant.appSecondaryColor,
        title: Text('All Orders',style: TextStyle(color: AppConstant.appTextColor,fontFamily: 'serif'),),
      ),
      body:StreamBuilder(
          stream :FirebaseFirestore.instance
              .collection('orders')
              .doc(user!.uid)
              .collection('confirmOrders')
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            //agr koi error hai hmare snapshot me to yh condition chale
            if(snapshot.hasError){
              return Center(
                child: Text('Error'),
              );
            }
            //agr waiting me h to kya return kro
            if(snapshot.connectionState==ConnectionState.waiting){
              return Container(
                height: Get.height/5.5,
                child: Center(
                  child: CupertinoActivityIndicator(),
                ),
              );
            }
            // yani ki jo hum document ko fetch karna chah rhe h kya vh empty to nhi hai agr empty hai to yha par hum simple return karvayenge
            if(snapshot.data!.docs.isEmpty){
              return Center(
                child: Text('No product found!!'),
              );
            }
            //
            if(snapshot.data!=null){
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context,index){
                    //yha par ek var par product ke data kka snapshot nikal lenge jisse hum id ke through data ko product model me gate kar sakte hai
                    final productsData=snapshot.data!.docs[index];
                    OrderModel orderModel=OrderModel(
                      productId: productsData['productId'],
                      categoryId: productsData['categoryId'],
                      productName: productsData['productName'],
                      categoryName: productsData['categoryName'],
                      salePrice: productsData['salePrice'],
                      fullPrice: productsData['fullPrice'],
                      productImages:productsData['productImages'],
                      deliveryTime: productsData['deliveryTime'],
                      isSale: productsData['isSale'],
                      productDescription: productsData['productDescription'],
                      createdAt: productsData['createdAt'],
                      updatedAt:productsData['updatedAt'],
                      productQuantity:productsData['productQuantity'],
                      productTotalPrice:productsData['productTotalPrice'],
                      customerId: productsData['customerId'],
                      status: productsData['status'],
                      customerName: productsData['customerName'],
                      customerPhone: productsData['customerPhone'],
                      customerlandmark: productsData['customerlandmark'],
                      customerAddress: productsData['customerAddress'],
                      customerDeviceToken: productsData['customerDeviceToken'],
                    );
                    //calculate cart price
                    priceController.fetchProductPrice();
                    return Card(
                          elevation: 14.0,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(orderModel.productImages[0]),
                            ),
                            title: Text(orderModel.productName),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(orderModel.productTotalPrice.toString()),
                                SizedBox(width: 100,),
                                orderModel.status!=true?Text('Pending..',style: TextStyle(color: Colors.redAccent),):Text('Deleverd..',style: TextStyle(color: Colors.lightGreenAccent),)
                              ],
                            ),
                          ),
                        );
                  }
              );

            }

            return Container();
          }
      ),

    );
  }
}

