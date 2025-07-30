import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String id;
  final String name;
  final String role;
  final String department;
  final String email;
  final String phone;
  final Timestamp joiningDate;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.email,
    required this.phone,
    required this.joiningDate,
  });

  // Factory constructor to create an Employee instance from a Firestore document
  factory Employee.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Employee(
      id: doc.id,
      name: data['name'] ?? 'No Name',
      role: data['role'] ?? 'No Role',
      department: data['department'] ?? 'No Department',
      email: data['email'] ?? 'No Email',
      phone: data['phone'] ?? 'No Phone',
      // Ensure you handle the timestamp correctly
      joiningDate: data['joining_date'] ?? Timestamp.now(),
    );
  }
}