import 'package:flutter/material.dart';
import 'package:orange_card/constants/constants.dart';
import 'package:orange_card/resources/models/folder.dart';
import 'package:orange_card/resources/viewmodels/FolderViewModel.dart';
import 'package:orange_card/ui/detail_folder/detail_folder_screen.dart';
import 'package:orange_card/ui/libraryPage/folder/components/folder_carditem.dart';
import 'package:orange_card/ui/libraryPage/folder/srceens/add_folder_screen.dart';
import 'package:orange_card/ui/skelton/folder.dart';
import 'package:provider/provider.dart';

class FolderScreen extends StatefulWidget {
  final FolderViewModel folderViewModel;

  const FolderScreen({Key? key, required this.folderViewModel})
      : super(key: key);

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  @override
  void initState() {
    super.initState();
    // setdata();
  }

  void _filterFolder(String query) async {
    widget.folderViewModel.searchFolder(query);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await setdata();
        },
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
              child: TextField(
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: _filterFolder,
              ),
            ),
            Expanded(child: _buildFolderList(context)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _navigateToAddFolderScreen(context);
          await setdata();
          setState(() {});
        },
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFolderList(BuildContext ScaffodContext) {
    return widget.folderViewModel.isLoading
        ? const FolderSkelton()
        : widget.folderViewModel.folders.isEmpty
            ? const Center(child: Text('List Folder is empty'))
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(ScaffodContext).size.width > 600 ? 4 : 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: widget.folderViewModel.folders.length,
                itemBuilder: (context, index) {
                  final folder = widget.folderViewModel.folders[index];
                  return GestureDetector(
                    onTap: () async {
                      final FolderViewModel folderViewModel =
                          Provider.of<FolderViewModel>(context, listen: false);
                      await folderViewModel.getTopicInModel(folder.topicIds);
                      print(folderViewModel.isLoading);
                      Navigator.push(
                        ScaffodContext,
                        MaterialPageRoute(
                          builder: (context) => DetailFolder(
                            folderViewModel: folderViewModel,
                            folder: folder,
                          ),
                        ),
                      );
                    },
                    child: FolderCardItem(
                      folder: folder,
                      onDelete: (folder) {
                        _showDeleteConfirmation(folder, context);
                      },
                      onEdit: (folder) {
                        _navigateToEditFolderScreen(context, folder);
                      },
                    ),
                  );
                },
              );
  }

  Future<void> _navigateToAddFolderScreen(BuildContext context) async {
    await showDialog<List>(
      context: context,
      builder: (_) => AddFolderScreen(
        folderViewModel: widget.folderViewModel,
      ),
    );
  }

  Future<void> _navigateToEditFolderScreen(
      BuildContext context, Folder folder) async {
    // Handle edit folder screen navigation
  }

  void _showDeleteConfirmation(Folder folder, BuildContext ScaffodContext) {
    showDialog(
      context: ScaffodContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete this folder"),
          content: const Text("You definitely want to delete this folder?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _deleteFolder(folder);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFolder(Folder folder) async {
    await widget.folderViewModel.deleteFolder(folder);
    // Show success message
  }

  Future<void> setdata() async {
    await widget.folderViewModel.loadFolders();
  }
}
