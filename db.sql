/* ============================================================
   RESET DATABASE fashion_shop (drop nếu đã tồn tại)
   ============================================================ */

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'fashion_shop')
BEGIN
    ALTER DATABASE fashion_shop SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE fashion_shop;
END
GO

/* ============================================================
   CREATE DATABASE fashion_shop
   ============================================================ */

CREATE DATABASE fashion_shop;
GO

USE fashion_shop;
GO

CREATE TABLE Roles
(
    RoleId INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100) NOT NULL
);

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
  PhanLoaiID INT NOT NULL,
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

/* Đánh giá sản phẩm (từ khách thật trong app hoặc import Amazon) */
CREATE TABLE dbo.DanhGia (
  ReviewID        BIGINT IDENTITY(1,1) PRIMARY KEY,
  SanPhamID       INT NOT NULL,
  KhachHangID     INT NULL,                 -- có thể NULL khi import từ Amazon
  ExternalUserID  NVARCHAR(100) NULL,       -- user id từ nguồn ngoài (Amazon)
  Rating          DECIMAL(3,2) NOT NULL,    -- 1..5 (có thể 0.5 step)
  ReviewTitle     NVARCHAR(300) NULL,
  ReviewText      NVARCHAR(MAX) NULL,
  VerifiedPurchase BIT NOT NULL DEFAULT(0),
  ReviewSource    NVARCHAR(20) NOT NULL 
                  CONSTRAINT ck_review_source CHECK (ReviewSource IN (N'INTERNAL',N'AMAZON',N'AGREASE')),
  ReviewTime      DATETIME2(3) NOT NULL CONSTRAINT df_review_time DEFAULT SYSDATETIME(),
  CONSTRAINT fk_dg_sp FOREIGN KEY (SanPhamID) REFERENCES dbo.SanPham(SanPhamID),
  CONSTRAINT fk_dg_kh FOREIGN KEY (KhachHangID) REFERENCES dbo.KhachHang(KhachHangID)
);
GO

-- Tổng hợp điểm đánh giá để hiển thị nhanh
CREATE TABLE dbo.SanPham_RatingAgg (
  SanPhamID    INT PRIMARY KEY,
  AvgRating    DECIMAL(4,2) NOT NULL DEFAULT(0),
  RatingCount  INT NOT NULL DEFAULT(0),
  UpdatedAt    DATETIME2(3) NOT NULL DEFAULT SYSDATETIME(),
  CONSTRAINT fk_ragg_sp FOREIGN KEY (SanPhamID) REFERENCES dbo.SanPham(SanPhamID)
);
GO

/* Kết quả phân tích cảm xúc từ BiLSTM-Attention */
CREATE TABLE dbo.Review_Sentiment (
  ReviewID        BIGINT NOT NULL PRIMARY KEY,
  SentimentLabel  NVARCHAR(8) NOT NULL 
                  CONSTRAINT ck_sent_label CHECK (SentimentLabel IN (N'NEG',N'NEU',N'POS')),
  SentimentScore  DECIMAL(6,5) NOT NULL,    -- e.g. xác suất POS
  AspectTermsJson NVARCHAR(MAX) NULL,       -- nếu có trích xuất aspect/opinion
  ModelName       NVARCHAR(80) NOT NULL,    -- 'BiLSTM-Attention'
  ModelVersion    NVARCHAR(40) NOT NULL,    -- ví dụ 'v1.0'
  InferredAt      DATETIME2(3) NOT NULL DEFAULT SYSDATETIME(),
  CONSTRAINT fk_sent_review FOREIGN KEY (ReviewID) REFERENCES dbo.DanhGia(ReviewID)
);
CREATE INDEX IX_DanhGia_SanPham_Time ON dbo.DanhGia (SanPhamID, ReviewTime DESC);
GO

/* Nhật ký tương tác User–Product (đủ cho view/click/cart/purchase/like) */
CREATE TABLE dbo.User_Product_Interaction (
  InteractionID BIGINT IDENTITY(1,1) PRIMARY KEY,
  KhachHangID   INT NOT NULL,
  SanPhamID     INT NOT NULL,
  BienTheID     INT NULL,
  EventType     NVARCHAR(16) NOT NULL
                CONSTRAINT ck_evt_type CHECK (EventType IN
                   (N'VIEW',N'CLICK',N'ADD_TO_CART',N'PURCHASE',N'LIKE',N'WISHLIST')),
  ViewTimeSec   INT NULL,              -- thời gian xem (giây)
  Quantity      INT NULL,              -- cho ADD_TO_CART/PURCHASE
  Channel       NVARCHAR(20) NULL,     -- ONLINE/OFFLINE/APP/WEB
  Referrer      NVARCHAR(60) NULL,     -- nguồn vào (search, campaign,…)
  Device        NVARCHAR(30) NULL,     -- MOBILE/IOS/ANDROID/DESKTOP
  SessionID     NVARCHAR(64) NULL,
  OccurredAt    DATETIME2(3) NOT NULL CONSTRAINT df_evt_time DEFAULT SYSDATETIME(),
  CONSTRAINT fk_evt_kh FOREIGN KEY (KhachHangID) REFERENCES dbo.KhachHang(KhachHangID),
  CONSTRAINT fk_evt_sp FOREIGN KEY (SanPhamID)   REFERENCES dbo.SanPham(SanPhamID),
  CONSTRAINT fk_evt_bt FOREIGN KEY (BienTheID)   REFERENCES dbo.SanPham_BienThe(BienTheID)
);
GO

CREATE INDEX IX_EVT_User_Time ON dbo.User_Product_Interaction (KhachHangID, OccurredAt DESC);
CREATE INDEX IX_EVT_Product_Time ON dbo.User_Product_Interaction (SanPhamID, OccurredAt DESC);

/* Phơi nhiễm ưu đãi/chiến dịch để tạo feature has_received_offer */
CREATE TABLE dbo.Marketing_Exposure (
  ExposureID  BIGINT IDENTITY(1,1) PRIMARY KEY,
  KhachHangID INT NOT NULL,
  MaID        INT NULL,                -- mã giảm giá trong hệ thống (nếu có)
  Campaign    NVARCHAR(80) NULL,
  Channel     NVARCHAR(20) NULL,       -- EMAIL/PUSH/ADS/… 
  ExposedAt   DATETIME2(3) NOT NULL DEFAULT SYSDATETIME(),
  CONSTRAINT fk_me_kh FOREIGN KEY (KhachHangID) REFERENCES dbo.KhachHang(KhachHangID),
  CONSTRAINT fk_me_mgg FOREIGN KEY (MaID)        REFERENCES dbo.MaGiamGia(MaID)
);
CREATE INDEX IX_MKT_User_Time ON dbo.Marketing_Exposure (KhachHangID, ExposedAt DESC);
GO

/* Mở rộng hồ sơ KH cho dữ liệu nhân khẩu học từ “Predict Customer Purchase Behavior” */
CREATE TABLE dbo.KhachHang_Profile (
  KhachHangID            INT PRIMARY KEY,
  CityCategory           NVARCHAR(10) NULL,   -- A/B/C
  StayYearsInCurrentCity TINYINT NULL,        -- 0..n
  MaritalStatus          BIT NULL,            -- 0/1
  Occupation             NVARCHAR(80) NULL,
  IncomeBracket          NVARCHAR(40) NULL,   -- Low/Med/High hoặc khoảng số
  InterestsJson          NVARCHAR(MAX) NULL,  -- sở thích (tags)
  UpdatedAt              DATETIME2(3) NOT NULL DEFAULT SYSDATETIME(),
  CONSTRAINT fk_khprof_kh FOREIGN KEY (KhachHangID) REFERENCES dbo.KhachHang(KhachHangID)
);
GO

