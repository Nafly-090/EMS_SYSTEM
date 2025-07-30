
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'edit_employee_screen.dart';
import 'colors.dart';
import 'employee_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // THIS IS THE KEY: We check if the keyboard is visible.
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: kPrimaryBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 24.0),
                decoration: const BoxDecoration(
                  color: kLightBgColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopEmployeeHeader(),
                    const SizedBox(height: 16),
                    _EmployeeList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // --- FIX #1: Conditionally hide the FloatingActionButton ---
      // If the keyboard is visible, the FAB will be null (hidden).
      floatingActionButton: isKeyboardVisible
          ? null
          : FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/AddnewEmy');
        },
        backgroundColor: kPrimaryBlue,
        // FIX #2: The default shape is a circle. This code creates a perfect circle.
        shape: const CircleBorder(), // Explicitly define the shape as a circle.
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // --- FIX #1: Conditionally hide the BottomNavigationBar ---
      // If the keyboard is visible, the bottom navigation bar will be null (hidden).
      bottomNavigationBar: isKeyboardVisible ? null : _BottomNavBar(),
    );
  }
}

// --- HEADER WIDGET (No changes) ---
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EMS System',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: kWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: kWhite, size: 28),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              filled: true,
              fillColor: kWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ],
      ),
    );
  }
}

// --- "TOP EMPLOY" HEADER WIDGET (No changes) ---
class _TopEmployeeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Top Employ',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: kDarkBlue,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kDarkBlue.withOpacity(0.5), width: 1.5),
            ),
            child: const Icon(Icons.circle_outlined, size: 10, color: Colors.transparent),
          ),
        ],
      ),
    );
  }
}

// --- EMPLOYEE LIST WIDGET (No changes) ---
class _EmployeeList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Employee').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No employees found.'));
          }
          final employees = snapshot.data!.docs.map((doc) => Employee.fromFirestore(doc)).toList();
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              return EmployeeCard(employee: employees[index]);
            },
          );
        },
      ),
    );
  }
}



class EmployeeCard extends StatelessWidget {
  final Employee employee;
  const EmployeeCard({super.key, required this.employee});

  Future<void> _deleteEmployee(BuildContext context, String employeeId) async {
    try {
      // Get the document reference and delete it
      await FirebaseFirestore.instance.collection('Employee').doc(employeeId).delete();

      // Show a success message
      // Use mounted check for safety in async gaps
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show an error message if something goes wrong
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete employee: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- CONFIRMATION DIALOG ---
  // This method shows the confirmation dialog before deleting.
  Future<void> _showDeleteConfirmationDialog(BuildContext context, String employeeId, String employeeName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: kDarkBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          title: Text(
            'Confirm Deletion',
            style: TextStyle(
              color: kWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                  'Are you sure you want to delete $employeeName?',
                  style: TextStyle(color: kWhite, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'This action cannot be undone.',
                  style: TextStyle(color: kGreyText, fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: kPrimaryBlue,
                backgroundColor: kTextFieldBackground.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: kWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteEmployee(context, employeeId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy.MM.dd').format(employee.joiningDate.toDate());

    return InkWell(
      onLongPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditEmployeeScreen(employee: employee),
          ),
        );
      },
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Card(
        color: kDarkBlue,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: kWhite,
                child: Icon(Icons.person, size: 36, color: kDarkBlue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(employee.name, style: const TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(employee.role, style: const TextStyle(color: kWhite, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(employee.department, style: const TextStyle(color: kGreyText, fontSize: 12)),
                          Text(employee.email, style: const TextStyle(color: kGreyText, fontSize: 12)),
                        ],
                      ),
                    ),
                    // --- THIS IS THE MODIFIED PART ---
                    Positioned(
                      top: -12, // Adjust position to align with tap area
                      right: -12, // Adjust position to align with tap area
                      child: IconButton(
                        icon: const Icon(Icons.more_horiz, color: kWhite),
                        onPressed: () {
                          // Call the confirmation dialog when the button is pressed
                          _showDeleteConfirmationDialog(context, employee.id, employee.name);
                        },
                      ),
                    ),
                    // --- END OF MODIFIED PART ---
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formattedDate, style: const TextStyle(color: kGreyText, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(employee.phone, style: const TextStyle(color: kGreyText, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showSignOutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: kDarkBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          title: Text(
            'Confirm Sign Out',
            style: TextStyle(
              color: kWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                  'Are you sure you want to sign out?',
                  style: TextStyle(color: kWhite, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'You will need to log in again to access your account.',
                  style: TextStyle(color: kGreyText, fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: kPrimaryBlue,
                backgroundColor: kTextFieldBackground.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: kWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _signOut(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: kWhite,
      elevation: 10.0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: kPrimaryBlue, size: 30),
              onPressed: () {},
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: const Icon(Icons.person_outline, color: kPrimaryBlue, size: 30),
              onPressed: () {
                _showSignOutConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}