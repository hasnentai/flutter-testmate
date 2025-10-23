import 'package:flutter/material.dart';

class TaxpayerFormScreen extends StatefulWidget {
  const TaxpayerFormScreen({super.key});

  @override
  State<TaxpayerFormScreen> createState() => _TaxpayerFormScreenState();
}

class _TaxpayerFormScreenState extends State<TaxpayerFormScreen> {
  final _panController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  
  bool _showPanError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Dashboard', style: TextStyle(color: Color(0xFF5B7FDB), fontSize: 14)),
                    Text('  >  ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    Text('Register', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
         
               
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F0FE),
                    border: Border.all(color: Color(0xFF5B7FDB), width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF5B7FDB), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('1. The entered details should be as per DL database.', style: TextStyle(color: Color(0xFF5B7FDB), fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('2. There are 3 attempts to enter correct details.', style: TextStyle(color: Color(0xFF5B7FDB), fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildFieldLabel('Enter DL Name', isRequired: true),
                const SizedBox(height: 8),
                _buildTextField(_panController, 'Enter DL of Name', hasError: _showPanError),
                if (_showPanError) ...[
                  const SizedBox(height: 4),
                  Text('Invalid DL, please re-enter', style: TextStyle(color: Color(0xFFD32F2F), fontSize: 12)),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('First Name'),
                          const SizedBox(height: 8),
                          _buildTextField(_firstNameController, 'Enter First Name'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Middle Name'),
                          const SizedBox(height: 8),
                          _buildTextField(_middleNameController, 'Enter Middle Name'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Last Name', isRequired: true),
                          const SizedBox(height: 8),
                          _buildTextField(_lastNameController, 'Enter Last Name'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFieldLabel('Date of Birth/ Date of Incorporation', isRequired: true),
                const SizedBox(height: 8),
                _buildTextField(_dobController, 'Enter Date of Birth/ Incorporation', suffixIcon: Icons.calendar_today, onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    _dobController.text = '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                  }
                }),
                const SizedBox(height: 24),
                _buildFieldLabel('Verification Code', isRequired: true),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 200,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text('mwxe2', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 4, color: Colors.black87)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFBDBDBD)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(Icons.volume_up, color: Colors.grey[700], size: 20),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFBDBDBD)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(Icons.refresh, color: Colors.grey[700], size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(width: 400, child: _buildTextField(_verificationCodeController, 'Enter Verification Code')),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_back, size: 16),
                      label: Text('Back'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF5B7FDB),
                        side: BorderSide(color: Color(0xFF5B7FDB)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showPanError = true;
                        });
                      },
                      label: Text('Proceed'),
                      icon: Icon(Icons.arrow_forward, size: 16),
                      iconAlignment: IconAlignment.end,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF9E9E9E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Text.rich(
      TextSpan(
        text: label,
        style: TextStyle(fontSize: 14, color: Colors.black87),
        children: [
          if (isRequired) TextSpan(text: ' *', style: TextStyle(color: Color(0xFFD32F2F))),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String placeholder, {bool hasError = false, IconData? suffixIcon, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      readOnly: onTap != null,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: hasError ? Color(0xFFD32F2F) : Color(0xFFBDBDBD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: hasError ? Color(0xFFD32F2F) : Color(0xFFBDBDBD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: hasError ? Color(0xFFD32F2F) : Color(0xFF5B7FDB), width: 2),
        ),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey[600], size: 18) : null,
      ),
    );
  }

  @override
  void dispose() {
    _panController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }
}
