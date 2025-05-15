import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/widgets/custom_app_bar.dart';
import 'package:meal_saver_phone/widgets/custom_bottom_bar.dart';
import 'package:meal_saver_phone/widgets/custom_button1.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final nameController = TextEditingController();
  final sizeController = TextEditingController();
  String selectedUnit = "g";
  DateTime? selectedDate;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.deepPurpleAccent,
              surface: Color.fromARGB(255, 22, 22, 22),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an expiration date.")),
      );
      return;
    }

    setState(() => isLoading = true);

    double sizeInput = double.parse(sizeController.text.trim());
    int sizeInGrams =
        selectedUnit == "kg" ? (sizeInput * 1000).round() : sizeInput.round();

    final response = await ApiService().addFood(
      name: nameController.text.trim(),
      size: sizeInGrams,
      expirationDate: selectedDate!.toIso8601String(),
    );

    setState(() => isLoading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(response)));

    if (response.toLowerCase().contains("success")) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      appBar: const CustomAppBar(title: 'Add Food'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildIconInput(
                icon: Icons.fastfood,
                label: "Food item name",
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Name is required";
                  if (value.length < 3) {
                    return "Name must be at least 3 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  const Icon(Icons.scale, color: Colors.white),
                  const SizedBox(width: 10),
                  const Text(
                    "Size",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildIconInput(
                      icon: Icons.numbers,
                      label: "Amount",
                      controller: sizeController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Size is required";
                        }
                        final number = double.tryParse(value);
                        if (number == null || number <= 0) {
                          return "Enter a valid number > 0";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 33, 33, 33),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButton<String>(
                      dropdownColor: const Color.fromARGB(255, 33, 33, 33),
                      value: selectedUnit,
                      underline: Container(),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedUnit = newValue!;
                        });
                      },
                      items:
                          <String>['g', 'kg'].map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.toUpperCase()),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white),
                  const SizedBox(width: 10),
                  const Text(
                    "Expiration Date",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      selectedDate == null
                          ? "Select date"
                          : DateFormat.yMMMd().format(selectedDate!),
                      style: const TextStyle(color: Colors.deepPurpleAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              CustomButton1(
                text: isLoading ? "Saving..." : "Save item",
                onPressed: isLoading ? null : _saveItem,
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : null,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildIconInput({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 33, 33, 33),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}
