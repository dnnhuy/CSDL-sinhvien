-- Tao bang Khoa
CREATE TABLE Khoa
(
	MaKhoa		varchar (4) constraint PK_Khoa_MaKhoa primary key,
	TenKhoa		varchar (50) not null

);

--Them du lieu vao bang Khoa
INSERT INTO Khoa VALUES ('KETN', N'Khoa K? toán');
INSERT INTO Khoa VALUES	('TMAI', N'Khoa Th??ng m?i');
INSERT INTO Khoa VALUES ('QTKD', N'Khoa Qu?n tr? kinh doanh');
INSERT INTO Khoa VALUES ('CNTT', N'Khoa Công ngh? thông tin');
INSERT INTO Khoa VALUES ('KTL', N'Khoa Kinh T? Lu?t');
INSERT INTO Khoa VALUES ('MKT', 'Marketing');
INSERT INTO Khoa VALUES ('DL', 'Du l?ch');
INSERT INTO Khoa VALUES ('THQ', 'Thu? h?i quan');
INSERT INTO Khoa VALUES ('TDBD', 'Th?m ??nh giá KDBDS');
INSERT INTO Khoa VALUES ('LLCT', 'Lý lu?n chính tr?');

-- Tao bang chuyen nganh
CREATE TABLE ChuyenNganh
(
	MaCN		varchar (6) PRIMARY KEY,
	TenCN		varchar (50) not null,
	MaKhoa		varchar (4),
    FOREIGN KEY (MaKhoa) REFERENCES Khoa(MaKhoa)
);

-- Them du  lieu vao bang Chuyennganh
INSERT INTO ChuyenNganh VALUES ('CN01',N'Tin h?c qu?n lý','CNTT');
INSERT INTO ChuyenNganh VALUES ('CN02',N'H? th?ng thông tin k? toán','CNTT');
INSERT INTO ChuyenNganh VALUES ('CN03',N'Th??ng m?i qu?c t?','TMAI');
INSERT INTO ChuyenNganh VALUES ('CN04',N'Th??ng m?i ?i?n t?','TMAI');
INSERT INTO ChuyenNganh VALUES ('CN05',N'Tài chính ??nh l??ng','KTL');
INSERT INTO ChuyenNganh VALUES ('CN06',N'Qu?n tr? kinh doanh t?ng h?p','QTKD');
INSERT INTO ChuyenNganh VALUES ('CN07',N'Qu?n tr? d? án','QTKD');
INSERT INTO ChuyenNganh VALUES ('CN08',N'Qu?n tr? bán hàng','QTKD');
INSERT INTO ChuyenNganh VALUES ('CN09',N'K? toán doanh nghi?p','KETN');
INSERT INTO ChuyenNganh VALUES ('CN10',N'Ki?m toán','KETN');
INSERT INTO ChuyenNganh VALUES ('CN11',N'Truy?n thông marketing','MKT');
INSERT INTO ChuyenNganh VALUES ('CN12',N'Qu?n tr? l? hành','DL');
INSERT INTO ChuyenNganh VALUES ('CN13',N'Qu?n tr? marketing','MKT');
INSERT INTO ChuyenNganh VALUES ('CN14',N'Kinh doanh BDS','TDBD');
INSERT INTO ChuyenNganh VALUES ('CN15',N'H?i quan xu?t nh?p kh?u','THQ');
INSERT INTO ChuyenNganh VALUES ('CN16',N'Lu?t ??u t? kinh doanh','KTL');

-- Tao bang Lop
CREATE TABLE Lop
(
	MaLop		varchar (6) PRIMARY KEY,
	TenLop		varchar (50) not null,
	MaCN		varchar (6),
    FOREIGN KEY (MaCN) REFERENCES ChuyenNganh(MaCN)
);

