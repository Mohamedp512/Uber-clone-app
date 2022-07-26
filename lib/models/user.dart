

class CustomUser{
  String id;
  String fullName;
  String phone;
  String email;

  CustomUser.fromJson(Map<String, dynamic> jsonData){
    fullName=jsonData['name'];
    email=jsonData['email'];
    phone=jsonData['phone'];    
  }
}