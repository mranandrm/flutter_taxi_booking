import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/AuthProvider.dart';
import 'package:image_picker/image_picker.dart';


class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final provider = context.read<AuthProvider>();
    await provider.loadUser();

    final user = provider.user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  String getAvatarUrl(AuthProvider provider) {
    if (_pickedImage != null) return "";
    return provider.user?.avatar ?? "";
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    final fields = {
      "name": _nameController.text,
      "email": _emailController.text,
    };

    if (_passwordController.text.isNotEmpty) {
      fields["password"] = _passwordController.text;
    }

    final res = await auth.updateProfile(fields);

    if (res["error"] != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res["error"])));
      return;
    }

    // upload image
    if (_pickedImage != null) {
      await auth.uploadProfilePic(_pickedImage!);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    final avatarUrl = getAvatarUrl(provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.green,
      ),
      body: provider.user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!)
                      : NetworkImage(avatarUrl) as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter email" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "New Password (optional)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Update Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _updateProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
