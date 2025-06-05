import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum UserType { professor, aluno }

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserType type;
  final String tipo; // 'professor' ou 'aluno'
  final int staircoins;
  final List<String> turmas;
  final DateTime? createdAt;

  String get nome => name;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    String? tipo,
    this.staircoins = 0,
    this.turmas = const [],
    this.createdAt,
  }) : tipo = tipo ?? (type == UserType.professor ? 'professor' : 'aluno');

  factory User.fromJson(Map<String, dynamic> json) {
    final userType = json['type'] == 'professor' ? UserType.professor : UserType.aluno;
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      type: userType,
      tipo: json['tipo'], // Opcional, será gerado automaticamente se não existir
      staircoins: json['staircoins'] ?? 0,
      turmas: json['turmas'] != null
          ? List<String>.from(json['turmas'])
          : [],
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] is Timestamp 
              ? (json['createdAt'] as Timestamp).toDate() 
              : DateTime.parse(json['createdAt'].toString()))
          : null,
    );
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final userType = data['tipo'] == 'professor' ? UserType.professor : UserType.aluno;
    
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      type: userType,
      tipo: data['tipo'],
      staircoins: data['staircoins'] ?? 0,
      turmas: data['turmas'] != null 
          ? List<String>.from(data['turmas']) 
          : [],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type == UserType.professor ? 'professor' : 'aluno',
      'tipo': tipo,
      'staircoins': staircoins,
      'turmas': turmas,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'tipo': tipo,
      'staircoins': staircoins,
      'turmas': turmas,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserType? type,
    String? tipo,
    int? staircoins,
    List<String>? turmas,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      type: type ?? this.type,
      tipo: tipo ?? this.tipo,
      staircoins: staircoins ?? this.staircoins,
      turmas: turmas ?? this.turmas,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id, 
    name, 
    email, 
    type, 
    tipo, 
    staircoins, 
    turmas,
    createdAt
  ];
}
