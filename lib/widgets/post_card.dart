
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/helper/color.dart';
import 'package:instagram_clone/until/utils.dart';

import '../resources/firestore_methods.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
    } catch (error) {
      showSnackBar(context, error.toString());
    }
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (error) {
      showSnackBar(context, error.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var user;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: mobileBackgroundColor
        ),
        color: mobileBackgroundColor,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              widget.snap['profImage'].toString(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.snap['username'].toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          widget.snap['uid'].toString() == user.uid
              ? IconButton(
            onPressed: () {
              showDialog(
                useRootNavigator: false,
                context: context,
                builder: (context) {
                  return Dialog(
                    child: ListView(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16),
                        shrinkWrap: true,
                        children: [
                          'Delete',
                        ]
                            .map(
                              (e) => InkWell(
                              child: Container(
                                padding:
                                const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16),
                                child: Text(e),
                              ),
                              onTap: () {
                                deletePost(
                                  widget.snap['postId']
                                      .toString(),
                                );
                                // remove the dialog box
                                Navigator.of(context).pop();
                              }),
                        )
                            .toList()),
                  );
                },
              );
            },
            icon: const Icon(Icons.more_vert),
          )
              : Container(),
        ],
      ),
    );
    throw UnimplementedError();
  }

}