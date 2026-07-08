const officegen = require('officegen');
const fs = require('fs');

const OUTPUT_DIR = 'c:\\Users\\anhnpv\\OneDrive - Thanh Cong Group\\Desktop\\code';

// Helper: tạo bảng với styling
function createTable(headers, rows, colWidths) {
    const table = [
        headers.map((h, i) => ({ val: h, opts: { bold: true, fill: '2F5496', color: 'FFFFFF', align: 'center', border: 1 } })),
    ];
    rows.forEach(row => {
        table.push(row.map((cell, i) => ({ val: cell, opts: { border: 1 } })));
    });
    return table;
}

// Helper: tạo tiêu đề
function makeHeading(text, size) {
    return { text, options: { bold: true, font_size: size || 16, color: '2F5496' } };
}

// Helper: tạo paragraph
function makePara(text, options = {}) {
    return { text, options: { font_size: 11, ...options } };
}

// ============ BÁO CÁO 1 ============
function createReport1(doc) {
    let p = doc.createP();
    p.addText('BAO CAO 1', { bold: true, font_size: 24, color: '2F5496' });
    
    p = doc.createP();
    p.addText('KHAO SAT TINH THICH UNG PHAN HE MUA HANG CUA NCC VOI NHU CAU QUAN TRI TCVH', { bold: true, font_size: 18, color: '2F5496' });
    
    p = doc.createP();
    p.addText('1.1. Tong quan du an', { bold: true, font_size: 14, color: '2F5496' });

    const infoData = [
        [{ val: 'Khach hang', opts: { bold: true, fill: 'D9E2F3' } }, 'Cong ty CP KCN To hop Cong nghe Thanh Cong Viet Hung (TCVH)'],
        [{ val: 'Nha thau', opts: { bold: true, fill: 'D9E2F3' } }, '3ASOFT'],
        [{ val: 'San pham', opts: { bold: true, fill: 'D9E2F3' } }, 'Arito ERP / Arito Procurement Suite'],
        [{ val: 'Pham vi dot 1', opts: { bold: true, fill: 'D9E2F3' } }, 'Mua noi dia + Nhap khau linh kien (L/C-SBLC, hai quan)'],
        [{ val: 'Ngay chot pham vi', opts: { bold: true, fill: 'D9E2F3' } }, '29/06/2026'],
    ];
    doc.addTable(infoData, { colW: [20, 80] });

    p = doc.createP();
    p.addText('1.2. Diem dau hien tai cua TCVH', { bold: true, font_size: 14, color: '2F5496' });

    const painHeaders = ['Ma Pain', 'Pain Point', 'He qua', 'Ma FR', 'Mo ta ma FR', 'Tinh thich ung'];
    const painRows = [
        ['P1', 'Lap & tong hop KHMS tren Excel, nhieu Ver (00/01/DIFF)', 'Kho kiem soat thay doi, sai so lieu, kho truy vet', 'FR-KH-01', 'Lap KHMS 3 cap (nam → thang → chi tiet); group theo HH/DV, thoi gian, phong ban', '✓'],
        ['P1', '', '', 'FR-KH-02', 'Tu sinh ma KHMS theo cau truc: KHMS/[Phong]/[Nam]/[So]', '✓'],
        ['P1', '', '', 'FR-KH-06', 'Bang tong hop mua sam (nam/thang) + quan ly phien ban Ver/DIFF', '✓'],
        ['P2', 'Phe duyet nhieu cap thu cong', 'Cham tre, khong ro chung tu dang o cap nao', 'FR-RP-02', 'Cau hinh luong phe duyet linh hoat: them/bo cap duyet, thay doi nguoi duyet, thiet lap dieu kien/han muc', '⚠ Phat trien moi'],
        ['P2', '', '', 'FR-RP-03', 'Gui thong bao (notification) tu dong giua cac buoc cho nguoi phu trach', '✓'],
        ['P3', 'Gui/nhan bao gia NCC qua email', 'Mat thoi gian, thieu minh bach, kho so sanh', 'FR-BG-01', 'Giay de nghi bao gia (RFQ) ke thua dong tu YCMS, gui de nghi den nhieu NCC', '✓'],
        ['P3', '', '', 'FR-BG-04', 'Ghi nhan bao gia NCC (dot nay nhap tay); gui mail de nghi bao gia tu phan mem de audit', '✓'],
        ['P3', '', '', 'FR-BG-05', 'Man hinh So sanh bao gia: bo sung cot Bao hanh, Dieu khoan TT, Bao lanh', '✓'],
        ['P4', 'Khong lien ket du lieu giua cac chung tu', 'Nhap lieu lai nhieu lan, sailech', 'Toan bo FR ke thua', 'Tat ca cac buoc sau (YCMS, RFQ, PO, Giao hang) deu ke thua du lieu tu buoc truoc', '✓'],
        ['P5', 'Theo doi hang NK, L/C, hai quan thu cong', 'Kho kiem soat tien do, rui ro thanh toan/giao nhan', 'FR-NK-02', 'Quan ly L/C-SBLC: phat hanh, theo doi, tat toan; ho tro 1 don hang co nhieu L/C', '✓'],
        ['P5', '', '', 'FR-NK-10', 'Phieu di duong + Tab Shipment: Invoice, B/L, container, hang tau, cang di/den, so kien, trong luong, ETD/ETA', '✓'],
        ['P5', '', '', 'FR-NK-12', 'Tat toan SBLC: Mua hang chuan bi HSTT → TCKT thanh toan', '✓'],
        ['P6', 'Thieu bao cao/dashboard tong hop', 'Lanh dao kho ra quyet dinh kip thoi', 'FR-RP-01', 'Dashboard & KPI tien do mua sam: so luong PO/HD, thoi gian duyet trung binh, ty le tuan thu KHMS', '✓'],
    ];

    const painTableData = [painHeaders, ...painRows];
    doc.addTable(painTableData, { colW: [8, 15, 17, 10, 40, 10] });

    p = doc.createP();
    p.addText('1.3. Tong hop danh gia tinh thich ung', { bold: true, font_size: 14, color: '2F5496' });

    const summaryRows = [
        ['✓ Dap ung trong pham vi', '38', '83%'],
        ['✗ Ngoai pham vi / Giai doan sau', '5', '11%'],
        ['⚠ Phat trien moi', '2', '4%'],
        ['✓ Mau in', '1', '2%'],
        [{ val: 'Tong', opts: { bold: true, fill: 'D9E2F3' } }, { val: '46', opts: { bold: true, fill: 'D9E2F3' } }, { val: '100%', opts: { bold: true, fill: 'D9E2F3' } }],
    ];
    doc.addTable(summaryRows, { colW: [60, 20, 20] });
}

