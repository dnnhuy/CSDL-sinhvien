//------------------------------------------2. VIEW------------------------------------------
/* 1. Tao View_ThongTinSinhVien hien thi thong tin cua tat ca sinh vien, bao gom ma 
 sinh vien, ho ten, ngay sinh, gioi tinh, so dien thoai, lop hoc, va ten tinh/thanh pho cua sinh vien do. */
CREATE OR REPLACE VIEW View_ThongTinSinhVien AS
SELECT SV.MSSV, SV.HoTenSV, SV.NgaySinhSV, SV.GioiTinhSV, SV.SDTSV, L.TenLop, TP.TenTinh
FROM SinhVien SV
JOIN Lop L ON SV.MaLop = L.MaLop
JOIN TinhTP TP ON SV.MaTinh = TP.MaTinh;

-- Thuc thi
SELECT * FROM View_ThongTinSinhVien;

/* 2. Tao View_ThongKe_SoLuongSinhVien thong ke so luong cac sinh vien thuoc mot lop. */
CREATE OR REPLACE VIEW View_ThongKe_SoLuongSinhVien AS
SELECT L.MaLop, L.TenLop, COUNT(S.MSSV) AS SoLuongSinhVien
FROM Lop L
JOIN SinhVien S ON L.MaLop = S.MaLop
GROUP BY L.MaLop, L.TenLop;

-- Thuc thi
SELECT * FROM View_ThongKe_SoLuongSinhVien;

/* 3. Tao View_DanhSachLopHP hien thi danh sach lop hoc phan voi thong tin ve mon hoc, 
giang vien, so luong sinh vien da dang ky. */
CREATE OR REPLACE VIEW View_DanhSachLopHP AS
SELECT LH.MaLHP, MH.TenMH, GV.HoTenGV, COUNT(DK.MSSV) AS SoLuongDangKy
FROM LopHP LH
JOIN MonHoc MH ON LH.MaMH = MH.MaMH
JOIN GiangVien GV ON LH.MaGV = GV.MaGV
LEFT JOIN DangKy DK ON LH.MaLHP = DK.MaLHP
GROUP BY LH.MaLHP, MH.TenMH, GV.HoTenGV;

-- Thuc thi
SELECT * FROM View_DanhSachLopHP;

/* 4. Tao View_ThongKeTinhThanh thong ke tinh thanh co nhieu sinh vien theo hoc tai truong nhat. */
CREATE OR REPLACE VIEW View_ThongKeTinhThanh AS
SELECT TT.MaTinh, TT.TenTinh, COUNT(SV.MSSV) AS SoLuongSinhVien
FROM TinhTP TT
JOIN SinhVien SV ON TT.MaTinh = SV.MaTinh
GROUP BY TT.MaTinh, TT.TenTinh
HAVING COUNT(SV.MSSV) = (
    SELECT MAX(SoLuongSinhVien)
    FROM (
        SELECT COUNT(SV.MSSV) AS SoLuongSinhVien
        FROM TinhTP TT
        JOIN SinhVien SV ON TT.MaTinh = SV.MaTinh
        GROUP BY TT.MaTinh
    )
);

-- Thuc thi
SELECT * FROM View_ThongKeTinhThanh;

/* 5. Tao View_ThongKeDiemTBMax thong ke sinh vien co diem trung binh cao nhat o tung lop hoc phan. */
CREATE OR REPLACE VIEW View_ThongKeDiemTBMax AS
SELECT LHP.MaLHP, LHP.MaMH, SV.MSSV, SV.HoTenSV, DT.DiemTb
FROM LopHP LHP
JOIN DiemThi DT ON LHP.MaLHP = DT.MaLHP
JOIN SinhVien SV ON DT.MSSV = SV.MSSV
WHERE DT.DiemTb = (
    SELECT MAX(DiemTb)
    FROM DiemThi
    WHERE MaLHP = LHP.MaLHP
)
ORDER BY LHP.MaLHP;

-- Thuc thi
SELECT * FROM View_ThongKeDiemTBMax;




// ------------------------------------------3. PROCEDURE----------------------------------------
//Giang vien co tuoi cao nhat
SET SERVEROUTPUT ON;
create or replace procedure get_oldest_lecturer
AS
  v_id varchar (5);
  v_name VARCHAR(50);
  v_age NUMBER;
BEGIN
  -- L?y gi?ng viên có tu?i cao nh?t
  SELECT MaGV, HoTenGV, (EXTRACT(Year from SYSDATE())-EXTRACT (Year from NgaySinhGV)) AS TUOI
  INTO
    v_id,
    v_name,
    v_age
  FROM Giangvien
  ORDER BY TUOI DESC
  FETCH FIRST 1 ROW ONLY;
  -- Hien thi thông tin giang viên
  DBMS_OUTPUT.PUT_LINE('Gi?ng viên có tu?i cao nh?t là:');
  DBMS_OUTPUT.PUT_LINE('MaGV: ' || v_id);
  DBMS_OUTPUT.PUT_LINE('H? tên: ' || v_name);
  DBMS_OUTPUT.PUT_LINE('Tu?i: ' || v_age);
END;
//Thuc thi
Exec  get_oldest_lecturer;

//Proc 2
create or replace procedure update_results
as
cursor kq_curs is select * from DIEMTHI ;
v_kq_curs DIEMTHI%ROWTYPE;
begin
   open kq_curs;
    loop
    fetch kq_curs into v_kq_curs;
        IF v_kq_curs.diemtb <= 4 THEN
         v_kq_curs.ketqua := 'Rot';
        ELSE
         v_kq_curs.ketqua := 'Dau';
        END IF;
    update DIEMTHI 
    set KETQUA=v_kq_curs.ketqua 
    where mssv=v_kq_curs.mssv and malhp=v_kq_curs.malhp;
    exit when kq_curs%notfound;
    end loop;
    close kq_curs;
    
commit;
    exception
        when NO_DATA_FOUND then  DBMS_OUTPUT.put_line('Khong tim thay');
        when others then DBMS_OUTPUT.put_line(SQLERRM);
end;
//Thuc thi
SET SERVEROUTPUT ON;
EXECUTE update_results;
Select * from Diemthi;