-- Them du lieu vao bang Lop
INSERT INTO Lop VALUES ('21DTH1',N'L?p tin h?c qu?n lý 01','CN01');
INSERT INTO Lop VALUES ('21DTK2',N'L?p h? th?ng thông tin k? toán 02','CN02');
INSERT INTO Lop VALUES ('21DKT1',N'L?p ki?m toán 01','CN10');
INSERT INTO Lop VALUES ('21DBH1',N'L?p qu?n tr? bán hàng 01','CN08');
INSERT INTO Lop VALUES ('21DTM1',N'L?p th??ng m?i ?i?n t? 01','CN04');
INSERT INTO Lop VALUES ('21DEM1',N'L?p tài chính ??nh l??ng 01','CN05');
INSERT INTO Lop VALUES ('20DEM1',N'L?p tài chính ??nh l??ng 02','CN05');
INSERT INTO Lop VALUES ('21DTH2',N'L?p tin h?c qu?n lý 02','CN01');
INSERT INTO Lop VALUES ('21DTH3',N'L?p tin h?c qu?n lý 03','CN01');
INSERT INTO Lop VALUES ('21DKT2',N'L?p ki?m toán 02','CN10');

-- Tao bang TinhTP
CREATE TABLE TinhTP
(
  MaTinh	varchar (5) primary key, 
  TenTinh   varchar (20) not null
)

-- Them du lieu vao bang TinhTP
	INSERT INTO TinhTP VALUES('MT01',N'Hà N?i');
	INSERT INTO TinhTP VALUES('MT02',N'Bình D??ng');
	INSERT INTO TinhTP VALUES('MT03',N'TPHCM');
	INSERT INTO TinhTP VALUES('MT04',N'??ng Nai');
	INSERT INTO TinhTP VALUES('MT05',N'Nha Trang');
    INSERT INTO TinhTP VALUES('MT06',N'Ninh Thu?n');
    INSERT INTO TinhTP VALUES('MT07',N'Bình thu?n');
    INSERT INTO TinhTP VALUES('MT08',N'Kiên Giang');
    INSERT INTO TinhTP VALUES('MT09',N'Bình D??ng');
    INSERT INTO TinhTP VALUES('MT10',N'Lâm ??ng');