// ============ BÁO CÁO 2 ============
function createReport2(doc) {
    let p = doc.createP();
    p.addText('BANG TONG HOP RAI SOAT QUY TRINH HIEN TAI VA DE XUAT PHUONG AN MO RONG', { bold: true, font_size: 18, color: '2F5496' });

    p = doc.createP();
    p.addText('2.1. Quy trinh mua sam noi dia', { bold: true, font_size: 14, color: '2F5496' });

    const flowHeaders = ['Giai doan', 'Ma FR', 'Mo ta ma FR', 'PT moi', 'De xuat mo rong'];
    const flowRows = [
        ['KHMS', 'FR-KH-01', 'Lap KHMS 3 cap (nam → thang → chi tiet); group theo HH/DV, thoi gian, phong ban', '—', 'Bang tong hop nam, sheet chi tiet KH1...KHn'],
        ['', 'FR-KH-02', 'Tu sinh ma KHMS: KHMS/[Phong]/[Nam]/[So]', '—', ''],
        ['', 'FR-KH-03', 'Ke hoach chi tiet dinh kem danh sach vat tu (ma, ten, DVT, SL, thoi gian, don gia, thanh tien, P/B/X)', '—', ''],
        ['', 'FR-KH-04', '4 cap phe duyet: Bo phan chuyen mon → TCKT → Mua hang → Ban Lanh dao', '—', ''],
        ['', 'FR-KH-05', 'Dieu chinh SL/chi tiet: ghi chu & tra trang thai ve cap tuong ung', '—', ''],
        ['', 'FR-KH-06', 'Bang tong hop mua sam (nam/thang) + quan ly phien ban Ver/DIFF', '—', ''],
        ['', 'FR-KH-07', 'Mau in Phieu yeu cau mua sam / Phieu KHMS', '—', ''],
        ['YCMS', 'FR-YC-01', '3 luong YCMS: (2.1) co KH–ke thua, (2.2) co KH–thay doi, (2.3) khong KH', '—', 'Ke thua du lieu tu KHMS, tu dong cap nhat trang thai KHMS'],
        ['', 'FR-YC-02', 'Luong 2.1: ke thua du lieu tu KHMS; tu dong cap nhat trang thai KHMS ve "Dang len YCMS"', '—', ''],
        ['', 'FR-YC-03', 'Luong 2.2: huy duyet KHMS → chinh sua → duyet lai, hoac dieu chinh & duyet theo tung dong', '—', ''],
        ['', 'FR-YC-04', "Tab 'Nha cung cap de xuat': tu hien thi cac ma NCC da tung mua mat hang", '—', ''],
        ['', 'FR-YC-05', 'Gui mail tu dong cho khach hang/NCC tu man hinh YCMS', '—', ''],
        ['RFQ', 'FR-BG-01', 'Giay de nghi bao gia: ke thua dong tu YCMS, gui de nghi den nhieu NCC', '—', 'Vendor Portal → GD2; hien tai nhap tay'],
        ['', 'FR-BG-04', 'Ghi nhan bao gia NCC (dot nay nhap tay); gui mail de nghi bao gia tu phan mem', '—', ''],
        ['', 'FR-BG-05', 'Man hinh So sanh bao gia: bo sung cot Bao hanh (thang), Dieu khoan TT, Bao lanh', '—', ''],
        ['', 'FR-BG-06', "Tab 'Thong tin bao lanh': loai, gia tri, thoi han, ngan hang phat hanh", '—', ''],
        ['', 'FR-BG-07', 'Bo sung dieu khoan giao hang & dieu kien bao hanh o buoc bao gia/so sanh', '—', ''],
        ['', 'FR-BG-02', 'Vendor Portal: gui mail kem link + user + mat khau', '✗', 'Giai doan 2'],
        ['', 'FR-BG-03', 'NCC tu cap nhat trang thai tung dong qua Vendor Portal', '✗', 'Giai doan 2'],
        ['PO/HD', 'FR-PO-01', "Tich chon 'NCC co hop dong nguyen tac': Co → soan PO; Khong → soan HD mua sam", '—', ''],
        ['', 'FR-PO-02', 'Don mua hang noi dia, ke thua du lieu tu buoc truoc', '—', ''],
        ['', 'FR-PO-03', 'Phe duyet PO/HD: Bo phan chuyen mon → Ke toan → Lanh dao; tich chon bo phan chuyen mon', '—', ''],
        ['', 'FR-PO-04', 'Lenh nhap hang ke thua tu PO', '—', ''],
        ['', 'FR-PO-05', 'Man hinh moi: Chung tu Thong bao hang ve — thiet ke rieng theo mau TCVH', '⚠ Phat trien moi', 'Thiet ke theo mau TCVH'],
        ['Giao hang', 'FR-GH-01', 'Thong bao giao hang: ke thua tu PO, 1 PO giao nhieu lan; gui notification cho user nhan', '—', 'Tich hop notification'],
        ['', 'FR-GH-02', 'Phieu nhap kho ke thua tu Lenh nhap hang', '—', ''],
        ['', 'FR-GH-03', 'Phieu nghiem thu (dich vu); nghiem thu theo tung HH/DV', '—', ''],
        ['', 'FR-GH-04', 'Phieu nhap vat tu/thiet bi vao cong truong (mau noi bo song ngu VI-EN)', '—', 'Mau Phieu nhap vat tu/thiet bi vao cong truong'],
        ['Hoa don - TT', 'FR-HD-01', 'Hoa don mua hang noi dia, lien ket voi PO/HD va Phieu nhap kho', '—', 'Tich hop ke toan cong no'],
        ['', 'FR-HD-03', 'Quan ly cong no phai tra & yeu cau thanh toan', '—', ''],
    ];

    doc.addTable([flowHeaders, ...flowRows], { colW: [10, 10, 45, 10, 25] });

    p = doc.createP();
    p.addText('2.2. Quy trinh nhap khau linh kien (6 giai doan)', { bold: true, font_size: 14, color: '2F5496' });

    const nkHeaders = ['Giai doan', 'Ma FR', 'Mo ta ma FR', 'PT moi', 'De xuat mo rong'];
    const nkRows = [
        ['Ke hoach NK', 'FR-NK-07', 'Ke hoach linh kien NK theo KHSX nam: VT&KHSX lap → TCKT ra soat → Lanh dao duyet (lien ket KHMS)', '—', 'NADIN tich hop → GD2'],
        ['', 'FR-MD-01', 'Danh muc VTHH mo rong: so ngay hang ve, MOQ, leadtime', '—', ''],
        ['Don hang & BOM', 'FR-NK-08', 'Dat hang & xac nhan BOM: dat theo xe (NADIN→dot sau nhap tay); tiep nhan BOM tu SKODA; xac nhan SL theo ma linh kien', '—', 'Phat trien moi: quan ly BOM theo xe'],
        ['', 'FR-NK-09', 'Ky HD: Mua hang soat xet & ky; TCKT + PC&KSTT phoi hop; Lanh dao duyet', '—', ''],
        ['', 'FR-NK-01', 'Don hang NK + duyet; Hoa don NK', '—', ''],
        ['Phat hanh SBLC', 'FR-NK-02', 'Quan ly L/C-SBLC: Mua hang de nghi → TCKT phat hanh → thong bao; ho tro 1 don hang co nhieu L/C', '—', 'Quan ly L/C-SBLC day du'],
        ['Phieu di duong', 'FR-NK-10', 'Phieu di duong + Tab Shipment: Invoice, B/L, container, hang tau, cang di/den, so kien, trong luong, ETD, ETA, ngay di thuc te, ngay den thuc te', '—', 'Tab Shipment day du - phat trien moi'],
        ['', 'FR-NK-11', 'Thanh toan van chuyen: Mua hang de nghi TT chi phi cang & de nghi TT thue NK → TCKT thuc hien (2 nhanh)', '—', '3 nhom thanh toan: cang, thue NK, SBLC'],
        ['Tiep nhan hang', 'FR-NK-04', 'Anh xa chung tu NK: (a) GD④ Phieu di duong, (b) GD⑤ Phieu ngoai quan (KNQ), (c) GD⑤ Phieu thong quan (TCMS)', '—', '2 luong xu ly'],
        ['', 'FR-NK-03', 'Xu ly thua/thieu: lap HD & don hang moi theo SL nhan thuc te, thay don goc', '—', ''],
        ['', 'FR-NK-06', 'Tiep nhan hang 2 luong: (a) KNQ → Phieu ngoai quan; (b) thong quan → kho TCMS → Phieu thong quan (= Phieu nhap kho TCMS)', '—', 'Khong co Phieu nhap mua rieng'],
        ['Thanh toan', 'FR-NK-12', 'Tat toan SBLC: Mua hang chuan bi HSTT → TCKT thanh toan', '—', ''],
    ];

    doc.addTable([nkHeaders, ...nkRows], { colW: [15, 10, 40, 10, 25] });

    p = doc.createP();
    p.addText('2.3. Cac yeu cau mo rong Giai doan 2', { bold: true, font_size: 14, color: '2F5496' });

    const wHeaders = ['Ma', 'Ten phuong an', 'Mo ta chi tiet', 'Uu tien', 'Phu thuoc'];
    const wRows = [
        ['W-01', 'Vendor Portal', 'Cong thong tin danh cho Nha cung cap: cho phep NCC dang nhap xem YCMS/RFQ, tu cap nhat bao gia, cap nhat trang thai tuyen dung tung dong hang, theo doi trang thai don hang. Deploy self-host on-premise', 'Should', 'Self-host on-premise'],
        ['W-02', 'Tich hop NADIN', 'Ket noi API voi he thong NADIN cua SKODA: tu dong dat hang theo xe, tiep nhan BOM tu dong, cap nhat trang thai don hang. Dot 1 xu ly nhap tay', 'Should', 'API NADIN'],
        ['W-03', 'Khai bao hai quan ECUS-VNACCS', 'Tich hop cong hai quan Viet Nam ECUS-VNACCS/VCIS: tu dong khai bao hai quan, tiep nhan ket qua thong quan, cap nhat trang thai lo hang', 'Should', 'Cong hai quan VN'],
        ['W-04', 'Tra cuu thue GDT', 'Tich hop API Tong cuc Thue (GDT): tra cuu hoa don dien tu, xac minh hoa don dau vao, doi chieu du lieu tu dong', 'Could', 'API GDT'],
        ['W-05', 'Hoa don IPA + eBanking', '(1) Hoa don dien tu dau vao (IPA): nhan va xu ly hoa don dien tu tu NCC. (2) eBanking: thanh toan dien tu truc tiep tu ERP qua ket noi ngan hang', 'Could', 'API Thue, API Ngan hang'],
    ];

    doc.addTable([wHeaders, ...wRows], { colW: [8, 15, 47, 10, 20] });
}

