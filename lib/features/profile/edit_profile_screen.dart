import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';
import 'package:nexmart/core/constants/app_strings.dart';
import 'package:nexmart/providers/user_provider.dart';
import 'package:nexmart/services/user_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  bool isLoading = false;

  Future<void> _saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Name cannot be empty')));
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await UserService().updateUserProfile(
        userId,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
      );

      if (!mounted) {
        return;
      }
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.profileUpdated)));
    } catch (e) {
      debugPrint('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.somethingWentWrong)));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final user = ref.read(userDataProvider).value;
    nameController = TextEditingController(text: user?.name ?? '');
    phoneController = TextEditingController(text: user?.phone ?? '');
    addressController = TextEditingController(text: user?.address ?? '');

    // Listen for late-arriving data and backfill the controllers
    ref.listenManual(userDataProvider, (previous, next) {
      final freshUser = next.value;
      if (freshUser != null && nameController.text.isEmpty) {
        nameController.text = freshUser.name;
        phoneController.text = freshUser.phone;
        addressController.text = freshUser.address;
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.white),
        title: Text(
          AppStrings.editProfile,
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: AppStrings.name, prefixIcon: Icon(Icons.person_outline_rounded)),
            ),

            SizedBox(height: AppSizes.md),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: AppStrings.phoneNumber, prefixIcon: Icon(Icons.phone_outlined)),
            ),

            SizedBox(height: AppSizes.md),

            TextField(
              controller: addressController,
              maxLines: 1,
              decoration: InputDecoration(labelText: AppStrings.address, prefixIcon: Icon(Icons.location_on_outlined)),
            ),

            SizedBox(height: AppSizes.xl),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _saveProfile(),
                child: isLoading ? CircularProgressIndicator(color: AppColors.white) : Text(AppStrings.saveChanges),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
