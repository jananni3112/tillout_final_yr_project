
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:email_validator/email_validator.dart';
import "package:firebase_auth/firebase_auth.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Future<void> main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie tracker',
      home: process(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class process extends StatefulWidget {

  const process({Key? key}) : super(key: key);

  @override
  State<process> createState() => _processState();
}

class _processState extends State<process> {
  bool state = true;
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      print(user);
      if (user == null) {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => SignScreen1()));
      } else {
        var var1 = user.uid;
        DatabaseReference ref1 = FirebaseDatabase.instance.ref(
            "USERID/$var1/perinfo/name");
        DatabaseEvent event1 = await ref1.once();
        Object? var2 = " ";
        setState(() {
          var2 = event1.snapshot.value;
        });
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => Home(username: var2,UID: var1,)));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
              image : DecorationImage(
                image: AssetImage("assets/images/sign.png"),
                fit: BoxFit.fill,
              )
          ),
          child: SpinKitFadingCircle(
            color: Colors.purple,
            size: 100.0,
          )
      ),
    );
  }
}

class SignScreen1 extends StatefulWidget {
  const SignScreen1({Key? key}) : super(key: key);

  @override
  State<SignScreen1> createState() => _SignScreen1State();
}

class _SignScreen1State extends State<SignScreen1> {
  TextEditingController _passtext = TextEditingController();
  bool error = true;
  bool _vis = true;
  String out = " ";
  bool state =false;
  TextEditingController _emailtext = TextEditingController();
  Future<void> signin(String email,String password) async{
    setState(() {
      state = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim()).then((UserCredential user) async {
        if( user != null) {
          var var1 = user.user?.uid;
          DatabaseReference ref1 = FirebaseDatabase.instance.ref(
              "USERID/$var1/perinfo/name");
          DatabaseEvent event1 = await ref1.once();
          Object? var2 = " ";
          setState(() {
            error = true;
            var2 = event1.snapshot.value;
            state = false;
            _emailtext.text = "";
            _passtext.text = "";
          });
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => Home(username: var2,UID: var1,)));
        }
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = false;
        setState(() {
          state=false;
        });
      });
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body : !state?Container(
            decoration: BoxDecoration(
                image : DecorationImage(
                  image: AssetImage("assets/images/sign.png"),
                  fit: BoxFit.fill,
                )
            ),
            child: Column(
              children: [
                Padding(padding: EdgeInsets.all(130.0)),
                Container(
                  width: MediaQuery.of(context).size.width * 1,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: Container(
                    child: Text("Sign In",
                      style: TextStyle(fontSize: 30,fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(20.0)),
                Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: TextField(
                      controller:_emailtext,
                      decoration: InputDecoration(
                          hintText: "Email Adderess",
                          hintStyle: TextStyle(fontSize: 23,color: Colors.black)
                      ),
                    )
                ),
                Padding(padding: EdgeInsets.all(20.0)),
                Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: TextField(
                      controller:_passtext,
                      obscureText: _vis,
                      maxLength: 10,
                      decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(fontSize: 23,color: Colors.black),
                          suffixIcon: IconButton(
                            icon: Icon(
                                _vis ? Icons.visibility_off : Icons.visibility
                            ),
                            onPressed: (){
                              setState(() {
                                _vis = !_vis;
                              });
                            },
                          )
                      ),
                    )
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: Row(
                      children: [
                        FlatButton(onPressed: (){
                          setState(() {
                            error=true;
                          });
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => forpass()));
                        }, child: Text("Forgot password",
                          style: TextStyle(color: Colors.blue),
                          textAlign: TextAlign.left,
                        ),),
                        Padding(padding: EdgeInsets.all(10.0)),
                        FlatButton(onPressed: () {
                          setState(() {
                            error=true;
                          });
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => Signup()));},
                            child: Text("Create Account",
                              style: TextStyle(color: Colors.blue),
                              textAlign: TextAlign.right,
                            ))
                      ],
                    )
                ),
                Padding(padding: EdgeInsets.all(20.0)),
                Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: BoxDecoration(
                        image : DecorationImage(
                          image: AssetImage("assets/images/sbox.JPG"),
                          fit: BoxFit.fill,
                        )
                    ),
                    child: FlatButton(
                      onPressed: () {
                        signin(_emailtext.text,
                            _passtext.text);
                      },
                      child: Text("Sign In",
                        style: TextStyle(fontSize: 22),),

                    )
                ),
                Container(
                  child: error?Text(""):Text("incorrect credentials",style: TextStyle(fontSize: 20,color: Colors.red)),
                )
              ],
            ),
          ): Container(
            decoration: BoxDecoration(
                image : DecorationImage(
                  image: AssetImage("assets/images/sign.png"),
                  fit: BoxFit.fill,
                )
            ),
            child: SpinKitFadingCircle(
              color: Colors.purple,
              size: 100.0,
            )
          ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  final username;
  final UID;
  const Home({Key? key, this.username, this.UID}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const platform = MethodChannel('samples.flutter.dev/battery');
  late List<Object?> _batteryLevel;
  String path1 =" ";
  List<Object?> _quantity = [""];
  List<Object?> _calorie = [""];
  List<double?> _count = [0];
  File? imagetemp;
  bool state = false;
  Future<void> _openGallery() async{
    final XFile? imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(imageFile == null) return;
    setState((){imagetemp = File(imageFile.path);
    path1 = imageFile.path;
    });
    _getBatteryLevel();
  }
  Future<void> _openCamera() async{
    final XFile? imageFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if(imageFile == null) return;
    setState((){imagetemp = File(imageFile.path);
    path1 = imageFile.path;
    state=true;
    });
    _getBatteryLevel();
  }
  Future<void> _getBatteryLevel() async {
    setState(() {
      state = true;
    });
    late List<Object?> batteryLevel;
    try {
      final List<Object?> result = await platform.invokeMethod('getBatteryLevel',path1);
      batteryLevel = result;
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'." as List<String>;
    }
    setState(() {
      _batteryLevel = batteryLevel;
    });
    if(_batteryLevel.isEmpty){
      setState(() {
        state = false;
      });
      showAlertDialog(context,"invalid image", "Warning");
    }
    else{
      output1();
    }

  }
  Future<void> output1() async{
    Object? var1 ="";
    for(var i = 0;i<_batteryLevel.length;i++) {
      setState(() {
        var1 = _batteryLevel[i];
      });
      try {
        DatabaseReference ref1 = FirebaseDatabase.instance.ref(
            "food/$var1/Quantity");
        DatabaseEvent event1 = await ref1.once();
        DatabaseReference ref2 = FirebaseDatabase.instance.ref(
            "food/$var1/Calories");
        DatabaseEvent event2 = await ref2.once();
        setState(() {
          _quantity.insert(i,event1.snapshot.value);
          _calorie.insert(i,event2.snapshot.value);
          _count.insert(i,1);
        });
      } catch (e) {
        print(e);
      }
    }
    print("ww${widget.UID}");
    setState(() {
      state=false;
    });
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => output(image: imagetemp,
          detect: _batteryLevel,
          quantity: _quantity,
          calorie: _calorie,
          count: _count,user: widget.UID,)));
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body :!state? Container(
              width: MediaQuery.of(context).size.width * 1,
              decoration: BoxDecoration(
                  image : DecorationImage(
                    image: AssetImage("assets/images/sign.png"),
                    fit: BoxFit.fill,
                  )
              ),
              child: Column(
                  children: [
                    Padding(padding: EdgeInsets.all(130.0)),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      height: MediaQuery.of(context).size.height * 0.07,

                      child: Container(
                        child: Text("Welcome ${widget.username}!",
                          style: TextStyle(fontSize: 30,fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.27,
                      height: MediaQuery.of(context).size.height * 0.13,
                      // color: Colors.blue,
                      decoration: BoxDecoration(
                          image : DecorationImage(
                            image: AssetImage("assets/images/bbox.JPG"),
                            fit: BoxFit.fill,
                          )
                      ),
                      child: IconButton(
                        icon: Icon(Icons.camera_alt_outlined),
                        iconSize: 40,
                        color: Colors.black,
                        onPressed: (){
                          _openCamera();
                        },
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(20.0)),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.27,
                      height: MediaQuery.of(context).size.height * 0.13,
                      decoration: BoxDecoration(
                          image : DecorationImage(
                            image: AssetImage("assets/images/bbox.JPG"),
                            fit: BoxFit.fill,
                          )
                      ),
                      child: IconButton(
                        icon: Icon(Icons.upload_outlined),
                        iconSize: 40,
                        color: Colors.black,
                        onPressed: (){
                          _openGallery();
                        },
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(20.0)),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.27,
                      height: MediaQuery.of(context).size.height * 0.13,
                      decoration: BoxDecoration(
                          image : DecorationImage(
                            image: AssetImage("assets/images/bbox.JPG"),
                            fit: BoxFit.fill,
                          )
                      ),
                      child: IconButton(
                        icon: Icon(Icons.fitness_center),
                        iconSize: 40,
                        color: Colors.black,
                        onPressed: () async {
                          setState(() {
                            state = true;
                          });
                          int n=0;
                          DateTime _date = DateTime.now();
                          DatabaseReference ref = FirebaseDatabase.instance.ref("USERID/${widget.UID}/perbmi/CWeight");
                          DatabaseEvent event = await ref.once();
                          var cweight = event.snapshot.value;
                          ref = FirebaseDatabase.instance.ref("USERID/${widget.UID}/perbmi/GWeight");
                          event = await ref.once();
                          var gweight = event.snapshot.value;
                          ref = FirebaseDatabase.instance.ref("USERID/${widget.UID}/perbmi/n");
                          event = await ref.once();
                          var  Scale= event.snapshot.value;
                          ref = FirebaseDatabase.instance.ref("USERID/${widget.UID}/peract/calorie");
                          event = await ref.once();
                          var  dcal= event.snapshot.value;
                          ref = FirebaseDatabase.instance.ref("USERID/${widget.UID}/peract/n");
                          event = await ref.once();
                          var  act= event.snapshot.value;
                          ref = FirebaseDatabase.instance.ref("USERID/${widget.UID}/daycalorie/${_date.day}-${_date.month}-${_date.year}/total/total");
                          event = await ref.once();
                          var  fcal= event.snapshot.value;
                          ref = FirebaseDatabase.instance.ref("USERID/${widget.UID}/perbmi/type");
                          event = await ref.once();
                          var  g= event.snapshot.value;
                          setState(() {
                            state=false;
                          });
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => goal(cweight: cweight,gweight: gweight,act: act,dcal: dcal,fcal: fcal,scale: Scale,g: g,)));
                        },
                      ),
                    ),
                  ]
              )
          ):Container(
              decoration: BoxDecoration(
                  image : DecorationImage(
                    image: AssetImage("assets/images/sign.png"),
                    fit: BoxFit.fill,
                  )
              ),
              child: SpinKitFadingCircle(
                color: Colors.purple,
                size: 100.0,
              )
          ),
      ),
    );
  }
}

