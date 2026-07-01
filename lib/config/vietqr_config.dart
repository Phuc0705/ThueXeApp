/// Cấu hình VietQR Payment
class VietQRConfig {
  // ⭐ Thay đổi thông tin tài khoản tại đây
  static const String bankCode = '970012'; // Vietcombank - thay mã ngân hàng nếu cần
  static const String accountNumber = '1234567890'; // ⭐ Thay số tài khoản của bạn
  static const String accountName = 'Thue Xe App'; // ⭐ Tên hiển thị trên QR
  
  // Tỷ giá (1 USD = ? VND)
  static const double usdToVndRate = 25000;
}
