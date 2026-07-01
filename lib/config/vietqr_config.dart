/// Cấu hình VietQR Payment
class VietQRConfig {
  // ⭐ Thông tin tài khoản nhận tiền
  static const String bankCode = '970012'; // Vietcombank
  static const String accountNumber = '1028293997'; // Số tài khoản Vietcombank
  static const String accountName = 'Thue Xe App'; // Tên hiển thị trên QR
  
  // Tỷ giá (1 USD = ? VND)
  static const double usdToVndRate = 25000;
}