//Proc 3: T?o th? t?c cho bi?t thông tin v? l?p v?i tham s? truy?n vào là mã l?p.
create or replace procedure lop_info(p_malop lop.malop%type)
as
v_malop lop.malop%type;
v_tenlop lop.tenlop%type;
v_MaCN lop.macn%type;
v_TenCN chuyennganh.tencn%type;
begin

    v_malop := p_malop;
    select malop, tenlop, lop.macn, tencn 
    into v_malop, v_tenlop, v_MaCN, v_TenCN
    from lop, chuyennganh cn
    where MaLop=v_MaLop and lop.macn=cn.macn;
    DBMS_OUTPUT.PUT_LINE('Ma lop: ' || v_MaLop);
    DBMS_OUTPUT.PUT_LINE('Ten lop: ' || v_TenLop);
    DBMS_OUTPUT.PUT_LINE('Si so lop: ' || v_TenLop);
    DBMS_OUTPUT.PUT_LINE('Ma CN: ' || v_Macn);
    DBMS_OUTPUT.PUT_LINE('Ten CN: ' || v_tencn);
    exception when no_data_found
    then dbms_output.put_line('Khong co lop');
end;
--Thuc thi
set serveroutput on
EXECUTE lop_info('&MaLop');

//Proc 4:
CREATE OR REPLACE PROCEDURE DS_SV (LHP DIEMTHI.MALHP%TYPE) 
AS
CURSOR CURS IS SELECT SV.MSSV, HOTENSV, DIEMTHI, KETQUA 
               FROM SINHVIEN SV, DIEMTHI DT 
               WHERE MALHP = LHP AND SV.MSSV=DT.MSSV ;
  S_MSSV DIEMTHI.MSSV%TYPE;
  S_HOTENSV SINHVIEN.HOTENSV%TYPE;
  S_DIEMTHI DIEMTHI.DIEMTHI%TYPE;
  S_KETQUA DIEMTHI.KETQUA%TYPE;
  BEGIN 
    OPEN CURS;
    LOOP
        FETCH CURS INTO S_MSSV,S_HOTENSV,  S_DIEMTHI,S_KETQUA ;
        EXIT WHEN CURS%NOTFOUND;
        DBMS_OUTPUT.put_line(CURS%ROWCOUNT ||'. MSSV: '||S_MSSV );  
        DBMS_OUTPUT.put_line(' ' ||'HO TEN: '||s_hotensv );
        DBMS_OUTPUT.put_line(' ' ||'DIEM THI: '||s_diemthi );
        DBMS_OUTPUT.put_line(' ' ||'KET QUA THI: '||s_ketqua ); 
        DBMS_OUTPUT.put_line(' ');
    END LOOP;
    CLOSE CURS;
  END;
