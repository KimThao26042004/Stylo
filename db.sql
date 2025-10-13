CREATE DATABASE fashion_shop;
go

USE fashion_shop;
go
/* 1. Tài khoản */
CREATE TABLE dbo.TaiKhoan (
  TaiKhoanID   INT IDENTITY(1,1) PRIMARY KEY,
  TenDangNhap  NVARCHAR(60) NOT NULL UNIQUE,
  MatKhauHash  NVARCHAR(255) NOT NULL,
  VaiTro       NVARCHAR(10)  NOT NULL
               CONSTRAINT ck_tk_vaitro CHECK (VaiTro IN (N'KH',N'NV',N'ADMIN')),
  created_at   DATETIME2(3)  NOT NULL CONSTRAINT df_tk_created DEFAULT SYSDATETIME(),
  updated_at   DATETIME2(3)  NOT NULL CONSTRAINT df_tk_updated DEFAULT SYSDATETIME()
);

CREATE TABLE dbo.KhachHang (
  KhachHangID  INT IDENTITY(1,1) PRIMARY KEY,
  HoTen        NVARCHAR(120) NOT NULL,
  GioiTinh     NVARCHAR(5)   NOT NULL
               CONSTRAINT ck_kh_gt CHECK (GioiTinh IN (N'NAM',N'NU')),
  ngaySinh     DATE          NOT NULL
               CONSTRAINT ck_kh_ns CHECK (
                 ngaySinh <= CAST(SYSDATETIME() AS DATE) AND
                 ngaySinh >= DATEADD(YEAR,-120, CAST(SYSDATETIME() AS DATE))
               ),
  Email        NVARCHAR(120) NOT NULL UNIQUE,
  SoDienThoai  NVARCHAR(20)  NULL,
  TaiKhoanID   INT NULL UNIQUE,  -- tối đa 1 tài khoản
  created_at   DATETIME2(3)  NOT NULL CONSTRAINT df_kh_created DEFAULT SYSDATETIME(),
  updated_at   DATETIME2(3)  NOT NULL CONSTRAINT df_kh_updated DEFAULT SYSDATETIME(),
  deleted_at   DATETIME2(3)  NULL,
  CONSTRAINT fk_kh_tk FOREIGN KEY (TaiKhoanID) REFERENCES dbo.TaiKhoan(TaiKhoanID) ON DELETE SET NULL
);

CREATE TABLE dbo.NhanVien (
  NhanVienID   INT IDENTITY(1,1) PRIMARY KEY,
  HoTen        NVARCHAR(120) NOT NULL,
  GioiTinh     NVARCHAR(5)   NOT NULL
               CONSTRAINT ck_nv_gt CHECK (GioiTinh IN (N'NAM',N'NU')),
  ngaySinh     DATE          NOT NULL
               CONSTRAINT ck_nv_ns CHECK (
                 ngaySinh <= CAST(SYSDATETIME() AS DATE) AND
                 ngaySinh >= DATEADD(YEAR,-120, CAST(SYSDATETIME() AS DATE))
               ),
  Email        NVARCHAR(120) NULL,
  SoDienThoai  NVARCHAR(20)  NULL,
  ChucVu       NVARCHAR(60)  NULL,
  TaiKhoanID   INT NULL UNIQUE,  -- mỗi NV tối đa 1 tài khoản
  created_at   DATETIME2(3)  NOT NULL CONSTRAINT df_nv_created DEFAULT SYSDATETIME(),
  updated_at   DATETIME2(3)  NOT NULL CONSTRAINT df_nv_updated DEFAULT SYSDATETIME(),
  CONSTRAINT fk_nv_tk FOREIGN KEY (TaiKhoanID) REFERENCES dbo.TaiKhoan(TaiKhoanID) ON DELETE SET NULL
);

CREATE TABLE dbo.DiaChi (
  DiaChiID     INT IDENTITY(1,1) PRIMARY KEY,
  KhachHangID  INT NOT NULL,
  HoTenNhan    NVARCHAR(120) NOT NULL,
  SDTNhan      NVARCHAR(20)  NULL,
  [Line]       NVARCHAR(160) NOT NULL,
  PhuongXa     NVARCHAR(120) NULL,
  QuanHuyen    NVARCHAR(120) NULL,
  TinhTP       NVARCHAR(120) NULL,
  AddressType  NVARCHAR(10)  NOT NULL
               CONSTRAINT ck_dc_type CHECK (AddressType IN (N'HOME',N'WORK',N'OTHER')),
  IsDefault    BIT           NOT NULL CONSTRAINT df_dc_isdefault DEFAULT (0),
  DefaultKey   AS (CASE WHEN IsDefault = 1 
                        THEN CAST(KhachHangID AS NVARCHAR(20)) + N'#' + AddressType
                        ELSE NULL END) PERSISTED,
  created_at   DATETIME2(3) NOT NULL CONSTRAINT df_dc_created DEFAULT SYSDATETIME(),
  updated_at   DATETIME2(3) NOT NULL CONSTRAINT df_dc_updated DEFAULT SYSDATETIME(),
  deleted_at   DATETIME2(3) NULL,
  CONSTRAINT uq_dc_default_per_type UNIQUE (DefaultKey),
  CONSTRAINT fk_dc_kh FOREIGN KEY (KhachHangID) REFERENCES dbo.KhachHang(KhachHangID)
);
GO

