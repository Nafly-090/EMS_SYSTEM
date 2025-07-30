import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'employee_model.dart';

class EditEmployeeScreen extends StatefulWidget {
  final Employee employee;

  const EditEmployeeScreen({super.key, required this.employee});

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _departmentController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee.name);
    _roleController = TextEditingController(text: widget.employee.role);
    _departmentController = TextEditingController(text: widget.employee.department);
    _emailController = TextEditingController(text: widget.employee.email);
    _phoneController = TextEditingController(text: widget.employee.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('Employee')
          .doc(widget.employee.id);

      await docRef.update({
        'name': _nameController.text,
        'role': _roleController.text,
        'department': _departmentController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update employee: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBlue,
      appBar: AppBar(
        title: const Text(
          'Edit Employee',
          style: TextStyle(color: kWhite, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Employee Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kWhite,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                color: kTextFieldBackground.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Name',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _roleController,
                        label: 'Role',
                        icon: Icons.work,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _departmentController,
                        label: 'Department',
                        icon: Icons.business,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateEmployee,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBlue,
                  foregroundColor: kWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Update Employee',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: kWhite),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kGreyText),
        prefixIcon: Icon(icon, color: kGreyText),
        filled: true,
        fillColor: kTextFieldBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a $label';
        }
        return null;
      },
    );
  }
}