class goal extends StatelessWidget {
  final cweight;//
  final gweight;//
  final dcal;//
  final fcal;//
  final g;
  final act;//
  final scale;//
  const goal({Key? key,this.cweight, this.gweight, this.dcal, this.fcal, this.g, this.act, this.scale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void logout() async {
      await FirebaseAuth.instance.signOut();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => SignScreen1()));
    }
    int n =1;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body : Container(
          width: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
              image : DecorationImage(
                image: AssetImage("assets/images/history.png"),
                fit: BoxFit.fill,
              )
          ),
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(40.0)),
              ListView(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                children: [
                  Card(
                      child:  ListView(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.08,
                            color: Colors.blue,
                            child: Row(
                              children: [
                                Padding(padding: EdgeInsets.all(10.0)),
                                Icon(Icons.monitor_weight,
                                  color:Colors.pink,
                                  size: 28.0,
                                ),
                                Padding(padding: EdgeInsets.all(10.0)),
                                Text("Nutrion Goal",
                                  style: TextStyle(fontSize: 20,),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Card(
                              child: Row(
                                children: [
                                  Padding(padding: EdgeInsets.all(5.0)),
                                  Text("Current Weight",
                                    style: TextStyle(fontSize: 15,),
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(padding: EdgeInsets.all(20.0)),
                                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 90, 0)),
                                  (scale ==1)?Text("$cweight kg",
                                    style: TextStyle(fontSize: 15,),
                                    textAlign: TextAlign.center,
                                  ):Text("$cweight lb",
                                    style: TextStyle(fontSize: 15,),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                          ),
                          Card(
                              child: Row(
                                children: [
                                  Padding(padding: EdgeInsets.all(5.0)),
                                  Text("Goal Weight",
                                    style: TextStyle(fontSize: 15,),
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(padding: EdgeInsets.all(20.0)),
                                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 110, 0)),
                                  (scale ==1)?Text("$gweight kg",
                                    style: TextStyle(fontSize: 15,),
                                    textAlign: TextAlign.center,
                                  ):Text("$gweight lb",
                                    style: TextStyle(fontSize: 15,),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                          ),
                          Card(
                              child: Row(
                                children: [
                                  Padding(padding: EdgeInsets.all(5.0)),
                                  Text("Weight Goal",
                                    style: TextStyle(fontSize: 15,),
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(padding: EdgeInsets.all(20.0)),
                                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 5, 0)),
                                  (scale==1)?(g == 1)?Text("Lose 1.00 Kg per week",
                                    style: TextStyle(fontSize: 15,),
                                    textAlign: TextAlign.center,
                                  ):(g == 2)?Text("Maintain weight",
                                    style: TextStyle(fontSize: 15,),
                                    textAlign: TextAlign.center,
                                  ):Text("Gain 1.00 Kg per week",
                                    style: TextStyle(fontSize: 15,),
                                    textAlign: TextAlign.center,
                                  ):(g == 1)?Text("Lose 1.00 lb per week",
                                    style: TextStyle(fontSize: 15,),
                                    textAlign: TextAlign.center,
                                  ):(g == 2)?Text("Maintain weight",
                                    style: TextStyle(fontSize: 15,),
                                    textAlign: TextAlign.center,
                                  ):Text("Gain 1.00 lb per week",
                                    style: TextStyle(fontSize: 15,),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                          ),
                          Card(
                              child: Row(
                                children: [
                                  Padding(padding: EdgeInsets.all(5.0)),
                                  Text("Activity Level",
                                    style: TextStyle(fontSize: 15,),
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(padding: EdgeInsets.all(20.0)),
                                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 25, 0)),
                                  (act == 1)?Text(" Moderately Active",
                                    style: TextStyle(fontSize: 15,),
                                    textAlign: TextAlign.center,
                                  ):Text("Active",
                                    style: TextStyle(fontSize: 15,),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                          ),
                        ],
                        padding: EdgeInsets.all(10),
                      )
                  ),
                  Card(
                    child: ListView(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.08,
                          color: Colors.blue,
                          child: Row(
                            children: [
                              Padding(padding: EdgeInsets.all(10.0)),
                              Icon(Icons.local_dining,
                              color:Colors.pink,
                                size: 28.0,
                              ),
                              Padding(padding: EdgeInsets.all(10.0)),
                              Text("Nutrion Goal",
                                style: TextStyle(fontSize: 20,),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Card(
                            child: Row(
                              children: [
                                Padding(padding: EdgeInsets.all(5.0)),
                                Text("Daily Calorie Budget",
                                  style: TextStyle(fontSize: 15,),
                                  textAlign: TextAlign.center,
                                ),
                                Padding(padding: EdgeInsets.all(20.0)),
                                Padding(padding: EdgeInsets.fromLTRB(0, 0, 40, 0)),
                                Text("$dcal cal",
                                  style: TextStyle(fontSize: 15,),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                        ),
                        Card(
                            child: Row(
                              children: [
                                Padding(padding: EdgeInsets.all(5.0)),
                                Text("Consumed Calorie today",
                                  style: TextStyle(fontSize: 15,),
                                  textAlign: TextAlign.center,
                                ),
                                Padding(padding: EdgeInsets.all(20.0)),
                                Padding(padding: EdgeInsets.fromLTRB(0, 0, 20, 0)),
                                Text("$fcal cal",
                                  style: TextStyle(fontSize: 15,),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                        ),
                      ],
                      padding: EdgeInsets.all(10),
                    )
                  ),
                  Card(
                      child: ListView(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        children: [
                          FlatButton(onPressed: (){logout();},
                            color: Colors.blue,
                            child: Container(
                            height: MediaQuery.of(context).size.height * 0.08,
                            color: Colors.blue,
                            child: Row(
                              children: [
                                //Padding(padding: EdgeInsets.all(10.0)),
                                Icon(Icons.logout,
                                  color:Colors.pink,
                                  size: 28.0,
                                ),
                                Padding(padding: EdgeInsets.all(10.0)),
                                Text("Log out",
                                  style: TextStyle(fontSize: 20,),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),),
                        ],
                        padding: EdgeInsets.all(10),
                      )
                  ),
                ],
                padding: EdgeInsets.all(10),
              ),
            ],
          )
        )
    );
  }
}


class output extends StatefulWidget {
  final image;
  final detect;
  final quantity;
  final calorie;
  final count;
  final user;
  const output({Key? key, this.image, this.detect, this.quantity, this.calorie, this.count, this.user}) : super(key: key);

  @override
  State<output> createState() => _outputState();
}

class _outputState extends State<output> {
  double sum=0;
  DateTime _date = DateTime.now();
  Object? _dropDownValue=" ";
  bool state = false;
  Future<void> ins(String? user) async{
    setState(() {
      state=true;
    });
    var var2 ="${_date.day}-${_date.month}-${_date.year}";
    DatabaseReference ref = FirebaseDatabase.instance.ref("USERID/$user/daycalorie/$var2");
    DatabaseEvent event = await ref.once();
    var var1 = event.snapshot.value;
    if(_dropDownValue !=" ") {
      if (var1 == null) {
        DatabaseReference ref = FirebaseDatabase.instance.ref(
            "USERID/$user/daycalorie");
        await ref.set({
          "$var2": {
            "total": {
              "total": sum,
            },
            "$_dropDownValue": {
              _dropDownValue: sum,
            }
          }
        });
        setState(() {
          state = false;
        });
        showAlertDialog(
            context, "The total calorie $sum", "for $_dropDownValue");
      }
      else {
        DatabaseReference ref = FirebaseDatabase.instance.ref(
            "USERID/$user/daycalorie/$var2/$_dropDownValue");
        DatabaseEvent event = await ref.once();
        var var1 = event.snapshot.value;
        if (var1 == null) {
          DatabaseReference ref1 = FirebaseDatabase.instance.ref(
              "USERID/$user/daycalorie/$var2/total/total");
          DatabaseEvent event1 = await ref1.once();
          var var1 = event1.snapshot.value.toString();
          var total = double.parse(var1);
          DatabaseReference ref2 = FirebaseDatabase.instance.ref(
              "USERID/$user/peract/calorie");
          DatabaseEvent event2 = await ref2.once();
          var var3 = event2.snapshot.value.toString();
          double ncal = double.parse(var3);
          if (ncal <= (total + sum)) {
            setState(() {
              state = false;
            });
            showAlertDialog(
                context, "It's going out of your calorie", "Warning");
          }
          else {
            DatabaseReference ref1 = FirebaseDatabase.instance.ref(
                "USERID/$user/daycalorie");
            await ref1.update({
              "$var2/$_dropDownValue": {
                _dropDownValue: sum,
              }
            });
            await ref1.update({
              "$var2/total": {
                "total": total + sum,
              }
            });
            setState(() {
              state = false;
            });
            showAlertDialog(
                context, "The total calorie $sum", "for $_dropDownValue");
          }
        }
        else {
          setState(() {
            state = false;
          });
          showAlertDialog(
              context, "You already updated $_dropDownValue", "Warning");
        }
      }
    }
    else{
      setState(() {
        state =false;
      });
      showAlertDialog(
          context, "The total calorie $sum", "for Given food");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body : Container(
          width: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
              image : DecorationImage(
                image: AssetImage("assets/images/history.png"),
                fit: BoxFit.fill,
              )
          ),
          child: Column(children: [
            Padding(padding: EdgeInsets.all(40.0)),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.3,
              color: Colors.pink,
                child: widget.image != null
                    ? Image.file(
                  widget.image,
                  width: 200.0,
                  height: 200.0,
                  fit: BoxFit.cover,
                ):Text(" ")
            ),
            Padding(padding: EdgeInsets.all(5.0)),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.07,
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.055,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Total cal', style: TextStyle(fontSize: 20.0),),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() {
                          sum=0;
                          for(var i=0;i< widget.detect.length;i++)
                            sum = sum +(widget.count[i]*widget.calorie[i]);
                        });
                        ins(widget.user);
                      },
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(25.0)),
                  Container(
                     width: MediaQuery.of(context).size.width * 0.36,
                      height: MediaQuery.of(context).size.height * 0.055,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child:DropdownButton(
                        hint: _dropDownValue == null ? Text('Dropdown')
                            : Text("  $_dropDownValue", style: TextStyle(color: Colors.black,fontSize: 20.0),),
                        isExpanded: true, iconSize: 30.0, style: TextStyle(color: Colors.black,fontSize: 20.0),
                        items: ['Breakfast', 'brunch', 'elevenses','lunch','tea','supper','dinner'].map(
                              (val) {return DropdownMenuItem<String>(value: val, child: Text(val),);},
                        ).toList(), onChanged: (val) {setState(() {_dropDownValue = val;},
                          );
                        },
                      )
                  )
                ],
              ),
            ),
            state?Text("loading.."):Text(""),
            Padding(padding: EdgeInsets.all(5.0)),
      Expanded(
        child: ListView.builder(
              itemBuilder: (BuildContext, index){
                return Card(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 1,
                      child: Row(
                            children: [
                              Padding(padding: EdgeInsets.all(5.0)),
                              Column(
                                children: [
                                  Padding(padding: EdgeInsets.all(15.0)),
                                  Container(
                                  width: MediaQuery.of(context).size.width * 0.3,
                                      child: Text("${widget.detect[index]}",style: TextStyle(color: Colors.black, fontSize: 20,
                                        fontWeight: FontWeight.w500,),),),
                                ],
                              ),
                              Column(
                                children: [
                                  Padding(padding: EdgeInsets.all(5.0)),
                                  Text("Quantity", style: TextStyle(color: Colors.black, fontSize: 16,
                                  ),),
                                  Row(
                                    children: [
                                      IconButton(onPressed: (){setState(() {
                                        if(widget.count[index] > 0.5){
                                        widget.count[index] = widget.count[index]-0.5;
                                        }
                                      });}, icon: Icon(Icons.remove)),
                                      Text("${widget.count[index]}", style: TextStyle(color: Colors.black, fontSize: 16,
                                      ),),
                                      IconButton(onPressed: (){setState(() {
                                        widget.count[index] = widget.count[index]+0.5;
                                      });}, icon: Icon(Icons.add)),
                                    ],
                                  ),
                                  Text("${widget.quantity[index]}", style: TextStyle(color: Colors.black, fontSize: 10,
                                  ),),
                                ],
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width * 0.2,
                                  child: Column(
                                    children: [
                                      Padding(padding: EdgeInsets.all(5.0)),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.2,
                                        child: Text("Calories", style: TextStyle(color: Colors.black, fontSize: 16,
                                        ),textAlign: TextAlign.center,),
                                      ),
                                      Padding(padding: EdgeInsets.all(4.0)),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.2,
                                        child: Text("${widget.calorie[index]*widget.count[index]}", style: TextStyle(color: Colors.black, fontSize: 20,
                                        ),textAlign: TextAlign.center,),
                                      )
                                    ],
                                  )
                              ),
                        ],
                      ),
                    ),

                );
              },
              itemCount: widget.detect.length,
              shrinkWrap: true,
              padding: EdgeInsets.all(15),

              itemExtent: 100,
              scrollDirection: Axis.vertical,
            ),
            ),
          ],),
        )
    );
  }
}

showAlertDialog(BuildContext context,String sum,Object? meal) {
  // Create button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("$meal"),
    content: Text("$sum"),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  Object cond ="";
  TextEditingController _passtext = TextEditingController();
  bool error = true;
  bool _vis = true;
  TextEditingController _emailtext = TextEditingController();
  TextEditingController _nametext = TextEditingController();
  TextEditingController _phonetext = TextEditingController();
  bool state = false;
  Future<void> signup() async {
    try {
      final newUser = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailtext.text.trim(),
          password: _passtext.text.trim());
      if (newUser != null) {
        print(newUser);
        ins(newUser.user?.uid);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        state=false;
      });
      cond=e.message!;
    }
  }
  Future<void> ins(String? user) async{
    DatabaseReference ref = FirebaseDatabase.instance.ref("USERID");
    await ref.update({
        "$user/perinfo":{
          "name": _nametext.text.trim(),
          "phone": _phonetext.text.trim(),
        }
    });
    setState(() {
      _emailtext.text = "";
      _passtext.text = "";
      _phonetext.text = "";
      _nametext.text = "";
      state=false;
    });
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => Page1(user: user,)));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body : !state?Container(
          decoration: BoxDecoration(
              image : DecorationImage(
                image: AssetImage("assets/images/sign.png"),
                fit: BoxFit.fill,
              )
          ),
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(130.0)),
              Container(
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.05,
                child: Container(
                  child: Text("Sign Up",
                    style: TextStyle(fontSize: 30,fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(6.0)),
              Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: TextField(
                    controller:_nametext,
                    decoration: InputDecoration(
                        hintText: "Name",
                        hintStyle: TextStyle(fontSize: 20,color: Colors.black)
                    ),
                  )
              ),
              Padding(padding: EdgeInsets.all(6.0)),
              Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: TextField(
                    controller:_phonetext,
                    decoration: InputDecoration(
                      hintText: "Phone Number",
                      hintStyle: TextStyle(fontSize: 20,color: Colors.black),
                    ),
                  )
              ),
              Padding(padding: EdgeInsets.all(6.0)),
              Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: TextField(
                    controller:_emailtext,
                    decoration: InputDecoration(
                        hintText: "Email Adderess",
                        hintStyle: TextStyle(fontSize: 20,color: Colors.black)
                    ),
                  )
              ),
              Padding(padding: EdgeInsets.all(6.0)),
              Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: TextField(
                    controller:_passtext,
                    obscureText: _vis,
                    decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(fontSize: 20,color: Colors.black),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _vis ? Icons.visibility_off : Icons.visibility
                          ),
                          onPressed: (){
                            setState(() {
                              setState(() {
                                _vis = !_vis;
                              });
                            });
                          },
                        )
                    ),
                  )
              ),

              Padding(padding: EdgeInsets.all(20.0)),
              Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.07,
                  decoration: BoxDecoration(
                      image : DecorationImage(
                        image: AssetImage("assets/images/sbox.JPG"),
                        fit: BoxFit.fill,
                      )
                  ),
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        state=true;
                      });
                      const patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                      RegExp regExp = new RegExp(patttern);
                      (!EmailValidator.validate(_emailtext.text))?setState((){cond ="Enter a valid email" ;state=false;}):
                      (!regExp.hasMatch(_phonetext.text) && _phonetext.text.length != 10)?setState((){cond ="Enter a valid phone number";state=false;}):
                      (_nametext.text == "" || _passtext == "")?setState((){cond ="Enter all credentials";state=false;}):
                      signup();
                    },
                    child: Text("Sign Up",
                      style: TextStyle(fontSize: 22),),

                  )
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: Text("$cond",
                    style: TextStyle(color: Colors.red,fontSize: 20),textAlign: TextAlign.center,)
              )
            ],
          ),
        ):Container(
            decoration: BoxDecoration(
                image : DecorationImage(
                  image: AssetImage("assets/images/sign.png"),
                  fit: BoxFit.fill,
                )
            ),
            child: SpinKitFadingCircle(
              color: Colors.purple,
              size: 100.0,
            )
        ),
    );
  }
}

