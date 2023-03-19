import 'package:bachelor_flutter_crush/bloc/reporting_bloc/reporting_event.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/models.dart';

import '../bloc/reporting_bloc/reporting_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;

class PaymentController extends GetxController {
  Map<String, dynamic>? paymentIntentData;
  late BuildContext context;

  void makePayment(BuildContext context) {
    this.context = context;

    InAppPayments.setSquareApplicationId(
        'sandbox-sq0idb-tGCIx1hiRafOVCkzw5V6XA');
    InAppPayments.startCardEntryFlow(
        onCardNonceRequestSuccess: _cardNonceRequestSuccess,
        onCardEntryCancel: _cardEntryCancel);
  }

  void _cardEntryCancel() {
    Navigator.pop(context, 'Ok');
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("Payment Failed"),
              content: const Text("The payment action was cancelled"),
              actions: <Widget>[
                TextButton(
                    onPressed: () => {Navigator.pop(context, 'Ok')},
                    child: const Text('Ok'))
              ],
            ));
  }

  void _cardNonceRequestSuccess(CardDetails result) {
    print("nonce: " + result.nonce);

    InAppPayments.completeCardEntry(onCardEntryComplete: _cardEntryComplete);
  }

  void _cardEntryComplete() {
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
  }

  void updateSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? addActive = prefs.getBool("addsActive");

    if (addActive == true) {
      prefs.setBool('addsActive', false);
    } else {
      prefs.setBool('addsActive', true);
    }
    addActive = !addActive!;
    print("Advertisements are now: " + addActive.toString());
  }
}
