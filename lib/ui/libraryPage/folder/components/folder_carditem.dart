import 'package:flutter/material.dart';
import 'package:orange_card/resources/models/folder.dart';
import 'package:orange_card/constants/constants.dart';

class FolderCardItem extends StatelessWidget {
  final Folder folder;
  final void Function(Folder) onDelete;
  final void Function(Folder) onEdit;

  const FolderCardItem({
    Key? key,
    required this.folder,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder,
              size: 64.0,
              color: kPrimaryColor, // You can customize the color
            ),
            const SizedBox(height: 5.0),
            Text(
              folder.title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5.0),
            Padding(
              padding: const EdgeInsets.only(left: 45),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${folder.topicIds.length} topics',
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                    ),
                  ),
                  PopupMenuButton<int>(
                    onSelected: (value) {
                      if (value == 0 && onEdit != null) {
                        onEdit(folder);
                      } else if (value == 1 && onDelete != null) {
                        onDelete(folder);
                      }
                    },
                    itemBuilder: (context) => [
                      if (onEdit != null)
                        const PopupMenuItem<int>(
                          value: 0,
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.black),
                              SizedBox(width: 8),
                              Text('Edit',
                                  style: TextStyle(color: Colors.black)),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem<int>(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
