import 'package:flutter/material.dart';
import 'add_car_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/gradient_app_bar.dart';
import '../../../../injection_container.dart';
import '../bloc/owner_bloc.dart';
import '../bloc/owner_event.dart';
import '../bloc/owner_state.dart';

class MyCarsPage extends StatefulWidget {
  const MyCarsPage({super.key});

  @override
  State<MyCarsPage> createState() => _MyCarsPageState();
}

class _MyCarsPageState extends State<MyCarsPage> {
  @override
  void initState() {
    super.initState();
    context.read<OwnerBloc>().add(GetMyCarsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Xe của tôi'),
      body: BlocConsumer<OwnerBloc, OwnerState>(
        listener: (context, state) {
          if (state is OwnerCarDeletedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xoá xe thành công')));
            context.read<OwnerBloc>().add(GetMyCarsEvent());
          } else if (state is OwnerCarStatusUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật trạng thái thành công')));
            context.read<OwnerBloc>().add(GetMyCarsEvent());
          } else if (state is OwnerError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is OwnerLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OwnerError) {
            return Center(child: Text(state.message));
          }
          if (state is OwnerCarsLoaded) {
            final myCars = state.cars;
            if (myCars.isEmpty) {
              return const Center(child: Text('Bạn chưa đăng ký cho thuê chiếc xe nào.'));
            }
            return ListView.builder(
              itemCount: myCars.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final car = myCars[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            image: car.imageUrl.isNotEmpty 
                                ? DecorationImage(image: NetworkImage(car.imageUrl), fit: BoxFit.cover)
                                : null,
                          ),
                          child: car.imageUrl.isEmpty ? const Icon(Icons.directions_car, color: Colors.blue) : null,
                        ),
                        title: Text(car.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${car.type} • \$${car.pricePerDay}/ngày'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(car.isAvailable 
                                    ? 'Sẵn sàng' 
                                    : (car.status == 'unavailable' ? 'Đã ẩn' : (car.status == 'pending' ? 'Chờ duyệt' : 'Đang thuê')), 
                                  style: TextStyle(
                                      color: car.isAvailable ? Colors.green : (car.status == 'unavailable' ? Colors.grey : (car.status == 'pending' ? Colors.blue : Colors.orange)), 
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold)),
                              ],
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Xoá xe'),
                                      content: const Text('Bạn có chắc chắn muốn xoá chiếc xe này khỏi danh sách?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            context.read<OwnerBloc>().add(DeleteCarEvent(car.id));
                                          }, 
                                          child: const Text('Xoá', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (value == 'hide') {
                                  context.read<OwnerBloc>().add(UpdateCarStatusEvent(car.id, 'unavailable'));
                                } else if (value == 'show') {
                                  context.read<OwnerBloc>().add(UpdateCarStatusEvent(car.id, 'available'));
                                }
                              },
                              itemBuilder: (context) => [
                                if (car.status != 'unavailable' && car.status != 'pending')
                                  const PopupMenuItem(
                                    value: 'hide',
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility_off, color: Colors.grey),
                                        SizedBox(width: 8),
                                        Text('Ẩn xe'),
                                      ],
                                    ),
                                  ),
                                if (car.status == 'unavailable')
                                  const PopupMenuItem(
                                    value: 'show',
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Hiện xe'),
                                      ],
                                    ),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Xoá xe', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigate to edit car or view details
                        },
                      ),
                    );
                  },
                );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(
            create: (_) => sl<OwnerBloc>(),
            child: const AddCarPage(),
          )));
          if (result == true) {
            if (context.mounted) {
              context.read<OwnerBloc>().add(GetMyCarsEvent());
            }
          }
        },
        label: const Text('Thêm xe mới'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