/* Đăng ký mô hình đã deploy (LogReg, TabPFN-v2, RF, GB, BiLSTM-Attn…) */
CREATE TABLE dbo.ML_Model (
  ModelID      INT IDENTITY(1,1) PRIMARY KEY,
  ModelName    NVARCHAR(80) NOT NULL,        -- 'LogisticRegression','TabPFN-v2','RF-Regressor',...
  Task         NVARCHAR(20) NOT NULL
               CONSTRAINT ck_model_task CHECK (Task IN (N'RECO',N'PURCHASE',N'SENTIMENT')),
  Framework    NVARCHAR(40) NULL,            -- 'sklearn','tabpfn','pytorch','onnx'
  Version      NVARCHAR(40) NOT NULL,        -- 'v1.1.0'
  TrainedAt    DATETIME2(3) NOT NULL DEFAULT SYSDATETIME(),
  MetricsJson  NVARCHAR(MAX) NULL            -- lưu AUC, F1, RMSE, v.v.
);
GO

/* Log điểm gợi ý (Regression score) theo user–product–model */
CREATE TABLE dbo.Recommendation_Score (
  RecID       BIGINT IDENTITY(1,1) PRIMARY KEY,
  ModelID     INT NOT NULL,
  KhachHangID INT NOT NULL,
  SanPhamID   INT NOT NULL,
  Score       DECIMAL(9,6) NOT NULL,    -- 0..1 hoặc 0..10
  RankInList  INT NULL,                  -- xếp hạng trong danh sách đề xuất
  CreatedAt   DATETIME2(3) NOT NULL DEFAULT SYSDATETIME(),
  CONSTRAINT fk_rec_model FOREIGN KEY (ModelID) REFERENCES dbo.ML_Model(ModelID),
  CONSTRAINT fk_rec_user  FOREIGN KEY (KhachHangID) REFERENCES dbo.KhachHang(KhachHangID),
  CONSTRAINT fk_rec_prod  FOREIGN KEY (SanPhamID)   REFERENCES dbo.SanPham(SanPhamID)
);
CREATE INDEX IX_Rec_User_Time ON dbo.Recommendation_Score (KhachHangID, CreatedAt DESC);
GO

/* Log dự đoán mua hàng (Classification) */
CREATE TABLE dbo.Purchase_Prediction_Log (
  PredID      BIGINT IDENTITY(1,1) PRIMARY KEY,
  ModelID     INT NOT NULL,
  KhachHangID INT NOT NULL,
  SanPhamID   INT NULL,                  -- có thể dự đoán theo user-level hoặc theo item cụ thể
  Probability DECIMAL(9,6) NOT NULL,     -- P(buy=1)
  Threshold   DECIMAL(9,6) NULL,         -- ngưỡng đang áp dụng
  PredLabel   BIT NOT NULL,              -- 1 = mua, 0 = không
  FeaturesJson NVARCHAR(MAX) NULL,       -- optional: snapshot feature
  CreatedAt    DATETIME2(3) NOT NULL DEFAULT SYSDATETIME(),
  CONSTRAINT fk_pp_model FOREIGN KEY (ModelID) REFERENCES dbo.ML_Model(ModelID),
  CONSTRAINT fk_pp_user  FOREIGN KEY (KhachHangID) REFERENCES dbo.KhachHang(KhachHangID),
  CONSTRAINT fk_pp_prod  FOREIGN KEY (SanPhamID) REFERENCES dbo.SanPham(SanPhamID)
);
CREATE INDEX IX_PP_User_Time ON dbo.Purchase_Prediction_Log (KhachHangID, CreatedAt DESC);
GO


-- Unique / Index
ALTER TABLE KhachHang ADD CONSTRAINT uq_kh_email UNIQUE (Email);
ALTER TABLE TaiKhoan  ADD CONSTRAINT uq_tk_username UNIQUE (TenDangNhap);
ALTER TABLE ThuongHieu ADD UNIQUE (Ten);
ALTER TABLE Size ADD UNIQUE (KyHieu);
ALTER TABLE SanPham_BienThe ADD UNIQUE (SKU);
ALTER TABLE SanPham_BienThe ADD UNIQUE (SanPhamID, MauID, SizeID);
ALTER TABLE MaGiamGia ADD UNIQUE (Code);

-- Sản phẩm → danh mục/brand
IF EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'fk_sp_dm'
)
BEGIN
    ALTER TABLE dbo.SanPham DROP CONSTRAINT fk_sp_dm;
END
GO

IF EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'fk_sp_th'
)
BEGIN
    ALTER TABLE dbo.SanPham DROP CONSTRAINT fk_sp_th;
END
GO

ALTER TABLE dbo.SanPham
ADD CONSTRAINT fk_sp_th FOREIGN KEY (ThuongHieuID) REFERENCES dbo.ThuongHieu(ThuongHieuID);
GO

/*
-- Tài khoản ↔ khách
ALTER TABLE TaiKhoan
  ADD CONSTRAINT fk_tk_kh FOREIGN KEY (KhachHangID) REFERENCES KhachHang(KhachHangID);
*/

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
GO

-- TaiKhoan
CREATE OR ALTER TRIGGER trg_touch_TaiKhoan
ON dbo.TaiKhoan
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Nếu cột updated_at đã được cập nhật thì bỏ qua
    IF (UPDATE(updated_at)) RETURN;

    UPDATE t
        SET updated_at = SYSDATETIME()
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

/* View tổng hợp hành vi → tạo feature cho RECO/Classification */
CREATE OR ALTER VIEW dbo.vw_UserProduct_Features AS
SELECT
  u.KhachHangID,
  e.SanPhamID,
  SUM(CASE WHEN e.EventType = N'VIEW'        THEN 1 ELSE 0 END) AS view_cnt,
  SUM(CASE WHEN e.EventType = N'CLICK'       THEN 1 ELSE 0 END) AS click_cnt,
  SUM(CASE WHEN e.EventType = N'ADD_TO_CART' THEN 1 ELSE 0 END) AS addcart_cnt,
  SUM(CASE WHEN e.EventType = N'PURCHASE'    THEN 1 ELSE 0 END) AS purchase_cnt,
  AVG(NULLIF(e.ViewTimeSec,0))                                     AS avg_view_time,
  MAX(e.OccurredAt)                                                AS last_interaction_at,
  MAX(CASE WHEN me.KhachHangID IS NULL THEN 0 ELSE 1 END)          AS has_received_offer
FROM dbo.KhachHang u
LEFT JOIN dbo.User_Product_Interaction e
  ON u.KhachHangID = e.KhachHangID
LEFT JOIN dbo.Marketing_Exposure me
  ON u.KhachHangID = me.KhachHangID 
GROUP BY u.KhachHangID, e.SanPhamID;
GO

/* View ghép thêm đặc tính sản phẩm & điểm rating tổng hợp */
CREATE OR ALTER VIEW dbo.vw_UserProduct_Trainset AS
SELECT
  f.*,
  sp.DanhMucID,
  sp.ThuongHieuID,
  ra.AvgRating,
  ra.RatingCount
