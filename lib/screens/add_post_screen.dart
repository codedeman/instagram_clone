import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helper/color.dart';
import '../providers/user_provider.dart';
import '../resources/firestore_methods.dart';
import '../until/utils.dart';

class NextScreen extends StatefulWidget {
  final Uint8List
      selectedImage; // Selected image passed from the previous screen

  const NextScreen({Key? key, required this.selectedImage}) : super(key: key);

  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).refreshUser();
  }

  void postImage(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    try {
      // Upload to storage and database
      String res = await FireStoreMethods().uploadPost(
        _descriptionController.text,
        widget.selectedImage, // Using the selected image
        uid,
        username,
        profImage,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        if (context.mounted) {
          showSnackBar(
            context,
            'Posted!',
          );
        }
        clearImage();
      } else {
        if (context.mounted) {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void clearImage() {
    setState(() {
      Navigator.pop(context); // Pop the current screen
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: clearImage,
        ),
        title: const Text('Post to'),
        centerTitle: false,
        actions: <Widget>[
          TextButton(
            onPressed: () => postImage(
              userProvider.getUser!.uid,
              userProvider.getUser!.username,
              userProvider.getUser!.photoUrl,
            ),
            child: const Text(
              "Post",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          isLoading
              ? const LinearProgressIndicator()
              : const Padding(padding: EdgeInsets.only(top: 0.0)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.red,
                backgroundImage: NetworkImage(
                  userProvider.getUser!.photoUrl,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: "Write a caption...",
                    border: InputBorder.none,
                  ),
                  maxLines: 8,
                ),
              ),
              SizedBox(
                height: 45.0,
                width: 45.0,
                child: AspectRatio(
                  aspectRatio: 487 / 451,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      fit: BoxFit.fill,
                      alignment: FractionalOffset.topCenter,
                      image: MemoryImage(widget.selectedImage),
                    )),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