-- Tao bang Sinh Vien
CREATE TABLE SinhVien
(
  MSSV			varchar (5) constraint PK_SinhVien_MSSV primary key, 
  HoTenSV		varchar (50)  not null,
  NgaySinhSV	date not null, 
  GioiTinhSV	varchar (6) not null  Check (GioiTinhSV in ('Nam', N'N?', N'Khác')),
  SDTSV			varchar(11) not null, 
  CMND			varchar (10) not null,
  MaLop			varchar (6)  not null,
  FOREIGN KEY (MaLop) REFERENCES Lop(MaLop),
  MaTinh		varchar (5) not null ,
  FOREIGN KEY (MaTinh) REFERENCES TinhTP(MaTinh)
);
drop table sinhvien
--Them du lieu vao bang SinhVien
        INSERT INTO SinhVien VALUES ('SV01', N'Nguy?n Xuân Hùng', TO_DATE('2003-10-9', 'YYYY-MM-DD'), 'Nam', '0915007602', '235687156', '21DTH1','MT04');
		INSERT INTO SinhVien VALUES ('SV02', N'Tr?n Hoàng D?ng',TO_DATE('2003-7-9', 'YYYY-MM-DD'), 'Nam', '0915000233', '244687156', '21DBH1','MT03');
		INSERT INTO SinhVien VALUES ('SV03', N'Nguy?n Qu?c Vi?t',TO_DATE( '2003-7-7', 'YYYY-MM-DD'), 'Nam', '0915007802', '235687476', '21DTH1','MT01');
		INSERT INTO SinhVien VALUES ('SV04', N'Nguy?n Mai H?ng', TO_DATE('2003-11-9', 'YYYY-MM-DD'), N'N?', '0975017602', '275687156', '21DTK2', 'MT02');
		INSERT INTO SinhVien VALUES ('SV05', N'Nguy?n Hà Anh', TO_DATE('2003-12-9', 'YYYY-MM-DD'), N'N?', '0935017602', '235777156', '21DTM1', 'MT04');
		INSERT INTO SinhVien VALUES ('SV06', N'Tr?n Nh?t Nhi', TO_DATE( '2003-6-19', 'YYYY-MM-DD'), N'N?', '0913007609', '235699156', '21DKT1', 'MT05');
		INSERT INTO SinhVien VALUES ('SV07', N'Tr?n Qu?c An', TO_DATE('2003-8-19', 'YYYY-MM-DD'), 'Nam', '0923007609', '235699956', '21DBH1', 'MT01');
		INSERT INTO SinhVien VALUES ('SV08', N'?? Nh?t Hà', TO_DATE('2003-7-18', 'YYYY-MM-DD'), N'N?', '0914007609', '235699157', '21DTH1', 'MT01');
		INSERT INTO SinhVien VALUES ('SV09', N'Tr?n Thiên Ân', TO_DATE( '2003-5-11', 'YYYY-MM-DD'), N'N?', '0613007609', '235699158', '21DBH1', 'MT05');
		INSERT INTO SinhVien VALUES ('SV010', N'Lê Th?o Nhi', TO_DATE('2003-2-12', 'YYYY-MM-DD'), N'N?', '0973007609', '235699159', '21DTH1', 'MT04');
		INSERT INTO SinhVien VALUES ('SV011', N'Nguy?n Hà D?u Th?o', TO_DATE('2003-1-20', 'YYYY-MM-DD'), N'N?', '0913607609', '235699160', '21DTK2', 'MT02');
		INSERT INTO SinhVien VALUES ('SV012', N'Ngô Qu?nh Mai', TO_DATE('2003-3-15', 'YYYY-MM-DD'), N'N?', '0913007605', '235699161', '21DTM1', 'MT01');
		INSERT INTO SinhVien VALUES ('SV013', N'Bùi Qu?nh Hoa', TO_DATE('2003-4-22', 'YYYY-MM-DD'), N'N?', '0913007633', '235699162', '21DKT1', 'MT03');
		INSERT INTO SinhVien VALUES ('SV014', N'Hu?nh Ph?m Th?y Tiên', TO_DATE('2003-5-16', 'YYYY-MM-DD'), N'N?', '0913117609', '235699163', '21DBH1', 'MT04');
		INSERT INTO SinhVien VALUES ('SV015', N'Tr?n B?o Ng?c', TO_DATE( '2003-8-12', 'YYYY-MM-DD'), N'N?', '0913004409', '235699164', '21DTH1', 'MT02');
		INSERT INTO SinhVien VALUES ('SV016', N'Nguy?n Ph??ng Nhi', TO_DATE( '2003-7-19', 'YYYY-MM-DD'), N'N?', '0953007609', '235699165', '21DBH1', 'MT03');
		INSERT INTO SinhVien VALUES ('SV017', N'D??c S? Ti?n', TO_DATE( '2003-2-11', 'YYYY-MM-DD'), 'Nam', '0913557609', '235699166', '21DTH1', 'MT04');
		INSERT INTO SinhVien VALUES ('SV018', N'Hoàng Song Hà', TO_DATE('2003-6-14', 'YYYY-MM-DD'), N'N?', '0913677609', '235699167', '21DTK2', 'MT01');
		INSERT INTO SinhVien VALUES ('SV019', N'Nguy?n Qu?nh', TO_DATE( '2003-1-21', 'YYYY-MM-DD'), N'N?', '0976007609', '235699168', '21DTM1', 'MT04');
		INSERT INTO SinhVien VALUES ('SV020', N'Nguy?n ?an Tiên', TO_DATE( '2003-7-12', 'YYYY-MM-DD'), N'N?', '0913008709', '235699169', '21DKT1', 'MT03');


-- Tao bang Giang Vien
CREATE TABLE GiangVien
(
  MaGV			varchar (5) primary key, 
  HoTenGV		varchar (50)  not null,
  NgaySinhGV	date not null, 
  GioiTinhGV	varchar (6) not null Check (GioiTinhGV in ('Nam', N'N?', N'Khác')),
  SDTGV			varchar(11) not null, 
  CMNDGV		varchar (10) not null,
  MaKhoa		varchar (4) ,
  FOREIGN KEY (MaKhoa) REFERENCES Khoa(MaKhoa)
);

