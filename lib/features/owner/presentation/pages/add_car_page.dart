import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/gradient_app_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/owner_bloc.dart';
import '../bloc/owner_event.dart';
import '../bloc/owner_state.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customBrandController = TextEditingController();
  
  String _selectedType = 'Sedan';
  String _selectedBrand = 'Toyota';
  String _selectedTransmission = 'Số tự động';
  String _selectedLocation = 'Quận 1';
  int _selectedSeats = 4;
  
  final List<String> _districts = [
    'Quận 1', 'Quận 2', 'Quận 3', 'Quận 4', 'Quận 5', 'Quận 6', 
    'Quận 7', 'Quận 8', 'Quận 9', 'Quận 10', 'Quận 11', 'Quận 12',
    'Bình Thạnh', 'Thủ Đức', 'Gò Vấp', 'Phú Nhuận', 'Tân Bình', 'Tân Phú', 'Bình Tân'
  ];
  final List<String> _brands = [
    'Toyota', 'Honda', 'Ford', 'Mercedes', 'BMW', 'Audi', 'Hyundai', 'Kia', 'Mazda', 'Khác'
  ];
  
  XFile? _carImage;
  XFile? _docFrontImage;
  XFile? _docBackImage;

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

  void _submitCar() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final user = authState.user;
      if (user.fullName.trim().isEmpty || 
          user.phoneNumber == null || user.phoneNumber!.trim().isEmpty || 
          user.idCard == null || user.idCard!.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng cập nhật đầy đủ thông tin (SĐT, CCCD) trong Hồ sơ trước khi đăng ký xe!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          )
        );
        return;
      }
    }

    if (!_formKey.currentState!.validate()) return;
    if (_selectedBrand == 'Khác' && _customBrandController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên hãng xe')));
      return;
    }
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

    context.read<OwnerBloc>().add(
      AddCarEvent(
        name: _nameController.text,
        brand: _selectedBrand == 'Khác' ? _customBrandController.text.trim() : _selectedBrand,
        pricePerDay: double.parse(_priceController.text),
        type: _selectedType,
        fuelType: 'Xăng', 
        transmission: _selectedTransmission,
        location: _selectedLocation,
        description: _descriptionController.text,
        seats: _selectedSeats,
        carImage: _carImage!,
        docFrontImage: _docFrontImage!,
        docBackImage: _docBackImage!,
      ),
    );
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
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
      appBar: const GradientAppBar(title: 'Đăng ký xe cho thuê'),
      body: BlocConsumer<OwnerBloc, OwnerState>(
        listener: (context, state) {
          if (state is OwnerCarAddedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đăng ký xe thành công!')),
            );
            Navigator.pop(context, true);
          } else if (state is OwnerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.message}'), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isUploading = state is OwnerLoading;
          
          return SingleChildScrollView(
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBrand,
                    decoration: const InputDecoration(labelText: 'Hãng xe', border: OutlineInputBorder()),
                    items: _brands.map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedBrand = v!),
                  ),
                  if (_selectedBrand == 'Khác') ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _customBrandController,
                      decoration: const InputDecoration(labelText: 'Nhập tên hãng xe', border: OutlineInputBorder()),
                      validator: (v) => _selectedBrand == 'Khác' && v!.trim().isEmpty ? 'Vui lòng nhập tên hãng xe' : null,
                    ),
                  ],
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(labelText: 'Loại xe', border: OutlineInputBorder()),
                    items: ['Sedan', 'SUV', 'Xe điện', 'Luxury', 'Bán tải'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedType = v!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTransmission,
                    decoration: const InputDecoration(labelText: 'Hộp số', border: OutlineInputBorder()),
                    items: ['Số tự động', 'Số sàn'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedTransmission = v!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedSeats,
                    decoration: const InputDecoration(labelText: 'Số chỗ', border: OutlineInputBorder()),
                    items: [2, 4, 7].map((int value) {
                      return DropdownMenuItem<int>(value: value, child: Text('$value chỗ'));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedSeats = v!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedLocation,
                    decoration: const InputDecoration(labelText: 'Khu vực (Quận/Huyện TPHCM)', border: OutlineInputBorder()),
                    items: _districts.map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedLocation = v!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Giá thuê / ngày (USD)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'Vui lòng nhập giá';
                      if (double.tryParse(v) == null) return 'Giá thuê phải là một số hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Mô tả chi tiết xe',
                      border: OutlineInputBorder(),
                    ),
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
                      onPressed: isUploading ? null : _submitCar,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      child: isUploading 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text('GỬI YÊU CẦU ĐĂNG KÝ'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
