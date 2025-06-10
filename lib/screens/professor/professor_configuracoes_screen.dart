import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class ProfessorConfiguracoesScreen extends StatefulWidget {
  const ProfessorConfiguracoesScreen({super.key});

  @override
  _ProfessorConfiguracoesScreenState createState() =>
      _ProfessorConfiguracoesScreenState();
}

class _ProfessorConfiguracoesScreenState
    extends State<ProfessorConfiguracoesScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _senhaController;

  File? _image;
  Uint8List? _imageBytes;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    _nomeController = TextEditingController(text: user?.nome ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _senhaController =
        TextEditingController(); // Password should not be pre-filled
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _salvarAlteracoes() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement saving changes (update user data in AuthProvider/backend)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Alterações salvas! (Funcionalidade a ser implementada)')),
      );
      // Navigator.pop(context); // Optionally pop after saving
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Pedir permissões APENAS se não for web
    PermissionStatus status = PermissionStatus.granted;
    if (!kIsWeb) {
      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
      } else {
        status = await Permission.photos.request();
      }
    }

    if (status.isGranted) {
      try {
        final pickedFile =
            await ImagePicker().pickImage(source: source, imageQuality: 80);

        if (pickedFile != null) {
          Uint8List? tempImageBytes;
          if (kIsWeb) {
            tempImageBytes = await pickedFile.readAsBytes();
          }

          setState(() {
            if (kIsWeb) {
              _imageBytes = tempImageBytes;
              _image = null;
            } else {
              _image = File(pickedFile.path);
              _imageBytes = null;
            }
            _isLoadingImage = true;
          });

          // Fazer upload da imagem
          final success = kIsWeb
              ? await authProvider.uploadProfilePicture(
                  fileBytes: tempImageBytes)
              : await authProvider.uploadProfilePicture(
                  filePath: pickedFile.path);

          if (success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Foto de perfil atualizada com sucesso!')),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Erro ao atualizar foto de perfil: ${authProvider.errorMessage ?? 'Erro desconhecido'}')),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nenhuma imagem selecionada.')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Erro ao selecionar ou fazer upload da imagem: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoadingImage = false;
        });
      }
    } else if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Permissão ${source == ImageSource.camera ? 'da câmera' : 'da galeria'} negada.')),
        );
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Permissão negada permanentemente. Por favor, habilite nas configurações do app.')),
        );
        openAppSettings(); // Abrir configurações do app para o usuário habilitar a permissão
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Define a imagem de fundo para o CircleAvatar
    ImageProvider<Object>? avatarImage;
    if (_image != null) {
      avatarImage = FileImage(_image!);
    } else if (_imageBytes != null && kIsWeb) {
      avatarImage = MemoryImage(_imageBytes!);
    } else if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
      avatarImage = NetworkImage(user.photoUrl!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Perfil'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: avatarImage,
                    child: _isLoadingImage
                        ? const CircularProgressIndicator(
                            color: AppTheme.primaryColor)
                        : ((_image == null &&
                                _imageBytes == null &&
                                (user?.photoUrl == null ||
                                    user!.photoUrl!.isEmpty))
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[600],
                              )
                            : null),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Tirar Foto'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.camera);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.image),
                                    title: const Text('Escolher da Galeria'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.gallery);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primaryColor,
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Login (Email)'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email';
                  }
                  // Basic email format validation
                  if (!value.contains('@')) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarAlteracoes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Salvar Alterações',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