// ============ BÁO CÁO 3 ============
function createReport3(doc) {
    let p = doc.createP();
    p.addText('KHAO SAT VA XAC NHAN YEU CAU PHAN HE MUA HANG NHA THAU', { bold: true, font_size: 18, color: '2F5496' });

    p = doc.createP();
    p.addText('A. Master Data (Danh muc/Master)', { bold: true, font_size: 14, color: '2F5496' });

    const mdHeaders = ['Ma', 'Ten yeu cau', 'Mo ta chi tiet', 'Uu tien', 'Nguon'];
    const mdRows = [
        ['FR-MD-01', 'Danh muc VTHH mo rong', 'Bo sung cac truong: (1) So ngay hang ve (leadtime), (2) Muc dich su dung, (3) Phan loai muc dich (van hanh/SXKD), (4) Ma tham chieu noi bo, (5) MOQ, (6) Danh muc nho, (7) Leadtime', 'M', 'KS 18/06'],
        ['FR-MD-02', 'Nhom HH/DV 2 cap + quy dinh thoi gian', 'Xay dung cay phan loai 2 cap: Phan loai Muc dich → Danh muc lon → Danh muc nho. Moi danh muc lon gan quy dinh: thoi gian hoan thanh KH nam, leadtime thong thuong, leadtime dac biet', 'S', 'Form KHMS'],
        ['FR-MD-03', 'Quy doi don vi tinh (UOM Conversion)', 'Cho phep chuyen doi giua cac don vi tinh cua cung mot hang hoa (VD: cai → loc → thung) voi he so quy doi', 'S', 'Deck Arito'],
    ];
    doc.addTable([mdHeaders, ...mdRows], { colW: [10, 20, 45, 10, 15] });

    p = doc.createP();
    p.addText('B. Ke hoach mua sam (KHMS)', { bold: true, font_size: 14, color: '2F5496' });

    const khHeaders = ['Ma', 'Ten yeu cau', 'Mo ta chi tiet', 'Uu tien', 'Nguon'];
    const khRows = [
        ['FR-KH-01', 'Lap KHMS 3 cap', 'He thong ho tro lap ke hoach 3 tang: (1) Ke hoach nam → (2) Ke hoach thang → (3) Ke hoach chi tiet. Cho phep group theo nhom HH/DV, theo thoi gian, theo phong ban', 'M', 'KS 24/06'],
        ['FR-KH-02', 'Tu sinh ma KHMS', 'Tu dong sinh ma KHMS theo cau truc: KHMS/[Phong]/[Nam]/[So] — VD: KHMS/VT&KHSX/2026/KH07', 'M', 'KS 24/06'],
        ['FR-KH-03', 'Ke hoach chi tiet dinh kem vat tu', 'Moi KHMS chi tiet cho phep dinh kem danh sach vat tu voi cac cot: Ma HH/DV, Ten, DVT, So luong, Thoi gian can hang, Thoi gian thanh toan, Don gia, Thanh tien, Phong/Ban/Xuong, Ghi chu', 'M', 'Form KHMS'],
        ['FR-KH-04', '4 cap phe duyet KHMS', 'Luong phe duyet: (1) Bo phan chuyen mon ra soat → (2) TCKT ra soat ton kho/chi phi → (3) Phong Mua hang ra soat → (4) Ban Lanh dao phe duyet. Tich chon bo phan chuyen mon neu can', 'M', 'KS 24/06'],
        ['FR-KH-05', 'Dieu chinh SL/chi tiet hang hoa', 'Cho phep dieu chinh so luong hoac chi tiet hang hoa ngay tren dong ke hoach, dong thoi ghi chu ly do thay doi va tra trang thai chung tu ve cap phe duyet tuong ung de duyet lai', 'M', 'KS 18/06, 24/06'],
        ['FR-KH-06', 'Bang tong hop + quan ly phien ban', 'Tao bang tong hop mua sam theo nam/thang de Ban Lanh dao duyet theo hang muc. Quan ly nhieu phien ban (Ver00, Ver01…) voi cot DIFF tu tinh chenh lech giua cac phien ban', 'M', 'KS 18/06, Form'],
        ['FR-KH-07', 'Mau in Phieu yeu cau mua sam', 'Thiet ke mau in Phieu yeu cau mua sam / Phieu KHMS theo dinh dang cua TCVH', 'S', 'KS 24/06'],
    ];
    doc.addTable([khHeaders, ...khRows], { colW: [10, 20, 45, 10, 15] });

    p = doc.createP();
    p.addText('C. Yeu cau mua sam (YCMS)', { bold: true, font_size: 14, color: '2F5496' });

    const ycHeaders = ['Ma', 'Ten yeu cau', 'Mo ta chi tiet', 'Uu tien', 'Nguon'];
    const ycRows = [
        ['FR-YC-01', '3 luong YCMS', 'He thong ho tro 3 luong: (2.1) Co ke hoach — lien ket KHMS chi tiet da duyet & ke thua du lieu; (2.2) Co ke hoach nhung thay doi (thoi gian/SL) — dieu chinh va duyet lai; (2.3) Khong co ke hoach — lap truc tiep YCMS ma khong can KHMS', 'M', 'KS 24/06'],
        ['FR-YC-02', 'Ke thua tu KHMS (luong 2.1)', 'Khi tao YCMS tu KHMS, he thong tu dong ke thua du lieu (ma vat tu, SL, thoi gian, DVT…). Dong thoi tu dong cap nhat trang thai dong KHMS chi tiet ve "Dang len YCMS"', 'M', 'KS 24/06'],
        ['FR-YC-03', 'Dieu chinh ke hoach (luong 2.2)', 'Khi YCMS can thay doi so voi KHMS (thay doi SL hoac thoi gian), cho phep: (a) huy duyet KHMS → chinh sua → duyet lai, hoac (b) dieu chinh tren YCMS va theo doi duyet theo tung dong', 'M', 'KS 24/06'],
        ['FR-YC-04', 'Tab NCC de xuat', 'Tab hien thi danh sach cac Nha cung cap de xuat. Tu dong hien thi cac ma NCC da tung duoc mua hang cung loai vat tu de nguoi dung tham khao khi lap YCMS', 'S', 'KS 18/06'],
        ['FR-YC-05', 'Gui mail tu dong', 'Cho phep gui email thong bao tu dong cho khach hang hoac NCC ngay tu man hinh YCMS (VD: thong bao YCMS moi duoc tao, duyet, tu choi…)', 'S', 'KS 18/06'],
    ];
    doc.addTable([ycHeaders, ...ycRows], { colW: [10, 18, 47, 10, 15] });

    p = doc.createP();
    p.addText('3.2. Tong hop yeu cau theo MoSCoW', { bold: true, font_size: 14, color: '2F5496' });

    const summaryRows = [
        ['M – Must', 'Bat buoc phai co', '27', '64%'],
        ['S – Should', 'Nen co', '9', '21%'],
        ['C – Could', 'Co the co', '1', '2%'],
        ['W – Won\'t (dot nay)', 'Giai doan 2', '2', '5%'],
        ['N/A', 'Ngoai pham vi', '1', '2%'],
        [{ val: 'Tong', opts: { bold: true, fill: 'D9E2F3' } }, { val: '', opts: { bold: true, fill: 'D9E2F3' } }, { val: '42', opts: { bold: true, fill: 'D9E2F3' } }, { val: '100%', opts: { bold: true, fill: 'D9E2F3' } }],
    ];
    doc.addTable(summaryRows, { colW: [30, 30, 20, 20] });
}