class Page1 extends StatefulWidget {
  final user;
  const Page1({Key? key, this.user}) : super(key: key);

  @override
  _Page1State createState() =>_Page1State();
}

class _Page1State extends State<Page1> {
  String error="";
  int _n = 4;
  double BMI =0;
  double _lbcweight = 100;
  double _lbgweight = 100;
  double _kgcweight = 50;
  double _kggweight = 50;
  double _cmheight=150;
  double _ftheight=4;
  int cat =0;
  bool state=false;
  Future<void> ins(String? user) async{
    setState(() {
      state=true;
    });
    DatabaseReference ref = FirebaseDatabase.instance.ref("USERID");
    if(_n == 1){
      await ref.update({
          "$user/perbmi":{
            "n": _n,
            "Height": _cmheight,
            "CWeight": _kgcweight,
            "GWeight": _kggweight,
            "BMI": BMI,
            "type": cat,
          }
      });
      setState(() {
        _n=4;
        error="";
        state=false;
      });
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => Page2(user: user,cat: cat,BMI: BMI,)));
    }
    else{
      if(_n == -1){
      await ref.update({
        "$user/perbmi":{
          "n": _n,
          "Height": _ftheight,
          "CWeight": _lbcweight,
          "GWeight": _lbgweight,
          "BMI": BMI,
          "type": cat,
        }
      });
      setState(() {
        _n=4;
        error="";
        state=false;
      });
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => Page2(user: user,cat: cat,BMI: BMI,)));
    }
    else{
      setState(() {
        state=false;
        error="Enter all Details";
      });
    }
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: !state?Container(
          decoration: BoxDecoration(
              image : DecorationImage(
                image: AssetImage("assets/images/history.png"),
                fit: BoxFit.fill,
              )
          ),
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(40.0)),
              Container(
                child: Row(
                  children: [
                    Padding(padding: EdgeInsets.all(30.0)),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: RaisedButton(
                        onPressed: (){setState(() {
                          _n=-1;
                        });},
                        color: Colors.blue,
                        child: (_n == -1)? Text("lb,ft", style: TextStyle(fontSize: 20, color: Color(0XFF1D1F33),)):
                        Text("lb,ft", style: TextStyle(fontSize: 20, color: Colors.white,)),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(30.0)),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: RaisedButton(
                        onPressed: (){setState(() {
                          _n=1;
                        });},
                        color: Colors.blue,
                        child: (_n == 1)? Text("kg,cm", style: TextStyle(fontSize: 20, color: Color(0XFF1D1F33),)):
                        Text("kg,cm", style: TextStyle(fontSize: 20, color: Colors.white,)),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(3.0)),
              Padding(padding: EdgeInsets.all(5.0)),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.18,
                  color: Colors.blue,
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.all(5.0)),
                    Text("HEIGHT",
                      style: TextStyle(
                        color: Color(0XFF1D1F33),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(2.0)),
                    (_n== 1)?RichText(text: TextSpan(
                        children: [
                          TextSpan(text: _cmheight.round().toString(),style: TextStyle(fontSize: 25, color: Colors.white,),),
                          TextSpan(text: " cm",style: TextStyle(fontSize: 20, color: Colors.white54,),)
                        ]
                    )):
                    RichText(text: TextSpan(
                        children: [
                          TextSpan(text: _ftheight.toString(),style: TextStyle(fontSize: 25, color: Colors.white,),),
                          TextSpan(text: " feet",style: TextStyle(fontSize: 20, color: Colors.white54,),)
                        ]
                    )),
                    (_n == 1)?SliderTheme(
                      data: SliderThemeData(
                        thumbColor: Colors.white54,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15.0),
                        activeTrackColor: Color(0XFF1D1F33),
                        inactiveTrackColor: Colors.white,),
                      child: Slider(
                          min: 100,
                          max: 200,
                          value: _cmheight,
                          onChanged: (height){
                            setState(() {
                              _cmheight = height.roundToDouble();
                            });
                          }),
                    ):
                    SliderTheme(
                      data: SliderThemeData(
                        thumbColor: Colors.white54,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15.0),
                        activeTrackColor: Color(0XFF1D1F33),
                        inactiveTrackColor: Colors.white,),
                      child: Slider(
                          min: 3,
                          max: 7,
                          value: _ftheight,
                          onChanged: (height){
                            setState(() {
                              int decimals = 2;
                              num fac = pow(10, decimals);
                              _ftheight = height;
                              _ftheight = (_ftheight * fac).round() / fac;
                            });
                          }),
                    )
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              Container(
                child: Row(
                  children: [
                    Padding(padding: EdgeInsets.all(17.5)),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.38,
                      height: MediaQuery.of(context).size.height * 0.23,
                      color: Colors.blue,
                      child: Column(
                        children: [
                          Padding(padding: EdgeInsets.all(3.0)),
                          Text("CURRENT",style: TextStyle(fontSize: 20,color: Color(0XFF1D1F33),decoration: TextDecoration.none,),
                            textAlign: TextAlign.center,),
                          Text("WEIGHT",style: TextStyle(fontSize: 20,color: Color(0XFF1D1F33),decoration: TextDecoration.none,),
                            textAlign: TextAlign.center,),
                          Padding(padding: EdgeInsets.all(3.0)),
                          (_n == 1)?Text(_kgcweight.round().toString(),style: TextStyle(fontSize: 25,color: Colors.white,decoration: TextDecoration.none,),
                            textAlign: TextAlign.center,):
                          Text(_lbcweight.toString(),style: TextStyle(fontSize: 25,color: Colors.white,decoration: TextDecoration.none,),
                            textAlign: TextAlign.center,),
                          Padding(padding: EdgeInsets.all(3.0)),
                          Row(
                            children: [
                              Padding(padding: EdgeInsets.all(3.7)),
                              FloatingActionButton(
                                heroTag: "btn1",
                                mini: true,
                                backgroundColor: Color(0XFF1D1F33),
                                onPressed: (){setState(() {
                                  if(_n==1){
                                    _kgcweight=_kgcweight-1;

                                  }
                                  if(_n==-1){
                                    int decimals = 2;
                                    num fac = pow(10, decimals);
                                    _lbcweight =_lbcweight - 2.2 ;
                                    _lbcweight = (_lbcweight * fac).round() / fac;

                                  }
                                });},
                                child: Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(12.0)),
                              FloatingActionButton(
                                heroTag: "btn2",
                                mini: true,
                                backgroundColor: Color(0XFF1D1F33),
                                onPressed: (){setState(() {
                                  if(_n==1){_kgcweight=_kgcweight+1;}
                                  else{
                                    int decimals = 2;
                                    num fac = pow(10, decimals);
                                    _lbcweight =_lbcweight + 2.2 ;
                                    _lbcweight = (_lbcweight * fac).round() / fac;
                                  }
                                });},
                                child: Icon(Icons.add, color: Colors.white, size: 20,),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(10.0)),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.38,
                      height: MediaQuery.of(context).size.height * 0.23,
                      color: Colors.blue,
                      child: Column(
                        children: [
                          Padding(padding: EdgeInsets.all(3.0)),
                          Text("GOAL   WEIGHT",style: TextStyle(fontSize: 20,color: Color(0XFF1D1F33),decoration: TextDecoration.none,),
                            textAlign: TextAlign.center,),
                          Padding(padding: EdgeInsets.all(3.0)),
                          (_n==1)?Text(_kggweight.round().toString(),style: TextStyle(fontSize: 25,color: Colors.white,decoration: TextDecoration.none,),
          textAlign: TextAlign.center,):
                          Text(_lbgweight.toString(),style: TextStyle(fontSize: 25,color: Colors.white,decoration: TextDecoration.none,),
                            textAlign: TextAlign.center,),
                          Padding(padding: EdgeInsets.all(3.0)),
                          Row(
                            children: [
                              Padding(padding: EdgeInsets.all(3.7)),
                              FloatingActionButton(
                                heroTag: "btn3",
                                mini: true,
                                backgroundColor: Color(0XFF1D1F33),
                                onPressed: (){setState(() {
                                  if(_n==1){_kggweight=_kggweight-1;}
                                  if(_n==-1){
                                    int decimals = 2;
                                    num fac = pow(10, decimals);
                                    _lbgweight =_lbgweight - 2.2 ;
                                    _lbgweight = (_lbgweight * fac).round() / fac;
                                  }
                                });},
                                child: Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(12.0)),
                              FloatingActionButton(
                                heroTag: "btn4",
                                mini: true,
                                backgroundColor: Color(0XFF1D1F33),
                                onPressed: (){setState(() {if(_n==1){_kggweight=_kggweight+1;}
                                else{
                                  int decimals = 2;
                                  num fac = pow(10, decimals);
                                  _lbgweight =_lbgweight + 2.2 ;
                                  _lbgweight = (_lbgweight * fac).round() / fac;
                                };});},
                                child: Icon(Icons.add, color: Colors.white, size: 20,),),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(15.0)),
              Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: Text("$error",
                    style: TextStyle(color: Colors.red,fontSize: 20),textAlign: TextAlign.center,)
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.07,
                  decoration: BoxDecoration(image : DecorationImage(
                        image: AssetImage("assets/images/sbox.JPG"), fit: BoxFit.fill,)),
                  child: FlatButton(
                    onPressed: () {setState(() {
                      int decimals = 2;
                      num fac = pow(10, decimals);
                      if(_n==1){
                        BMI = ((_kgcweight /(_cmheight*_cmheight))*(100*100));
                        BMI = (BMI * fac).round() / fac;
                        (_kgcweight > _kggweight)? cat=1:(_kgcweight==_kggweight)?cat=2:cat=3;
                        print(BMI);
                      }
                      if(_n==-1){
                        BMI = (_lbcweight /(_ftheight*_ftheight))*703;
                        BMI = (BMI * fac).round() / fac;
                        (_lbcweight > _lbgweight)? cat=1:(_lbcweight==_lbgweight)?cat=2:cat=3;
                        print(BMI);
                      }
                      ins(widget.user);
                    });},
                    child: Text("Next", style: TextStyle(fontSize: 22),),
                  )
              ),
            ],
          ),
        ):Container(
            decoration: BoxDecoration(
                image : DecorationImage(
                  image: AssetImage("assets/images/sign.png"),
                  fit: BoxFit.fill,
                )
            ),
            child: SpinKitFadingCircle(
              color: Colors.purple,
              size: 100.0,
            )
        ),
      ),
    );
  }
}

class Page2 extends StatefulWidget {
  final user;
  final cat;
  final BMI;
  const Page2({Key? key, this.user, this.cat, this.BMI}) : super(key: key);
  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  String error="";
  int _n = 4;
  int _gen = 50;
  double _age=20;
  int cal=0;
  bool state=false;
  Future<void> ins(String? user) async{
    setState(() {
      state=true;
    });
    DatabaseReference ref = FirebaseDatabase.instance.ref("USERID");
    if(_n != 4 && _gen != 50){
      if(_gen == 1){
        setState(() {
          (widget.cat==1)?((_n==-1)?cal = 1700 : cal = 1500):
          (widget.cat==2)?((_n==-1)?cal = 2200: cal = 2000):
          ((_n==-1)?cal = 2450: cal = 2250);
        });
        await ref.update({
          "$user/peract":{
            "n": _n,
            "gender": "Female",
            "age": _age,
            "calorie": cal,
          }
        });
      }
      else{
        setState(() {
          (widget.cat==1)?((_n==-1)?cal = 2300 : cal = 2100):
          (widget.cat==2)?((_n==-1)?cal = 2800: cal = 2600):
          ((_n==-1)?cal = 3050: cal = 2850);
        });
        await ref.update({
          "$user/perbmi":{
            "n": _n,
            "gender": "Male",
            "age": _age,
            "calorie": cal,
          }
        });
      }
      setState(() {
        state=false;
      });
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => approve(cal: cal,cat: widget.cat,BMI: widget.BMI,)));
    }
    else{
      setState(() {
        state=false;
        error="Enter all Details";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: !state?Container(
          decoration: BoxDecoration(
              image : DecorationImage(
                image: AssetImage("assets/images/history.png"),
                fit: BoxFit.fill,
              )
          ),
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(50.0)),
              Container(
                child: Row(
                  children: [
                    Padding(padding: EdgeInsets.all(17.5)),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: RaisedButton(onPressed: (){setState(() {_gen = -1;});},
                        color: Colors.blue,
                        child: Column(
                          children: [
                            Container(
                              child: (_gen == -1)?
                              Icon(Icons.male,color: Color(0XFF1D1F33), size: 100,):
                              Icon(Icons.male,color: Colors.white,size: 100,),
                            ),
                            //Padding(padding: EdgeInsets.all(17.5)),
                            Container(
                              child: (_gen == -1)?
                              Text("MALE",style: TextStyle(fontSize: 20,color: Color(0XFF1D1F33),)):
                              Text("MALE", style: TextStyle(fontSize: 20, color: Colors.white,)),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(18.0)),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: RaisedButton(onPressed: (){setState(() {_gen = 1;});},
                        color: Colors.blue,
                        child: Column(
                          children: [
                            Container(
                              child: (_gen == 1)?
                              Icon(Icons.female,color: Color(0XFF1D1F33), size: 100,):
                              Icon(Icons.female,color: Colors.white,size: 100,),
                            ),
                            //Padding(padding: EdgeInsets.all(17.5)),
                            Container(
                              child: (_gen == 1)?
                              Text("FEMALE",style: TextStyle(fontSize: 20,color: Color(0XFF1D1F33),)):
                              Text("FEMALE", style: TextStyle(fontSize: 20, color: Colors.white,)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(5.0)),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.18,
                color: Colors.blue,
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.all(5.0)),
                    Text("AGE", style: TextStyle(color: Color(0XFF1D1F33),fontSize: 20,fontWeight: FontWeight.w500,),),
                    Padding(padding: EdgeInsets.all(2.0)),
                   Text(_age.round().toString(),style: TextStyle(fontSize: 25, color: Colors.white,)),
                    SliderTheme(
                      data: SliderThemeData(
                        thumbColor: Colors.white54,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15.0),
                        activeTrackColor: Color(0XFF1D1F33),
                        inactiveTrackColor: Colors.white,),
                      child: Slider(min: 13, max: 100, value: _age,
                          onChanged: (age){setState(() {_age = age.roundToDouble();});
                          }),
                    )
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              Container(
                child: Row(
                  children: [
                    Padding(padding: EdgeInsets.all(22.0)),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: RaisedButton(
                        onPressed: (){setState(() {_n=-1;});},
                        color: Colors.blue,
                        child: (_n == -1)? Text("Active", style: TextStyle(fontSize: 20, color: Color(0XFF1D1F33),)):
                        Text("Active", style: TextStyle(fontSize: 20, color: Colors.white,)),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(10.0)),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: RaisedButton(
                        onPressed: (){setState(() {_n=1;});},
                        color: Colors.blue,
                        child: (_n == 1)? Text("Moderalty Active", style: TextStyle(fontSize: 20, color: Color(0XFF1D1F33),)):
                        Text("Moderalty Active", style: TextStyle(fontSize: 20, color: Colors.white,)),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(15.0)),
              Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: Text("$error",
                    style: TextStyle(color: Colors.red,fontSize: 20),textAlign: TextAlign.center,)
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.07,
                  decoration: BoxDecoration(image : DecorationImage(
                    image: AssetImage("assets/images/sbox.JPG"), fit: BoxFit.fill,)),
                  child: FlatButton(
                    onPressed: () {
                      ins(widget.user);
                      },
                    child: Text("Next", style: TextStyle(fontSize: 22),),
                  )
              ),
            ],
          ),
        ):Container(
            decoration: BoxDecoration(
                image : DecorationImage(
                  image: AssetImage("assets/images/sign.png"),
                  fit: BoxFit.fill,
                )
            ),
            child: SpinKitFadingCircle(
              color: Colors.purple,
              size: 100.0,
            )
        ),
      ),
    );
  }
}

class approve extends StatefulWidget {
  final BMI;
  final cal;
  final cat;
  const approve({Key? key, this.BMI, this.cal, this.cat}) : super(key: key);

  @override
  State<approve> createState() => _approveState();
}

class _approveState extends State<approve> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body : Container(
            width: MediaQuery.of(context).size.width * 1,
            decoration: BoxDecoration(
                image : DecorationImage(
                  image: AssetImage("assets/images/sign.png"),
                  fit: BoxFit.fill,
                )
            ),
            child: Column(
              children: [
                Padding(padding: EdgeInsets.all(110.0)),
                Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: Text("SUCCESSFULL!",
                      style: TextStyle(fontSize: 40),
                      textAlign: TextAlign.center,
                    )
                ),
                Padding(padding: EdgeInsets.all(5.0)),
                Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: Icon(Icons.check,
                      size: 80,
                      color: Colors.black,
                    )
                ),
                Padding(padding: EdgeInsets.all(30.0)),
                Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: Text("Accont created succesfully",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    )
                ),
                Container(
                    child: (widget.BMI >= 18.5)?
                    Container(
                        child: (widget.BMI <= 25)?
                        Text("NORMALWEIGHT",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),):
                        Text("OVERWEIGHT",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),)
                    ):
                    Text("UNDERWEIGHT",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),)
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: (widget.cat == 1)?
                    Text("By eating ${widget.cal} calories you can reduce weight by 1 pd per week",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),textAlign: TextAlign.center,):
                    (widget.cat == 2)?
                    Text("By eating ${widget.cal} calories you can maintain your weight 1",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),textAlign: TextAlign.center,):
                    Text("By eating ${widget.cal} calories you can gain weight by 1 pd per week",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),textAlign: TextAlign.center,)
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: BoxDecoration(
                        image : DecorationImage(
                          image: AssetImage("assets/images/sbox.JPG"),
                          fit: BoxFit.fill,
                        )
                    ),
                    child: FlatButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => SignScreen1()));
                      },
                      child: Text("Sign In",
                        style: TextStyle(fontSize: 22),),

                    )
                ),
              ],
            ),
          )
      ),
    );
  }
}