FROM dbo.vw_UserProduct_Features f
JOIN dbo.SanPham sp ON sp.SanPhamID = f.SanPhamID
LEFT JOIN dbo.SanPham_RatingAgg ra ON ra.SanPhamID = f.SanPhamID;

/* ============================================================ */
/* ============================================================ */
/* ============================================================ */
/* ============================================================ */

DROP TABLE IF EXISTS Staging_ProductData;

CREATE TABLE Staging_ProductData (
    product_id NVARCHAR(100),
    product_name NVARCHAR(255),
    brand NVARCHAR(255),
    category NVARCHAR(255),
    sub_category NVARCHAR(255),
    price DECIMAL(12,2),
    cost DECIMAL(12,2),
    rating DECIMAL(3,2),
    image_url NVARCHAR(500)
);
GO
DECLARE @tk_nv INT;
DECLARE @tk_ad INT;

ALTER TABLE dbo.TaiKhoan
DROP CONSTRAINT ck_tk_vaitro;
GO

ALTER TABLE dbo.TaiKhoan
DROP COLUMN VaiTro;
GO
ALTER TABLE dbo.TaiKhoan
ADD RoleId INT NULL;
GO
ALTER TABLE dbo.TaiKhoan
ADD CONSTRAINT fk_tk_role FOREIGN KEY (RoleId)
REFERENCES dbo.Roles(RoleId);
GO


ALTER TABLE dbo.DanhMuc
DROP COLUMN ParentID;
GO

DROP TABLE IF EXISTS dbo.Purchase_Prediction_Log;
GO

DROP TABLE IF EXISTS dbo.Recommendation_Score;
GO

DROP TABLE IF EXISTS dbo.ML_Model;
GO

DROP TABLE IF EXISTS dbo.Marketing_Exposure;
GO

DROP TABLE IF EXISTS dbo.PhatSinhKho;
GO

DROP TABLE IF EXISTS dbo.Review_Sentiment;
GO

DROP TABLE IF EXISTS dbo.SanPham_RatingAgg;
GO

DROP TABLE IF EXISTS dbo.KhachHang_Profile;
GO

DROP TABLE IF EXISTS dbo.DiaChi;
GO

DROP TABLE IF EXISTS dbo.GioHang;
GO

ALTER TABLE dbo.GioHang_ChiTiet DROP CONSTRAINT fk_ghct_gh;
GO

ALTER TABLE dbo.GioHang_ChiTiet DROP CONSTRAINT fk_ghct_bt;
GO

DROP TABLE IF EXISTS dbo.GioHang_ChiTiet;
GO

DROP TABLE IF EXISTS dbo.HoaDon;
GO

DROP TABLE IF EXISTS dbo.ThanhToan;
GO

DROP TABLE IF EXISTS dbo.DonHang_MaGiamGia;
GO

DROP TABLE IF EXISTS dbo.MaGiamGia;
GO

DROP TABLE IF EXISTS dbo.BaoCao;
GO
/* ============================================================ */
/* ============================================================ */
/* ============================================================ */
/* ============================================================ */


/* ============================================================
   B2. Insert PhanLoai (category)
   ============================================================ */

INSERT INTO dbo.PhanLoai (Ten)
VALUES
 (N'Sporting Goods'),
 (N'Free Items'),
 (N'Personal Care'),
 (N'Accessories'),
 (N'Apparel'),
 (N'Footwear'),
 (N'Home');
 GO


/* ============================================================
   B2. Insert DanhMuc (sub_category)
   ============================================================ */
PRINT '============================================';
PRINT '      B2. INSERT DANHMUC (SUB-CATEGORY)';
PRINT '============================================';

INSERT INTO dbo.DanhMuc (Ten, PhanLoaiID)
SELECT DISTINCT
    sp.sub_category,
    pl.PhanLoaiID
FROM Staging_ProductData sp
JOIN dbo.PhanLoai pl 
    ON pl.Ten = sp.category
WHERE sp.sub_category IS NOT NULL
  AND sp.sub_category NOT IN (SELECT Ten FROM dbo.DanhMuc);


PRINT '→ Done DanhMuc';
GO


/* ============================================================
   B3. Insert ThuongHieu
   ============================================================ */

PRINT '============================================';
PRINT '      B3. INSERT THUONGHIEU';
PRINT '============================================';

INSERT INTO dbo.ThuongHieu (Ten)
SELECT DISTINCT brand
FROM Staging_ProductData
WHERE brand IS NOT NULL
  AND brand NOT IN (SELECT Ten FROM dbo.ThuongHieu);

PRINT '→ Done ThuongHieu';
GO


/* ============================================================
   B4. Insert SanPham
   ============================================================ */

PRINT '============================================';
PRINT '      B4. INSERT SANPHAM';
PRINT '============================================';

INSERT INTO dbo.SanPham (TenSanPham, MoTa, DanhMucID, ThuongHieuID)
SELECT DISTINCT
    sp.product_name,
    N'Mô tả tự động từ dataset Kaggle',
    dm.DanhMucID,
    th.ThuongHieuID
FROM Staging_ProductData sp
LEFT JOIN dbo.DanhMuc dm ON dm.Ten = sp.sub_category
LEFT JOIN dbo.ThuongHieu th ON th.Ten = sp.brand
WHERE sp.product_name NOT IN (SELECT TenSanPham FROM dbo.SanPham);

PRINT '→ Done SanPham';
GO


/* ============================================================
   B5. Insert MauSac (default)
   ============================================================ */

PRINT '============================================';
PRINT '      B5. INSERT MAUSAC';
PRINT '============================================';

IF NOT EXISTS (SELECT 1 FROM dbo.MauSac)
BEGIN
    INSERT INTO dbo.MauSac (Ten, MaHex) VALUES
    (N'Trắng', '#FFFFFF'),
    (N'Đen',   '#000000'),
    (N'Xanh',  '#1E90FF');
END

PRINT '→ Done MauSac';
GO


/* ============================================================
   B6. Insert Size (default)
   ============================================================ */

PRINT '============================================';
PRINT '      B6. INSERT SIZE';
PRINT '============================================';

IF NOT EXISTS (SELECT 1 FROM dbo.[Size] WHERE KyHieu='S')
INSERT INTO dbo.[Size] (KyHieu, ThuTu) VALUES ('S',1);

IF NOT EXISTS (SELECT 1 FROM dbo.[Size] WHERE KyHieu='M')
INSERT INTO dbo.[Size] (KyHieu, ThuTu) VALUES ('M',2);

IF NOT EXISTS (SELECT 1 FROM dbo.[Size] WHERE KyHieu='L')
INSERT INTO dbo.[Size] (KyHieu, ThuTu) VALUES ('L',3);

PRINT '→ Done Size';
GO


/* ============================================================
   B7. Insert Biến thể SKU (9 SKU/sản phẩm)
   ============================================================ */
PRINT '============================================';
PRINT '      B7. INSERT SANPHAM_BIENTHE (SKU)';
PRINT '============================================';

-- đảm bảo bảng MauSac có dữ liệu
IF NOT EXISTS (SELECT 1 FROM MauSac)
BEGIN
    INSERT INTO MauSac (Ten, MaHex)
    VALUES (N'Đỏ','#FF0000'),(N'Đen','#000000'),(N'Xanh','#00FF00');
END
GO

