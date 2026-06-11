class ApiConfig {
  // Ganti IP ini dengan IP Address komputer server (komputer tempat XAMPP/Flask berjalan)
  // Untuk emulator Android berjalan di mesin yang sama, gunakan 10.0.2.2
  // Untuk web browser atau device fisik, gunakan IP Address jaringan (misal: 192.168.1.x)
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  static const String registerUrl = '$baseUrl/register';
  static const String loginUrl = '$baseUrl/login';
  static const String categoriesUrl = '$baseUrl/user/categories';
  static const String missionsUrl = '$baseUrl/missions';
  static const String startMissionUrl = '$baseUrl/missions/start';
  static const String checkinMissionUrl = '$baseUrl/missions/checkin';
}
