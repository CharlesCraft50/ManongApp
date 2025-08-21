import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:manong_application/main.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/widgets/image_dialog.dart';

final Logger logger = Logger('image_picker_card');

class ImagePickerCard extends StatefulWidget {
  final Function(List<File> images) onImageSelect;

  const ImagePickerCard({super.key, required this.onImageSelect});
  @override
  State<ImagePickerCard> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<ImagePickerCard> {
  List<File> _images = [];
  final ImagePicker picker = ImagePicker();
  final int maxImages = 3;

  Future<bool> _isValidImage(File file) async {
    try {
      final decodedImage = await decodeImageFromList(await file.readAsBytes());
      return decodedImage.width > 0 && decodedImage.height > 0;
    } catch (_) {
      return false;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.gallery) {
      final List<XFile> pickedFiles = await picker.pickMultiImage(
        imageQuality: 80, // compress
        maxWidth: 1024,
      );

      if (pickedFiles.isNotEmpty) {
        int remaining = maxImages - _images.length;
        for (var xfile in pickedFiles.take(remaining)) {
          File file = File(xfile.path);
          if (await _isValidImage(file)) {
            setState(() {
              _images.add(file);
            });
          }
        }
        widget.onImageSelect(_images);
      }
    } else {
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null && _images.length < maxImages) {
        File file = File(pickedFile.path);
        if (await _isValidImage(file)) {
          setState(() {
            _images.add(file);
          });
          widget.onImageSelect(_images);
        } else {
          logger.severe("Invalid image selected, skipping...");
        }
      }
    }
  }

  void _showImageDialog(File image) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (_) => ImageDialog(image: image),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColorScheme.royalBlueLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _images.length >= maxImages
            ? null
            : _pickImage(ImageSource.gallery),
        child: SizedBox(
          width: double.infinity,
          child: _images.isNotEmpty
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 8),
                      for (var img in _images)
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () {
                                  _showImageDialog(img);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    img,
                                    height: 150,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _images.remove(img);
                                  });
                                  widget.onImageSelect(_images);
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 32,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              : DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    radius: Radius.circular(12),
                    dashPattern: [10, 5],
                    strokeWidth: 2,
                    color: AppColorScheme.royalBlueMedium,
                    padding: EdgeInsets.all(32),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.image),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to add photos',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