-- đảm bảo bảng Size có dữ liệu
IF NOT EXISTS (SELECT 1 FROM [Size])
BEGIN
    INSERT INTO [Size] (KyHieu, ThuTu)
    VALUES (N'S',1),(N'M',2),(N'L',3);
END
GO

-- Insert SKU nếu chưa tồn tại
INSERT INTO SanPham_BienThe (SanPhamID, MauID, SizeID, SKU, GiaBan, GiaNhap, TrangThai)
SELECT 
    sp.SanPhamID,
    ms.MauID,
    s.SizeID,
    CONCAT('SKU-', sp.SanPhamID, '-', ms.MauID, '-', s.SizeID),
    ABS(CHECKSUM(NEWID())) % 500000 + 100000,
    ABS(CHECKSUM(NEWID())) % 300000 + 50000,
    'ACTIVE'
FROM SanPham sp
CROSS JOIN MauSac ms
CROSS JOIN [Size] s
WHERE NOT EXISTS (
    SELECT 1 FROM SanPham_BienThe bt
    WHERE bt.SanPhamID = sp.SanPhamID
      AND bt.MauID = ms.MauID
      AND bt.SizeID = s.SizeID
);

PRINT '→ Done SanPham_BienThe';
GO


/* ============================================================
   B8. Insert TonKho (tự random)
   ============================================================ */

PRINT '============================================';
PRINT '      B8. INSERT TONKHO';
PRINT '============================================';

INSERT INTO dbo.TonKho (BienTheID, OnHand, Reserved, AvgCost)
SELECT 
    bt.BienTheID,
    ABS(CHECKSUM(NEWID())) % 90 + 10,  -- tồn kho 10 → 100
    0,
    bt.GiaNhap
FROM dbo.SanPham_BienThe bt
WHERE bt.BienTheID NOT IN (SELECT BienTheID FROM dbo.TonKho);

PRINT '→ Done TonKho';
GO


/* ============================================================
   B9. Insert ảnh sản phẩm
   ============================================================ */
/* ============================ */
/*    ADD ExternalID only once  */
/* ============================ */
IF COL_LENGTH('dbo.SanPham', 'ExternalID') IS NULL
    ALTER TABLE dbo.SanPham ADD ExternalID NVARCHAR(50) NULL;
GO


/* ============================ */
/*      UPDATE ExternalID       */
/* ============================ */

UPDATE sp
SET sp.ExternalID = st.product_id
FROM dbo.SanPham sp
JOIN Staging_ProductData st 
      ON sp.TenSanPham = CONCAT('SP ', st.product_id);
GO


/* ============================ */
/*      INSERT dummy images     */
/* ============================ */

PRINT '============================================';
PRINT '      INSERT ANHSANPHAM (LOCAL IMAGE PATH)';
PRINT '============================================';

INSERT INTO dbo.AnhSanPham (SanPhamID, URL, IsPrimary)
SELECT 
    sp.SanPhamID,
    CONCAT(
        '/Content/images/',
        sp.SanPhamID,
        '.jpg'
    ) AS URL,
    1 AS IsPrimary
FROM dbo.SanPham sp
WHERE NOT EXISTS (
    SELECT 1 
    FROM dbo.AnhSanPham a
    WHERE a.SanPhamID = sp.SanPhamID
);
GO

PRINT '→ Done AnhSanPham';


/* ============================================================
   B10. Fix UNIQUE lỗi & Insert KhachHang từ dataset
   ============================================================ */
-- DROP ALL UNIQUE constraints on KhachHang
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql = @sql + 
    'ALTER TABLE dbo.KhachHang DROP CONSTRAINT [' + i.name + '];'
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID('dbo.KhachHang')
  AND i.is_unique = 1
  AND i.is_primary_key = 0;

EXEC(@sql);


-- INSERT KhachHang SAFE
;WITH KH AS (
    SELECT DISTINCT st.product_id
    FROM Staging_ProductData st
    WHERE st.product_id IS NOT NULL AND st.product_id <> ''
)
INSERT INTO dbo.KhachHang (HoTen, GioiTinh, ngaySinh, Email, SoDienThoai)
SELECT 
    CONCAT(N'User ', kh.product_id),
    CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN N'NAM' ELSE N'NU' END,
    DATEFROMPARTS(1990 + (ABS(CHECKSUM(NEWID())) % 20), 1, 1),
    CONCAT('user', kh.product_id, '@mail.com'),
    CONCAT('09', RIGHT('00000000' 
        + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS VARCHAR(8)), 8))
FROM KH kh
WHERE CONCAT('user', kh.product_id, '@mail.com') NOT IN (
    SELECT Email FROM dbo.KhachHang
);



/* ============================================================
   B11. Insert User_Product_Interaction
        VIEW, CLICK, ADD_TO_CART, PURCHASE
   ============================================================ */

PRINT '============================================';
PRINT '      B11. INSERT USER_PRODUCT_INTERACTION';
PRINT '============================================';

-- Tạo bảng tạm BaseEvents dùng cho nhiều INSERT
IF OBJECT_ID('tempdb..#BaseEvents') IS NOT NULL
    DROP TABLE #BaseEvents;

SELECT DISTINCT
    st.product_id,
    st.product_name,
    kh.KhachHangID,
    sp.SanPhamID,
    (SELECT TOP 1 BienTheID 
     FROM dbo.SanPham_BienThe bt 
     WHERE bt.SanPhamID = sp.SanPhamID
     ORDER BY NEWID()) AS BienTheID,
    ABS(CHECKSUM(NEWID())) % 100 AS rnd
INTO #BaseEvents
FROM Staging_ProductData st
JOIN dbo.KhachHang kh 
     ON kh.Email = CONCAT('user', st.product_id, '@mail.com')  -- nếu sau này bạn đổi logic email thì sửa join ở đây
JOIN dbo.SanPham sp 
     ON sp.TenSanPham = st.product_name;
GO

---------------------------------------------------
-- VIEW: tất cả
---------------------------------------------------
INSERT INTO dbo.User_Product_Interaction
    (KhachHangID, SanPhamID, BienTheID, EventType, ViewTimeSec, Quantity, Channel, Referrer, Device)
SELECT 
    b.KhachHangID,
    b.SanPhamID,
    b.BienTheID,
    N'VIEW',
    ABS(CHECKSUM(NEWID())) % 60 + 5, -- 5–65s
    1,
    N'WEB',
    N'SEARCH',
    N'DESKTOP'
FROM #BaseEvents b;

---------------------------------------------------
-- CLICK: khoảng 40% bản ghi
---------------------------------------------------
INSERT INTO dbo.User_Product_Interaction
    (KhachHangID, SanPhamID, BienTheID, EventType, ViewTimeSec, Quantity, Channel, Referrer, Device)
SELECT 
    b.KhachHangID,
    b.SanPhamID,
    b.BienTheID,
    N'CLICK',
    NULL,
    1,
    N'WEB',
    N'RECOMMEND',
    N'MOBILE'
FROM #BaseEvents b
WHERE b.rnd < 40;

---------------------------------------------------
-- ADD_TO_CART: khoảng 20% (tập con của CLICK)
---------------------------------------------------
INSERT INTO dbo.User_Product_Interaction
    (KhachHangID, SanPhamID, BienTheID, EventType, ViewTimeSec, Quantity, Channel, Referrer, Device)
