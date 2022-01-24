class Upload {
  String file;
  String? password;
  int maxDownloads;
  String expireDate;
  String downloadUrl;
  String deleteUrl;
  String originalName;

  Upload(
    this.file,
    this.password,
    this.maxDownloads,
    this.expireDate,
    this.downloadUrl,
    this.deleteUrl,
    this.originalName,
  );
}

class FilePassword{
  String file;
  String password;
  FilePassword(this.file, this.password);
}
