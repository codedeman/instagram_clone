import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/helper/color.dart';

class FollowButton extends StatelessWidget {
  final Function()? function;
  final Color backgroundColor;
  final Color borderColor;
  final String text;
  final Color textColor;
  const FollowButton(
      {Key? key,
      required this.backgroundColor,
      required this.borderColor,
      required this.text,
      required this.textColor,
      this.function})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed: function,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 5), // Adjust these values
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          // alignment: Alignment.center,
          // width: 100,
          // height: 27,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class FollowButtonWidget extends StatelessWidget {
  final bool isFollowing;
  final String uid;
  final VoidCallback onFollowUnfollow;

  const FollowButtonWidget({
    Key? key,
    required this.isFollowing,
    required this.uid,
    required this.onFollowUnfollow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser!.uid == uid) {
      return const SizedBox.shrink(); // Empty widget
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FollowButton(
          text: 'Message',
          backgroundColor: Colors.black,
          textColor: Colors.white,
          borderColor: isFollowing ? Colors.grey : Colors.blue,
          function: onFollowUnfollow,
        ),
        const SizedBox(width: 0), // Reduced width to bring the buttons closer
        FollowButton(
          text: isFollowing ? 'Unfollow' : 'Follow',
          backgroundColor: isFollowing ? Colors.white : Colors.blue,
          textColor: isFollowing ? Colors.black : Colors.white,
          borderColor: isFollowing ? Colors.grey : Colors.blue,
          function: onFollowUnfollow,
        ),
      ],
    );
  }
}
