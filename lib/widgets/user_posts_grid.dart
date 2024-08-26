import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserPostsGrid extends StatefulWidget {
  final String uid;

  const UserPostsGrid({Key? key, required this.uid}) : super(key: key);

  @override
  State<UserPostsGrid> createState() => _UserPostsGridState();
}

class _UserPostsGridState extends State<UserPostsGrid>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          itemCount: (snapshot.data! as dynamic).docs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 1.5,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            DocumentSnapshot snap = (snapshot.data! as dynamic).docs[index];

            return SizedBox(
              child: Image(
                image: NetworkImage(snap['postUrl']),
                fit: BoxFit.cover,
              ),
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true; // Keep state alive
}
