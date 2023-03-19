import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/reporting_bloc/reporting_bloc.dart';
import '../bloc/reporting_bloc/reporting_event.dart';
import '../controllers/payment_controller.dart';

import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;

class RemoveAddsButton extends StatelessWidget {
  const RemoveAddsButton({Key? key}) : super(key: key);

  static bool addsActive = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DarkPatternsBloc, DarkPatternsState>(
        builder: (context, state) {
      if (state is DarkPatternsActivatedState) {
        getSharedPreferences();
        return buyAddRemover(context);
      } else {
        return Container();
      }
    });
  }

  buyAddRemover(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 0),
        child: IconButton(
            onPressed: () {
              getSharedPreferences();
              showDialog(
                  context: context,
                  builder: (BuildContext context) => addsActive
                      ? AlertDialog(
                          title: const Text('Remove Adds'),
                          content: const Text(
                              'Do you want to remove adds for 2,99€?'),
                          elevation: 24,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () =>
                                    {Navigator.pop(context, 'Cancel')},
                                child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => {
                                Navigator.pop(context, 'Ok'),
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const PaymentController())),
                              },
                              child: const Text('OK'),
                            )
                          ],
                        )
                      : AlertDialog(
                          title: const Text('Adds already deactivated'),
                          content: const Text(
                              'You already have bought adds, do you want to cancel your subscription?'),
                          elevation: 24,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () => {Navigator.pop(context, 'No')},
                                child: const Text('No')),
                            TextButton(
                              onPressed: () => {reactivateAdds(context)},
                              child: const Text('Yes'),
                            )
                          ],
                        ));
            },
            icon: const Icon(Icons.money_off)));
  }

  void reactivateAdds(BuildContext context) {
    updateSharedPreferences();
    Navigator.pop(context, 'Ok');
    print("Reactivate Adds");
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("Subscription cancelled"),
              content: const Text("Adds are now active again!"),
              actions: <Widget>[
                TextButton(
                    onPressed: () => {Navigator.pop(context, 'Ok')},
                    child: const Text('Ok')),
              ],
            ));
    final reportingBloc = flutter_bloc.BlocProvider.of<ReportingBloc>(context);
    reportingBloc.add(ReportPaidForRemovingAddsEvent(false));
  }

  void getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    addsActive = prefs.getBool("addsActive")!;
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
