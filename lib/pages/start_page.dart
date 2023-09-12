import 'package:bachelor_flutter_crush/persistence/reporting_service.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _RegisterState();
}

class _RegisterState extends State<StartPage> {
  Map userData = {};
  final _formkey = GlobalKey<FormState>();
  TextEditingController dateCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: SizedBox(
                      width: 450,
                      height: 450,
                      //decoration: BoxDecoration(
                      //borderRadius: BorderRadius.circular(40),
                      //border: Border.all(color: Colors.blueGrey)),
                      child: Image.asset('assets/images/login/login-page.png'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    // validator: ((value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'please enter some text';
                    //   } else if (value.length < 5) {
                    //     return 'Enter atleast 5 Charecter';
                    //   }

                    //   return null;
                    // }),
                    onSaved: (value) {
                      userData['firstName'] = value;
                    },
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Enter first named'),
                      MinLengthValidator(3, errorText: 'Minimum 3 charecter filled name'),
                    ]),

                    decoration: const InputDecoration(
                        hintText: 'Enter first Name',
                        labelText: 'first named',
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.green,
                        ),
                        errorStyle: TextStyle(fontSize: 18.0),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.all(Radius.circular(9.0)))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onSaved: (value) {
                      userData['lastName'] = value;
                    },
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Enter last named'),
                      MinLengthValidator(3, errorText: 'Last name should be atleast 3 charater'),
                    ]),
                    decoration: const InputDecoration(
                        hintText: 'Enter last Name',
                        labelText: 'Last named',
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                        errorStyle: TextStyle(fontSize: 18.0),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.all(Radius.circular(9.0)))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onSaved: (value) {
                      userData['email'] = value;
                    },
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Enter email address'),
                      EmailValidator(errorText: 'Please correct email filled'),
                    ]),
                    decoration: const InputDecoration(
                        hintText: 'Email',
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.lightBlue,
                        ),
                        errorStyle: TextStyle(fontSize: 18.0),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.all(Radius.circular(9.0)))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onSaved: (value) {
                      userData['mobile'] = value;
                    },
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Enter mobile number'),
                      PatternValidator(r'(^[0-9]{10}$)', errorText: 'enter vaid mobile number'),
                    ]),
                    decoration: const InputDecoration(
                        hintText: 'Mobile',
                        labelText: 'Mobile',
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.all(Radius.circular(9)))),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      onSaved: (value) {
                        userData['dob'] = value;
                      },
                      controller: dateCtl,
                      decoration: const InputDecoration(
                          hintText: "Date of birth",
                          labelText: "Date of birth",
                          prefixIcon: Icon(
                            Icons.cake,
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.all(Radius.circular(9)))),
                      onTap: () async {
                        DateTime? date = DateTime(1900);
                        FocusScope.of(context).requestFocus(FocusNode());

                        date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100));
                        dateCtl.text = DateFormat('dd-MM-yyyy').format(date!);
                      },
                    )),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SizedBox(
                    // margin: EdgeInsets.fromLTRB(200, 20, 50, 0),
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    // margin: EdgeInsets.fromLTRB(200, 20, 50, 0),
                    child: ElevatedButton(
                      child: const Text(
                        'Register',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          _formkey.currentState?.save();
                          print("User data $userData");
                          ReportingService.addUserData(userData);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                )),
              ],
            )),
      ),
    ));
  }
}