//thuc thi
set serveroutput on;
//Thuc thi thu tuc
EXECUTE  DS_SV('&LHP');
//Thuc thi khoi lenh
DECLARE 
  TB NUMBER := &TB ;
  CURSOR C1 IS SELECT MALHP, AVG(DIEMTHI)AS DTB FROM DIEMTHI GROUP BY MALHP
  HAVING AVG(DIEMTHI) >TB;
  BEGIN
  DBMS_OUTPUT.put_line('DANH SACH CAC LHP CO MUC DIEM THI TRUNG BINH
  LON HON '||TB);
  FOR ITEM IN C1
  LOOP
    DBMS_OUTPUT.put_line(' ' ||'LOP HOC PHAN: '||ITEM.MALHP );
    DBMS_OUTPUT.put_line(' ' ||'CO DIEM THI TRUNG BINH: '||ITEM.DTB);
    DS_SV(ITEM.MALHP);
   END LOOP;
    END;


//Proc 5: 
create or replace procedure add_tinh (v_matinh tinhtp.matinh%TYPE, v_tentinh tinhtp.tentinh%TYPE)
as
v_matinh_temp tinhtp.matinh%TYPE;
v_loi EXCEPTION;
begin
select matinh into v_matinh_temp from tinhtp
where matinh=v_matinh;
if v_matinh_temp is not null then raise v_loi;
end if;
exception when v_loi then 
dbms_output.put_line('Khong them duoc'); when no_data_found then
insert into tinhtp (matinh,tentinh) values (v_matinh,v_tentinh); 
dbms_output.put_line('Tinh '|| v_tentinh || ' da duoc them.');
end;
--thuc thi
set serveroutput on
execute add_tinh('&p_Matinh', '&Tentinh');


//------------------------------------------4. FUNCTION------------------------------------------
/* 1. Tao ham cho biet thong tin sinh vien co diem thi cao nhat v?i tham so truyen vao la Ma lop hoc phan. */
CREATE OR REPLACE FUNCTION TimSinhVienDiemCaoNhat(MaLHP_IN VARCHAR)
RETURN VARCHAR
IS
    MSSV_MAX VARCHAR(5);
BEGIN
    SELECT MSSV INTO MSSV_MAX
    FROM DiemThi
    WHERE MaLHP = MaLHP_IN
    ORDER BY DiemThi DESC
    FETCH FIRST 1 ROW ONLY;    
    RETURN MSSV_MAX;
END;

-- Thuc thi
SET SERVEROUTPUT ON;
DECLARE
    MSSV_MAX VARCHAR(5);
    HOTENSV VARCHAR(50);
    DIEMTHI FLOAT;
    MALHP VARCHAR(8);
BEGIN
    MSSV_MAX := TIMSINHVIENDIEMCAONHAT('LHP05');
SELECT SV.HOTENSV, DT.DIEMTHI, DT.MALHP
INTO HOTENSV, DIEMTHI, MALHP
FROM SINHVIEN SV
INNER JOIN DIEMTHI DT ON SV.MSSV = DT.MSSV
WHERE SV.MSSV = MSSV_MAX
AND DT.MALHP = 'LHP05';
    DBMS_OUTPUT.PUT_LINE('Sinh vien co diem thi cao nhat: ' || HOTENSV);
    DBMS_OUTPUT.PUT_LINE('Ma so sinh vien: ' || MSSV_MAX);
    DBMS_OUTPUT.PUT_LINE('Diem thi: ' || DIEMTHI);
    DBMS_OUTPUT.PUT_LINE('Ma lop hoc phan: ' || MALHP);
END;

/* 2. Tao ham cho biet so luong giang vien voi tham so truyen vao la Ma khoa. */
CREATE OR REPLACE FUNCTION DemSoLuongGiangVien(MaKhoa_input IN VARCHAR2) RETURN NUMBER IS
    SoLuongGiangVien NUMBER;
BEGIN
    SELECT COUNT(*) INTO SoLuongGiangVien
    FROM GiangVien gv
    WHERE gv.MaKhoa = MaKhoa_input;

    RETURN SoLuongGiangVien;
END;

-- Thuc thi
SET SERVEROUTPUT ON;
DECLARE
    NumGiangVien NUMBER;
BEGIN
    NumGiangVien := DemSoLuongGiangVien('QTKD');
    DBMS_OUTPUT.PUT_LINE('So luong giang vien cua khoa la: ' || NumGiangVien);
END;

/* 3. Tao ham cho biet 2 lop hoc phan co so luong sinh vien dang ky nhieu nhat. */
CREATE OR REPLACE FUNCTION TimLopHPNhieuSinhVienNhat RETURN SYS_REFCURSOR IS
    Cur SYS_REFCURSOR;
BEGIN
    OPEN Cur FOR
    SELECT lh.MaLHP, COUNT(*) AS SoLuongSinhVien
    FROM LopHP lh
    JOIN DangKy dk ON lh.MaLHP = dk.MaLHP
    GROUP BY lh.MaLHP
    ORDER BY SoLuongSinhVien DESC
    FETCH FIRST 2 ROWS ONLY;

    RETURN Cur;
END;

-- Thuc thi
SET SERVEROUTPUT ON;
DECLARE
    Cur SYS_REFCURSOR;
    MaLHP LopHP.MaLHP%TYPE;
    SoLuongSinhVien NUMBER;
BEGIN
    Cur := TimLopHPNhieuSinhVienNhat;

    LOOP
        FETCH Cur INTO MaLHP, SoLuongSinhVien;
        EXIT WHEN Cur%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Lop hoc phan: ' || MaLHP || ', So luong sinh vien: ' || SoLuongSinhVien);
    END LOOP;

    CLOSE Cur;
END;

/* 4. Tao ham de tinh tong so sinh vien trong co so du lieu va tra ve ket qua la mot so nguyen. */
CREATE OR REPLACE FUNCTION COUNT_SinhVien RETURN NUMBER IS
  total_students NUMBER;
BEGIN
  SELECT COUNT(*) INTO total_students FROM SinhVien;
  RETURN total_students;
END;

-- Thuc thi
SET SERVEROUTPUT ON;
DECLARE
  num_students NUMBER;
BEGIN
  num_students := COUNT_SinhVien;
  DBMS_OUTPUT.PUT_LINE('Tong so sinh vien trong co so du lieu: ' || num_students);
END;

/* 5. Tao ham nhan vao MSSV cua mot sinh vien va tra ve ten day du cua sinh vien do duoi dang mot chuoi. */
CREATE OR REPLACE FUNCTION GET_HoTenSV(MSSV_IN VARCHAR2) RETURN VARCHAR2 IS
  HoTenSV VARCHAR2(50);
BEGIN
  SELECT HoTenSV INTO HoTenSV FROM SinhVien WHERE MSSV = MSSV_IN;
  RETURN HoTenSV;
END;

-- Thuc thi
SET SERVEROUTPUT ON;
DECLARE
  MSSV VARCHAR2(5) := 'SV011';
  HoTenSV VARCHAR2(50);
BEGIN
  HoTenSV := GET_HoTenSV(MSSV);
  DBMS_OUTPUT.PUT_LINE('Ho ten sinh vien: ' || HoTenSV);
END;

/* 6. Tao ham de tim sinh vien co diem trung binh cao nhat va tra ve thong tin cua sinh vien do duoi dang mot con tro hoac bo gia tri. */
CREATE OR REPLACE FUNCTION GET_SinhVienDiemCaoNhat RETURN SYS_REFCURSOR IS
  v_cursor SYS_REFCURSOR;
BEGIN
  OPEN v_cursor FOR
    SELECT s.MSSV, s.HoTenSV, s.NgaySinhSV, s.GioiTinhSV, s.SDTSV, s.CMND, s.MaLop, s.MaTinh
    FROM SinhVien s
    JOIN (
      SELECT MSSV, AVG(DiemTb) AS DiemTrungBinh
      FROM DiemThi
      GROUP BY MSSV
      HAVING AVG(DiemTb) = (
        SELECT MAX(AVG(DiemTb))
        FROM DiemThi
        GROUP BY MSSV
      )
    ) dt ON s.MSSV = dt.MSSV;

  RETURN v_cursor;
END;

-- Thuc thi
SET SERVEROUTPUT ON;
DECLARE
  v_result SYS_REFCURSOR;
  v_MSSV SinhVien.MSSV%TYPE;
  v_HoTenSV SinhVien.HoTenSV%TYPE;
  v_NgaySinhSV SinhVien.NgaySinhSV%TYPE;
  v_GioiTinhSV SinhVien.GioiTinhSV%TYPE;
  v_SDTSV SinhVien.SDTSV%TYPE;
  v_CMND SinhVien.CMND%TYPE;
  v_MaLop SinhVien.MaLop%TYPE;
  v_MaTinh SinhVien.MaTinh%TYPE;
BEGIN
  v_result := GET_SinhVienDiemCaoNhat;
  FETCH v_result INTO v_MSSV, v_HoTenSV, v_NgaySinhSV, v_GioiTinhSV, v_SDTSV, v_CMND, v_MaLop, v_MaTinh;
  CLOSE v_result;

  DBMS_OUTPUT.PUT_LINE('MSSV: ' || v_MSSV);
  DBMS_OUTPUT.PUT_LINE('Ho va ten: ' || v_HoTenSV);
  DBMS_OUTPUT.PUT_LINE('Ngay sinh: ' || v_NgaySinhSV);
  DBMS_OUTPUT.PUT_LINE('Gioi tinh: ' || v_GioiTinhSV);
  DBMS_OUTPUT.PUT_LINE('So dien thoai: ' || v_SDTSV);
  DBMS_OUTPUT.PUT_LINE('CMND: ' || v_CMND);
  DBMS_OUTPUT.PUT_LINE('Ma lop: ' || v_MaLop);
  DBMS_OUTPUT.PUT_LINE('Ma Tinh: ' || v_MaTinh);
END;

/* 7. Tao ham nhan vao ten lop hoc va tra ve danh sach tat ca sinh vien trong lop do duoi dang mot bang hoac con tro. */
CREATE OR REPLACE FUNCTION GET_SinhVienByLop(
  p_TenLop IN Lop.TenLop%TYPE
) RETURN SYS_REFCURSOR IS
  v_cursor SYS_REFCURSOR;
BEGIN
  OPEN v_cursor FOR
    SELECT s.MSSV, s.HoTenSV, s.NgaySinhSV, s.GioiTinhSV, s.SDTSV, s.CMND, s.MaLop, s.MaTinh
    FROM SinhVien s
    JOIN Lop l ON s.MaLop = l.MaLop
    WHERE l.TenLop = p_TenLop;

  RETURN v_cursor;
END;

-- Thuc thi
SET SERVEROUTPUT ON;
DECLARE
  v_result SYS_REFCURSOR;
  v_MSSV SinhVien.MSSV%TYPE;
  v_HoTenSV SinhVien.HoTenSV%TYPE;
  v_NgaySinhSV SinhVien.NgaySinhSV%TYPE;
  v_GioiTinhSV SinhVien.GioiTinhSV%TYPE;
  v_SDTSV SinhVien.SDTSV%TYPE;
  v_CMND SinhVien.CMND%TYPE;
  v_MaLop SinhVien.MaLop%TYPE;
  v_MaTinh SinhVien.MaTinh%TYPE;
BEGIN
  v_result := GET_SinhVienByLop('Lop kiem toan 01');

  LOOP
    FETCH v_result INTO v_MSSV, v_HoTenSV, v_NgaySinhSV, v_GioiTinhSV, v_SDTSV, v_CMND, v_MaLop, v_MaTinh;
    EXIT WHEN v_result%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE('MSSV: ' || v_MSSV);
    DBMS_OUTPUT.PUT_LINE('Ho va ten: ' || v_HoTenSV);
    DBMS_OUTPUT.PUT_LINE('Ngay sinh: ' || v_NgaySinhSV);
    DBMS_OUTPUT.PUT_LINE('Gioi tinh: ' || v_GioiTinhSV);
    DBMS_OUTPUT.PUT_LINE('So dien thoai: ' || v_SDTSV);
    DBMS_OUTPUT.PUT_LINE('CMND: ' || v_CMND);
    DBMS_OUTPUT.PUT_LINE('Ma lop: ' || v_MaLop);
    DBMS_OUTPUT.PUT_LINE('Ma tinh: ' || v_MaTinh);
  END LOOP;

  CLOSE v_result;
END;


//------------------------------------------5. PACKAGE------------------------------------------
/* 1. Package lop_info gom: 
a. Thu tuc lop_list, nhan vao 1 tham so vao la ma lop, thu tuc in danh sach sinh vien thuoc lop do. 
b. Ham lop_find, nhan vao 1 tham so la ma lop. Ham tra ve 1 neu ma lop ton tai duy nhat trong bang lop, nguoc lai tra ve 0. 
c. Viet khoi lenh (block) nhap vao gia tri cho bien la ma lop, su dung package lop_info de xac dinh ma lop co ton tai trong 
bang lop khong? Neu co thi in danh sach sinh vien cua lop do. */

-- Thu tuc lop_list
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE lop_list(p_MaLop IN VARCHAR2) AS
BEGIN
  FOR rec IN (SELECT sv.MSSV, sv.HoTenSV, sv.NgaySinhSV, sv.GioiTinhSV, sv.SDTSV, sv.CMND
              FROM SinhVien sv
              WHERE sv.MaLop = p_MaLop)
  LOOP
    DBMS_OUTPUT.PUT_LINE('MSSV: ' || rec.MSSV);
    DBMS_OUTPUT.PUT_LINE('Ho va ten: ' || rec.HoTenSV);
    DBMS_OUTPUT.PUT_LINE('Ngay sinh: ' || TO_CHAR(rec.NgaySinhSV, 'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('Gioi tinh: ' || rec.GioiTinhSV);
    DBMS_OUTPUT.PUT_LINE('So dien thoai: ' || rec.SDTSV);
    DBMS_OUTPUT.PUT_LINE('CMND: ' || rec.CMND);
    DBMS_OUTPUT.PUT_LINE('--------------------------------------');
  END LOOP;
END;

-- Thuc thi
BEGIN
  lop_list('21DTH1');
END;

-- Ham lop_find
CREATE OR REPLACE FUNCTION lop_find(p_MaLop IN VARCHAR2) RETURN NUMBER AS
  v_Count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_Count
  FROM Lop
  WHERE MaLop = p_MaLop;

  IF v_Count = 1 THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;
END;

-- Thuc thi
SET SERVEROUTPUT ON;
DECLARE
  v_Result NUMBER;
BEGIN
  v_Result := lop_find('21DTH1');
  IF v_Result = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Ma lop ton tai duy nhat trong bang "LOP"');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Ma lop khong ton tai hoac trung lap trong bang "LOP"');
  END IF;
END;

-- Package
CREATE OR REPLACE PACKAGE lop_info AS
  FUNCTION lop_find(p_MaLop IN VARCHAR2) RETURN NUMBER;
  PROCEDURE lop_list(p_MaLop IN VARCHAR2);
END lop_info;

CREATE OR REPLACE PACKAGE BODY lop_info AS
  FUNCTION lop_find(p_MaLop IN VARCHAR2) RETURN NUMBER AS
    v_Count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_Count
    FROM Lop
    WHERE MaLop = p_MaLop;

    IF v_Count = 1 THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END lop_find;

  PROCEDURE lop_list(p_MaLop IN VARCHAR2) AS
  BEGIN
    FOR rec IN (SELECT sv.MSSV, sv.HoTenSV, sv.NgaySinhSV, sv.GioiTinhSV, sv.SDTSV, sv.CMND
                FROM SinhVien sv
                WHERE sv.MaLop = p_MaLop)
    LOOP
      DBMS_OUTPUT.PUT_LINE('MSSV: ' || rec.MSSV);
      DBMS_OUTPUT.PUT_LINE('Ho va ten: ' || rec.HoTenSV);
      DBMS_OUTPUT.PUT_LINE('Ngay sinh: ' || TO_CHAR(rec.NgaySinhSV, 'DD/MM/YYYY'));
      DBMS_OUTPUT.PUT_LINE('Gioi tinh: ' || rec.GioiTinhSV);
      DBMS_OUTPUT.PUT_LINE('So dien thoai: ' || rec.SDTSV);
      DBMS_OUTPUT.PUT_LINE('CMND: ' || rec.CMND);
      DBMS_OUTPUT.PUT_LINE('--------------------------------------');
    END LOOP;
  END lop_list;
END lop_info;

-- Viet khoi lenh (block), thuc thi
SET SERVEROUTPUT ON;
DECLARE
  v_MaLop VARCHAR2(6);
  v_Exist NUMBER;
BEGIN
  v_MaLop := '21DTK2';
  v_Exist := lop_info.lop_find(v_MaLop);

  IF v_Exist = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Ma lop ' || v_MaLop || ' ton tai trong bang "LOP"');
    DBMS_OUTPUT.PUT_LINE('Danh sach sinh vien thuoc lop ' || v_MaLop || ':');
    lop_info.lop_list(v_MaLop);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Ma lop ' || v_MaLop || ' khong ton tai trong bang "LOP"');
  END IF;
END;

/* 2. Package gv gom: 
a. Thu tuc gv_oldest, nhan vao 1 tham so vao la ma khoa, thu tuc in giang vien lon tuoi nhat cua khoa. 
b. Ham gv _find, nhan vao 1 tham so la ma khoa. Ham tra ve 1 neu ma khoa ton tai duy nhat trong bang khoa, nguoc lai tra ve 0. 
c. Viet khoi lenh (block) nhap vao gia tri cho bien la ma khoa, su dung package gv de xac dinh ma khoa co ton tai trong 
bang khoa khong? Neu co thi in giang vien lon tuoi nhat cua khoa do. */

-- Thu tuc 
CREATE OR REPLACE PROCEDURE gv_oldest(p_MaKhoa IN VARCHAR2) AS
  v_GV_ID GiangVien.MaGV%TYPE;
  v_GV_Ten GiangVien.HoTenGV%TYPE;
  v_GV_Tuoi NUMBER;
BEGIN
  SELECT gv.MaGV, gv.HoTenGV, EXTRACT(YEAR FROM sysdate) - EXTRACT(YEAR FROM gv.NgaySinhGV) INTO v_GV_ID, v_GV_Ten, v_GV_Tuoi
  FROM GiangVien gv
  WHERE gv.MaKhoa = p_MaKhoa
  ORDER BY gv.NgaySinhGV ASC
  FETCH FIRST 1 ROWS ONLY;
  IF v_GV_ID IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('Giang vien lon tuoi nhat cua khoa ' || p_MaKhoa || ':');
    DBMS_OUTPUT.PUT_LINE('Ma giang viên: ' || v_GV_ID);
    DBMS_OUTPUT.PUT_LINE('Ten giang vien: ' || v_GV_Ten);
    DBMS_OUTPUT.PUT_LINE('Tuoi: ' || v_GV_Tuoi);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Khong tim thay giang vien trong khoa ' || p_MaKhoa);
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Khong tim thay giang vien trong khoa ' || p_MaKhoa);
END;

-- Thuc thi
EXECUTE gv_oldest('KETN');

-- Ham
CREATE OR REPLACE FUNCTION gv_find(p_MaKhoa IN VARCHAR2) RETURN NUMBER AS
  v_Count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_Count
  FROM Khoa
  WHERE MaKhoa = p_MaKhoa;
  IF v_Count = 1 THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
END;

-- Thuc thi
SET SERVEROUTPUT ON;
DECLARE
  v_Result NUMBER;
BEGIN
  v_Result := gv_find('CNTTT');
  IF v_Result = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Ma khoa ton tai duy nhat trong bang "KHOA"');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Ma khoa khong ton tai hoac trung lap trong bang "KHOA"');
  END IF;
END;

-- Package
CREATE OR REPLACE PACKAGE gv AS
  PROCEDURE gv_oldest(p_MaKhoa IN VARCHAR2);
  FUNCTION gv_find(p_MaKhoa IN VARCHAR2) RETURN NUMBER;
END gv;

CREATE OR REPLACE PACKAGE BODY gv AS
 
  PROCEDURE gv_oldest(p_MaKhoa IN VARCHAR2) AS
    v_GV_ID GiangVien.MaGV%TYPE;
    v_GV_Ten GiangVien.HoTenGV%TYPE;
    v_GV_Tuoi NUMBER;
  BEGIN
    
    SELECT gv.MaGV, gv.HoTenGV, EXTRACT(YEAR FROM sysdate) - EXTRACT(YEAR FROM gv.NgaySinhGV)
    INTO v_GV_ID, v_GV_Ten, v_GV_Tuoi
    FROM GiangVien gv
    WHERE gv.MaKhoa = p_MaKhoa
    ORDER BY gv.NgaySinhGV ASC
    FETCH FIRST 1 ROWS ONLY;

    IF v_GV_ID IS NOT NULL THEN
      DBMS_OUTPUT.PUT_LINE('Giang vien lon tuoi nhat cua khoa ' || p_MaKhoa || ':');
      DBMS_OUTPUT.PUT_LINE('Ma giang vien: ' || v_GV_ID);
      DBMS_OUTPUT.PUT_LINE('Ten giang vien: ' || v_GV_Ten);
      DBMS_OUTPUT.PUT_LINE('Tuoi: ' || v_GV_Tuoi);
    ELSE
      DBMS_OUTPUT.PUT_LINE('Khong tim thay giang vien trong khoa ' || p_MaKhoa);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Khong tim thay giang vien trong khoa ' || p_MaKhoa);
  END gv_oldest;
  
  FUNCTION gv_find(p_MaKhoa IN VARCHAR2) RETURN NUMBER AS
    v_Count NUMBER;
  BEGIN
    SELECT COUNT(*)
    INTO v_Count
    FROM Khoa
    WHERE MaKhoa = p_MaKhoa;
    IF v_Count = 1 THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
  END gv_find;
END gv;

-- Viet khoi lenh (block), thuc thi
SET SERVEROUTPUT ON;
DECLARE
  v_MaKhoa VARCHAR2(4);
  v_Result NUMBER;
BEGIN
  v_MaKhoa := 'KTL';
  v_Result := gv.gv_find(v_MaKhoa);
  IF v_Result = 1 THEN
    gv.gv_oldest(v_MaKhoa);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Ma khoa ' || v_MaKhoa || ' khong ton tai trong bang "KHOA".');
  END IF;
END;

/* 3. Package diem gom:
a. Thu tuc diem_list, nhan vao 1 tham so vao la ma lop hoc phan, thu tuc in danh sach diem thi cua sinh vien thuoc lop hoc phan do. 
b. Ham lhp _find, nhan vao 1 tham so la ma lop hoc phan. Ham tra ve 1 neu ma lop hoc phan ton tai duy nhat trong bang lop hoc phan,
nguoc lai tra ve 0. 
c. Viet khoi lenh (block) nhap vao gia tri cho bien la ma lop hoc phan, su dung package diem de xac dinh ma lop hoc phan co ton tai 
trong bang lop hoc phan khong? Neu co thi in danh sach diem thi cua sinh vien thuoc lop hoc phan do. */

-- Thu tuc
CREATE OR REPLACE PROCEDURE diem_list(p_MaLHP IN VARCHAR2) AS
BEGIN
  FOR rec IN (SELECT sv.MSSV, sv.HoTenSV, dt.DiemQt, dt.DiemThi, dt.DiemTb
              FROM SinhVien sv
              JOIN DangKy dk ON sv.MSSV = dk.MSSV
              JOIN DiemThi dt ON sv.MSSV = dt.MSSV AND dk.MaLHP = dt.MaLHP
              WHERE dk.MaLHP = p_MaLHP)
  LOOP
    DBMS_OUTPUT.PUT_LINE('MSSV: ' || rec.MSSV);
    DBMS_OUTPUT.PUT_LINE('Ho va ten: ' || rec.HoTenSV);
    DBMS_OUTPUT.PUT_LINE('Diem qua trinh: ' || rec.DiemQt);
    DBMS_OUTPUT.PUT_LINE('Diem thi: ' || rec.DiemThi);
    DBMS_OUTPUT.PUT_LINE('Diem trung binh: ' || rec.DiemTb);
    DBMS_OUTPUT.PUT_LINE('------------------------');
  END LOOP;
END diem_list;

-- Thuc thi
SET SERVEROUTPUT ON;
BEGIN
  diem_list('LHP04'); 
END;

-- Ham
CREATE OR REPLACE FUNCTION lhp_find(p_MaLHP IN VARCHAR2) RETURN NUMBER AS
  v_Count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_Count
  FROM LopHP
  WHERE MaLHP = p_MaLHP;

  IF v_Count = 1 THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;
END lhp_find;

-- Thuc thi
SET SERVEROUTPUT ON;
DECLARE
  v_Result NUMBER;
BEGIN
  v_Result := lhp_find('LHP04'); 
  IF v_Result = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Ma lop hoc phan ton tai duy nhat trong bang "LOPHP"');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Ma lop hoc phan khong ton tai hoac trung lap trong bang "LOPHP"');
  END IF;
