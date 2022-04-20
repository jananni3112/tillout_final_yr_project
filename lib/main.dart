
import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:email_validator/email_validator.dart';
import "package:firebase_auth/firebase_auth.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

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
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}



class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3),
            ()=>Navigator.pushReplacement(context,
            MaterialPageRoute(builder:
                (context) =>
                SignScreen1()
            )
        )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image : DecorationImage(
            image: AssetImage("assets/images/launching screen.png"),
            fit: BoxFit.fill,
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
  TextEditingController _emailtext = TextEditingController();
  Future<void> signin() async{
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailtext.text.trim(),
          password: _passtext.text.trim()).then((UserCredential user) {
        if( user != null) {
          setState(() {
            error = true;
          });
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => Home()));
        }
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = false;
      });
      print(e.message);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body : Container(
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
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => forpass()));
                      }, child: Text("Forgot password",
                        style: TextStyle(color: Colors.blue),
                        textAlign: TextAlign.left,
                      ),),
                      Padding(padding: EdgeInsets.all(10.0)),
                      FlatButton(onPressed: () {Navigator.push(context, MaterialPageRoute(
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
                      signin();
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
        )
    );
  }
}




class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

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
    });
    _getBatteryLevel();
  }
  Future<void> _getBatteryLevel() async {
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
    output1();
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
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => output(image: imagetemp,
          detect: _batteryLevel,
          quantity: _quantity,
          calorie: _calorie,
          count: _count,)));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Padding(padding: EdgeInsets.all(100.0)),
                  Container(
                    width: MediaQuery.of(context).size.width * 1,
                    height: MediaQuery.of(context).size.height * 0.07,

                    child: Container(
                      child: Text("Welcome Janani!",
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
                      icon: Icon(Icons.history),
                      iconSize: 40,
                      color: Colors.black,
                      onPressed: (){Navigator.push(context, MaterialPageRoute(
                          builder: (context) => history()));},
                    ),
                  ),
                ]
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
  const output({Key? key, this.image, this.detect, this.quantity, this.calorie, this.count}) : super(key: key);

  @override
  State<output> createState() => _outputState();
}

class _outputState extends State<output> {
  double sum=0;
  DateTime _date = DateTime.now();
  List<String> _locations = ['A', 'B', 'C', 'D']; // Option 2
  Object? _selectedLocation = "A";
  Object? _dropDownValue=" ";
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
                        showAlertDialog(context,sum,_dropDownValue);
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
                              Padding(padding: EdgeInsets.all(5.0)),
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
                              //Padding(padding: EdgeInsets.all(10.0)),
                              Container(
                                  width: MediaQuery.of(context).size.width * 0.2,
                                  child: Column(
                                    children: [
                                      Padding(padding: EdgeInsets.all(5.0)),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.2,
                                        //height: MediaQuery.of(context).size.height * 0.1,
                                        child: Text("Calories", style: TextStyle(color: Colors.black, fontSize: 16,
                                        ),textAlign: TextAlign.center,),
                                      ),
                                      Padding(padding: EdgeInsets.all(4.0)),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.2,
                                        //height: MediaQuery.of(context).size.height * 0.1,
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

class history extends StatefulWidget {
  const history({Key? key}) : super(key: key);

  @override
  _historyState createState() => _historyState();
}

class _historyState extends State<history> {
  double sum=0;
  Object var1 = " ";
  DateTime _date = DateTime.now();
  _pickdate(BuildContext context) async {
    DateTime? date =await showDatePicker(context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year-1),
        lastDate: DateTime(DateTime.now().year+1) );
    setState(() { _date = date!; }); }
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
            Padding(padding: EdgeInsets.all(70.0)),
            Row(children: [
              Padding(padding: EdgeInsets.all(15.0)),
              Text("Select the date :  ",
                style: TextStyle(color: Colors.black, fontSize: 25,
                  fontWeight: FontWeight.w500, ),),
              Container(
                  width: MediaQuery.of(context).size.width * 0.34,
                  height: MediaQuery.of(context).size.height * 0.055,
                  child:     RaisedButton(
                    onPressed: (){ _pickdate(context); },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.blueAccent,
                    child: Text("${_date.day}-${_date.month}-${_date.year}",
                      style: TextStyle( color: Colors.black, fontSize: 20,
                        fontWeight: FontWeight.w500, ),),

                  )
              )],),
            Padding(padding: EdgeInsets.all(200.0)),
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
                    showAlertDialog(context,sum,var1);
                  },
                  child: Text("Total cal",
                    style: TextStyle(fontSize: 22),),

                )
            ),
          ],),
        )
    );
  }
}

showAlertDialog(BuildContext context,double sum,Object? date) {
  // Create button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("$date"),
    content: Text("The total calories is: $sum"),
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
  var cond ="";
  TextEditingController _passtext = TextEditingController();
  bool error = true;
  bool _vis = true;
  TextEditingController _emailtext = TextEditingController();
  TextEditingController _nametext = TextEditingController();
  TextEditingController _phonetext = TextEditingController();
  Future<void> signup() async {
    try {
      final newUser = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailtext.text.trim(),
          password: _passtext.text.trim());
      if (newUser != null) {
        const patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
        RegExp regExp = new RegExp(patttern);
        (_phonetext.text == "9597413567")?setState((){cond = "Phone number already exist";}):
        (!EmailValidator.validate(_emailtext.text))?setState((){cond ="Enter a valid email" ;}):
        (!regExp.hasMatch(_phonetext.text) && _phonetext.text.length != 10)?setState((){cond ="Enter a valid phone number";}):
        (_nametext.text == "" && _passtext == "")?setState((){cond ="Enter all credentials";}):
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => approve()));
      }
    } catch (e) {
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body : Container(
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
        )
    );
  }
}



class approve extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Padding(padding: EdgeInsets.all(140.0)),

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
              Padding(padding: EdgeInsets.all(40.0)),
              Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: Text("Accont created succesfully",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
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
  Future<void> resetpass() async{
    try {
   final new1 =  await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailnum.text.trim()).then((value) => setState((){
            error =1;
   }));
   if(error == 1)
     {
       Navigator.push(context, MaterialPageRoute(
           builder: (context) => passapp()));
     }

    } on FirebaseAuthException catch (e) {
      setState(() {
        error =0;
      });
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body : Container(
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
        )
    );
  }
}


class passapp extends StatelessWidget {
  const passapp({Key?key}):
        super(key:key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
