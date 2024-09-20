class User {
  String userID;
  String userName;
  String namaDepan;
  String gelar;
  String namaBelakang;
  String namaLengkap;
  String passwd;
  String alamat1Line1;
  String alamat1Line2;
  String noTelepon;
  String noHP;
  String email;
  bool isActive;
  bool isDeleted;
  String nik;
  String nip;
  String jabatan;
  List<String> pRole;

  User({
    required this.userID,
    required this.userName,
    required this.namaDepan,
    required this.gelar,
    required this.namaBelakang,
    required this.namaLengkap,
    required this.passwd,
    required this.alamat1Line1,
    required this.alamat1Line2,
    required this.noTelepon,
    required this.noHP,
    required this.email,
    required this.isActive,
    required this.isDeleted,
    required this.nik,
    required this.nip,
    required this.jabatan,
    required this.pRole,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: json['UserID'],
      userName: json['UserName'],
      namaDepan: json['NamaDepan'],
      gelar: json['Gelar'],
      namaBelakang: json['NamaBelakang'],
      namaLengkap: json['NamaLengkap'],
      passwd: json['Passwd'],
      alamat1Line1: json['Alamat1Line1'],
      alamat1Line2: json['Alamat1Line2'],
      noTelepon: json['NoTelepon'],
      noHP: json['NoHP'],
      email: json['Email'],
      isActive: json['IsActive'],
      isDeleted: json['IsDeleted'],
      nik: json['Nik'],
      nip: json['NIP'],
      jabatan: json['Jabatan'],
      pRole: List<String>.from(json['pRole']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserID': userID,
      'UserName': userName,
      'NamaDepan': namaDepan,
      'Gelar': gelar,
      'NamaBelakang': namaBelakang,
      'NamaLengkap': namaLengkap,
      'Passwd': passwd,
      'Alamat1Line1': alamat1Line1,
      'Alamat1Line2': alamat1Line2,
      'NoTelepon': noTelepon,
      'NoHP': noHP,
      'Email': email,
      'IsActive': isActive,
      'IsDeleted': isDeleted,
      'Nik': nik,
      'NIP': nip,
      'Jabatan': jabatan,
      'pRole': pRole,
    };
  }
}
