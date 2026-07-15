import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository repository;

  AdminBloc({required this.repository}) : super(AdminInitial()) {
    on<FetchDashboardStats>(_onFetchDashboardStats);
    on<FetchAllUsers>(_onFetchAllUsers);
    on<UpdateUserInfo>(_onUpdateUserInfo);
    on<DeleteUserEvent>(_onDeleteUser);
    on<ChangeUserRoleEvent>(_onChangeUserRole);
    on<FetchAllBookings>(_onFetchAllBookings);
    on<UpdateBookingStatusEvent>(_onUpdateBookingStatus);
    on<FetchPendingCars>(_onFetchPendingCars);
    on<ApproveCarEvent>(_onApproveCar);
  }

  Future<void> _onFetchDashboardStats(FetchDashboardStats event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final stats = await repository.getDashboardStats();
      emit(AdminDashboardLoaded(
        totalUsers: stats['totalUsers'] ?? 0,
        totalCars: stats['totalCars'] ?? 0,
        newBookings: stats['newBookings'] ?? 0,
        monthlyRevenue: (stats['monthlyRevenue'] ?? 0).toDouble(),
      ));
    } catch (e) {
      emit(AdminError('Lỗi tải thống kê: ${e.toString()}'));
    }
  }

  Future<void> _onFetchAllUsers(FetchAllUsers event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final users = await repository.getAllUsers();
      emit(AdminUsersLoaded(users));
    } catch (e) {
      emit(AdminError('Lỗi tải danh sách người dùng: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUserInfo(UpdateUserInfo event, Emitter<AdminState> emit) async {
    try {
      await repository.updateUserInfo(event.userId, event.name, event.phone, event.idCard);
      final users = await repository.getAllUsers();
      emit(const AdminActionSuccess('Cập nhật người dùng thành công'));
      emit(AdminUsersLoaded(users));
    } catch (e) {
      emit(AdminError('Lỗi cập nhật người dùng: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteUser(DeleteUserEvent event, Emitter<AdminState> emit) async {
    try {
      await repository.deleteUser(event.userId);
      final users = await repository.getAllUsers();
      emit(const AdminActionSuccess('Xóa người dùng thành công'));
      emit(AdminUsersLoaded(users));
    } catch (e) {
      emit(AdminError('Lỗi xóa người dùng: ${e.toString()}'));
    }
  }

  Future<void> _onChangeUserRole(ChangeUserRoleEvent event, Emitter<AdminState> emit) async {
    try {
      await repository.changeUserRole(event.userId, event.role);
      final users = await repository.getAllUsers();
      emit(const AdminActionSuccess('Cập nhật quyền thành công'));
      emit(AdminUsersLoaded(users));
    } catch (e) {
      emit(AdminError('Lỗi cập nhật quyền: ${e.toString()}'));
    }
  }

  Future<void> _onFetchAllBookings(FetchAllBookings event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final bookings = await repository.getAllBookings();
      emit(AdminBookingsLoaded(bookings));
    } catch (e) {
      emit(AdminError('Lỗi tải danh sách đặt xe: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateBookingStatus(UpdateBookingStatusEvent event, Emitter<AdminState> emit) async {
    try {
      await repository.updateBookingStatus(event.bookingId, event.status);
      final bookings = await repository.getAllBookings();
      emit(const AdminActionSuccess('Cập nhật trạng thái thành công'));
      emit(AdminBookingsLoaded(bookings));
    } catch (e) {
      emit(AdminError('Lỗi cập nhật trạng thái đặt xe: ${e.toString()}'));
    }
  }

  Future<void> _onFetchPendingCars(FetchPendingCars event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final cars = await repository.getPendingCars();
      emit(AdminPendingCarsLoaded(cars));
    } catch (e) {
      emit(AdminError('Lỗi tải danh sách xe chờ duyệt: ${e.toString()}'));
    }
  }

  Future<void> _onApproveCar(ApproveCarEvent event, Emitter<AdminState> emit) async {
    try {
      await repository.approveCar(event.carId, event.isApproved);
      final cars = await repository.getPendingCars();
      emit(AdminActionSuccess(event.isApproved ? 'Đã duyệt xe thành công' : 'Đã từ chối xe'));
      emit(AdminPendingCarsLoaded(cars));
    } catch (e) {
      emit(AdminError('Lỗi xử lý duyệt xe: ${e.toString()}'));
    }
  }
}