SELECT 
    b.KhachHangID,
    b.SanPhamID,
    b.BienTheID,
    N'ADD_TO_CART',
    NULL,
    ABS(CHECKSUM(NEWID())) % 3 + 1, -- 1–3 sp
    N'WEB',
    N'CAMPAIGN',
    N'MOBILE'
FROM #BaseEvents b
WHERE b.rnd < 20;

---------------------------------------------------
-- PURCHASE: khoảng 10% (tập con, dùng làm nguồn tạo đơn hàng)
---------------------------------------------------
INSERT INTO dbo.User_Product_Interaction
    (KhachHangID, SanPhamID, BienTheID, EventType, ViewTimeSec, Quantity, Channel, Referrer, Device)
SELECT 
    b.KhachHangID,
    b.SanPhamID,
    b.BienTheID,
    N'PURCHASE',
    NULL,
    ABS(CHECKSUM(NEWID())) % 3 + 1,
    N'ONLINE',
    N'CHECKOUT',
    N'MOBILE'
FROM #BaseEvents b
WHERE b.rnd < 30;

PRINT N'→ Done User_Product_Interaction (VIEW/CLICK/ADD_TO_CART/PURCHASE)';

-- (Không bắt buộc) Dọn bảng tạm
IF OBJECT_ID('tempdb..#BaseEvents') IS NOT NULL
    DROP TABLE #BaseEvents;

/* ============================================================
   B12. Insert Rating vào DanhGia
   ============================================================ */

PRINT '============================================';
PRINT '      B12. INSERT DANHGIA';
PRINT '============================================';

INSERT INTO dbo.DanhGia (SanPhamID, KhachHangID, Rating, ReviewSource, VerifiedPurchase, ReviewTitle, ReviewText)
SELECT 
    sp.SanPhamID,
    kh.KhachHangID,
    4.0,  -- dataset không có rating
    N'INTERNAL',
    1,
    N'Review tự động',
    N'Review sinh tự động.'
FROM Staging_ProductData st
JOIN SanPham sp ON sp.ExternalID = st.product_id
JOIN KhachHang kh ON kh.Email = CONCAT('user', st.product_id, '@mail.com')
WHERE st.product_id IS NOT NULL;


PRINT '→ Done DanhGia';
GO

/* ============================================================
   B13. Tạo đơn hàng / chi tiết / hóa đơn / thanh toán / vận đơn
        từ các interaction PURCHASE
   ============================================================ */

PRINT '============================================';
PRINT '      B13. INSERT DONHANG, DH_CHITIET, HOADON, VANDON';
PRINT '============================================';

DECLARE @KhachHangID INT,
        @SanPhamID   INT,
        @BienTheID   INT,
        @Qty         INT,
        @DonHangID   INT,
        @DonGia      DECIMAL(12,2),
        @TongTien    DECIMAL(12,2),
        @PhiVC       DECIMAL(12,2),
        @TongTT      DECIMAL(12,2);

/* Lấy tối đa 200 interaction PURCHASE để tạo đơn demo */
DECLARE cur_purchase CURSOR FAST_FORWARD FOR
SELECT TOP (200)
    u.KhachHangID,
    u.SanPhamID,
    u.BienTheID,
    ISNULL(u.Quantity, 1) AS Qty
FROM dbo.User_Product_Interaction u
WHERE u.EventType = N'PURCHASE'
ORDER BY u.OccurredAt DESC;

OPEN cur_purchase;
FETCH NEXT FROM cur_purchase INTO @KhachHangID, @SanPhamID, @BienTheID, @Qty;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Nếu BienTheID null, chọn 1 biến thể bất kỳ
    IF @BienTheID IS NULL
    BEGIN
        SELECT TOP 1 @BienTheID = BienTheID
        FROM dbo.SanPham_BienThe
        WHERE SanPhamID = @SanPhamID
        ORDER BY NEWID();
    END

    -- Lấy giá bán
    SELECT @DonGia = GiaBan
    FROM dbo.SanPham_BienThe
    WHERE BienTheID = @BienTheID;

    IF @DonGia IS NULL
        SET @DonGia = 100000; -- fallback

    SET @TongTien = @DonGia * @Qty;
    SET @PhiVC    = 30000;
    SET @TongTT   = @TongTien + @PhiVC;

    -- 1. Tạo đơn hàng
    INSERT INTO dbo.DonHang
        (KhachHangID, TrangThai, KenhBan, TongTienHang, TongGiamGia, Thue, PhiVanChuyen, TongThanhToan)
    VALUES
        (@KhachHangID, N'DELIVERED', N'ONLINE', @TongTien, 0, 0, @PhiVC, @TongTT);

    SET @DonHangID = SCOPE_IDENTITY();

    -- 2. Thêm chi tiết đơn hàng
    INSERT INTO dbo.DonHang_ChiTiet
        (DonHangID, BienTheID, SoLuong, DonGia, GiamGia, Thue)
    VALUES
        (@DonHangID, @BienTheID, @Qty, @DonGia, 0, 0);

    -- 5. Vận đơn
    INSERT INTO dbo.VanDon
        (DonHangID, DVVC, MaVanDon, TrangThaiGiao, PhiVanChuyen, NgayGui, NgayGiaoDuKien)
    VALUES
        (@DonHangID, N'GHN', CONCAT('GHN', @DonHangID), N'DELIVERED', @PhiVC, CAST(GETDATE() AS DATE), DATEADD(DAY, 3, CAST(GETDATE() AS DATE)));

    -- Reset BienThe cho vòng sau
    SET @BienTheID = NULL;

    FETCH NEXT FROM cur_purchase INTO @KhachHangID, @SanPhamID, @BienTheID, @Qty;
END

CLOSE cur_purchase;
DEALLOCATE cur_purchase;

PRINT '→ Done Đơn hàng / Hóa đơn / Thanh toán / Vận đơn';
GO

/* DonHang PURCHASE */
INSERT INTO DonHang (KhachHangID, TrangThai, KenhBan, TongTienHang)
SELECT 
    upi.KhachHangID,
    N'NEW',
    N'ONLINE',
    bt.GiaBan * upi.Quantity
FROM User_Product_Interaction upi
JOIN SanPham_BienThe bt ON bt.BienTheID = upi.BienTheID
WHERE upi.EventType = 'PURCHASE';
GO

INSERT INTO DonHang_ChiTiet (DonHangID, BienTheID, SoLuong, DonGia)
SELECT 
    dh.DonHangID,
    upi.BienTheID,
    upi.Quantity,
    bt.GiaBan
FROM DonHang dh
JOIN User_Product_Interaction upi ON upi.KhachHangID = dh.KhachHangID
JOIN SanPham_BienThe bt ON bt.BienTheID = upi.BienTheID
WHERE upi.EventType = 'PURCHASE';
GO


/* ============================================================
   B14. Insert THUONGHIEU
   ============================================================ */
PRINT '============================================';
PRINT '      B13. INSERT THUONGHIEU';
PRINT '============================================';

/* Tạo brand chỉ từ đầu tiên toàn ký tự a-z (không số, không ký tự lạ) */
WITH RawBrand AS (
    SELECT DISTINCT
        CASE 
            WHEN CHARINDEX(' ', st.product_name + ' ') > 0 
                THEN LEFT(st.product_name, CHARINDEX(' ', st.product_name + ' ') - 1)
            ELSE st.product_name
        END AS Brand
    FROM Staging_ProductData st
    WHERE st.product_name IS NOT NULL
)
INSERT INTO dbo.ThuongHieu (Ten)
SELECT Brand
FROM RawBrand
WHERE Brand IS NOT NULL
  AND Brand <> ''
  -- chỉ cho phép A–Z hoặc a–z, KHÔNG có số / ký tự khác
  AND PATINDEX('%[^A-Za-z]%', Brand) = 0
  AND Brand NOT IN (SELECT Ten FROM dbo.ThuongHieu);