END;

-- Package
CREATE OR REPLACE PACKAGE diem AS
  PROCEDURE diem_list(p_MaLHP IN VARCHAR2);
  FUNCTION lhp_find(p_MaLHP IN VARCHAR2) RETURN NUMBER;
END diem;

CREATE OR REPLACE PACKAGE BODY diem AS
  PROCEDURE diem_list(p_MaLHP IN VARCHAR2) AS
  BEGIN
    FOR rec IN (SELECT sv.MSSV, sv.HoTenSV, dt.DiemQt, dt.DiemThi, dt.DiemTb
                FROM SinhVien sv
                JOIN DangKy dk ON sv.MSSV = dk.MSSV
                JOIN DiemThi dt ON sv.MSSV = dt.MSSV AND dk.MaLHP = dt.MaLHP
                WHERE dk.MaLHP = p_MaLHP)
    LOOP
      DBMS_OUTPUT.PUT_LINE('MSSV: ' || rec.MSSV);
      DBMS_OUTPUT.PUT_LINE('Ho va ten: ' || rec.HoTenSV);
      DBMS_OUTPUT.PUT_LINE('Diem qua trinh: ' || rec.DiemQt);
      DBMS_OUTPUT.PUT_LINE('Diem thi: ' || rec.DiemThi);
      DBMS_OUTPUT.PUT_LINE('Diem trung binh: ' || rec.DiemTb);
      DBMS_OUTPUT.PUT_LINE('------------------------');
    END LOOP;
  END diem_list;
  
  FUNCTION lhp_find(p_MaLHP IN VARCHAR2) RETURN NUMBER AS
    v_Count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_Count
    FROM LopHP
    WHERE MaLHP = p_MaLHP;

    IF v_Count = 1 THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END lhp_find;
