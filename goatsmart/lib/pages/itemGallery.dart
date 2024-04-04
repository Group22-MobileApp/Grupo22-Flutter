// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:goatsmart/pages/home.dart';

class ItemGallery extends StatefulWidget {
  static const String routeName = 'ItemGallery';
  const ItemGallery({Key? key}) : super(key: key);

  @override
  _ItemGallery createState() => _ItemGallery();
}

class _ItemGallery extends State<ItemGallery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        //App bar size
        toolbarHeight: 120.0,
        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: CircleAvatar(
            // Face Circle
            radius: 100.0,
            backgroundImage: Image.asset('assets/images/prof.jpg').image,
          ),
        ),     
        title: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  fillColor: Color.fromARGB(255, 211, 210, 210),
                  filled: true,
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),                    
                  ),
                ),
              ),
            ),      
          ],            
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Padding( 
            padding: const EdgeInsets.all(8.0), 
            child: Text(
              'Hello, Adriana!',
              style: TextStyle(fontSize: 54, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [ 
              Padding( 
                //Padding left
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Just For You',
                  style: TextStyle(fontSize: 44),                                    
                ),
              ),
              Padding( 
                padding: const EdgeInsets.all(8.0), 
                child: TextButton(
                  onPressed: () => Navigator.popAndPushNamed(context, HomePage.routeName),
                  style: TextButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 0, 0, 0),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 38,
                          // fontFamily: 'R',
                          //Bold
                          fontWeight: FontWeight.bold,
                        ),
                      ),                  
                      const Padding(
                        padding: EdgeInsets.only(left: 30),
                      ),
                      FloatingActionButton(onPressed: null, 
                      backgroundColor: Color.fromARGB(230, 255, 168, 6), 
                      foregroundColor: Colors.white,
                      shape: CircleBorder(),
                        child: Icon(Icons.arrow_forward_outlined),
                      ),
                    ],
                  ),
                ),  
              ),
            ],
          ),
          Expanded(
            child: const Grid(),            
          ),
          Padding( 
            padding: const EdgeInsets.all(8.0), 
            child: Text(
              'New Items',
              style: TextStyle(fontSize: 44),                                    
            ),
          ),
          Expanded(
            child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Image.asset('assets/images/11.jpg'), 
              Image.asset('assets/images/12.jpg'),
              Image.asset('assets/images/13.jpg'),
              Image.asset('assets/images/14.jpg'),           
              ],
            )            
          ),
        ],
      ),
    );
  }
}

class Grid extends StatelessWidget {
  const Grid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(10),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFFE0F7FA),
          child: Image.asset('assets/images/1.jpg', fit: BoxFit.fill),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFFE0F7FA),
          child: Image.asset('assets/images/2.jpg', fit: BoxFit.fill),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFFE0F7FA),
          child: Image.asset('assets/images/3.jpg', fit: BoxFit.fill),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFFE0F7FA),
          child: Image.asset('assets/images/4.jpg', fit: BoxFit.fill),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFFE0F7FA),
          child: Image.asset('assets/images/5.jpg', fit: BoxFit.fill),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFFE0F7FA),
          child: Image.asset('assets/images/6.jpg', fit: BoxFit.fill),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFFE0F7FA),
          child: Image.asset('assets/images/7.jpg', fit: BoxFit.fill),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFFE0F7FA),
          child: Image.asset('assets/images/8.jpg', fit: BoxFit.fill),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFFE0F7FA),
          child: Image.asset('assets/images/9.jpg', fit: BoxFit.fill),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFFE0F7FA),
          child: Image.asset('assets/images/10.jpg', fit: BoxFit.fill),
        ),
      ],
    );
  }
}    