import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/account_provider.dart';
import '../auth_screen/auth_common.dart';

class UpdateAddressScreen extends StatefulWidget {
  final dynamic address;
  const UpdateAddressScreen({super.key, required this.address});

  @override
  State<UpdateAddressScreen> createState() => _UpdateAddressScreenState();
}

class _UpdateAddressScreenState extends State<UpdateAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  // State quản lý địa chỉ 3 cấp
  dynamic _selectedProvince;
  dynamic _selectedDistrict;
  dynamic _selectedWard;
  late TextEditingController _streetDetail;

  late String _type;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    _type = widget.address.loaiDiaChi;
    _isDefault = widget.address.isDefault;
    _streetDetail = TextEditingController();

    // Thực hiện load dữ liệu và phân tách chuỗi sau khi frame đầu tiên được vẽ
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeAddressData();
    });
  }

  /// Hàm xử lý logic phân tách chuỗi và mapping với API
  Future<void> _initializeAddressData() async {
    final provider = context.read<AccountProvider>();

    // 1. Load danh sách tỉnh
    await provider.loadProvinces();

    // 2. Tách chuỗi: "Số nhà, Phường, Quận, Tỉnh"
    List<String> parts = widget.address.diaChiChiTiet.split(', ');
    if (parts.length >= 4) {
      String provinceName = parts.last.trim();
      String districtName = parts[parts.length - 2].trim();
      String wardName = parts[parts.length - 3].trim();
      String street = parts.sublist(0, parts.length - 3).join(', ');

      _streetDetail.text = street;

      // 3. Tìm và gán Province
      try {
        _selectedProvince = provider.provinces.firstWhere((p) => p.name == provinceName);

        // 4. Load và tìm District
        await provider.loadDistricts(_selectedProvince.code);
        _selectedDistrict = provider.districts.firstWhere((d) => d.name == districtName);

        // 5. Load và tìm Ward
        await provider.loadWards(_selectedDistrict.code);
        _selectedWard = provider.wards.firstWhere((w) => w.name == wardName);

        setState(() {}); // Cập nhật giao diện sau khi tìm thấy hết
      } catch (e) {
        debugPrint("Lỗi mapping địa chỉ: $e");
        _streetDetail.text = widget.address.diaChiChiTiet; // Fallback nếu lỗi
      }
    } else {
      _streetDetail.text = widget.address.diaChiChiTiet;
    }
  }

  @override
  void dispose() {
    _streetDetail.dispose();
    super.dispose();
  }

  void _showStatusMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
        ]),
        backgroundColor: isError ? Colors.redAccent : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWard == null) {
      _showStatusMessage("Vui lòng chọn đầy đủ địa chỉ hành chính");
      return;
    }

    final provider = context.read<AccountProvider>();
    final fullAddress = "${_streetDetail.text.trim()}, ${_selectedWard.name}, ${_selectedDistrict.name}, ${_selectedProvince.name}";

    await provider.updateAddress(
      id: widget.address.diaChiId,
      diaChiChiTiet: fullAddress,
      loaiDiaChi: _type,
      isDefault: _isDefault,
    );

    if (!mounted) return;
    if (provider.error != null) {
      _showStatusMessage(provider.error!);
    } else {
      _showStatusMessage('Cập nhật địa chỉ thành công!', isError: false);
      Future.delayed(const Duration(milliseconds: 500), () => Navigator.pop(context, true));
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa địa chỉ này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<AccountProvider>();
      await provider.deleteAddress(widget.address.diaChiId);
      if (mounted && provider.error == null) {
        _showStatusMessage('Đã xóa địa chỉ', isError: false);
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const AppBackBar(title: 'Chỉnh sửa địa chỉ'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // DROP DOWN TỈNH
                          DropdownButtonFormField<dynamic>(
                            value: _selectedProvince,
                            hint: const Text("Tỉnh/Thành phố"),
                            items: account.provinces.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                            onChanged: (v) {
                              setState(() { _selectedProvince = v; _selectedDistrict = null; _selectedWard = null; });
                              if (v != null) account.loadDistricts(v.code);
                            },
                            decoration: const InputDecoration(border: InputBorder.none),
                          ),
                          const Divider(height: 1),
                          // DROP DOWN HUYỆN
                          DropdownButtonFormField<dynamic>(
                            value: _selectedDistrict,
                            hint: const Text("Quận/Huyện"),
                            items: account.districts.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                            onChanged: (v) {
                              setState(() { _selectedDistrict = v; _selectedWard = null; });
                              if (v != null) account.loadWards(v.code);
                            },
                            decoration: const InputDecoration(border: InputBorder.none),
                          ),
                          const Divider(height: 1),
                          // DROP DOWN XÃ
                          DropdownButtonFormField<dynamic>(
                            value: _selectedWard,
                            hint: const Text("Phường/Xã"),
                            items: account.wards.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                            onChanged: (v) => setState(() => _selectedWard = v),
                            decoration: const InputDecoration(border: InputBorder.none),
                          ),
                          const Divider(height: 1),
                          // SỐ NHÀ
                          TextFormField(
                            controller: _streetDetail,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Số nhà, tên đường',
                              border: InputBorder.none,
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Bắt buộc' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // KHỐI LOẠI ĐỊA CHỈ & MẶC ĐỊNH
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonFormField<String>(
                        value: _type,
                        items: ['Nhà ở', 'Văn phòng', 'Căn hộ'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => _type = v!),
                        decoration: const InputDecoration(labelText: 'Loại địa chỉ', border: InputBorder.none),
                      ),
                    ),
                    const Divider(height: 1),
                    Container(
                      color: Colors.white,
                      child: SwitchListTile(
                        title: const Text('Đặt làm địa chỉ mặc định'),
                        activeColor: const Color(0xFFE53935),
                        value: _isDefault,
                        onChanged: widget.address.isDefault ? null : (v) => setState(() => _isDefault = v),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: account.isLoading ? null : _handleDelete,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: const Text('Xóa địa chỉ', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: AppTheme.primaryButton(context),
                onPressed: account.isLoading ? null : _handleUpdate,
                child: account.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CẬP NHẬT', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }
}