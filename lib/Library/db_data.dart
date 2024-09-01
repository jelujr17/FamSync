import 'package:mysql1/mysql1.dart';

class DB {
  Future<MySqlConnection> conexion() async {
    MySqlConnection conn;
    try {
      conn = await MySqlConnection.connect(ConnectionSettings(
        host: 'localhost',
        port: 3306,
        user: 'root',
        password: 'root',
        db: 'smart_family',
      ));
    } catch (e) {
      conn = await MySqlConnection.connect(ConnectionSettings(
        host: '192.168.0.102',
        port: 3306,
        user: 'root',
        password: 'root',
        db: 'smart_family',
      ));
    }
    return conn;
  }
}
