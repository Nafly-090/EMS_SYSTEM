// home.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        onPressed: () {},
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
                'ESM System',
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

// --- EMPLOYEE CARD WIDGET (Using the correct Stack version) ---
class EmployeeCard extends StatelessWidget {
  final Employee employee;
  const EmployeeCard({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy.MM.dd').format(employee.joiningDate.toDate());
    return Card(
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
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(Icons.more_horiz, color: kWhite),
                  ),
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
    );
  }
}

// --- BOTTOM NAVIGATION BAR WIDGET (No changes) ---
class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: kLightBgColor,
      elevation: 10.0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home_outlined, color: kPrimaryBlue, size: 30),
              onPressed: () {},
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: const Icon(Icons.person_outline, color: kPrimaryBlue, size: 30),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}