--Them du lieu vao bang GiangVien
    INSERT INTO GiangVien VALUES ('GV01', N'Nguy?n Quang Kh?i',  TO_DATE(  '1980-10-12', 'YYYY-MM-DD'), 'Nam', '0975007632', '735687156', 'QTKD');
    INSERT INTO GiangVien VALUES('GV02', N'Tr?n Xuân H??ng',  TO_DATE( '1979-7-9', 'YYYY-MM-DD'), N'N?', '0935000433', '744687156', 'QTKD');
    INSERT INTO GiangVien VALUES('GV03', N'Nguy?n Qu?c ??t',  TO_DATE(  '1978-7-7', 'YYYY-MM-DD'), 'Nam', '0985007802', '735687476', 'CNTT');
    INSERT INTO GiangVien VALUES('GV04', N'L??ng Mai Quyên',  TO_DATE(  '1981-11-9', 'YYYY-MM-DD'), N'N?', '0975017688', '975687156', 'KETN');
    INSERT INTO GiangVien VALUES('GV05', N'Tr?n Mai Thanh',  TO_DATE(  '1985-12-9', 'YYYY-MM-DD'), N'N?', '0935666602', '735777156', 'CNTT');
    INSERT INTO GiangVien VALUES('GV06', N'Bùi Xuân Anh',  TO_DATE(  '1984-6-19', 'YYYY-MM-DD'), N'N?', '0913007677', '735699156', 'CNTT'); 
    INSERT INTO GiangVien VALUES('GV07', N'Ph?m Ng?c Anh',  TO_DATE(  '1984-6-15', 'YYYY-MM-DD'), 'Nam', '0913447677', '735699122', 'TMAI');
    INSERT INTO GiangVien VALUES('GV08', N'Tr?n Th? La',  TO_DATE( '1987-7-17', 'YYYY-MM-DD'), N'N?', '0913447622', '735699352', 'KTL');
    INSERT INTO GiangVien VALUES('GV09', N'Ph?m Th? Khánh',  TO_DATE(  '1985-5-15', 'YYYY-MM-DD'), N'N?', '0913444380', '735699865', 'CNTT');
    INSERT INTO GiangVien VALUES('GV10', N'Bùi Minh',  TO_DATE(  '1986-6-16', 'YYYY-MM-DD'), 'Nam', '0913443579', '735699197', 'TMAI');

-- Tao bang MonHoc
CREATE TABLE MonHoc
(
  MaMH		varchar (5) primary key, 
  TenMH		varchar (50)  not null,
  SoTinChi	number not null, 
  SoTietLT	number not null, 
  SoTietTH	number not null, 
  MaKhoa	varchar (4)  not null ,
  FOREIGN KEY (MaKhoa) REFERENCES Khoa(MaKhoa)
);

-- Them du lieu vao bang MonHoc
        INSERT INTO MonHoc VALUES ('MH01', N'C? s? d? li?u', 4, 30, 60, 'CNTT');
		INSERT INTO MonHoc VALUES('MH02', N'Lu?t ??u t?', 3, 30, 15, 'KTL');
		INSERT INTO MonHoc VALUES('MH03', N'Qu?n tr? d? án', 3, 30, 15, 'QTKD');
		INSERT INTO MonHoc VALUES('MH04', N'Ki?m toán c?n b?n', 3, 30, 15, 'KETN');
		INSERT INTO MonHoc VALUES('MH05', N'Th??ng m?i qu?c t?', 3, 30, 15, 'TMAI');
        INSERT INTO MonHoc VALUES('MH06', N'Dien toan dam may', 3, 30, 15, 'CNTT');
        INSERT INTO MonHoc VALUES('MH07', N'An toan thong tin', 3, 30, 15, 'CNTT');
        INSERT INTO MonHoc VALUES('MH08', N'Lap trinh web', 4, 30, 60, 'CNTT');
        INSERT INTO MonHoc VALUES('MH09', N'Kiem toan quoc te', 3, 30, 15, 'KETN');
        INSERT INTO MonHoc VALUES('MH010', N'Quan tri tac nghiep', 3, 30, 60, 'QTKD');

