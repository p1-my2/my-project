import 'download_helper_stub.dart'
    if (dart.library.html) 'download_helper_web.dart' as helper;

Future<void> downloadFile(List<int> bytes, String filename) async {
  await helper.saveAndDownloadFile(bytes, filename);
}