END diem;

-- Viet khoi lenh (block), thuc thi
SET SERVEROUTPUT ON;
DECLARE
  v_MaLHP VARCHAR2(8);
  v_Exist NUMBER;
BEGIN
  v_MaLHP := '&Enter_MaLHP'; -- LHP03
  v_Exist := diem.lhp_find(v_MaLHP);
  
  IF v_Exist = 1 THEN
    diem.diem_list(v_MaLHP);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Ma lop hoc phan khong ton tai.');
  END IF;
END;

/* 4. Package tinh gom:
a. Thu tuc tinh_add, them mot tinh voi 2 tham so vao la ma tinh thanh pho va ten tinh thanh pho. 
b. Ham tinh_check, nhan vao 1 tham so la ma tinh thanh pho. Ham tra 1 neu ma tinh ton tai duy nhat trong bang TINHTP, nguoc lai tra ve 0.
c. Viet khoi lenh (block) nhap vao gia tri cho bien la ma tinh thanh pho, su dung package tinh de xac dinh tinh do co ton tai trong bang TINHTP chua? 
Neu chua thi them tinh do vao bang TINHTP. */

-- Thu tuc
CREATE OR REPLACE PROCEDURE tinh_add(
  p_MaTinh IN TinhTP.MaTinh%TYPE,
  p_TenTinh IN TinhTP.TenTinh%TYPE
)
IS
BEGIN
  INSERT INTO TinhTP (MaTinh, TenTinh)
  VALUES (p_MaTinh, p_TenTinh);
  
  DBMS_OUTPUT.PUT_LINE('Them tinh, thanh pho thanh cong.');
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    DBMS_OUTPUT.PUT_LINE('Ma tinh thanh pho da ton tai.');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Da xay ra loi khi them tinh thanh pho.');
END;

