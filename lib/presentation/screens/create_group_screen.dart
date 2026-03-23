import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  static String get routeName => 'CreateGroupScreen';

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final List<String> _selectedUsers = [];

  final List<Map<String, String>> _contacts = [
    {'name': 'علی رضایی', 'id': 'ali_123'},
    {'name': 'سارا محمدی', 'id': 'sara_m'},
    {'name': 'رضا علوی', 'id': 'reza_aa'},
    {'name': 'مریم اکبری', 'id': 'maryam_akb'},
    {'name': 'امیر حسین', 'id': 'amir_h'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'گروه جدید',
          style: TextStyle(fontFamily: 'cr', color: Colors.black, fontSize: 18),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
        ),
        actions: [
          // دکمه تایید نهایی
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed:
                  _selectedUsers.isEmpty || _groupNameController.text.isEmpty
                  ? null
                  : () {
                      // عملیات ساخت گروه در Bloc
                    },
              child: Text(
                'ساخت',
                style: TextStyle(
                  fontFamily: 'cr',
                  color:
                      _selectedUsers.isEmpty ||
                          _groupNameController.text.isEmpty
                      ? Colors.grey
                      : Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                  },
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // فیلد نام گروه
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextField(
                      controller: _groupNameController,
                      onChanged: (value) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'نام گروه را وارد کنید...',
                        hintStyle: TextStyle(fontFamily: 'cr', fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // بخش دوم: نمایش کاربران انتخاب شده (Horizontal List)
          if (_selectedUsers.isNotEmpty)
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedUsers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(
                                'https://via.placeholder.com/150',
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedUsers.removeAt(index);
                                  });
                                },
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _selectedUsers[index].split(
                            '_',
                          )[0], // نمایش بخشی از آیدی
                          style: const TextStyle(
                            fontFamily: 'cr',
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          const Divider(),

          // بخش سوم: لیست مخاطبین برای انتخاب
          Expanded(
            child: ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final user = _contacts[index];
                final isSelected = _selectedUsers.contains(user['id']);

                return ListTile(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedUsers.remove(user['id']);
                      } else {
                        _selectedUsers.add(user['id']!);
                      }
                    });
                  },
                  leading: const CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150',
                    ),
                  ),
                  title: Text(
                    user['name']!,
                    style: const TextStyle(fontFamily: 'cr'),
                  ),
                  subtitle: Text(
                    '@${user['id']}',
                    style: const TextStyle(fontFamily: 'cr', fontSize: 12),
                  ),
                  trailing: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
