import 'package:bachelor_flutter_crush/helpers/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bachelor_flutter_crush/bloc/reporting_bloc/reporting_event.dart';

import '../bloc/reporting_bloc/reporting_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
class PaymentController extends StatefulWidget {
  const PaymentController({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PaymentState();
  }

  void updateSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? addActive = prefs.getBool("addsActive");
    if (addActive == true) {
      prefs.setBool('addsActive', false);
    } else {
      prefs.setBool('addsActive', true);
    }
  }
}

class PaymentState extends State<PaymentController> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    print("Init Payment");
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add Credit Card Details',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage('assets/images/credit/bg.png'),
              fit: BoxFit.fill,
            ),
            color: Colors.black,
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 30,
                ),
                CreditCardWidget(
                  glassmorphismConfig:
                  useGlassMorphism ? Glassmorphism.defaultConfig() : null,
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  bankName: 'Axis Bank',
                  frontCardBorder:
                  !useGlassMorphism ? Border.all(color: Colors.grey) : null,
                  backCardBorder:
                  !useGlassMorphism ? Border.all(color: Colors.grey) : null,
                  showBackView: isCvvFocused,
                  obscureCardNumber: true,
                  obscureCardCvv: true,
                  isHolderNameVisible: true,
                  cardBgColor: AppColors.cardBgColor,
                  backgroundImage:
                  useBackgroundImage ? 'assets/images/credit/card_bg.png' : null,
                  isSwipeGestureEnabled: true,
                  onCreditCardWidgetChange:
                      (CreditCardBrand creditCardBrand) {},
                  customCardTypeIcons: <CustomCardTypeIcon>[
                    CustomCardTypeIcon(
                      cardType: CardType.mastercard,
                      cardImage: Image.asset(
                        'assets/images/credit/mastercard.png',
                        height: 48,
                        width: 48,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        CreditCardForm(
                          formKey: formKey,
                          obscureCvv: true,
                          obscureNumber: true,
                          cardNumber: cardNumber,
                          cvvCode: cvvCode,
                          isHolderNameVisible: true,
                          isCardNumberVisible: true,
                          isExpiryDateVisible: true,
                          cardHolderName: cardHolderName,
                          expiryDate: expiryDate,
                          themeColor: Colors.blue,
                          textColor: Colors.white,
                          cardNumberDecoration: InputDecoration(
                            labelText: 'Number',
                            hintText: 'XXXX XXXX XXXX XXXX',
                            hintStyle: const TextStyle(color: Colors.white),
                            labelStyle: const TextStyle(color: Colors.white),
                            focusedBorder: border,
                            enabledBorder: border,
                          ),
                          expiryDateDecoration: InputDecoration(
                            hintStyle: const TextStyle(color: Colors.white),
                            labelStyle: const TextStyle(color: Colors.white),
                            focusedBorder: border,
                            enabledBorder: border,
                            labelText: 'Expired Date',
                            hintText: 'XX/XX',
                          ),
                          cvvCodeDecoration: InputDecoration(
                            hintStyle: const TextStyle(color: Colors.white),
                            labelStyle: const TextStyle(color: Colors.white),
                            focusedBorder: border,
                            enabledBorder: border,
                            labelText: 'CVV',
                            hintText: 'XXX',
                          ),
                          cardHolderDecoration: InputDecoration(
                            hintStyle: const TextStyle(color: Colors.white),
                            labelStyle: const TextStyle(color: Colors.white),
                            focusedBorder: border,
                            enabledBorder: border,
                            labelText: 'Card Holder',
                          ),
                          onCreditCardModelChange: onCreditCardModelChange,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: _onValidate,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: <Color>[
                                  AppColors.colorB58D67,
                                  AppColors.colorB58D67,
                                  AppColors.colorE5D1B2,
                                  AppColors.colorF9EED2,
                                  AppColors.colorFFFFFD,
                                  AppColors.colorF9EED2,
                                  AppColors.colorB58D67,
                                ],
                                begin: Alignment(-1, -4),
                                end: Alignment(1, 4),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: const Text(
                              'Buy Add Removal',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'halter',
                                fontSize: 14,
                                package: 'flutter_credit_card',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onValidate() {
    if (formKey.currentState!.validate()) {
          Navigator.pop(context, 'Ok');
    print("Payment Complete");
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("Successfully Removed Adds"),
              content: const Text(
                  "Thank you for purchasing the Remove Adds Function, you are getting charged for 2,99€ per month from now on!"),
              actions: <Widget>[
                TextButton(
                    onPressed: () => {Navigator.pop(context, 'Ok')},
                    child: const Text('Ok')),
              ],
            ));
    final reportingBloc = flutter_bloc.BlocProvider.of<ReportingBloc>(context);
    reportingBloc.add(ReportPaidForRemovingAddsEvent(true));
    updateSharedPreferences();
    } else {
      print('invalid!');
    }
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  void updateSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? addActive = prefs.getBool("addsActive");
    if (addActive == true) {
      prefs.setBool('addsActive', false);
    } else {
      prefs.setBool('addsActive', true);
    }
  }
}

// import 'package:bachelor_flutter_crush/bloc/reporting_bloc/reporting_event.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:square_in_app_payments/in_app_payments.dart';
// import 'package:square_in_app_payments/models.dart';
//
// import '../bloc/reporting_bloc/reporting_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
//
// class PaymentController extends GetxController {
//   Map<String, dynamic>? paymentIntentData;
//   late BuildContext context;
//
//   void makePayment(BuildContext context) {
//     this.context = context;
//
//     InAppPayments.setSquareApplicationId(
//         'sandbox-sq0idb-tGCIx1hiRafOVCkzw5V6XA');
//     InAppPayments.startCardEntryFlow(
//         onCardNonceRequestSuccess: _cardNonceRequestSuccess,
//         onCardEntryCancel: _cardEntryCancel);
//   }
//
//   void _cardEntryCancel() {
//     Navigator.pop(context, 'Ok');
//     showDialog(
//         context: context,
//         builder: (BuildContext context) => AlertDialog(
//               title: const Text("Payment Failed"),
//               content: const Text("The payment action was cancelled"),
//               actions: <Widget>[
//                 TextButton(
//                     onPressed: () => {Navigator.pop(context, 'Ok')},
//                     child: const Text('Ok'))
//               ],
//             ));
//   }
//
//   void _cardNonceRequestSuccess(CardDetails result) {
//     print("nonce: " + result.nonce);
//
//     InAppPayments.completeCardEntry(onCardEntryComplete: _cardEntryComplete);
//   }
//
//   void _cardEntryComplete() {
//     Navigator.pop(context, 'Ok');
//     print("Payment Complete");
//     showDialog(
//         context: context,
//         builder: (BuildContext context) => AlertDialog(
//               title: const Text("Successfully Removed Adds"),
//               content: const Text(
//                   "Thank you for purchasing the Remove Adds Function, you are getting charged for 2,99€ per month from now on!"),
//               actions: <Widget>[
//                 TextButton(
//                     onPressed: () => {Navigator.pop(context, 'Ok')},
//                     child: const Text('Ok')),
//               ],
//             ));
//     final reportingBloc = flutter_bloc.BlocProvider.of<ReportingBloc>(context);
//     reportingBloc.add(ReportPaidForRemovingAddsEvent(true));
//     updateSharedPreferences();
//   }
//
//   void updateSharedPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool? addActive = prefs.getBool("addsActive");
//     if (addActive == true) {
//       prefs.setBool('addsActive', false);
//     } else {
//       prefs.setBool('addsActive', true);
//     }
//   }
// }