-- Thuc thi
SET SERVEROUTPUT ON;
BEGIN
  tinh_add('MT06', 'Tay Ninh');
END;

-- Ham
CREATE OR REPLACE FUNCTION tinh_check(p_MaTinh IN TinhTP.MaTinh%TYPE) RETURN NUMBER
IS
  v_Count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_Count
  FROM TinhTP
  WHERE MaTinh = p_MaTinh;
  
  IF v_Count = 1 THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END;

-- Thuc thi
SET SERVEROUTPUT ON;
DECLARE
  v_Result NUMBER;
BEGIN
  v_Result := tinh_check('MT06');
  IF v_Result = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Ma tinh ton tai duy nhat trong bang "TINHTP"');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Ma tinh khong ton tai hoac trung lap trong bang "TINHTP"');
  END IF;
END;

-- Package
CREATE OR REPLACE PACKAGE tinh IS

  PROCEDURE tinh_add(
    p_MaTinh IN TinhTP.MaTinh%TYPE,
    p_TenTinh IN TinhTP.TenTinh%TYPE
  );

  FUNCTION tinh_check(p_MaTinh IN TinhTP.MaTinh%TYPE) RETURN NUMBER;

END tinh;

CREATE OR REPLACE PACKAGE BODY tinh IS

  PROCEDURE tinh_add(
    p_MaTinh IN TinhTP.MaTinh%TYPE,
    p_TenTinh IN TinhTP.TenTinh%TYPE
  )
  IS
  BEGIN
    INSERT INTO TinhTP (MaTinh, TenTinh)
    VALUES (p_MaTinh, p_TenTinh);
    
    DBMS_OUTPUT.PUT_LINE('Them tinh thanh pho thanh cong.');
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      DBMS_OUTPUT.PUT_LINE('Ma tinh thanh pho da ton tai.');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Da xay ra loi khi them tinh thanh pho.');
  END;

  FUNCTION tinh_check(p_MaTinh IN TinhTP.MaTinh%TYPE) RETURN NUMBER
  IS
    v_Count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_Count
    FROM TinhTP
    WHERE MaTinh = p_MaTinh;
    
    IF v_Count = 1 THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

