import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;


class StoreData {
  
  
 Future<String> uploadImageToStorage(String childName,Uint8List file) async {
 
if (FirebaseAuth.instance.currentUser == null) {
    print("No authenticated user available for uploading.");
} else {
    print("Authenticated user: ${FirebaseAuth.instance.currentUser!.uid}");
}
    Reference ref = _storage.ref().child(childName);
    
    UploadTask uploadTask = ref.putData(file);
    
    try {
    TaskSnapshot snapshot = await uploadTask;
    
    String downloadUrl = await snapshot.ref.getDownloadURL();
  
    return downloadUrl;
  } catch (e) {
    print("Upload failed: $e");
    return Future.error("Upload failed: $e");
  }
  }


  Future<String> saveData({required Uint8List file, required String uid}) async {
    
    final DocumentReference _firestore =
          FirebaseFirestore.instance.collection('users').doc(uid);
         
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
    
} else {
    
}
    
      String resp = "Some error occurred";
      try {

        
        String imageUrl = await uploadImageToStorage('profileImages/$uid', file);


       await _firestore.update({
            'profileImage': imageUrl
        }); 
        currentUser?.updatePhotoURL(imageUrl);

        return imageUrl;
       
      } catch(err) {
          resp = err.toString();
      }
      return resp;
  }

  
}