class forpass extends StatefulWidget {
  const forpass({Key? key}) : super(key: key);

  @override
  State<forpass> createState() => _forpassState();
}

class _forpassState extends State<forpass> {
  TextEditingController _emailnum = TextEditingController();
  int error = 2;
  bool state = false;
  Future<void> resetpass() async{
    setState(() {
      state=true;
    });
    try {
   final new1 =  await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailnum.text.trim()).then((value) => setState((){
            error =1;
   }));
   if(error == 1)
     {
       setState(() {
         state=false;
       });
       Navigator.push(context, MaterialPageRoute(
           builder: (context) => passapp()));
     }

    } on FirebaseAuthException catch (e) {
      setState(() {
        error =0;
        setState(() {
          state=false;
        });
      });
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body : !state?Container(
          decoration: BoxDecoration(
              image : DecorationImage(
                image: AssetImage("assets/images/sign.png"),
                fit: BoxFit.fill,
              )
          ),
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(130.0)),
              Container(
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.05,
                child: Container(
                  child: Text("Forgot Password",
                    style: TextStyle(fontSize: 30,fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(20.0)),
              Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: TextField(
                    controller:_emailnum,
                    decoration: InputDecoration(
                        hintText: "Email Address ",
                        hintStyle: TextStyle(fontSize: 20,color: Colors.black)
                    ),
                  )
              ),

              Padding(padding: EdgeInsets.all(20.0)),
              Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.07,
                  decoration: BoxDecoration(
                      image : DecorationImage(
                        image: AssetImage("assets/images/sbox.JPG"),
                        fit: BoxFit.fill,
                      )
                  ),
                  child: FlatButton(
                    onPressed: () {
                      resetpass();
                    },
                    child: Text("Next",
                      style: TextStyle(fontSize: 22),),

                  )
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: (error == 0)?Text("enter a valid email address",
                    style: TextStyle(color: Colors.red,fontSize: 20),textAlign: TextAlign.center,):
                  Text("")
              ) ],
          ),
        ):Container(
            decoration: BoxDecoration(
                image : DecorationImage(
                  image: AssetImage("assets/images/sign.png"),
                  fit: BoxFit.fill,
                )
            ),
            child: SpinKitFadingCircle(
              color: Colors.purple,
              size: 100.0,
            )
        ),
    );
  }
}


