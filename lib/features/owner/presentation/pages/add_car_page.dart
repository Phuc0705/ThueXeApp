import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedType = 'Sedan';
  
  XFile? _carImage;
  XFile? _documentImage;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isDocument) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isDocument) {
          _documentImage = image;
        } else {
          _carImage = image;
        }
      });
    }
  }

  Future<void> _submitCar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_carImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ảnh xe')));
      return;
    }
    if (_documentImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng tải lên giấy tờ xe (eKYC)')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Bạn chưa đăng nhập!');

      // Upload ảnh xe
      final carExt = _carImage!.path.split('.').last;
      final carFileName = 'car_${DateTime.now().millisecondsSinceEpoch}.$carExt';
      final carBytes = await _carImage!.readAsBytes();
      await supabase.storage.from('cars').uploadBinary(carFileName, carBytes);
      final carUrl = supabase.storage.from('cars').getPublicUrl(carFileName);

      // Upload giấy tờ xe
      final docExt = _documentImage!.path.split('.').last;
      final docFileName = 'doc_${DateTime.now().millisecondsSinceEpoch}.$docExt';
      final docBytes = await _documentImage!.readAsBytes();
      await supabase.storage.from('cars').uploadBinary(docFileName, docBytes);
      final docUrl = supabase.storage.from('cars').getPublicUrl(docFileName);

      // Insert vào bảng cars
      await supabase.from('cars').insert({
        'owner_id': userId,
        'name': _nameController.text,
        'brand': _brandController.text,
        'type': _selectedType,
        'price_per_day': double.parse(_priceController.text),
        'image_urls': [carUrl], // Mảng chứa URL ảnh xe
        // 'document_urls': [docUrl], // Tạm comment lại để tránh lỗi nếu chưa tạo cột trên Supabase
        'status': 'available', // Cho phép hiển thị luôn để dễ test
        'fuel_type': 'Xăng', 
        'transmission': 'Số tự động',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký xe thành công!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Widget _buildImagePicker(String title, XFile? file, bool isDocument) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickImage(isDocument),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[400]!),
            ),
            child: file != null
                ? (kIsWeb 
                    ? Image.network(file.path, fit: BoxFit.cover) 
                    : Image.file(File(file.path), fit: BoxFit.cover))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                      Text('Nhấn để chọn ảnh', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký xe cho thuê')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thông tin xe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên xe (ví dụ: Mercedes C200)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên xe' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Hãng xe', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Loại xe', border: OutlineInputBorder()),
                items: ['Sedan', 'SUV', 'Xe điện', 'Luxury', 'Bán tải'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Giá thuê / ngày (\u0024)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập giá' : null,
              ),
              const SizedBox(height: 24),
              _buildImagePicker('Hình ảnh xe', _carImage, false),
              const SizedBox(height: 24),
              _buildImagePicker('Giấy tờ xe (eKYC)', _documentImage, true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _submitCar,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: _isUploading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('GỬI YÊU CẦU ĐĂNG KÝ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
