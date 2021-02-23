import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';

import 'package:google_sign_in/google_sign_in.dart';
// import '../../../../Desktop/flutter/.pub-cache/hosted/pub.dartlang.org/google_sign_in-4.3.0/lib/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final DateTime timestamp = DateTime.now();
final commentsRef = Firestore.instance.collection('comments');
final activityFeedRef = Firestore.instance.collection('feed');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final timelineRef = Firestore.instance.collection('timeline');
User currentUser;



class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isAuth = false;
  PageController pageController; 
  int pageIndex = 0;

  @override
  void initState() { 
    super.initState();
    pageController = PageController();
    //Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account){
      handeSignIn(account);
    },onError: (err){
      print('Error signing in: $err');
    });
    //Reauthenticate user when app is reopened
    googleSignIn.signInSilently(suppressErrors: false)
            .then((account){
              handeSignIn(account);
    }).catchError((err){
      print('Error signing in: $err');
    });
  }

  handeSignIn(GoogleSignInAccount account){
    if(account != null){
        createUserInFirestore();
        setState(() {
          isAuth = true;
        });
      }else{
        setState(() {
          isAuth = false;
        });
      }
  }

  createUserInFirestore()async{
    //1. Check if the user exists in users collection acc to their userid
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();
    print(" Printing User at Line 70 $user");
    print("Printing doc.exists and !doc.exists");
    print( doc.exists);
    print(!doc.exists);
    //2.if the user doesnt exists, then we want to take them to the create acc page
    if(!doc.exists){
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount()));
    
    //3.get the username from create account use it to make new user documents in users collection
      usersRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photourl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp,
      });

      doc = await usersRef.document(user.id).get();
     
      } //end if
      print("----------------------------------------------------");
      String photo = user.photoUrl;
      print("$photo");


      currentUser = User.fromDocument(doc);   // Don't delete
      
      
      print(currentUser);
      print(currentUser.username);
      print("*************");
      print(currentUser.photoUrl);


  }

  @override
  void dispose() { 
    pageController.dispose();
    super.dispose();
  }

  login(){
    googleSignIn.signIn();
  }

  logout(){
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex){
      setState(() {
        this.pageIndex = pageIndex;
      });
  }

  onTap(int pageIndex){
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
 

  Scaffold buildAuthScreen(){
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera,size: 40.0,)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  Scaffold buildUnAuthScreen(){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ]
          )
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("FlutterShare",
            style : TextStyle(
                fontFamily: "Signatra",
                fontSize: 90.0,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () => login(),
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),

              ),
            ),
          ],
        ),
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
