class UserInfo {
  String? mobile;
  String? countryCode;
  String? email;
  String? name;
  String? userId;
  String? profileUrl;
  String? rslId;
  String? profileImage;

  UserInfo({
    this.mobile = "",
    this.countryCode = "",
    this.email = "",
    this.name = "",
    this.userId = "",
    this.profileUrl = "",
    this.rslId = "",
    this.profileImage = "",
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mobile'] = this.mobile;
    data['countryCode'] = this.countryCode;
    data['email'] = this.email;
    data['name'] = this.name;
    data['userId'] = this.userId;
    data['profileUrl'] = this.profileUrl;
    data['rslId'] = this.rslId.toString();
    data['profile_image'] = this.profileImage;
    return data;
  }
}
