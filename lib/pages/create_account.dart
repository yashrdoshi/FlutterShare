import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username;

  submit(){
    if(username != null){
      final form = _formKey.currentState;

      if(form.validate()){
            form.save();
            SnackBar snackbar = SnackBar(content: Text("Welcome $username..!!"),);
            _scaffoldKey.currentState.showSnackBar(snackbar);

            Timer(Duration(seconds: 2),(){
              Navigator.pop(context,username);  
            });

      }
    }
  }


  @override
  Scaffold build(BuildContext parentContext) {
    // return Scaffold(appBar: AppBar(backgroundColor: Colors.red,),);
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context,titleText: "Set up your Profile"),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:25.0),
                  child: Center(
                    child: Text(
                      "Create a User Account",
                      style: TextStyle(
                        fontFamily: "Signatra",
                        color: Colors.black,
                        fontSize: 25.0
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                        child: Form(
                          autovalidate: true,
                      key: _formKey,
                      child: TextFormField(
                        validator: (val) {
                          if(val.trim().length < 3 || val.isEmpty)
                            return "Username too short";
                          else if(val.trim().length > 12)
                            return "Username too Long";
                          return null;
                        },
                        onChanged: (val){
                          setState(() {
                            username = val;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          labelText: "Username",
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: "Must be atleast 3 characters",
                        ),
                      )
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      submit();                      
                    });
                  },
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