/*2. Phân loại – Danh mục – Thương hiệu – Sản phẩm */
CREATE TABLE dbo.PhanLoai (
  PhanLoaiID INT IDENTITY(1,1) PRIMARY KEY,
  Ten        NVARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE dbo.DanhMuc (
  DanhMucID  INT IDENTITY(1,1) PRIMARY KEY,
  Ten        NVARCHAR(120) NOT NULL,
  ParentID   INT NULL,
  PhanLoaiID INT NOT NULL,
  CONSTRAINT fk_dm_parent FOREIGN KEY (ParentID)   REFERENCES dbo.DanhMuc(DanhMucID),
  CONSTRAINT fk_dm_pl     FOREIGN KEY (PhanLoaiID) REFERENCES dbo.PhanLoai(PhanLoaiID)
);

CREATE TABLE dbo.ThuongHieu (
  ThuongHieuID INT IDENTITY(1,1) PRIMARY KEY,
  Ten          NVARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE dbo.SanPham (
  SanPhamID    INT IDENTITY(1,1) PRIMARY KEY,
  TenSanPham   NVARCHAR(160) NOT NULL,
  MoTa         NVARCHAR(MAX) NULL,
  DanhMucID    INT NULL,
  ThuongHieuID INT NULL,
  created_at   DATETIME2(3) NOT NULL CONSTRAINT df_sp_created DEFAULT SYSDATETIME(),
  updated_at   DATETIME2(3) NOT NULL CONSTRAINT df_sp_updated DEFAULT SYSDATETIME(),
  CONSTRAINT fk_sp_dm FOREIGN KEY (DanhMucID) REFERENCES dbo.DanhMuc(DanhMucID),
  CONSTRAINT fk_sp_th FOREIGN KEY (ThuongHieuID) REFERENCES dbo.ThuongHieu(ThuongHieuID)
);
GO

/*3. Thuộc tính – Biến thể (SKU) & Ảnh */
CREATE TABLE dbo.MauSac (
  MauID INT IDENTITY(1,1) PRIMARY KEY,
  Ten   NVARCHAR(50) NOT NULL UNIQUE,
  MaHex NCHAR(7) NULL
);

CREATE TABLE dbo.[Size] (
  SizeID INT IDENTITY(1,1) PRIMARY KEY,
  KyHieu NVARCHAR(10) NOT NULL UNIQUE,
  ThuTu  INT NOT NULL DEFAULT (0)
);

CREATE TABLE dbo.SanPham_BienThe (
  BienTheID  INT IDENTITY(1,1) PRIMARY KEY,
  SanPhamID  INT NOT NULL,
  MauID      INT NOT NULL,
  SizeID     INT NOT NULL,
  SKU        NVARCHAR(64) NOT NULL UNIQUE,
  Barcode    NVARCHAR(64) NULL,
  GiaBan     DECIMAL(12,2) NOT NULL,
  GiaNhap    DECIMAL(12,2) NULL,
  TrangThai  NVARCHAR(10)  NOT NULL
             CONSTRAINT ck_bt_trangthai CHECK (TrangThai IN (N'ACTIVE',N'INACTIVE')),
  created_at DATETIME2(3)  NOT NULL CONSTRAINT df_bt_created DEFAULT SYSDATETIME(),
  updated_at DATETIME2(3)  NOT NULL CONSTRAINT df_bt_updated DEFAULT SYSDATETIME(),
  CONSTRAINT uq_bt_combo UNIQUE (SanPhamID, MauID, SizeID),
  CONSTRAINT fk_bt_sp   FOREIGN KEY (SanPhamID) REFERENCES dbo.SanPham(SanPhamID),
  CONSTRAINT fk_bt_mau  FOREIGN KEY (MauID)     REFERENCES dbo.MauSac(MauID),
  CONSTRAINT fk_bt_size FOREIGN KEY (SizeID)    REFERENCES dbo.[Size](SizeID)
);

CREATE TABLE dbo.AnhSanPham (
  AnhID     INT IDENTITY(1,1) PRIMARY KEY,
  SanPhamID INT NULL,
  BienTheID INT NULL,
  URL       NVARCHAR(255) NOT NULL,
  IsPrimary BIT NOT NULL DEFAULT (0),
  CONSTRAINT fk_img_sp FOREIGN KEY (SanPhamID)  REFERENCES dbo.SanPham(SanPhamID),
  CONSTRAINT fk_img_bt FOREIGN KEY (BienTheID)  REFERENCES dbo.SanPham_BienThe(BienTheID)
);
GO

/* 4. Tồn kho – Phát sinh kho */
CREATE TABLE dbo.TonKho (
  BienTheID  INT NOT NULL PRIMARY KEY,
  OnHand     INT NOT NULL CONSTRAINT ck_ton_onhand CHECK (OnHand >= 0) DEFAULT (0),
  Reserved   INT NOT NULL CONSTRAINT ck_ton_res    CHECK (Reserved >= 0) DEFAULT (0),
  AvgCost    DECIMAL(12,2) NULL,
  Available  AS (OnHand - Reserved) PERSISTED,
  updated_at DATETIME2(3) NOT NULL CONSTRAINT df_ton_updated DEFAULT SYSDATETIME(),
  CONSTRAINT fk_ton_bt FOREIGN KEY (BienTheID) REFERENCES dbo.SanPham_BienThe(BienTheID)
);

CREATE TABLE dbo.PhatSinhKho (
  PhatSinhID INT IDENTITY(1,1) PRIMARY KEY,
  ThoiDiem   DATETIME2(3) NOT NULL CONSTRAINT df_psk_time DEFAULT SYSDATETIME(),
  BienTheID  INT  NOT NULL,
  SoLuong    INT  NOT NULL,   -- dương: nhập/hoàn; âm: bán/xuất/huỷ
  DonGia     DECIMAL(12,2) NULL,
  Loai       NVARCHAR(12) NOT NULL
             CONSTRAINT ck_psk_loai CHECK (Loai IN
               (N'NHAP',N'BAN',N'TRA_NHAP',N'TRA_BAN',N'DIEU_CHINH',N'HUY')),
  NhanVienID INT NULL,
  GhiChu     NVARCHAR(255) NULL,
  INDEX IX_PSK_BienThe_Time (BienTheID, ThoiDiem),
  CONSTRAINT fk_psk_bt FOREIGN KEY (BienTheID)  REFERENCES dbo.SanPham_BienThe(BienTheID),
  CONSTRAINT fk_psk_nv FOREIGN KEY (NhanVienID) REFERENCES dbo.NhanVien(NhanVienID)
);
GO

/* 5. Bán hàng */
CREATE TABLE dbo.GioHang (
  GioHangID   INT IDENTITY(1,1) PRIMARY KEY,
  KhachHangID INT NOT NULL,
  NgayTao     DATETIME2(3) NOT NULL CONSTRAINT df_gh_created DEFAULT SYSDATETIME(),
  CONSTRAINT fk_gh_kh FOREIGN KEY (KhachHangID) REFERENCES dbo.KhachHang(KhachHangID)
);

CREATE TABLE dbo.GioHang_ChiTiet (
  GioHangID INT NOT NULL,
  BienTheID INT NOT NULL,
  SoLuong   INT NOT NULL,
  DonGia    DECIMAL(12,2) NULL,
  CONSTRAINT pk_ghct PRIMARY KEY (GioHangID, BienTheID),
  CONSTRAINT fk_ghct_gh FOREIGN KEY (GioHangID) REFERENCES dbo.GioHang(GioHangID) ON DELETE CASCADE,
  CONSTRAINT fk_ghct_bt FOREIGN KEY (BienTheID) REFERENCES dbo.SanPham_BienThe(BienTheID)
);

CREATE TABLE dbo.DonHang (
  DonHangID     INT IDENTITY(1,1) PRIMARY KEY,
  KhachHangID   INT NOT NULL,
  TrangThai     NVARCHAR(10) NOT NULL
                CONSTRAINT ck_dh_trangthai CHECK (TrangThai IN
                  (N'NEW',N'CONFIRMED',N'PACKED',N'SHIPPED',N'DELIVERED',N'CANCELLED',N'RETURNED')),
  KenhBan       NVARCHAR(10) NOT NULL
                CONSTRAINT ck_dh_kenhban CHECK (KenhBan IN (N'ONLINE',N'OFFLINE',N'TIKTOK',N'SHOPEE')),
  TongTienHang  DECIMAL(12,2) NOT NULL DEFAULT (0),
  TongGiamGia   DECIMAL(12,2) NOT NULL DEFAULT (0),
  Thue          DECIMAL(12,2) NOT NULL DEFAULT (0),
  PhiVanChuyen  DECIMAL(12,2) NOT NULL DEFAULT (0),
  TongThanhToan DECIMAL(12,2) NOT NULL DEFAULT (0),
  NgayDat       DATETIME2(3)  NOT NULL CONSTRAINT df_dh_ngaydat DEFAULT SYSDATETIME(),
  updated_at    DATETIME2(3)  NOT NULL CONSTRAINT df_dh_updated DEFAULT SYSDATETIME(),
  CONSTRAINT fk_dh_kh FOREIGN KEY (KhachHangID) REFERENCES dbo.KhachHang(KhachHangID)
);

CREATE TABLE dbo.DonHang_ChiTiet (
  DonHangID INT NOT NULL,
  BienTheID INT NOT NULL,
  SoLuong   INT NOT NULL CONSTRAINT ck_dhct_qty CHECK (SoLuong > 0),
  DonGia    DECIMAL(12,2) NOT NULL CONSTRAINT ck_dhct_price CHECK (DonGia >= 0),
  GiamGia   DECIMAL(12,2) NOT NULL DEFAULT (0),
  Thue      DECIMAL(12,2) NOT NULL DEFAULT (0),
  CONSTRAINT pk_dhct PRIMARY KEY (DonHangID, BienTheID),
  CONSTRAINT fk_dhct_dh FOREIGN KEY (DonHangID) REFERENCES dbo.DonHang(DonHangID) ON DELETE CASCADE,
  CONSTRAINT fk_dhct_bt FOREIGN KEY (BienTheID) REFERENCES dbo.SanPham_BienThe(BienTheID)
);

CREATE TABLE dbo.HoaDon (
  HoaDonID  INT IDENTITY(1,1) PRIMARY KEY,
  DonHangID INT NOT NULL,
  NgayLap   DATETIME2(3) NOT NULL CONSTRAINT df_hd_ngaylap DEFAULT SYSDATETIME(),
  TongTien  DECIMAL(12,2) NOT NULL,
  CONSTRAINT fk_hd_dh FOREIGN KEY (DonHangID) REFERENCES dbo.DonHang(DonHangID)
);

CREATE TABLE dbo.ThanhToan (
  ThanhToanID  INT IDENTITY(1,1) PRIMARY KEY,
  HoaDonID     INT NOT NULL,
  PhuongThuc   NVARCHAR(15) NOT NULL
               CONSTRAINT ck_tt_pt CHECK (PhuongThuc IN (N'TIENMAT',N'CHUYENKHOAN',N'ONLINE')),
  SoTien       DECIMAL(12,2) NOT NULL,
  TrangThai    NVARCHAR(10) NOT NULL
               CONSTRAINT ck_tt_trangthai CHECK (TrangThai IN (N'PENDING',N'PAID',N'FAILED',N'REFUNDED')),
  Provider     NVARCHAR(60) NULL,
  TransactionID NVARCHAR(120) NULL,
  NgayThanhToan DATETIME2(3) NOT NULL CONSTRAINT df_tt_date DEFAULT SYSDATETIME(),
  CONSTRAINT fk_tt_hd FOREIGN KEY (HoaDonID) REFERENCES dbo.HoaDon(HoaDonID)
);

CREATE TABLE dbo.VanDon (
  VanDonID       INT IDENTITY(1,1) PRIMARY KEY,
  DonHangID      INT NOT NULL,
  DVVC           NVARCHAR(80) NULL,
  MaVanDon       NVARCHAR(120) NULL,
  TrangThaiGiao  NVARCHAR(12) NOT NULL
                 CONSTRAINT ck_vd_trangthai CHECK (TrangThaiGiao IN
                   (N'CREATED',N'PICKED',N'INTRANSIT',N'DELIVERED',N'FAILED',N'RETURNED')),
  PhiVanChuyen   DECIMAL(12,2) NOT NULL DEFAULT (0),
  NgayGui        DATE NULL,
  NgayGiaoDuKien DATE NULL,
  CONSTRAINT fk_vd_dh FOREIGN KEY (DonHangID) REFERENCES dbo.DonHang(DonHangID)
);

CREATE TABLE dbo.MaGiamGia (
  MaID      INT IDENTITY(1,1) PRIMARY KEY,
  Code      NVARCHAR(40) NOT NULL UNIQUE,
  Loai      NVARCHAR(10) NOT NULL CONSTRAINT ck_mgg_loai CHECK (Loai IN (N'PERCENT',N'FIXED')),
  GiaTri    DECIMAL(12,2) NOT NULL,
  ToiDa     DECIMAL(12,2) NULL,
  DieuKien  NVARCHAR(255) NULL,
  NgayBD    DATE NOT NULL,
  NgayKT    DATE NOT NULL,
  SoLanDung INT  NOT NULL DEFAULT (0),
  TrangThai NVARCHAR(10) NOT NULL CONSTRAINT ck_mgg_trangthai CHECK (TrangThai IN (N'ACTIVE',N'INACTIVE'))
);

CREATE TABLE dbo.DonHang_MaGiamGia (
  DonHangID    INT NOT NULL,
  MaID         INT NOT NULL,
  GiaTriApDung DECIMAL(12,2) NOT NULL,
  CONSTRAINT pk_dhmg PRIMARY KEY (DonHangID, MaID),
  CONSTRAINT fk_dhmg_dh FOREIGN KEY (DonHangID) REFERENCES dbo.DonHang(DonHangID) ON DELETE CASCADE,
  CONSTRAINT fk_dhmg_mg FOREIGN KEY (MaID)      REFERENCES dbo.MaGiamGia(MaID)
);

CREATE TABLE dbo.BaoCao (
  BaoCaoID   INT IDENTITY(1,1) PRIMARY KEY,
  NhanVienID INT NOT NULL,
  NgayLap    DATE NOT NULL,
  NoiDung    NVARCHAR(MAX) NULL,
  CONSTRAINT fk_bc_nv FOREIGN KEY (NhanVienID) REFERENCES dbo.NhanVien(NhanVienID)
);
GO

-- Unique / Index
ALTER TABLE KhachHang ADD CONSTRAINT uq_kh_email UNIQUE (Email);
ALTER TABLE TaiKhoan  ADD CONSTRAINT uq_tk_username UNIQUE (TenDangNhap);
ALTER TABLE ThuongHieu ADD UNIQUE (Ten);
ALTER TABLE Size ADD UNIQUE (KyHieu);
ALTER TABLE SanPham_BienThe ADD UNIQUE (SKU);
ALTER TABLE SanPham_BienThe ADD UNIQUE (SanPhamID, MauID, SizeID);
ALTER TABLE MaGiamGia ADD UNIQUE (Code);

-- FK phân cấp danh mục
ALTER TABLE DanhMuc
  ADD CONSTRAINT fk_dm_parent FOREIGN KEY (ParentID) REFERENCES DanhMuc(DanhMucID);
  
-- Sản phẩm → danh mục/brand
ALTER TABLE SanPham
  ADD CONSTRAINT fk_sp_dm  FOREIGN KEY (DanhMucID)   REFERENCES DanhMuc(DanhMucID);
ALTER TABLE SanPham
  ADD CONSTRAINT fk_sp_th  FOREIGN KEY (ThuongHieuID) REFERENCES ThuongHieu(ThuongHieuID);

-- Tài khoản ↔ khách
ALTER TABLE TaiKhoan
  ADD CONSTRAINT fk_tk_kh FOREIGN KEY (KhachHangID) REFERENCES KhachHang(KhachHangID);

--Khách hàng
ALTER TABLE dbo.KhachHang
ADD CONSTRAINT ck_kh_ngaysinh
CHECK (
  ngaySinh <= CAST(SYSDATETIME() AS DATE)
  AND ngaySinh >= DATEADD(YEAR, -120, CAST(SYSDATETIME() AS DATE))
);

ALTER TABLE dbo.KhachHang WITH CHECK
ADD CONSTRAINT ck_kh_gt
CHECK (GioiTinh IN (N'NAM', N'NU'));

--Nhân viên
ALTER TABLE dbo.NhanVien
ADD CONSTRAINT ck_kh_ngaysinh
CHECK (
  ngaySinh <= CAST(SYSDATETIME() AS DATE)
  AND ngaySinh >= DATEADD(YEAR, -120, CAST(SYSDATETIME() AS DATE))
);

ALTER TABLE dbo.NhanVien WITH CHECK
ADD CONSTRAINT ck_kh_gioitinh
CHECK (GioiTinh IN (N'NAM', N'NU'));

-- Biến thể - SanPham/Mau/Size
ALTER TABLE SanPham_BienThe
  ADD CONSTRAINT fk_bt_sp   FOREIGN KEY (SanPhamID) REFERENCES SanPham(SanPhamID);
ALTER TABLE SanPham_BienThe
  ADD CONSTRAINT fk_bt_mau  FOREIGN KEY (MauID)     REFERENCES MauSac(MauID);
ALTER TABLE SanPham_BienThe
  ADD CONSTRAINT fk_bt_size FOREIGN KEY (SizeID)    REFERENCES Size(SizeID);

-- Ảnh
ALTER TABLE AnhSanPham
  ADD CONSTRAINT fk_img_sp  FOREIGN KEY (SanPhamID)  REFERENCES SanPham(SanPhamID);
ALTER TABLE AnhSanPham
  ADD CONSTRAINT fk_img_bt  FOREIGN KEY (BienTheID)  REFERENCES SanPham_BienThe(BienTheID);

-- Tồn kho & phát sinh
ALTER TABLE TonKhoKho
  ADD CONSTRAINT fk_ton_kho FOREIGN KEY (KhoID)     REFERENCES Kho(KhoID);
ALTER TABLE TonKhoKho
  ADD CONSTRAINT fk_ton_bt  FOREIGN KEY (BienTheID) REFERENCES SanPham_BienThe(BienTheID);
ALTER TABLE PhatSinhKho
  ADD CONSTRAINT fk_psk_kho FOREIGN KEY (KhoID)     REFERENCES Kho(KhoID);
 ALTER TABLE PhatSinhKho
  ADD CONSTRAINT fk_psk_bt  FOREIGN KEY (BienTheID) REFERENCES SanPham_BienThe(BienTheID);

-- Giỏ & chi tiết
ALTER TABLE GioHang
  ADD CONSTRAINT fk_gh_kh FOREIGN KEY (KhachHangID) REFERENCES KhachHang(KhachHangID);
ALTER TABLE GioHang_ChiTiet
  ADD CONSTRAINT fk_ghct_gh FOREIGN KEY (GioHangID)  REFERENCES GioHang(GioHangID) ON DELETE CASCADE;
ALTER TABLE GioHang_ChiTiet
  ADD CONSTRAINT fk_ghct_bt FOREIGN KEY (BienTheID)  REFERENCES SanPham_BienThe(BienTheID);

-- Đơn & chi tiết
ALTER TABLE DonHang
  ADD CONSTRAINT fk_dh_kh FOREIGN KEY (KhachHangID) REFERENCES KhachHang(KhachHangID);
ALTER TABLE DonHang_ChiTiet
  ADD CONSTRAINT fk_dhct_dh FOREIGN KEY (DonHangID) REFERENCES DonHang(DonHangID) ON DELETE CASCADE;
ALTER TABLE DonHang_ChiTiet
  ADD CONSTRAINT fk_dhct_bt FOREIGN KEY (BienTheID) REFERENCES SanPham_BienThe(BienTheID);

-- Hóa đơn, thanh toán, vận đơn
ALTER TABLE HoaDon
  ADD CONSTRAINT fk_hd_dh FOREIGN KEY (DonHangID) REFERENCES DonHang(DonHangID);
ALTER TABLE ThanhToan
  ADD CONSTRAINT fk_tt_hd FOREIGN KEY (HoaDonID) REFERENCES HoaDon(HoaDonID);
ALTER TABLE VanDon
  ADD CONSTRAINT fk_vd_dh FOREIGN KEY (DonHangID) REFERENCES DonHang(DonHangID);

-- Mã giảm giá
ALTER TABLE DonHang_MaGiamGia
  ADD CONSTRAINT fk_dhmg_dh FOREIGN KEY (DonHangID) REFERENCES DonHang(DonHangID) ON DELETE CASCADE;
ALTER TABLE DonHang_MaGiamGia
  ADD CONSTRAINT fk_dhmg_mg FOREIGN KEY (MaID)      REFERENCES MaGiamGia(MaID);

-- Báo cáo
ALTER TABLE BaoCao
  ADD CONSTRAINT fk_bc_nv FOREIGN KEY (NhanVienID) REFERENCES NhanVien(NhanVienID);

--CHECK 
ALTER TABLE DonHang_ChiTiet
  ADD CONSTRAINT ck_dhct_qty CHECK (SoLuong > 0);
ALTER TABLE DonHang_ChiTiet
  ADD CONSTRAINT ck_dhct_price CHECK (DonGia >= 0);

ALTER TABLE TonKhoKho
  ADD CONSTRAINT ck_ton_nonneg CHECK (SoLuong >= 0);

ALTER TABLE dbo.SanPham
ADD CONSTRAINT ck_sp_time_order CHECK (created_at <= updated_at);

SET FOREIGN_KEY_CHECKS = 1;

/* Lấy brand id đã có sẵn  */
DECLARE @th_bw INT, @th_sx INT;
SELECT @th_bw = ThuongHieuID FROM dbo.ThuongHieu WHERE Ten=N'BasicWear';
SELECT @th_sx = ThuongHieuID FROM dbo.ThuongHieu WHERE Ten=N'StreetX';

/* Phân loại */
INSERT INTO dbo.PhanLoai (Ten) VALUES (N'Áo'), (N'Quần'), (N'Giày');

DECLARE @pl_ao INT, @pl_quan INT, @pl_giay INT;
SELECT @pl_ao   = PhanLoaiID FROM dbo.PhanLoai WHERE Ten=N'Áo';
SELECT @pl_quan = PhanLoaiID FROM dbo.PhanLoai WHERE Ten=N'Quần';
SELECT @pl_giay = PhanLoaiID FROM dbo.PhanLoai WHERE Ten=N'Giày';

/* ==== Danh mục gốc ==== */
INSERT INTO dbo.DanhMuc (Ten, PhanLoaiID, ParentID)
VALUES (N'Áo', @pl_ao, NULL), (N'Quần', @pl_quan, NULL), (N'Giày', @pl_giay, NULL);

DECLARE @dm_ao INT, @dm_quan INT, @dm_giay INT;
SELECT @dm_ao   = DanhMucID FROM dbo.DanhMuc WHERE Ten=N'Áo';
SELECT @dm_quan = DanhMucID FROM dbo.DanhMuc WHERE Ten=N'Quần';
SELECT @dm_giay = DanhMucID FROM dbo.DanhMuc WHERE Ten=N'Giày';

/* Danh mục con */
INSERT INTO dbo.DanhMuc (Ten, PhanLoaiID, ParentID) VALUES
(N'Áo thun',      @pl_ao,   @dm_ao),
(N'Áo khoác',     @pl_ao,   @dm_ao),
(N'Quần jean',    @pl_quan, @dm_quan),
(N'Giày sneaker', @pl_giay, @dm_giay);

DECLARE @dm_ao_thun INT, @dm_ao_khoac INT, @dm_quan_jean INT, @dm_giay_snkr INT;
SELECT @dm_ao_thun   = DanhMucID FROM dbo.DanhMuc WHERE Ten=N'Áo thun';
SELECT @dm_ao_khoac  = DanhMucID FROM dbo.DanhMuc WHERE Ten=N'Áo khoác';
SELECT @dm_quan_jean = DanhMucID FROM dbo.DanhMuc WHERE Ten=N'Quần jean';
SELECT @dm_giay_snkr = DanhMucID FROM dbo.DanhMuc WHERE Ten=N'Giày sneaker';

/* Sản phẩm*/
INSERT INTO dbo.SanPham (TenSanPham, MoTa, DanhMucID, ThuongHieuID) VALUES
(N'Áo thun basic premium', N'Cotton compact, không xù',           @dm_ao_thun,  @th_bw),
(N'Áo thun oversized',     N'Vải dày 220gsm, form rộng',          @dm_ao_thun,  @th_sx),
(N'Áo khoác dù nhẹ',       N'Chống gió, chống nước nhẹ',          @dm_ao_khoac, @th_bw),
(N'Quần jean tapered',     N'Denim co giãn, cạp vừa',             @dm_quan_jean,@th_sx),
(N'Quần jean regular',     N'Denim dày, bền màu',                 @dm_quan_jean,@th_bw),
(N'Sneaker classic',       N'Đế cao su, upper da tổng hợp',       @dm_giay_snkr,@th_sx);

/* Lấy id sản phẩm theo tên để chèn SKU */
DECLARE 
  @sp_ao_thun_basic    INT,
  @sp_ao_thun_oversize INT,
  @sp_ao_khoac         INT,
  @sp_quan_tapered     INT,
  @sp_quan_regular     INT,
  @sp_sneaker          INT;

SELECT @sp_ao_thun_basic    = SanPhamID FROM dbo.SanPham WHERE TenSanPham=N'Áo thun basic premium';
SELECT @sp_ao_thun_oversize = SanPhamID FROM dbo.SanPham WHERE TenSanPham=N'Áo thun oversized';
SELECT @sp_ao_khoac         = SanPhamID FROM dbo.SanPham WHERE TenSanPham=N'Áo khoác dù nhẹ';
SELECT @sp_quan_tapered     = SanPhamID FROM dbo.SanPham WHERE TenSanPham=N'Quần jean tapered';
SELECT @sp_quan_regular     = SanPhamID FROM dbo.SanPham WHERE TenSanPham=N'Quần jean regular';
SELECT @sp_sneaker          = SanPhamID FROM dbo.SanPham WHERE TenSanPham=N'Sneaker classic';

/* Màu & Size */
INSERT INTO dbo.MauSac (Ten, MaHex) VALUES (N'Trắng', N'#FFFFFF'), (N'Đen', N'#000000'), (N'Xanh', N'#1E90FF');
INSERT INTO dbo.[Size] (KyHieu, ThuTu) VALUES (N'S',1),(N'M',2),(N'L',3),(N'40',10),(N'41',11);

DECLARE @m_trang INT, @m_den INT, @m_xanh INT, @s_S INT, @s_M INT, @s_L INT, @s_40 INT, @s_41 INT;
SELECT @m_trang = MauID FROM dbo.MauSac WHERE Ten=N'Trắng';
SELECT @m_den   = MauID FROM dbo.MauSac WHERE Ten=N'Đen';
SELECT @m_xanh  = MauID FROM dbo.MauSac WHERE Ten=N'Xanh';
SELECT @s_S  = SizeID FROM dbo.[Size] WHERE KyHieu=N'S';
SELECT @s_M  = SizeID FROM dbo.[Size] WHERE KyHieu=N'M';
SELECT @s_L  = SizeID FROM dbo.[Size] WHERE KyHieu=N'L';
SELECT @s_40 = SizeID FROM dbo.[Size] WHERE KyHieu=N'40';
SELECT @s_41 = SizeID FROM dbo.[Size] WHERE KyHieu=N'41';

/* SKU*/
INSERT INTO dbo.SanPham_BienThe (SanPhamID, MauID, SizeID, SKU, Barcode, GiaBan, GiaNhap, TrangThai) VALUES
(@sp_ao_thun_basic, @m_trang, @s_M, N'TS-TRANG-M', N'1110001', 199000, 120000, N'ACTIVE'),
(@sp_ao_thun_basic, @m_den,   @s_L, N'TS-DEN-L',   N'1110002', 199000, 120000, N'ACTIVE'),
(@sp_quan_tapered,  @m_den,   @s_M, N'JE-DEN-M',   N'2220001', 299000, 200000, N'ACTIVE'),
(@sp_sneaker,       @m_xanh,  @s_40,N'SN-XANH-40', N'3330001', 699000, 450000, N'ACTIVE'),
(@sp_sneaker,       @m_xanh,  @s_41,N'SN-XANH-41', N'3330002', 699000, 450000, N'ACTIVE');

/* ===== Tài khoản & Hồ sơ ===== */
INSERT INTO dbo.TaiKhoan (TenDangNhap, MatKhauHash, VaiTro)
VALUES (N'khoa@example.com', N'$2a$10$hashNV', N'NV'),
       (N'a.nguyen@example.com', N'$2a$10$hashKH', N'KH'),
       (N'kimthao12a17@gmail.com', N'$2a$10$hashAD', N'ADMIN');

DECLARE @tk_nv INT, @tk_kh INT, @tk_ad INT;
SELECT @tk_nv = TaiKhoanID FROM dbo.TaiKhoan WHERE TenDangNhap=N'khoa@example.com';
SELECT @tk_kh = TaiKhoanID FROM dbo.TaiKhoan WHERE TenDangNhap=N'a.nguyen@example.com';
SELECT @tk_ad = TaiKhoanID FROM dbo.TaiKhoan WHERE TenDangNhap=N'kimthao@gmail.com';

INSERT INTO dbo.NhanVien (HoTen, GioiTinh, ngaySinh, Email, SoDienThoai, ChucVu, TaiKhoanID) VALUES
(N'Phạm Minh Khoa', N'NAM', '1992-04-10', N'khoa@example.com', N'0909111222', N'Nhân viên', @tk_nv),
(N'Đặng Thị Kim Thảo',     N'NU',  '1995-09-21', N'kimthao12a17@gmail.com', N'0909333444', N'Quản lý',   @tk_ad);

INSERT INTO dbo.KhachHang (HoTen, GioiTinh, ngaySinh, Email, SoDienThoai, TaiKhoanID) VALUES
(N'Nguyễn Văn An', N'NAM', '1994-06-15', N'a.nguyen@example.com', N'0909000001', @tk_kh);

/*Tồn kho*/
INSERT INTO dbo.TonKho (BienTheID, OnHand, Reserved, AvgCost) VALUES
(1, 50, 2, 125000.00),
(2, 30, 0, 120000.00),
(3, 70, 3, 205000.00),
(4, 25, 0, 455000.00),
(5, 40, 1, 452000.00);


-- TaiKhoan
CREATE OR ALTER TRIGGER trg_touch_TaiKhoan ON dbo.TaiKhoan
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF (UPDATE(updated_at)) RETURN;
  UPDATE t SET updated_at = SYSDATETIME()
  FROM dbo.TaiKhoan t
  JOIN inserted i ON i.TaiKhoanID = t.TaiKhoanID;
END
GO

-- KhachHang
CREATE OR ALTER TRIGGER trg_touch_KhachHang ON dbo.KhachHang
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF (UPDATE(updated_at)) RETURN;
  UPDATE t SET updated_at = SYSDATETIME()
  FROM dbo.KhachHang t
  JOIN inserted i ON i.KhachHangID = t.KhachHangID;
END
GO

-- NhanVien
CREATE OR ALTER TRIGGER trg_touch_NhanVien ON dbo.NhanVien
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF (UPDATE(updated_at)) RETURN;
  UPDATE t SET updated_at = SYSDATETIME()
  FROM dbo.NhanVien t
  JOIN inserted i ON i.NhanVienID = t.NhanVienID;
END
GO

-- DiaChi
CREATE OR ALTER TRIGGER trg_touch_DiaChi ON dbo.DiaChi
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF (UPDATE(updated_at)) RETURN;
  UPDATE t SET updated_at = SYSDATETIME()
  FROM dbo.DiaChi t
  JOIN inserted i ON i.DiaChiID = t.DiaChiID;
END
GO

-- SanPham
CREATE OR ALTER TRIGGER trg_touch_SanPham ON dbo.SanPham
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF (UPDATE(updated_at)) RETURN;
  UPDATE t SET updated_at = SYSDATETIME()
  FROM dbo.SanPham t
  JOIN inserted i ON i.SanPhamID = t.SanPhamID;
END
GO

-- SanPham_BienThe
CREATE OR ALTER TRIGGER trg_touch_SanPham_BienThe ON dbo.SanPham_BienThe
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF (UPDATE(updated_at)) RETURN;
  UPDATE t SET updated_at = SYSDATETIME()
  FROM dbo.SanPham_BienThe t
  JOIN inserted i ON i.BienTheID = t.BienTheID;
END
GO

-- TonKho
CREATE OR ALTER TRIGGER trg_touch_TonKho ON dbo.TonKho
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF (UPDATE(updated_at)) RETURN;
  UPDATE t SET updated_at = SYSDATETIME()
  FROM dbo.TonKho t
  JOIN inserted i ON i.BienTheID = t.BienTheID;
END
GO

-- DonHang
CREATE OR ALTER TRIGGER trg_touch_DonHang ON dbo.DonHang
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF (UPDATE(updated_at)) RETURN;
  UPDATE t SET updated_at = SYSDATETIME()
  FROM dbo.DonHang t
  JOIN inserted i ON i.DonHangID = t.DonHangID;
END
GO