class passapp extends StatelessWidget {
  const passapp({Key?key}):
        super(key:key);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body : Container(
            width: MediaQuery.of(context).size.width * 1,
            decoration: BoxDecoration(
                image : DecorationImage(
                  image: AssetImage("assets/images/sign.png"),
                  fit: BoxFit.fill,
                )
            ),
            child: Column(
              children: [
                Padding(padding: EdgeInsets.all(110.0)),

                Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.15,
                    child:
                    Text("PASSWORD UPDATED",
                      style: TextStyle(fontSize: 40),
                      textAlign: TextAlign.center,
                    )
                ),
                //Padding(padding: EdgeInsets.all(5.0)),
                Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: Icon(Icons.check_circle_outline,
                      size: 80,
                      color: Colors.black,
                    )
                ),
                Padding(padding: EdgeInsets.all(30.0)),
                Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.15,
                    child:
                    Text("Your identity has been verified ,  set your new password in the sent link then try to login",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    )
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: BoxDecoration(
                        image : DecorationImage(
                          image: AssetImage("assets/images/sbox.JPG"),
                          fit: BoxFit.fill,
                        )
                    ),
                    child: FlatButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => SignScreen1()));
                        },
                        child:Text("Sign In",
                          style: TextStyle(fontSize: 22),)
                    )
                ),
              ],
            ),
          )
      ),
    );
  }
}
