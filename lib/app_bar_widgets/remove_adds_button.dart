import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoveAddsButton extends StatelessWidget {
  const RemoveAddsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DarkPatternsBloc, DarkPatternsState>(
        builder: (context, state) {
      if (state is DarkPatternsActivatedState) {
        return Padding(
            padding: const EdgeInsets.only(right: 0),
            child: IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
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
                                onPressed: () => {buyAddRemover(context)},
                                child: const Text('OK'),
                              )
                            ],
                          ));
                },
                icon: const Icon(Icons.money_off)));
      } else {
        return Container();
      }
    });
  }

  buyAddRemover(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? addActive = prefs.getBool("addsActive");
    if(addActive == true) {
      prefs.setBool('addsActive', false);
    } else{
      prefs.setBool('addsActive', true);
    }
    addActive = !addActive!;
    print("Advertisements are now: " + addActive.toString());
    Navigator.pop(context, 'Ok');
  }
}
