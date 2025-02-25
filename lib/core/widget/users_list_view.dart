import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../src/chat/provider/opened_chat_provider.dart';
import '../../src/profile/model/profile_model.dart';
import '../provider/theme_provider.dart';
import '../provider/users_provider.dart';
import 'async_view.dart';

class UsersListView extends ConsumerStatefulWidget {
  const UsersListView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UsersListViewState();
}

class _UsersListViewState extends ConsumerState<UsersListView> {
  final TextEditingController _searchController = TextEditingController();
  List<Profile> _filteredUsers = [];

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersProvider);
    final theme = ref.watch(themeProvider);
    final double screenWidth = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: screenWidth * 0.3,
          constraints: BoxConstraints(
            maxWidth: double.infinity,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: AsyncView(
            asyncValue: usersState,
            onData: (users) {
              // If no search has been performed, initialize _filteredUsers to the full list.
              if (_searchController.text.isEmpty && _filteredUsers.isEmpty) {
                _filteredUsers = users;
              }

              // Use the default list if the search yields no results.
              final displayUsers =
                  _filteredUsers.isEmpty ? users : _filteredUsers;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _filteredUsers = users
                              .where((user) => user.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Search users',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      itemCount: displayUsers.length,
                      itemBuilder: (context, index) {
                        final user = displayUsers[index];
                        return ListTile(
                          onTap: () {
                            ref.read(openedChatIdProvider.notifier).state =
                                user.id;
                            Navigator.pop(context);
                          },
                          leading: CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(user.photoUrl),
                          ),
                          title: Text(user.name),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
