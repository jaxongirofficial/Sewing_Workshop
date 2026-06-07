final class CustomerRequestDto {
  const CustomerRequestDto({
    required this.fullName,
    required this.phone,
    required this.address,
  });

  final String fullName;
  final String phone;
  final String address;

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phone': phone,
        'address': address,
      };
}

final class CustomerUpdateDto {
  const CustomerUpdateDto({
    this.fullName,
    this.phone,
    this.address,
  });

  final String? fullName;
  final String? phone;
  final String? address;

  Map<String, dynamic> toJson() => {
        if (fullName != null) 'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
      };
}
