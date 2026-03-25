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
      // backgroundColor: Colors.white, -> حذف شد
      appBar: AppBar(
        // backgroundColor: Colors.white, -> حذف شد
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'گروه جدید',
          style: TextStyle(fontFamily: 'cr', fontSize: 18), // رنگ مشکی حذف شد
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed:
                  _selectedUsers.isEmpty || _groupNameController.text.isEmpty
                  ? null
                  : () {
                      // عملیات ساخت گروه
                    },
              child: Text(
                'ساخت',
                style: TextStyle(
                  fontFamily: 'cr',
                  color:
                      _selectedUsers.isEmpty ||
                          _groupNameController.text.isEmpty
                      ? Colors.grey
                      : const Color.fromARGB(255, 14, 208, 211), // رنگ اصلی اپلیکیشن شما
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
                  onTap: () {},
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color.fromARGB(255, 14, 208, 211).withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color.fromARGB(255, 14, 208, 211),
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
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
                          borderSide: BorderSide(color: Color.fromARGB(255, 14, 208, 211)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_selectedUsers.isNotEmpty)
            // ... (بخش کاربران انتخاب شده تغییری نیاز نداشت)
            Container( /* ... */ ),

          const Divider(),

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
                    color: isSelected ? const Color.fromARGB(255, 14, 208, 211) : Colors.grey,
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
