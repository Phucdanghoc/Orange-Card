import 'package:flutter/material.dart';
import 'package:orange_card/resources/models/folder.dart';
import 'package:orange_card/resources/viewmodels/FolderViewModel.dart';
import 'package:orange_card/constants/constants.dart';
import 'package:orange_card/ui/skelton/folder.dart';

class ListFolder extends StatefulWidget {
  final FolderViewModel folderViewModel;
  const ListFolder({super.key, required this.folderViewModel});

  @override
  State<ListFolder> createState() => _ListFolderState();
}

class _ListFolderState extends State<ListFolder> {
  List<Folder> folders = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // void _scrollListener() {
  //   if (_scrollController.position.pixels ==
  //       _scrollController.position.maxScrollExtent) {
  //     _loadMoreData();
  //   }
  // }

  // void _loadMoreData() {
  //   Future.delayed(const Duration(milliseconds: 50), () {});
  // }
  Future<void> setdata() async {
    await widget.folderViewModel.loadFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
          child: TextField(
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (value) {
              // Implement your search logic here
            },
          ),
        ),
        Expanded(
          child: widget.folderViewModel.isLoading
              ? const FolderSkelton() // Display skeleton UI when loading
              : RefreshIndicator(
                  onRefresh: () async {
                    await setdata();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: folders.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.folder,
                                    size: 64.0, color: kPrimaryColor),
                                const SizedBox(height: 16.0),
                                Text(
                                  folders[index].title,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  '${folders[index].topicIds.length} topics',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
