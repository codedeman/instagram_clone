import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/widgets/option_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import '../helper/color.dart';
import '../providers/user_provider.dart';
import '../resources/firestore_methods.dart';
import '../until/utils.dart';

class ImageModel {
  final Future<File?> file;

  ImageModel(this.file);

  Future<String?> get path async {
    final file = await this.file;
    return file?.path;
  }
}

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  bool isLoading = false;
  List<AssetEntity> _mediaList = [];
  AssetEntity? _selectedImage;
  List<ImageModel>? _selectedImages;
  Set<String> _selectedFilePaths = {};

  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadImages();
    Provider.of<UserProvider>(context, listen: false).refreshUser();
  }

  Future<void> _loadImages() async {
    setState(() {
      _mediaList = []; // Ensure the list is empty before loading
    });

    final status = await PhotoManager.requestPermissionExtend();

    if (status == PermissionState.authorized) {
      final List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(type: RequestType.image);

      if (albums.isNotEmpty) {
        final AssetPathEntity recentAlbum = albums.first;
        final List<AssetEntity> media =
            await recentAlbum.getAssetListPaged(page: 0, size: 100);

        setState(() {
          _mediaList = media;
        });
      } else {
        setState(() {
          _mediaList = [];
        });
      }
    } else {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text(
            'The app needs access to your photos to function properly. Please enable photo access in the app settings.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Open Settings'),
              onPressed: () {
                openAppSettings();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void postImage(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });

    try {
      String res = await FireStoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profImage,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        if (context.mounted) {
          showSnackBar(context, 'Posted!');
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
      showSnackBar(context, err.toString());
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  void _showImageBottomSheet(BuildContext context) async {
    final selectedFilePaths = _selectedFilePaths.toSet();
    final selectedImageModels = await Future.wait(
      _mediaList.map((asset) async {
        final file = await asset.file;
        if (file != null && selectedFilePaths.contains(file.path)) {
          return asset;
        }
        return null;
      }),
    ).then((results) => results.whereType<AssetEntity>().toList());
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Stack(
            children: [
              // Image previews
              Align(
                alignment: Alignment.topCenter,
                child: selectedImageModels.isEmpty
                    ? const Center(child: Text('No images selected'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedImageModels.length,
                        itemBuilder: (context, index) {
                          final asset = selectedImageModels[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FutureBuilder<File?>(
                              future: asset.file,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (snapshot.hasError || !snapshot.hasData) {
                                  return const Center(child: Icon(Icons.error));
                                }

                                final file = snapshot.data!;
                                return Image.file(
                                  file,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
              // Next button positioned at the bottom right corner
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle the "Next" button press, e.g., navigate to a new screen
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Rounded corners
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      minimumSize:
                          Size(80, 50), // Adjust the size as per your needs
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('New reel'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings button tap
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                OptionButton(icon: Icons.camera_alt, label: 'Camera'),
                OptionButton(icon: Icons.gif, label: 'Clip hub'),
                OptionButton(icon: Icons.view_quilt, label: 'Templates'),
                OptionButton(icon: Icons.star, label: 'Made for you'),
              ],
            ),
          ),
          // Media grid
          Expanded(
            child: _mediaList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(4),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: _mediaList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final asset = _mediaList[index];
                      return FutureBuilder<File?>(
                        future: asset.file, // Convert AssetEntity to File
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Center(child: Icon(Icons.error));
                          }

                          final file = snapshot.data!;
                          final path = file.path;
                          final isSelected = _selectedFilePaths.contains(path);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedFilePaths.remove(path);
                                } else {
                                  _selectedFilePaths.add(path);
                                }

                                if (_selectedFilePaths.isNotEmpty) {
                                  _showImageBottomSheet(context);
                                }
                              });
                            },
                            child: Stack(
                              children: [
                                FutureBuilder<Uint8List?>(
                                  future: asset.thumbnailData,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return const Center(
                                          child: Icon(Icons.error));
                                    }

                                    final bytes = snapshot.data!;
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: MemoryImage(bytes),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (isSelected)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 30,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
