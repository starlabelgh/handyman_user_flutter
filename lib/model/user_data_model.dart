class UserData {
  int? id;
  String? firstName;
  String? lastName;
  String? username;
  var providerId;
  int? status;
  String? description;
  String? userType;
  String? email;
  String? contactNumber;
  int? countryId;
  int? stateId;
  int? cityId;
  String? cityName;
  String? address;
  String? providerTypeId;
  String? providerType;
  int? isFeatured;
  String? displayName;
  String? createdAt;
  String? updatedAt;
  String? profileImage;
  String? timeZone;
  String? lastNotificationSeen;
  String? uid;
  String? loginType;
  int? serviceAddressId;
  num? providersServiceRating;
  num? handymanRating;
  int? isVerifyProvider;
  String? designation;
  String? apiToken;
  String? emailVerifiedAt;
  String? playerId;
  List<String>? userRole;
  HandymanReview? handymanReview;
  int? isUserExist;
  String? password;

  String? verificationId;
  String? otpCode;

  bool isSelected = false;

  UserData({
    this.address,
    this.apiToken,
    this.cityId,
    this.contactNumber,
    this.countryId,
    this.createdAt,
    this.displayName,
    this.email,
    this.emailVerifiedAt,
    this.firstName,
    this.id,
    this.isFeatured,
    this.lastName,
    this.playerId,
    this.description,
    this.providerType,
    this.cityName,
    this.providerId,
    this.providerTypeId,
    this.stateId,
    this.status,
    this.updatedAt,
    this.userRole,
    this.userType,
    this.username,
    this.profileImage,
    this.uid,
    this.handymanRating,
    this.handymanReview,
    this.lastNotificationSeen,
    this.loginType,
    this.providersServiceRating,
    this.serviceAddressId,
    this.timeZone,
    this.isVerifyProvider,
    this.isUserExist,
    this.password,
    this.designation,
    this.verificationId,
    this.otpCode,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      address: json['address'],
      apiToken: json['api_token'],
      cityId: json['city_id'],
      contactNumber: json['contact_number'],
      countryId: json['country_id'],
      createdAt: json['created_at'],
      displayName: json['display_name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      firstName: json['first_name'],
      id: json['id'],
      isFeatured: json['is_featured'],
      lastName: json['last_name'],
      playerId: json['player_id'],
      providerId: json['provider_id'],
      //providertype_id: json['providertype_id'],
      stateId: json['state_id'],
      status: json['status'],
      updatedAt: json['updated_at'],
      userRole: json['user_role'] != null ? new List<String>.from(json['user_role']) : null,
      userType: json['user_type'],
      username: json['username'],
      profileImage: json['profile_image'],
      uid: json['uid'],
      description: json['description'],
      providerType: json['providertype'],
      cityName: json['city_name'],
      loginType: json['login_type'],
      serviceAddressId: json['service_address_id'],
      lastNotificationSeen: json['last_notification_seen'],
      providersServiceRating: json['providers_service_rating'],
      handymanRating: json['handyman_rating'],
      handymanReview: json['handyman_review'] != null ? new HandymanReview.fromJson(json['handyman_review']) : null,
      timeZone: json['time_zone'],
      isVerifyProvider: json['is_verify_provider'],
      isUserExist: json['is_user_exist'],
      verificationId: json['verificationId'],
      designation: json['designation'],
      otpCode: json['otpCode'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['api_token'] = this.apiToken;
    data['city_id'] = this.cityId;
    data['contact_number'] = this.contactNumber;
    data['country_id'] = this.countryId;
    data['created_at'] = this.createdAt;
    data['display_name'] = this.displayName;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['first_name'] = this.firstName;
    data['id'] = this.id;
    data['is_featured'] = this.isFeatured;
    data['last_name'] = this.lastName;
    data['player_id'] = this.playerId;
    data['provider_id'] = this.providerId;
    data['providertype_id'] = this.providerTypeId;
    data['state_id'] = this.stateId;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['user_type'] = this.userType;
    data['username'] = this.username;
    data['profile_image'] = this.profileImage;
    data['uid'] = this.uid;
    data['description'] = this.description;
    data['providertype'] = this.providerType;
    data['city_name'] = this.cityName;
    if (this.userRole != null) {
      data['user_role'] = this.userRole;
    }
    data['time_zone'] = this.timeZone;
    data['uid'] = this.uid;
    data['login_type'] = this.loginType;
    data['service_address_id'] = this.serviceAddressId;
    data['last_notification_seen'] = this.lastNotificationSeen;
    data['providers_service_rating'] = this.providersServiceRating;
    data['handyman_rating'] = this.handymanRating;
    if (this.handymanReview != null) {
      data['handyman_review'] = this.handymanReview!.toJson();
    }
    data['is_verify_provider'] = this.isVerifyProvider;
    data['is_user_exist'] = this.isUserExist;
    data['designation'] = this.designation;
    data['verificationId'] = this.verificationId;
    data['otpCode'] = this.otpCode;

    return data;
  }
}

class HandymanReview {
  int? id;
  int? customerId;
  num? rating;
  String? review;
  int? serviceId;
  int? bookingId;
  int? handymanId;
  String? handymanName;
  String? handymanProfileImage;
  String? customerName;
  String? customerProfileImage;
  String? createdAt;

  HandymanReview(
      {this.id,
      this.customerId,
      this.rating,
      this.review,
      this.serviceId,
      this.bookingId,
      this.handymanId,
      this.handymanName,
      this.handymanProfileImage,
      this.customerName,
      this.customerProfileImage,
      this.createdAt});

  HandymanReview.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    rating = json['rating'];
    review = json['review'];
    serviceId = json['service_id'];
    bookingId = json['booking_id'];
    handymanId = json['handyman_id'];
    handymanName = json['handyman_name'];
    handymanProfileImage = json['handyman_profile_image'];
    customerName = json['customer_name'];
    customerProfileImage = json['customer_profile_image'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customer_id'] = this.customerId;
    data['rating'] = this.rating;
    data['review'] = this.review;
    data['service_id'] = this.serviceId;
    data['booking_id'] = this.bookingId;
    data['handyman_id'] = this.handymanId;
    data['handyman_name'] = this.handymanName;
    data['handyman_profile_image'] = this.handymanProfileImage;
    data['customer_name'] = this.customerName;
    data['customer_profile_image'] = this.customerProfileImage;
    data['created_at'] = this.createdAt;
    return data;
  }
}