// ============ MAIN ============
async function main() {
    // Tạo Report 1
    const doc1 = officegen('docx');
    createReport1(doc1);
    const buf1 = await doc1.generate();
    fs.writeFileSync(OUTPUT_DIR + '\\BaoCao1_KhaoSatTinhThichUng.docx', buf1);
    console.log('Report 1 created: BaoCao1_KhaoSatTinhThichUng.docx');

    // Tạo Report 2
    const doc2 = officegen('docx');
    createReport2(doc2);
    const buf2 = await doc2.generate();
    fs.writeFileSync(OUTPUT_DIR + '\\BaoCao2_RaiSoatQuyTrinh_DeXuatMoRong.docx', buf2);
    console.log('Report 2 created: BaoCao2_RaiSoatQuyTrinh_DeXuatMoRong.docx');

    // Tạo Report 3
    const doc3 = officegen('docx');
    createReport3(doc3);
    const buf3 = await doc3.generate();
    fs.writeFileSync(OUTPUT_DIR + '\\BaoCao3_KhaoSatXacNhanYeuCau.docx', buf3);
    console.log('Report 3 created: BaoCao3_KhaoSatXacNhanYeuCau.docx');

    console.log('\nAll 3 reports created successfully!');
    console.log('Location: ' + OUTPUT_DIR);
}

main().catch(console.error);