-- Tao bang LopHP
CREATE TABLE LopHP
(
  MaLHP			varchar(8) primary key, 
  NgayBd		date not null, 
  NgayKt		date not null, 
  NgayDukienthi	date not null, 
  HK		    number not null Check (HK in (1, 2, 3)),
  Nam			number not null,
  MaMH			varchar (5) ,
  FOREIGN KEY (MaMH) REFERENCES MonHoc(MaMH),
  MaGV			varchar (5)  not null,
  FOREIGN KEY (MaGV) REFERENCES GiangVien(MaGV)
);

--Them du lieu vao bang LopHP
INSERT INTO LopHP VALUES ('LHP01', TO_DATE( '2022-2-20', 'YYYY-MM-DD'), TO_DATE( '2022-5-20', 'YYYY-MM-DD'), TO_DATE('2022-6-20', 'YYYY-MM-DD'), 1, 2022, 'MH01','GV03');
INSERT INTO LopHP VALUES ('LHP02', TO_DATE( '2022-2-20', 'YYYY-MM-DD'), TO_DATE( '2022-5-20', 'YYYY-MM-DD'),TO_DATE( '2022-6-20', 'YYYY-MM-DD'), 1, 2022, 'MH02', 'GV08');
INSERT INTO LopHP VALUES ('LHP03', TO_DATE( '2022-2-20', 'YYYY-MM-DD'),TO_DATE( '2022-2-20', 'YYYY-MM-DD'), TO_DATE('2022-6-20', 'YYYY-MM-DD'), 3, 2022, 'MH03', 'GV01');
INSERT INTO LopHP VALUES ('LHP04',  TO_DATE( '2022-3-10', 'YYYY-MM-DD'), TO_DATE( '2022-6-10', 'YYYY-MM-DD'),TO_DATE( '2022-6-30', 'YYYY-MM-DD'), 2, 2022, 'MH04', 'GV04');
INSERT INTO LopHP VALUES ('LHP05',  TO_DATE( '2022-3-10', 'YYYY-MM-DD'), TO_DATE( '2022-6-10', 'YYYY-MM-DD'), TO_DATE( '2022-6-30', 'YYYY-MM-DD'), 2, 2022, 'MH05', 'GV07');
INSERT INTO LopHP VALUES ('LHP06', TO_DATE( '2022-2-20', 'YYYY-MM-DD'), TO_DATE( '2022-5-20', 'YYYY-MM-DD'), TO_DATE('2022-6-20', 'YYYY-MM-DD'), 2, 2022, 'MH01','GV03');
INSERT INTO LopHP VALUES ('LHP07', TO_DATE( '2022-2-20', 'YYYY-MM-DD'), TO_DATE( '2022-5-20', 'YYYY-MM-DD'),TO_DATE( '2022-6-20', 'YYYY-MM-DD'), 2, 2022, 'MH02', 'GV08');
INSERT INTO LopHP VALUES ('LHP08', TO_DATE( '2023-1-2', 'YYYY-MM-DD'),TO_DATE( '2023-3-20', 'YYYY-MM-DD'), TO_DATE('2023-4-2', 'YYYY-MM-DD'), 1, 2023, 'MH03', 'GV01');
INSERT INTO LopHP VALUES ('LHP09',  TO_DATE( '2022-3-10', 'YYYY-MM-DD'), TO_DATE( '2022-6-10', 'YYYY-MM-DD'),TO_DATE( '2022-6-30', 'YYYY-MM-DD'), 3, 2022, 'MH04', 'GV04');
INSERT INTO LopHP VALUES ('LHP10',  TO_DATE( '2022-3-10', 'YYYY-MM-DD'), TO_DATE( '2022-6-10', 'YYYY-MM-DD'), TO_DATE( '2022-6-30', 'YYYY-MM-DD'), 3, 2022, 'MH05', 'GV07');


