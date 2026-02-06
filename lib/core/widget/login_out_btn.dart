import 'package:agym/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginOutButton extends StatelessWidget {
  const LoginOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.exit_to_app, color: Colors.red),
      tooltip: "Logout",
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Logout"),
              content: const Text("Do you really want to logout?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<AuthCubit>().logout();
                  },
                  child: const Text("Logout"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