PRINT '→ Done Thương hiệu ';
GO

/* ============================================================
   B14. CẬP NHẬT ExternalID, DanhMucID, ThuongHieuID CHO SANPHAM
   ============================================================ */
PRINT '============================================';
PRINT '      B14. CẬP NHẬT ExternalID, DanhMucID, ThuongHieuID CHO SANPHAM';
PRINT '============================================';


------------------------------------------------------------
-- 1) MAP DanhMucID theo sub_category (ưu tiên)
------------------------------------------------------------
UPDATE sp
SET sp.DanhMucID = dm.DanhMucID
FROM dbo.SanPham sp
JOIN Staging_ProductData st 
      ON st.product_name = sp.TenSanPham
JOIN dbo.DanhMuc dm 
      ON dm.Ten = st.sub_category
WHERE st.sub_category IS NOT NULL;
GO


------------------------------------------------------------
-- 2) MAP DanhMucID theo category (fallback)
------------------------------------------------------------
UPDATE sp
SET sp.DanhMucID = dm.DanhMucID
FROM dbo.SanPham sp
JOIN Staging_ProductData st 
      ON st.product_name = sp.TenSanPham
JOIN dbo.DanhMuc dm 
      ON dm.Ten = st.category
WHERE sp.DanhMucID IS NULL
  AND st.category IS NOT NULL;
GO


------------------------------------------------------------
-- 3) MAP ThuongHieuID theo Brand (chỉ chữ cái A–Z)
------------------------------------------------------------
;WITH BrandMap AS (
    SELECT 
        st.product_name,
        CASE 
            WHEN CHARINDEX(' ', st.product_name + ' ') > 0 
                THEN LEFT(st.product_name, CHARINDEX(' ', st.product_name + ' ') - 1)
            ELSE st.product_name
        END AS Brand
    FROM Staging_ProductData st
)
UPDATE sp
SET sp.ThuongHieuID = th.ThuongHieuID
FROM dbo.SanPham sp
JOIN BrandMap bm 
      ON bm.product_name = sp.TenSanPham
JOIN dbo.ThuongHieu th 
      ON th.Ten = bm.Brand
WHERE PATINDEX('%[^A-Za-z]%', bm.Brand) = 0;   -- chỉ nhận brand sạch
GO

UPDATE dbo.SanPham
SET ThuongHieuID = 499
WHERE ThuongHieuID IS NULL;
GO


/* ============================================================
   B15. CẬP NHẬT brand, price, cost, img_url cho staging_ProductData
   ============================================================ */
PRINT '============================================';
PRINT '      B15. CẬP NHẬT brand, price, cost, img_url cho staging_ProductData';
PRINT '============================================';

/* Gán brand vào bảng Staging_ProductData */
UPDATE st
SET st.brand = LEFT(st.product_name, CHARINDEX(' ', st.product_name + ' ') - 1)
FROM Staging_ProductData st
WHERE st.brand IS NULL;
GO

UPDATE st
SET st.brand = th.ThuongHieuID
FROM Staging_ProductData st
JOIN dbo.ThuongHieu th
     ON th.Ten = st.brand;
GO

/* Tính giá trung bình cho mỗi SanPham */
WITH PriceInfo AS (
    SELECT 
        sp.ExternalID AS product_id,
        AVG(bt.GiaBan)  AS avg_price,
        AVG(bt.GiaNhap) AS avg_cost
    FROM dbo.SanPham sp
    JOIN dbo.SanPham_BienThe bt
         ON bt.SanPhamID = sp.SanPhamID
    WHERE sp.ExternalID IS NOT NULL
    GROUP BY sp.ExternalID
)
UPDATE st
SET 
    st.price = pi.avg_price,
    st.cost  = pi.avg_cost
FROM Staging_ProductData st
JOIN PriceInfo pi ON pi.product_id = st.product_id;
GO
ALTER TABLE dbo.DanhGia
ALTER COLUMN ReviewText NVARCHAR(MAX);  -- Đảm bảo cột ReviewText là NVARCHAR
ALTER TABLE dbo.DanhGia
ALTER COLUMN ReviewTitle NVARCHAR(255);  -- Nếu ReviewTitle có giới hạn chiều dài

/*
-- Chèn đánh giá cho SanPhamID = 41044
INSERT INTO dbo.DanhGia (SanPhamID, KhachHangID, Rating, ReviewSource, VerifiedPurchase, ReviewTitle, ReviewText)
VALUES
(41044, 133339, 4.5, 'INTERNAL', 1, 'Sản phẩm rất tốt!', 'Tôi rất hài lòng về sản phẩm này, chất lượng tốt và đúng như mô tả.'),
(41044, 133339, 5, 'INTERNAL', 1, 'Sản phẩm rất tốt!', 'Tuyệt vời'),
(41044, 133339, 3.5, 'INTERNAL', 0, 'Tạm ổn', 'Không có gì nổi bật, chỉ là một trải nghiệm bình thường.'),
(41044, 133339, 4, 'INTERNAL', 0, 'Sản phẩm rất tốt!', 'Nhân viên thân thiện, nhiệt tình hỗ trợ.');
GO

INSERT INTO dbo.DanhGia (SanPhamID, KhachHangID, Rating, ReviewSource, VerifiedPurchase, ReviewTitle, ReviewText)
VALUES
(41053, 133339, 4.5, 'INTERNAL', 1, 'Sản phẩm rất tốt!', 'Tôi rất hài lòng về sản phẩm này, chất lượng tốt và đúng như mô tả.'),
(41053, 133339, 5, 'INTERNAL', 1, 'Sản phẩm rất tốt!', 'Tuyệt vời'),
(41053, 133339, 3.5, 'INTERNAL', 0, 'Tạm ổn', 'Không có gì nổi bật');
GO

INSERT INTO dbo.DanhGia (SanPhamID, KhachHangID, Rating, ReviewSource, VerifiedPurchase, ReviewTitle, ReviewText)
VALUES
(41052, 133339, 5, 'INTERNAL', 1, 'Sản phẩm rất tốt!', 'Tuyệt vời'),
(41052, 133339, 2, 'INTERNAL', 0, 'Tạm ổn', 'Không có gì nổi bật');
GO
*/


INSERT INTO dbo.DonHang_ChiTiet
    (DonHangID, BienTheID, SoLuong, DonGia, GiamGia, Thue)
SELECT TOP (200)
    DH.DonHangID,
    COALESCE(UPI.BienTheID, BT.BienTheID) AS BienTheID,
    ISNULL(UPI.Quantity, 1)               AS SoLuong,
    ISNULL(BT.GiaBan, 100000)              AS DonGia,
    0 AS GiamGia,
    0 AS Thue
FROM dbo.User_Product_Interaction UPI
JOIN dbo.DonHang DH
    ON DH.KhachHangID = UPI.KhachHangID
OUTER APPLY (
    SELECT TOP 1 *
    FROM dbo.SanPham_BienThe
    WHERE SanPhamID = UPI.SanPhamID
    ORDER BY NEWID()
) BT
WHERE UPI.EventType = N'PURCHASE'
ORDER BY UPI.OccurredAt DESC;

