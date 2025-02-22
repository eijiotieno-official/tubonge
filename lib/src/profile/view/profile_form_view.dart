import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/controller/upload_media_controller.dart';
import '../../../core/provider/is_url_provider.dart';
import '../../../core/provider/media_picker_provider.dart';
import '../../../core/widget/error_message_view.dart';
import '../controller/update_profile_controller.dart';
import '../model/profile_model.dart';
import 'photo_view.dart';

class ProfileFormView extends ConsumerStatefulWidget {
  final Profile profile;
  const ProfileFormView({
    super.key,
    required this.profile,
  });

  @override
  ConsumerState<ProfileFormView> createState() => _CreateProfileFormState();
}

class _CreateProfileFormState extends ConsumerState<ProfileFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();

  late Profile _profile;
  PlatformFile? platformFile;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _nameController =
        TextEditingController.fromValue(TextEditingValue(text: _profile.name));
  }

  Future<void> _pickImage() async {
    await ref.read(filePickerProvider.notifier).call(type: FileType.image);

    final filePickerState = ref.read(filePickerProvider);

    filePickerState.whenData(
      (platformFiles) {
        platformFile = platformFiles.isNotEmpty ? platformFiles.first : null;

        if (platformFile != null) {
          setState(() {
            _profile = _profile.copyWith(photoUrl: platformFile!.name);
          });
        }
      },
    );
  }

  String? _nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  Future<void> _handleSubmit(PlatformFile? file) async {
    if (!mounted) return;

    // If the profile exists
    if (_profile.isNotEmpty) {
      final isValidUrl = ref.read(isUrlProvider)(_profile.photoUrl);

      final bool shouldUpload = file != null;

      if (!shouldUpload && isValidUrl) {
        // No new file and existing photoUrl is already a valid URL → just update the profile
        final updateNotifier = ref.read(updateProfileProvider.notifier);
        await updateNotifier.call(_profile);
        return;
      }

      if (shouldUpload) {
        // Upload the file
        final uploadMediaNotifier =
            ref.read(uploadMediaProvider(file).notifier);
        await uploadMediaNotifier.upload();

        if (!mounted) return;

        // Get the uploaded media state
        final uploadMediaState = ref.read(uploadMediaProvider(file));

        // Wait for upload completion
        uploadMediaState.whenData(
          (mediaUpload) async {
            if (mediaUpload.state == MediaUploadState.success) {
              if (!mounted) return;

              // Update the profile with new photo URL
              setState(() {
                _profile = _profile.copyWith(photoUrl: mediaUpload.downloadUrl);
              });

              if (!mounted) return;

              // Update profile on the backend
              final updateNotifier = ref.read(updateProfileProvider.notifier);
              await updateNotifier.call(_profile);

              if (!mounted) return;

              // Clear selected file
              ref.read(filePickerProvider.notifier).clear();
            }
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final updateState = ref.watch(updateProfileProvider);

    final filePickerState = ref.watch(filePickerProvider);

    final platformFiles = filePickerState.value ?? [];

    platformFile = platformFiles.isNotEmpty ? platformFiles.first : null;

    final mediaUploadState = platformFile != null
        ? ref.watch(uploadMediaProvider(platformFile))
        : AsyncValue.data(MediaUpload.empty);

    isLoading = updateState.isLoading || mediaUploadState.isLoading;

    errorMessage =
        updateState.error?.toString() ?? mediaUploadState.error?.toString();

    return Material(
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.0),
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          child: SizedBox(
            width: screenWidth * 0.3,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PhotoView(
                      onPickImage: _pickImage,
                      platformFile: platformFile,
                      photoUrl: ref.read(isUrlProvider)(_profile.photoUrl)
                          ? _profile.photoUrl
                          : null,
                    ),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      enabled: !isLoading,
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      validator: _nameValidator,
                      decoration: const InputDecoration(
                        labelText: "Name",
                      ),
                      onChanged: (value) {
                        setState(() {
                          _profile = _profile.copyWith(name: value);
                        });
                      },
                    ),
                    const SizedBox(height: 24.0),
                    ErrorMessageView(errorMessage: errorMessage),
                    const SizedBox(height: 24.0),
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                        ),
                      )
                    else
                      FilledButton(
                        onPressed: () => _handleSubmit(platformFile),
                        child: const Text(
                          "Submit",
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
