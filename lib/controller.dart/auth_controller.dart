import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔴 Yeh import sab se zaroori hai
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talal_todo/routes/route_names.dart';

class AuthController extends GetxController {
  // Poori app mein is controller ko access karne ke liye instance
  static AuthController instance = Get.find(); 
  
  final FirebaseAuth auth = FirebaseAuth.instance;
  
  // Loading state 
  var isLoading = false.obs;
final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 // ==========================================
  // SIGN UP FUNCTION (Fixed Navigation & Loading)
  // ==========================================
  Future<void> signUp(String name, String email, String password) async {
    try {
      // 🔴 Loading start karein taa ke UI mein spinner nazar aaye
      isLoading.value = true; 

      // 1. Firebase Auth mein account banayen
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // 2. User ka Name aur Email Firestore database mein save karein
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "Success", 
        "Account created successfully!", 
        backgroundColor: Colors.green.shade100, 
        colorText: Colors.green.shade900
      );
          
      // 🔴 FIX: Account banne ke baad Main Screen par automatically move kar dein
      Get.offAllNamed(RouteNames.mainscreen); 

    } catch (e) {
      Get.snackbar(
        "Error", 
        e.toString(), 
        backgroundColor: Colors.redAccent, 
        colorText: Colors.white
      );
    } finally {
      // 🔴 Loading khatam karein
      isLoading.value = false;
    }
  }
  Future<void> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      
      await auth.signInWithEmailAndPassword(email: email, password: password);
      
      Get.snackbar(
        "Success", 
        "Signed in successfully!",
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      Get.offAllNamed(RouteNames.mainscreen);
      
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Login Failed", 
        e.message ?? "Invalid email or password",
        backgroundColor: Colors.redAccent,
        colorText: Colors.redAccent,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }


 Future<void> forgetPassword(String email) async {
    try {
      isLoading.value = true;
      
      await auth.sendPasswordResetEmail(email: email);
      
      Get.snackbar(
        "Link Sent", 
        "Password reset link has been sent to your email!",
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Agar pehle se sign in page par hain toh dobara route push karne ki zaroorat nahi.
      // Lekin aap Get.back() kar sakte hain taa ke popup dialog band ho jaye.
      Get.back();
      
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Error", 
        e.message ?? "Could not send reset link",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white, // 🔴 Isko white kar diya taa ke parha jaye
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}