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
  XFile? _docFrontImage;
  XFile? _docBackImage;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  // type: 0 = car, 1 = doc front, 2 = doc back
  Future<void> _pickImage(int type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (type == 0) {
          _carImage = image;
        } else if (type == 1) {
          _docFrontImage = image;
        } else if (type == 2) {
          _docBackImage = image;
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
    if (_docFrontImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng tải lên mặt trước giấy tờ xe')));
      return;
    }
    if (_docBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng tải lên mặt sau giấy tờ xe')));
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

      // Upload giấy tờ xe mặt trước
      final docFrontExt = _docFrontImage!.path.split('.').last;
      final docFrontFileName = 'doc_front_${DateTime.now().millisecondsSinceEpoch}.$docFrontExt';
      final docFrontBytes = await _docFrontImage!.readAsBytes();
      await supabase.storage.from('cars').uploadBinary(docFrontFileName, docFrontBytes);
      final docFrontUrl = supabase.storage.from('cars').getPublicUrl(docFrontFileName);

      // Upload giấy tờ xe mặt sau
      final docBackExt = _docBackImage!.path.split('.').last;
      final docBackFileName = 'doc_back_${DateTime.now().millisecondsSinceEpoch}.$docBackExt';
      final docBackBytes = await _docBackImage!.readAsBytes();
      await supabase.storage.from('cars').uploadBinary(docBackFileName, docBackBytes);
      final docBackUrl = supabase.storage.from('cars').getPublicUrl(docBackFileName);

      // Insert vào bảng cars
      await supabase.from('cars').insert({
        'owner_id': userId,
        'name': _nameController.text,
        'brand': _brandController.text,
        'type': _selectedType,
        'price_per_day': double.parse(_priceController.text),
        'image_urls': [carUrl], // Mảng chứa URL ảnh xe
        'document_urls': [docFrontUrl, docBackUrl],
        'status': 'pending', // Chờ duyệt
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

  Widget _buildImagePicker(String title, XFile? file, int type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickImage(type),
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
              _buildImagePicker('Hình ảnh xe', _carImage, 0),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildImagePicker('Mặt trước giấy tờ', _docFrontImage, 1),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImagePicker('Mặt sau giấy tờ', _docBackImage, 2),
                  ),
                ],
              ),
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