END tinh;

-- Viet khoi lenh (block), thuc thi
SET SERVEROUTPUT ON;
DECLARE
  v_MaTinh TinhTP.MaTinh%TYPE := 'MT07'; 
  v_Exist NUMBER;
BEGIN
  v_Exist := tinh.tinh_check(v_MaTinh);
  
  IF v_Exist = 0 THEN
   
    tinh.tinh_add(v_MaTinh, 'Binh Thuan'); 
    
    DBMS_OUTPUT.PUT_LINE('Them tinh thanh pho thanh cong.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Tinh thanh pho da ton tai.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Da xay ra loi.');
END;



//------------------------------------------6. TRIGGER------------------------------------------
//TRIG 1:
CREATE OR REPLACE TRIGGER calcu_diem
BEFORE INSERT ON Diemthi
FOR EACH ROW
DECLARE
  v_diemtb float;
BEGIN
  -- Tinh diem trung binh c?a sinh viên
  v_diemtb :=( :NEW.diemthi + :NEW.diemqt)/2;
  :NEW.diemtb:=v_diemtb;
  --Cap nhat ket qua thi
   IF v_diemtb <= 4 THEN
         :NEW.ketqua := 'Rot';
        ELSE
         :NEW.ketqua := 'Dau';
    END IF;
END;

//Thuc thi
INSERT INTO DiemThi VALUES ('SV019', 'LHP01', 9, 8, NULL, Null);
SELECT * from Diemthi where mssv='SV019' and malhp='LHP01';

//TRIG 2:
CREATE OR REPLACE TRIGGER Add_Score
AFTER INSERT ON DangKy
FOR EACH ROW
DECLARE
  v_MSSV DANGKY.MSSV%TYPE;
  v_MALHP DANGKY.MALHP%TYPE;
BEGIN
  -- L?y thông tin sinh viên và môn h?c t? b?ng ??ng kí
  v_MSSV := :NEW.MSSV;
  v_MALHP := :NEW.MALHP;
  
  -- Thêm dòng m?i vào b?ng ?i?m thi
  dbms_output.put_line('Sinh vien '||v_mssv || ' hoc lop hoc phan '||v_malhp|| ' duoc cap nhat thong tin vao Diemthi');
  INSERT INTO DiemThi (MSSV,MALHP,DIEMQT, DIEMTHI, DIEMTB,ketqua)
  VALUES (v_MSSV,v_MALHP, NULL,NULL,NULL,NULL);
END;


//Thuc thi
INSERT INTO DangKy VALUES('SV018', 'LHP03',  TO_DATE(  '2022-2-1', 'YYYY-MM-DD'));


//TRIG 3
CREATE OR REPLACE TRIGGER PreventFutureRegistrationDate
BEFORE INSERT OR UPDATE ON DangKy
DECLARE
    v_current_date NUMBER;
