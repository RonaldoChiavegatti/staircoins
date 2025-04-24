enum UserType { professor, aluno }

class User {
  final String id;
  final String name;
  final String email;
  final UserType type;
  final String tipo; // 'professor' ou 'aluno'
  final int? coins;
  final int staircoins;
  final List<String> turmas;

  String get nome => name;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    String? tipo,
    this.coins,
    this.staircoins = 0,
    this.turmas = const [],
  }) : this.tipo = tipo ?? (type == UserType.professor ? 'professor' : 'aluno');

  factory User.fromJson(Map<String, dynamic> json) {
    final userType = json['type'] == 'professor' ? UserType.professor : UserType.aluno;
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      type: userType,
      tipo: json['tipo'], // Opcional, será gerado automaticamente se não existir
      coins: json['coins'],
      staircoins: json['staircoins'] ?? 0,
      turmas: json['turmas'] != null
          ? List<String>.from(json['turmas'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type == UserType.professor ? 'professor' : 'aluno',
      'tipo': tipo,
      'coins': coins,
      'staircoins': staircoins,
      'turmas': turmas,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserType? type,
    String? tipo,
    int? coins,
    int? staircoins,
    List<String>? turmas,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      type: type ?? this.type,
      tipo: tipo ?? this.tipo,
      coins: coins ?? this.coins,
      staircoins: staircoins ?? this.staircoins,
      turmas: turmas ?? this.turmas,
    );
  }
}