-- Tao bang Dangky
CREATE TABLE DangKy
(
   MSSV			varchar (5) not null ,
   MaLHP			varchar (8)  not null ,
   NgayDK		date not null,
   CONSTRAINT PK_DK PRIMARY KEY (MSSV,MaLHP),
   FOREIGN KEY (MSSV) REFERENCES SinhVien(MSSV),
   FOREIGN KEY (MaLHP) REFERENCES LopHP(MaLHP)
);

--Them du lieu vao bang DangKy
        INSERT INTO DangKy VALUES ('SV01', 'LHP01',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV02', 'LHP03', TO_DATE( '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV03', 'LHP01',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV04', 'LHP01',  TO_DATE( '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV05', 'LHP05',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV06', 'LHP04',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV07', 'LHP03', TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV08', 'LHP01',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV09', 'LHP03',  TO_DATE( '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV010', 'LHP01',  TO_DATE( '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV011', 'LHP01',  TO_DATE( '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV012', 'LHP05',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV013', 'LHP04',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV014', 'LHP03',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV015', 'LHP01',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV016', 'LHP03',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV017', 'LHP01',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV018', 'LHP01',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV019', 'LHP05',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD')); 
        INSERT INTO DangKy VALUES('SV019', 'LHP01',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));
		INSERT INTO DangKy VALUES('SV020', 'LHP04',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));
        INSERT INTO DangKy VALUES('SV020', 'LHP01',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));

-- Tao bang DiemThi
CREATE TABLE DiemThi
(
  MSSV		varchar (5) not null ,
  MaLHP		varchar (8)  not null ,
  DiemQt	float  Check (DiemQt >=0), 
  DiemThi   float  Check (DiemThi >=0), 
  DiemTb    float Check (DiemTb >=0), 
  KetQua    varchar (20),
   CONSTRAINT PK_Diem PRIMARY KEY (MSSV,MaLHP),
   FOREIGN KEY (MSSV) REFERENCES SinhVien(MSSV),
   FOREIGN KEY (MaLHP) REFERENCES LopHP(MaLHP)
);
drop table diemthi
--Them du lieu vao bang DiemThi
INSERT INTO DiemThi VALUES  ('SV01', 'LHP01', 3, 2, 2.5, Null);
		INSERT INTO DiemThi VALUES ('SV02', 'LHP03', 8, 10, 9, Null);
		INSERT INTO DiemThi VALUES ('SV03', 'LHP01', 7, 7, 7, Null);
		INSERT INTO DiemThi VALUES ('SV04', 'LHP01', 9, 9, 9, Null);
		INSERT INTO DiemThi VALUES ('SV05', 'LHP05', 9, 10, 9.5, Null);
		INSERT INTO DiemThi VALUES ('SV06', 'LHP04', 7, 9, 8, Null);
		INSERT INTO DiemThi VALUES ('SV07', 'LHP03', 4, 4, 4, Null);
		INSERT INTO DiemThi VALUES ('SV08', 'LHP01', 5, 7, 6, Null);
		INSERT INTO DiemThi VALUES ('SV09', 'LHP03', 6, 4, 5, Null);
		INSERT INTO DiemThi VALUES ('SV010', 'LHP01', 7, 7, 7, Null);
		INSERT INTO DiemThi VALUES ('SV011', 'LHP01', 1, 2, 1.5, Null);
		INSERT INTO DiemThi VALUES ('SV012', 'LHP05', 3, 5, 4, Null);
		INSERT INTO DiemThi VALUES ('SV013', 'LHP04', 8, 8, 8, Null);
		INSERT INTO DiemThi VALUES ('SV014', 'LHP03', 8, 10, 9, Null);
		INSERT INTO DiemThi VALUES ('SV015', 'LHP01', 7, 7, 7, Null);
		INSERT INTO DiemThi VALUES ('SV016', 'LHP03', 6, 4, 5, Null);
		INSERT INTO DiemThi VALUES ('SV017', 'LHP01', 4, 8, 6, Null);
		INSERT INTO DiemThi VALUES ('SV018', 'LHP01', 6, 2, 4, Null);
		INSERT INTO DiemThi VALUES ('SV019', 'LHP05', 6, 6, 6, Null); 
		INSERT INTO DiemThi VALUES ('SV020', 'LHP04', 5, 7, 6, Null);