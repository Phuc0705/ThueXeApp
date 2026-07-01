import 'dart:convert';

class VietQRService {
  /// Tạo VietQR từ thông tin tài khoản ngân hàng
  /// 
  /// Tham số:
  /// - bankCode: Mã ngân hàng (VD: 970012 = VietcomBank, 970014 = MB Bank)
  /// - accountNumber: Số tài khoản
  /// - accountName: Tên chủ tài khoản
  /// - amount: Số tiền (VND)
  /// - description: Mô tả giao dịch
  /// - transactionId: Mã giao dịch
  static String generateVietQR({
    required String bankCode,
    required String accountNumber,
    required String accountName,
    required int amount,
    required String description,
    required String transactionId,
  }) {
    // Định dạng theo EMV Co - Merchant Presented Mode (MPM)
    // Cấu trúc: TAG - LENGTH - VALUE
    
    Map<String, String> tags = {
      '00': '011012',        // Phiên bản
      '01': '12',            // Ký hiệu khởi tạo
      '81': '06VIETQR',      // Globally Unique Identifier
      '50': '0010A000000727',// Application Template
      '51': '0707A000000727', // Merchant Account Information
    };

    // Thông tin tài khoản merchant
    // Format: 0012 (length) + VIETQR + 01 (serviceCode) + bankCode + accountNumber
    final accountInfo = _encodeTag(
      '0012',
      'VIETQR' +
          '01' +
          bankCode +
          accountNumber,
    );

    // Tên merchant
    final merchantName = _encodeTag('59', accountName);

    // Thành phố
    final city = _encodeTag('60', '0704'); // Hà Nội

    // Mô tả giao dịch
    final purpose = _encodeTag('62', description);

    // Số tiền
    final amountTag = _encodeTag('54', amount.toString());

    // Tham chiếu giao dịch
    final txnRef = _encodeTag('63', transactionId);

    // CRC checksum
    String qrData = accountInfo + merchantName + city + purpose + amountTag + txnRef;
    final crc = _calculateCRC16(qrData);

    qrData += _encodeTag('63', crc);

    return qrData;
  }

  /// Encode tag theo EMV
  static String _encodeTag(String tag, String value) {
    final length = value.length.toString().padLeft(2, '0');
    return '$tag$length$value';
  }

  /// Tính CRC16-CCITT
  static String _calculateCRC16(String data) {
    int crc = 0xFFFF;
    List<int> bytes = utf8.encode(data);

    for (int byte in bytes) {
      crc ^= (byte << 8);
      for (int i = 0; i < 8; i++) {
        crc <<= 1;
        if ((crc & 0x10000) != 0) {
          crc ^= 0x1021;
          crc &= 0xFFFF;
        }
      }
    }

    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  /// API VietQR để generate QR image
  /// https://api.vietqr.io/https://api.vietqr.io/v2/generate
  static String getVietQRImageUrl({
    required String bankCode,
    required String accountNumber,
    required String accountName,
    required int amount,
    required String description,
  }) {
    return 'https://api.vietqr.io/https://api.vietqr.io/v2/generate?'
        'accountName=${Uri.encodeComponent(accountName)}&'
        'accountNumber=$accountNumber&'
        'acqId=$bankCode&'
        'amount=$amount&'
        'addInfo=${Uri.encodeComponent(description)}&'
        'template=compact';
  }
}

/// Mã ngân hàng VN (Bank Code)
class BankCodes {
  static const String VIETCOMBANK = '970012'; // Vietcombank
  static const String MBBANK = '970014'; // MB Bank
  static const String TECHCOMBANK = '970015'; // Techcombank
  static const String VPBANK = '970016'; // VPBank
  static const String AGRIBANK = '970018'; // Agribank
  static const String ACB = '970010'; // ACB
  static const String SACOMBANK = '970019'; // Sacombank
  static const String SHB = '970020'; // SHB
  static const String VIB = '970021'; // VIB
  static const String EXIMBANK = '970092'; // Eximbank
}