INSERT INTO DonHang_ChiTiet
    (DonHangID, BienTheID, SoLuong, DonGia, GiamGia, Thue)
SELECT
    DH.DonHangID,
    BT.BienTheID,
    1 AS SoLuong,
    ISNULL(BT.GiaBan, 100000) AS DonGia,
    0 AS GiamGia,
    0 AS Thue
FROM DonHang DH
OUTER APPLY (
    SELECT TOP 1 BienTheID, GiaBan
    FROM SanPham_BienThe
    ORDER BY NEWID()
) BT;
-- Phải ra 0
SELECT COUNT(*) 
FROM DonHang_ChiTiet c
LEFT JOIN DonHang d ON c.DonHangID = d.DonHangID
WHERE d.DonHangID IS NULL;

UPDATE DonHang
SET 
    PhiVanChuyen = 30000,
    TongThanhToan = ISNULL(TongTienHang, 0) + 30000;

--------------------------------------------------

SET IDENTITY_INSERT SanPham ON;
INSERT INTO SanPham (SanPhamID, TenSanPham, DanhMucID, MoTa, created_at, updated_at)
VALUES
(10007, N'Nike Women As Trophy Swo White T-Shirts', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(41000, N'Gini and Jony Girls Woven Blue Shorts', 21, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(10000, N'Palm Tree Girls Sp Jace Sko White Skirts', 21, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(10009, N'Nike Men Town Round Red Neck T-Shirts', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(10008, N'Nike Men Town Navy Blue T-Shirts', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(10001, N'Palm Tree Kids Girls Sp Jema Skt Blue Skirts', 21, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(10006, N'Nike Men AS T90 Black Tshirts', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(21000, N'Fastrack Men Leatherette White Belt', 3, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(11000, N'Puma Men Slick 3HD Yellow Black Watches', 2, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(10003, N'Nike Women As Nike Eleme White T-Shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(32000, N'Playboy Men Brown Socks', 34, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(22000, N'Murcia Women Casual Grey Handbag', 41, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(53000, N'FNF Multi Coloured Printed Sari', 29, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(55165, N'Lakme True Wear Classics Clear Glass Nail Polish 012', 10, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(33713, N'Cobblerz Men Red Flip Flops', 22, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(23581, N'Nike Fragrances Women Original Deo', 1, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(28169, N'Ray-Ban Men Aviator Gold Sunglasses', 31, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(27121, N'Miss-T Maroon Bra', 37, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(28955, N'BIBA Women White Kurta', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(7003,  N's.Oliver Men''s Sky Polo Blue T-shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE());
SET IDENTITY_INSERT SanPham OFF;

SET IDENTITY_INSERT SanPham ON;
INSERT INTO SanPham (SanPhamID, TenSanPham, DanhMucID, MoTa, created_at, updated_at)
VALUES
(12000, N'Mark Taylor Men White Striped Shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(20008, N'United Colors of Benetton Men Printed Orange TShirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(20001, N'United Colors of Benetton Men Printed Green T-shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(20006, N'United Colors of Benetton Women Printed Green T-shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(20007, N'United Colors of Benetton Men White Printed T-shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(20000, N'United Colors of Benetton Men White Solid T-shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(20009, N'United Colors of Benetton Olive T-shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(20005, N'United Colors of Benetton Women Blue Printed Top', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(20002, N'United Colors of Benetton Women Solid Black Top', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(20003, N'United Colors of Benetton Men Printed White TShirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(20004, N'United Colors of Benetton Men Printed Beige TShirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(43000, N'Nike Men White Air Dictate Sports Shoes', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(13000, N'Inc 5 Women Casual Black Heels', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(30001, N'Aspen Women White Dial Watch', 2, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(30000, N'Aspen Women Silver Dial Watch', 2, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(30002, N'Aspen Women White Dial Watch', 2, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(57256, N'Murcia Women Pink Handbag', 41, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(11443, N'United Colors of Benetton Women Light Winter Pink Tops', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(25676, N'Fastrack Women Black Casual Watch', 2, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(39229, N'Femella Women Petal Black Shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(20304, N'Jealous 21 Women Stripes Maroon Sweater', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(14131, N'Flying Machine Women Washed Blue Jeans', 21, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(5566,  N'Ant Kids Girl''s Maroon With Flower Kidswear', 23, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(36261, N'SDL by Sweet Dreams Men Navy Blue Pyjama Set', 17, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(49962, N'Hanes Men White Pack of 3 T-shirts', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(22453, N'Global Desi Women Solid Black Top', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(31878, N'Fabindia Women Black Jacquard Silk Stole', 38, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(46116, N'ADIDAS Men Olive Terrace Shoes', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(7231,  N'Rockport Men''s Bvallee Black Shoe', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(34536, N'Red Tape Men Brown Shoes', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(29887, N'Mayhem Women Cat Eye Sunglasses 1016-104', 31, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(8279,  N'Mr.Men Men''s Green Tea T-shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(3691,  N'Lotto Men''s Honololu White Blue Shoe', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(55501, N'Revlon Wrap Yourself In Rubies Super Lustrous Lip Gloss 53', 40, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(13314, N'Gini and Jony Kids Boys Check Red Shirts', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(30196, N'Nike Unisex Casual Red Backpack', 41, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(2743,  N'Classic Polo Men''s White T-shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(43464, N'SDL by Sweet Dreams Women Blue Night suits', 17, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(46324, N'Reebok Men Grey Premier Road Supreme Sports Shoes', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(22661, N'Wildcraft Lavender & Grey Slingbag', 41, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(29289, N'Wrangler Men Miriam Checks Pink Shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(51393, N'Myntra Men Green Check Shorts', 21, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(8877,  N'Regent Polo Club Men White Shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(17586, N'Speedo Unisex Funky Eyewear White Sunglasses', 31, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(50241, N'Stoln Women Blue Handbag', 41, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(9199,  N'Puma Women Trekkies Ska Target Oc White Casual Shoes', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(43656, N'ONLY Women Orange Shorts', 21, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(13126, N'Lee Cooper Men Brown Formal Shoes', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(27313, N'ADIDAS Women Natural Vitality Deos', 1, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE());
SET IDENTITY_INSERT SanPham OFF;

SET IDENTITY_INSERT SanPham ON;
INSERT INTO SanPham (SanPhamID, TenSanPham, DanhMucID, MoTa, created_at, updated_at)
VALUES
(39309, N'Red Chief Men Brown Shoes', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(5680,  N'Skechers Men''s Compelling Desterity Black Shoe', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(37055, N'Lino Perros Women Brown Belt', 3, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(21130, N's.Oliver Women Solid Maroon Top', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(15305, N'ADIDAS Men Aerostar White Sports Shoes', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(4752,  N'ADIDAS Men''s Red Polo T-shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(10677, N'Doodle Girl Flap doodle angel Pink Tops', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(24442, N'Facit Men Grey Printed Innerwear Vest', 37, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(40107, N'ADIDAS Men Black T-shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(32527, N'Tonino Lamborghini Men Forza Deo', 1, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(25590, N'Vishudh Women Beige & Green Printed Churidar Kurta with Dupatta', 23, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(56062, N'Colorbar Extra Durable Gossip Lip Color 005', 40, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(12120, N'Aurelia Women Printed Orange Kurtas', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(26315, N'Proline Men Charcoal Grey Track Pants', 21, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(42650, N'Alma Women Red Printed Kurta', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(30270, N'Speedo Men Sheet Sunglasses', 31, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(6839,  N'Timberland Unisex Waximum Shoe Accessories', 45, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(54735, N'Vans Men Grey Shoes', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(35702, N'Nike Men Solarsoft Slide Black Sandals', 22, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(23667, N'Spykar Men Navy Blue Check Shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(50395, N'Miss Sixty Silver Dial Watch', 2, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(17452, N'CASIO Sheen Women White Dial Chronograph Watch SX007 SHN-5016D-7ADR', 2, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(9871,  N'Status Quo Men Stripes Green Tshirts', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(47322, N'Baggit Women Brown Chakde Lips Mobile Pouch', 41, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(6005,  N'Highlander Men Red Blue Checked Slim Fit Shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(31190, N'Cabarelli Men Accessory Gift Set', 39, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(3745,  N'Tantra Kid''s Cool Yellow Kidswear', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(54507, N'Lino Perros Women Pink Handbag', 41, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(18628, N'Puma Men Knitted Chocolate Brown Sweaters', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(48158, N'Fossil Women Red Wallet', 41, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(28881, N'Enamor Women Pink Mid-Rise Bikini Brief', 37, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(30042, N'Skagen Men Brown Watch', 2, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(2697,  N'Disney Kids Girl''s Blue Pooh Kidswear', 23, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(51075, N'Satya Paul Cream and Brown Saree', 29, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(22587, N'Nike Kids Boys Purple T-shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(35530, N'Enroute Teens Beige Sandals', 22, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(47110, N'Marvel Boys Blue & Red Spiderman Shoes', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(6237,  N'Lee Women''s Iris White T-shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(23455, N'Deni Yo Men Blue Washed Slim Fit Jeans', 21, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(48964, N'Revv Men Steel Ring', 39, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(17660, N'Catwalk Women Ballerina Brown Casual Shoe', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(37267, N'United Colors of Benetton Girls Red Printed Dress', 23, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(45647, N'Park Avenue Men Navy Blue Briefs', 37, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(4560,  N'Nike Men''s Dunk Low White Shoe', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(59218, N'Titan Him & Her Black Watches', 2, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(10445, N'Flying Machine Men Midrise Blue Jeans', 21, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(57382, N'Amante Women Pack of 2 Briefs PFCN03', 37, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(24670, N'Converse Unisex Floral Print Casual Shoes', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(56250, N'SDL by Sweet Dreams Men Grey Melange Pyjama Set', 17, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(11597, N'W Women Printed Cream Kurtas', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(27491, N'Jockey Women Pink Briefs', 37, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(54163, N'Femella Silver Necklace', 39, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(3321,  N'KKR Mens Fangear Polo Jersey', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(42006, N'Baggit Women Beige Goofy Jhuti Wallet', 41, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(12776, N'Mother Earth Women Shilpis Collt Blue Kurtas', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(35968, N'Flying Machine Men Crown Purple T-shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(26543, N'ID Men Black & Yellow Sandals', 22, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(47574, N'Portia Women White Wedges', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(6653,  N'Nike Men''s Air Force White Orange Shoe', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(23031, N'Arrow Men White Striped Shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(17204, N'United Colors of Benetton Women Funky Eyewear Brown Sunglasses', 31, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(51411, N'Myntra Men Turquoise Blue Striped Shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(7781,  N'Wildcraft Unisex Blue Backpack', 41, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(45223, N'Casio Vintage Collection Analog-Digital Watch AQ-230A-7DMQAD03', 2, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(4104,  N'Fila Men Tremor Black Sandal', 22, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(21766, N'Fossil Men Marcus Brown Belt', 3, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(14481, N'Flying Machine Men Beige Casual Shoes', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(37603, N'Madagascar3 Girls Purple Printed T-Shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(4938,  N'Gini and Jony Boy''s Kaden Grey Blue Infant Kidswear', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(56634, N'Olay Women Total Effects 7 in 1 Foaming Cleanser', 44, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(41683, N'Catwalk Women Brown Heels', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(32371, N'Q&Q Women White Dial Watch', 2, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(40751, N'Roxy Women Blue Flip Flops', 22, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(10021, N'Nike Men As Woven Shor White Shorts', 21, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(15761, N'Facit Men Hunk Green Innerwear Vest', 37, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(45011, N'Maxima Men Digital Multifunction Watch', 2, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(4336,  N'Fila Men''s Leonard White Black Shoe', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(37431, N'Murcia Women Black Handbag', 41, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(20486, N'Baggit Women Princy Gang Black Belt', 3, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(32143, N'Playboy Men Duet Pack of 2 Briefs', 37, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(56406, N'Rocia Women Maroon & Black Sandals', 22, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(10213, N'Murcia Women Hahk Black Handbags', 41, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(38479, N'Gini and Jony Boys Core Green T-shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(33091, N'Catwalk Women Gold Flats', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(1644,  N'Kipsta Men Loose Fit Round Neck Jersey Red', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(40563, N'Titan Women White Dial Watch NB9701WM01', 2, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(30614, N'Nike Men Striped Black Jersey', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(13496, N'Chimp Men Teja Main Hoon Blue Tshirts', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(55283, N'Lakme Absolute Cheek Chromatic Day Blushes Blusher', 44, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(12544, N'Tantra Women Printed Peach T-shirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(42234, N'Sepia Women Blue Printed Top', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(17036, N'Gas Men Caddy Casual Shoe', 20, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(6461,  N'Lotto Men''s Soccer Track Flip Flop', 22, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(18842, N'Puma Men Graphic Stellar Blue Tshirt', 24, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(46694, N'Rasasi Women Blue Lady Perfume', 1, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE()),
(51623, N'Fossil Women Pink Dial Chronograph Watch ES3050', 2, N'Mô tả tự động từ dataset Kaggle', GETDATE(), GETDATE());
SET IDENTITY_INSERT SanPham OFF;

ALTER TABLE [dbo].[TaiKhoan]
ADD EmailConfirmed BIT NOT NULL DEFAULT 0;

-- 1. Thay đổi cột HoTen từ NOT NULL sang NULL
ALTER TABLE [dbo].[KhachHang]
ALTER COLUMN [HoTen] [nvarchar](120) NULL;

-- 2. Thay đổi cột GioiTinh từ NOT NULL sang NULL
ALTER TABLE [dbo].[KhachHang]
ALTER COLUMN [GioiTinh] [nvarchar](5) NULL;

-- 3. Thay đổi cột ngaySinh từ NOT NULL sang NULL
ALTER TABLE [dbo].[KhachHang]
ALTER COLUMN [ngaySinh] [date] NULL;

-- 4. Thay đổi cột created_at từ NOT NULL sang NULL
ALTER TABLE [dbo].[KhachHang]
ALTER COLUMN [created_at] [datetime2](3) NULL;

-- 5. Thay đổi cột updated_at từ NOT NULL sang NULL
ALTER TABLE [dbo].[KhachHang]
ALTER COLUMN [updated_at] [datetime2](3) NULL;

SELECT COUNT(*) AS SoLuongSanPham
FROM SanPham_BienThe;


SELECT * 
FROM AnhSanPham where SanPhamID = 20001;


