import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class UploadService {
  Future<Map<String, dynamic>> uploadDataset() async {
    // Pick CSV file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['csv'],
  withData: true,
);

    if (result == null) {
      throw Exception("No file selected.");
    }

    final PlatformFile file = result.files.first;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("User is not logged in.");
    }

    final request = http.MultipartRequest(
  "POST",
  Uri.parse("${ApiConfig.baseUrl}/datasets/upload"),
);

    request.headers["Authorization"] = "Bearer $token";

    // Use bytes for Web, path for Mobile/Desktop
    if (file.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          file.bytes!,
          filename: file.name,
        ),
      );
    } else if (file.path != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          file.path!,
        ),
      );
    } else {
      throw Exception("Unable to read selected file.");
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Upload failed.");
    }
  }
}