BEGIN
    -- Lay ngay hien tai
    SELECT TO_NUMBER(TO_CHAR(SYSDATE, 'DD')) INTO v_current_date FROM DUAL;

    -- Kiem tra xem ngay hien tai có phai la ngay 30 khong 
    IF v_current_date = 1 THEN
        RAISE_APPLICATION_ERROR(-20001, 'He thong dang bao tri dinh ki, vui long cap nhat sau');
    END IF;
END;

//TRIG 4
CREATE OR REPLACE TRIGGER StudentManagementTrigger
AFTER DELETE ON SinhVien
DECLARE
  v_Action VARCHAR2(10);
BEGIN
  IF INSERTING THEN
    v_Action := 'INSERT';
  ELSIF UPDATING THEN
    v_Action := 'UPDATE';
  ELSIF DELETING THEN
    v_Action := 'DELETE';
  END IF;
 --G?i thông báo sau khi th?c hi?n câu l?nh DELETE
  IF v_Action = 'DELETE' THEN
   dbms_output.put_line('Mot sinh vien da bi xoa ra khoi he thong.');
    -- G?i email thông báo, S? d?ng gói UTL_MAIL ?? g?i email
   -- UTL_MAIL.SEND(sender => '2121005193@sv.ufm.edu.vn',
                 -- recipients => 'nhuyduong.thd@gmail.com',
                 -- subject => '[XOA SINH VIEN',
                  --message => 'Mot sinh vien da bi xoa ra khoi he thong.');
  END IF;
END;


//Thuc thi
--Them sinh vien de test
INSERT INTO SinhVien VALUES ('SV000', N'Duong Ngoc Nhu Y', TO_DATE( '2003-12-12', 'YYYY-MM-DD'), N'N?', '0313008709', '235696169', '21DTH1', 'MT05');
DELETE FROM Sinhvien where MSSV='SV000';

//TRIG 5
-- View_ThongTinSinhVien hien thi thong tin cua tat ca sinh vien, bao gom ma 
--sinh vien, ho ten, ngay sinh, gioi tinh, so dien thoai, lop hoc, va ten tinh/thanh pho cua sinh vien do. 
CREATE OR REPLACE VIEW View_ThongTinSinhVien AS
SELECT SV.MSSV, SV.HoTenSV, SV.NgaySinhSV, SV.GioiTinhSV, SV.SDTSV, L.TenLop, TP.TenTinh
FROM SinhVien SV
JOIN Lop L ON SV.MaLop = L.MaLop
JOIN TinhTP TP ON SV.MaTinh = TP.MaTinh;
--
SELECT * FROM View_ThongTinSinhVien;

-- Tao trigger
CREATE OR REPLACE TRIGGER View_ThongTinSinhVien_delete
INSTEAD OF DELETE ON View_ThongTinSinhVien
FOR EACH ROW
BEGIN
    DELETE FROM SinhVien 
        WHERE MSSV = :old.MSSV;
END;
--Thuc thi
--Them sinh vien de test
INSERT INTO SinhVien VALUES ('SV000', N'Duong Ngoc Nhu Y', TO_DATE( '2003-12-12', 'YYYY-MM-DD'), N'N?', '0313008709', '235696169', '21DTH1', 'MT05');

DELETE FROM View_ThongTinSinhVien where MSSV='SV000';
 
//TRIG 6: Tuoi cua giang vien khong duoc lon gap 5 lan giang vien tre tuoi nhat
CREATE OR REPLACE TRIGGER equitable_age
FOR UPDATE OR INSERT ON giangvien
COMPOUND TRIGGER
-- Khai báo record
TYPE id_age_rt IS RECORD ( magv giangvien.magv%TYPE ,ngaysinhgv giangvien.ngaysinhgv%TYPE );
-- Danh sách m? nv và l??ng nv
TYPE row_level_info_t IS TABLE OF id_age_rt INDEX BY PLS_INTEGER;
g_row_level_info  row_level_info_t;

AFTER EACH ROW IS
BEGIN
    g_row_level_info (g_row_level_info.COUNT + 1).magv := :new.magv;
    g_row_level_info (g_row_level_info.COUNT).ngaysinhgv := :new.ngaysinhgv;
    DBMS_OUTPUT.put_line ('Them thong tin giang vien  ' || g_row_level_info.COUNT || ': '
    || g_row_level_info (g_row_level_info.COUNT).magv || '-' || g_row_level_info (g_row_level_info.COUNT).ngaysinhgv );
END AFTER EACH ROW;


AFTER STATEMENT IS
    tuoi_max int;
    l_max_allowed giangvien.ngaysinhgv%TYPE;
BEGIN
    SELECT MIN(EXTRACT(Year from SYSDATE)-EXTRACT (Year from NgaySinhGV)) * 5, MAX(NgaySinhGV) INTO tuoi_max,l_max_allowed FROM giangvien; 
    DBMS_OUTPUT.put_line ( 'make_equitable max allowed ' || l_max_allowed || 'Count = ' || g_row_level_info.COUNT );
    FOR indx IN 1 .. g_row_level_info.COUNT 
        LOOP
            DBMS_OUTPUT.put_line ('Ma giang vien va ngay sinh: ' || g_row_level_info (indx).magv || '-' || g_row_level_info (indx).ngaysinhgv);
            IF tuoi_max <  (EXTRACT(Year from SYSDATE)-EXTRACT (Year from g_row_level_info (indx).ngaysinhgv)) THEN
                UPDATE giangvien SET ngaysinhgv = l_max_allowed
                WHERE magv = g_row_level_info (indx).magv;
            END IF;
        END LOOP;
END AFTER STATEMENT;

END equitable_age;




--drop trigger equitable_age;
-- Thuc thi
INSERT INTO GiangVien VALUES('GV000', N'Nha Vy',  TO_DATE( '1842-6-16', 'YYYY-MM-DD'), 'Nam', '0913043579', '735699197', 'TMAI');

SELECT * FROM GIANGVIEN
WHERE MAGV='GV000';

DELETE FROM GIANGVIEN
WHERE MAGV='GV000';

SELECT MAX(NgaySinhGV) as Ngay, 
MIN(EXTRACT(Year from SYSDATE)-EXTRACT (Year from NgaySinhGV))as tuoi 
FROM giangvien;

