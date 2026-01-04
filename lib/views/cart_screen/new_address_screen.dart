import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/account_provider.dart';
import '../auth_screen/auth_common.dart';

class NewAddressScreen extends StatefulWidget {
  const NewAddressScreen({super.key});

  @override
  State<NewAddressScreen> createState() => _NewAddressScreenState();
}

class _NewAddressScreenState extends State<NewAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  // State quản lý chọn địa chỉ
  dynamic _selectedProvince; // LocationModel?
  dynamic _selectedDistrict; // LocationModel?
  dynamic _selectedWard;     // LocationModel?

  final _streetDetail = TextEditingController();
  String _type = 'Nhà ở';
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadProvinces();
    });
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProvince == null || _selectedDistrict == null || _selectedWard == null) {
      _showStatusMessage('Vui lòng chọn đầy đủ Tỉnh/Huyện/Xã');
      return;
    }

    final provider = context.read<AccountProvider>();

    // Ghép chuỗi địa chỉ: Số nhà, Phường, Quận, Tỉnh
    final fullAddress = "${_streetDetail.text.trim()}, ${_selectedWard.name}, ${_selectedDistrict.name}, ${_selectedProvince.name}";

    await provider.addAddress(
      diaChiChiTiet: fullAddress,
      loaiDiaChi: _type,
      isDefault: _isDefault,
    );

    if (!mounted) return;
    if (provider.error != null) {
      _showStatusMessage(provider.error!);
      return;
    }
    _showStatusMessage('Thêm địa chỉ mới thành công', isError: false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const AppBackBar(title: 'Địa chỉ mới'),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 12),

              /// Khối chọn địa chỉ hành chính
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Dropdown Tỉnh/Thành
                    DropdownButtonFormField<dynamic>(
                      value: _selectedProvince,
                      hint: const Text("Tỉnh/Thành phố"),
                      items: account.provinces.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedProvince = v;
                          _selectedDistrict = null;
                          _selectedWard = null;
                        });
                        if (v != null) account.loadDistricts(v.code);
                      },
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                    const Divider(height: 1),

                    // Dropdown Quận/Huyện
                    DropdownButtonFormField<dynamic>(
                      value: _selectedDistrict,
                      hint: const Text("Quận/Huyện"),
                      items: account.districts.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedDistrict = v;
                          _selectedWard = null;
                        });
                        if (v != null) account.loadWards(v.code);
                      },
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                    const Divider(height: 1),

                    // Dropdown Phường/Xã
                    DropdownButtonFormField<dynamic>(
                      value: _selectedWard,
                      hint: const Text("Phường/Xã"),
                      items: account.wards.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                      onChanged: (v) => setState(() => _selectedWard = v),
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                    const Divider(height: 1),

                    // Số nhà, tên đường
                    TextFormField(
                      controller: _streetDetail,
                      decoration: const InputDecoration(
                        labelText: 'Số nhà, tên đường',
                        border: InputBorder.none,
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập số nhà, tên đường' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// Khối loại địa chỉ và mặc định
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  value: _type,
                  items: ['Nhà ở', 'Văn phòng', 'Căn hộ']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
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
                  onChanged: (v) => setState(() => _isDefault = v),
                ),
              ),

              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: AppTheme.primaryButton(context),
                    onPressed: account.isLoading ? null : _submit,
                    child: account.isLoading
                        ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                        : const Text('HOÀN TẤT'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}