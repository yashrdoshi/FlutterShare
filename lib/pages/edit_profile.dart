import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
// import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/widgets/progress.dart';

class EditProfile extends StatefulWidget {

  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _bioValid = true;
  bool _displayNameValid = true;


  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser()async{
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });

  }

  Column buildDisplayNameField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:EdgeInsets.only(top:12.0) ,
          child: Text("Display Name",
          style: TextStyle(color: Colors.black,
            fontWeight: FontWeight.bold,
           ),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Display Name",
            errorText: _displayNameValid ? null : "Display Name too Short",
          ),
        ),
      ],
    );
  }

  Column buildBioField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:EdgeInsets.only(top:12.0) ,
          child: Text("Bio",
          style: TextStyle(color: Colors.black,
           fontWeight: FontWeight.bold,
           ),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Bio",
            errorText: _bioValid? null: "Bio too Long",
          ),
        ),
      ],
    );
  }

  updateProfileData(){
    setState(() {
      displayNameController.text.trim().length < 3 || displayNameController.text.isEmpty ? _displayNameValid = false : _displayNameValid = true;

      bioController.text.trim().length > 100 ? _bioValid = false : _bioValid = true;
    });
    
    if(_bioValid && _displayNameValid){
        usersRef.document(widget.currentUserId).updateData({
          "displayName" : displayNameController.text,
          "bio": bioController.text,
        });

      SnackBar snackbar = SnackBar(content: Text("Profile Updated!"),);
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }

  }

  logout()async{
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Future.delayed(Duration.zero, () {Navigator.pop(context);}),
            icon: Icon(
              Icons.done,
              size: 30.0,
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
      body: isLoading? circularProgress(): ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding:EdgeInsets.only(top:16.0,bottom:8.0),
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: user.photoUrl == null? null: CachedNetworkImageProvider(user.photoUrl),
                  ), 
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      buildDisplayNameField(),
                      buildBioField(),
                    ],
                  ),
                ),
                RaisedButton(
                  color: Colors.black,
                  onPressed: updateProfileData,
                  child: Text(
                    "Update Profile",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: FlatButton.icon(
                    color: Colors.black,
                    onPressed: logout, 
                    icon: Icon(Icons.cancel, color: Colors.red,), 
                    label: Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
