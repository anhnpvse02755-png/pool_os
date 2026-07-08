const officegen = require('officegen');
const fs = require('fs');

const OUTPUT_DIR = 'c:\\Users\\anhnpv\\OneDrive - Thanh Cong Group\\Desktop\\code';

// Helper: tạo table style
function makeTableStyle() {
    return {
        tableColWidth: 9000,
        tableSize: 20,
        tableAlign: 'left',
        borders: true,
        borderSize: 4,
    };
}

// Helper: tạo header cell
function makeHeaderCell(text) {
    return {
        val: text,
        opts: {
            bold: true,
            color: 'FFFFFF',
            fill: '2F5496',
            align: 'center',
            valign: 'center',
            sz: 18,
        }
    };
}

// Helper: tạo cell thường
function makeCell(text, options = {}) {
    return {
        val: text || '',
        opts: {
            fill: options.fill || 'FFFFFF',
            align: options.align || 'left',
            valign: 'center',
            sz: 18,
            ...options,
        }
    };
}

// ============ BÁO CÁO 1 ============
function createReport1(docx) {
    // Tiêu đề chính
    let p = docx.createP({ align: 'center' });
    p.addText('BÁO CÁO 1', { bold: true, font_size: 28, color: '2F5496' });
    
    p = docx.createP({ align: 'center' });
    p.addText('KHẢO SÁT TÍNH THÍCH ỨNG PHÂN HỆ MUA HÀNG CỦA NCC VỚI NHU CẦU QUẢN TRỊ TCVH', { bold: true, font_size: 16, color: '2F5496' });

    p = docx.createP();
    p.addText('1.1. Tổng quan dự án', { bold: true, font_size: 14, color: '2F5496' });

    const infoData = [
        [
            makeHeaderCell('Trường'),
            makeHeaderCell('Nội dung'),
        ],
        [
            makeCell('Khách hàng', { fill: 'D9E2F3', bold: true }),
            makeCell('Công ty CP KCN Tổ hợp Công nghệ Thanh Cong Việt Hưng (TCVH)'),
        ],
        [
            makeCell('Nhà thầu', { fill: 'D9E2F3', bold: true }),
            makeCell('3ASOFT'),
        ],
        [
            makeCell('Sản phẩm', { fill: 'D9E2F3', bold: true }),
            makeCell('Arito ERP / Arito Procurement Suite'),
        ],
        [
            makeCell('Phạm vi đợt 1', { fill: 'D9E2F3', bold: true }),
            makeCell('Mua nội địa + Nhập khẩu linh kiện (L/C-SBLC, hải quan)'),
        ],
        [
            makeCell('Ngày chốt phạm vi', { fill: 'D9E2F3', bold: true }),
            makeCell('29/06/2026'),
        ],
    ];
    docx.createTable(infoData, { tableColWidth: 3000, tableSize: 20, borders: true, borderSize: 4 });

    p = docx.createP();
    p.addText('1.2. Điểm đau hiện tại của TCVH', { bold: true, font_size: 14, color: '2F5496' });

    const painHeaders = ['Mã Pain', 'Pain Point', 'Hệ quả', 'Mã FR', 'Mô tả mã FR', 'Tính thích ứng'];
    const painRows = [
        ['P1', 'Lập & tổng hợp KHMS trên Excel, nhiều Ver (00/01/DIFF)', 'Khó kiểm soát thay đổi, sai số liệu, khó truy vết', 'FR-KH-01', 'Lập KHMS 3 cấp (năm → tháng → chi tiết); group theo HH/DV, thời gian, phòng ban', '✓'],
        ['P1', '', '', 'FR-KH-02', 'Tự sinh mã KHMS theo cấu trúc: KHMS/[Phòng]/[Năm]/[Số]', '✓'],
        ['P1', '', '', 'FR-KH-06', 'Bảng tổng hợp mua sắm (năm/tháng) + quản lý phiên bản Ver/DIFF', '✓'],
        ['P2', 'Phê duyệt nhiều cấp thủ công', 'Chậm trễ, không rõ chứng từ đang ở cấp nào', 'FR-RP-02', 'Cấu hình luồng phê duyệt linh hoạt: thêm/bỏ cấp duyệt, thay đổi người duyệt, thiết lập điều kiện/hạn mức', '⚠ Phát triển mới'],
        ['P2', '', '', 'FR-RP-03', 'Gửi thông báo (notification) tự động giữa các bước cho người phụ trách', '✓'],
        ['P3', 'Gửi/nhận báo giá NCC qua email', 'Mất thời gian, thiếu minh bạch, khó so sánh', 'FR-BG-01', 'Giấy đề nghị báo giá (RFQ) kế thừa đòng từ YCMS, gửi đề nghị đến nhiều NCC', '✓'],
        ['P3', '', '', 'FR-BG-04', 'Ghi nhận báo giá NCC (đợt này nhập tay); gửi mail đề nghị báo giá từ phần mềm để audit', '✓'],
        ['P3', '', '', 'FR-BG-05', 'Màn hình So sánh báo giá: bổ sung cột Bảo hành, Điều khoản TT, Bảo lãnh', '✓'],
        ['P4', 'Không liên kết dữ liệu giữa các chứng từ', 'Nhập liệu lại nhiều lần, sai lệch', 'Toàn bộ FR kế thừa', 'Tất cả các bước sau (YCMS, RFQ, PO, Giao hàng) đều kế thừa dữ liệu từ bước trước', '✓'],
        ['P5', 'Theo dõi hàng NK, L/C, hải quan thủ công', 'Khó kiểm soát tiến độ, rủi ro thanh toán/giao nhận', 'FR-NK-02', 'Quản lý L/C-SBLC: phát hành, theo dõi, tất toán; hỗ trợ 1 đơn hàng có nhiều L/C', '✓'],
        ['P5', '', '', 'FR-NK-10', 'Phiếu đi đường + Tab Shipment: Invoice, B/L, container, hãng tàu, cảng đi/đến, số kiện, trọng lượng, ETD/ETA', '✓'],
        ['P5', '', '', 'FR-NK-12', 'Tất toán SBLC: Mua hàng chuẩn bị HSTT → TCKT thanh toán', '✓'],
        ['P6', 'Thiếu báo cáo/dashboard tổng hợp', 'Lãnh đạo khó ra quyết định kịp thời', 'FR-RP-01', 'Dashboard & KPI tiến độ mua sắm: số lượng PO/HD, thời gian duyệt trung bình, tỷ lệ tuân thủ KHMS', '✓'],
    ];

    const painTableData = [
        painHeaders.map(h => makeHeaderCell(h)),
        ...painRows.map(row => row.map(cell => makeCell(cell))),
    ];
    docx.createTable(painTableData, { tableColWidth: 2000, tableSize: 18, borders: true, borderSize: 4 });

    p = docx.createP();
    p.addText('1.3. Tổng hợp đánh giá tính thích ứng', { bold: true, font_size: 14, color: '2F5496' });

    const summaryRows = [
        [makeHeaderCell('Trạng thái'), makeHeaderCell('Số lượng'), makeHeaderCell('Tỷ lệ')],
        [makeCell('✓ Đáp ứng trong phạm vi'), makeCell('38'), makeCell('83%')],
        [makeCell('✗ Ngoài phạm vi / Giai đoạn sau'), makeCell('5'), makeCell('11%')],
        [makeCell('⚠ Phát triển mới'), makeCell('2'), makeCell('4%')],
        [makeCell('✓ Mẫu in'), makeCell('1'), makeCell('2%')],
        [makeCell('Tổng', { fill: 'D9E2F3', bold: true }), makeCell('46', { fill: 'D9E2F3', bold: true }), makeCell('100%', { fill: 'D9E2F3', bold: true })],
    ];
    docx.createTable(summaryRows, { tableColWidth: 5000, tableSize: 20, borders: true, borderSize: 4 });
}

// ============ BÁO CÁO 2 ============
function createReport2(docx) {
    let p = docx.createP({ align: 'center' });
    p.addText('BÁO CÁO 2', { bold: true, font_size: 28, color: '2F5496' });

    p = docx.createP({ align: 'center' });
    p.addText('BẢNG TỔNG HỢP RÀ SOÁT QUY TRÌNH HIỆN TẠI VÀ ĐỀ XUẤT PHƯƠNG ÁN MỞ RỘNG', { bold: true, font_size: 14, color: '2F5496' });

    p = docx.createP();
    p.addText('2.1. Quy trình mua sắm nội địa', { bold: true, font_size: 14, color: '2F5496' });

    const flowHeaders = ['Giai đoạn', 'Mã FR', 'Mô tả mã FR', 'PT mới', 'Đề xuất mở rộng'];
    const flowRows = [
        ['KHMS', 'FR-KH-01', 'Lập KHMS 3 cấp (năm → tháng → chi tiết); group theo HH/DV, thời gian, phòng ban', '—', 'Bảng tổng hợp năm, sheet chi tiết KH1...KHn'],
        ['', 'FR-KH-02', 'Tự sinh mã KHMS: KHMS/[Phòng]/[Năm]/[Số]', '—', ''],
        ['', 'FR-KH-03', 'Kế hoạch chi tiết đính kèm danh sách vật tư (mã, tên, DVT, SL, thời gian, đơn giá, thành tiền, P/B/X)', '—', ''],
        ['', 'FR-KH-04', '4 cấp phê duyệt: Bộ phận chuyên môn → TCKT → Mua hàng → Ban Lãnh đạo', '—', ''],
        ['', 'FR-KH-05', 'Điều chỉnh SL/chi tiết: ghi chú & trả trạng thái về cấp tương ứng', '—', ''],
        ['', 'FR-KH-06', 'Bảng tổng hợp mua sắm (năm/tháng) + quản lý phiên bản Ver/DIFF', '—', ''],
        ['', 'FR-KH-07', 'Mẫu in Phiếu yêu cầu mua sắm / Phiếu KHMS', '—', ''],
        ['YCMS', 'FR-YC-01', '3 luồng YCMS: (2.1) có KH–kế thừa, (2.2) có KH–thay đổi, (2.3) không KH', '—', 'Kế thừa dữ liệu từ KHMS, tự động cập nhật trạng thái KHMS'],
        ['', 'FR-YC-02', 'Luồng 2.1: kế thừa dữ liệu từ KHMS; tự động cập nhật trạng thái KHMS về "Đang lên YCMS"', '—', ''],
        ['', 'FR-YC-03', 'Luồng 2.2: hủy duyệt KHMS → chỉnh sửa → duyệt lại, hoặc điều chỉnh & duyệt theo từng dòng', '—', ''],
        ['', 'FR-YC-04', "Tab 'Nhà cung cấp đề xuất': tự hiển thị các mã NCC đã từng mua mặt hàng", '—', ''],
        ['', 'FR-YC-05', 'Gửi mail tự động cho khách hàng/NCC từ màn hình YCMS', '—', ''],
        ['RFQ', 'FR-BG-01', 'Giấy đề nghị báo giá: kế thừa dòng từ YCMS, gửi đề nghị đến nhiều NCC', '—', 'Vendor Portal → GD2; hiện tại nhập tay'],
        ['', 'FR-BG-04', 'Ghi nhận báo giá NCC (đợt này nhập tay); gửi mail đề nghị báo giá từ phần mềm', '—', ''],
        ['', 'FR-BG-05', 'Màn hình So sánh báo giá: bổ sung cột Bảo hành (tháng), Điều khoản TT, Bảo lãnh', '—', ''],
        ['', 'FR-BG-06', "Tab 'Thông tin bảo lãnh': loại, giá trị, thời hạn, ngân hàng phát hành", '—', ''],
        ['', 'FR-BG-07', 'Bổ sung điều khoản giao hàng & điều kiện bảo hành ở bước báo giá/so sánh', '—', ''],
        ['', 'FR-BG-02', 'Vendor Portal: gửi mail kèm link + user + mật khẩu', '✗', 'Giai đoạn 2'],
        ['', 'FR-BG-03', 'NCC tự cập nhật trạng thái từng dòng qua Vendor Portal', '✗', 'Giai đoạn 2'],
        ['PO/HD', 'FR-PO-01', "Chọn 'NCC có hợp đồng nguyên tắc': Có → soạn PO; Không → soạn HD mua sắm", '—', ''],
        ['', 'FR-PO-02', 'Đơn mua hàng nội địa, kế thừa dữ liệu từ bước trước', '—', ''],
        ['', 'FR-PO-03', 'Phê duyệt PO/HD: Bộ phận chuyên môn → Kế toán → Lãnh đạo; chọn bộ phận chuyên môn', '—', ''],
        ['', 'FR-PO-04', 'Lệnh nhập hàng kế thừa từ PO', '—', ''],
        ['', 'FR-PO-05', 'Màn hình mới: Chứng từ Thông báo hàng về — thiết kế riêng theo mẫu TCVH', '⚠ Phát triển mới', 'Thiết kế theo mẫu TCVH'],
        ['Giao hàng', 'FR-GH-01', 'Thông báo giao hàng: kế thừa từ PO, 1 PO giao nhiều lần; gửi notification cho user nhận', '—', 'Tích hợp notification'],
        ['', 'FR-GH-02', 'Phiếu nhập kho kế thừa từ Lệnh nhập hàng', '—', ''],
        ['', 'FR-GH-03', 'Phiếu nghiệm thu (dịch vụ); nghiệm thu theo từng HH/DV', '—', ''],
        ['', 'FR-GH-04', 'Phiếu nhập vật tư/thiết bị vào công trường (mẫu nội bộ song ngữ VI-EN)', '—', 'Mẫu Phiếu nhập vật tư/thiết bị vào công trường'],
        ['Hóa đơn - TT', 'FR-HD-01', 'Hóa đơn mua hàng nội địa, liên kết với PO/HD và Phiếu nhập kho', '—', 'Tích hợp kế toán công nợ'],
        ['', 'FR-HD-03', 'Quản lý công nợ phải trả & yêu cầu thanh toán', '—', ''],
    ];

    const flowTableData = [
        flowHeaders.map(h => makeHeaderCell(h)),
        ...flowRows.map(row => row.map(cell => makeCell(cell))),
    ];
    docx.createTable(flowTableData, { tableColWidth: 2000, tableSize: 16, borders: true, borderSize: 4 });

    p = docx.createP();
    p.addText('2.2. Quy trình nhập khẩu linh kiện (6 giai đoạn)', { bold: true, font_size: 14, color: '2F5496' });

    const nkHeaders = ['Giai đoạn', 'Mã FR', 'Mô tả mã FR', 'PT mới', 'Đề xuất mở rộng'];
    const nkRows = [
        ['Kế hoạch NK', 'FR-NK-07', 'Kế hoạch linh kiện NK theo KHSX năm: VT&KHSX lập → TCKT rà soát → Lãnh đạo duyệt (liên kết KHMS)', '—', 'NADIN tích hợp → GD2'],
        ['', 'FR-MD-01', 'Danh mục VTHH mở rộng: số ngày hàng về, MOQ, leadtime', '—', ''],
        ['Đơn hàng & BOM', 'FR-NK-08', 'Đặt hàng & xác nhận BOM: đặt theo xe (NADIN→đợt sau nhập tay); tiếp nhận BOM từ SKODA; xác nhận SL theo mã linh kiện', '—', 'Phát triển mới: quản lý BOM theo xe'],
        ['', 'FR-NK-09', 'Ký HD: Mua hàng soát xét & ký; TCKT + PC&KSTT phối hợp; Lãnh đạo duyệt', '—', ''],
        ['', 'FR-NK-01', 'Đơn hàng NK + duyệt; Hóa đơn NK', '—', ''],
        ['Phát hành SBLC', 'FR-NK-02', 'Quản lý L/C-SBLC: Mua hàng đề nghị → TCKT phát hành → thông báo; hỗ trợ 1 đơn hàng có nhiều L/C', '—', 'Quản lý L/C-SBLC đầy đủ'],
        ['Phiếu đi đường', 'FR-NK-10', 'Phiếu đi đường + Tab Shipment: Invoice, B/L, container, hãng tàu, cảng đi/đến, số kiện, trọng lượng, ETD, ETA, ngày đi thực tế, ngày đến thực tế', '—', 'Tab Shipment đầy đủ - phát triển mới'],
        ['', 'FR-NK-11', 'Thanh toán vận chuyển: Mua hàng đề nghị TT chi phí cảng & đề nghị TT thuế NK → TCKT thực hiện (2 nhánh)', '—', '3 nhóm thanh toán: cảng, thuế NK, SBLC'],
        ['Tiếp nhận hàng', 'FR-NK-04', 'Ánh xạ chứng từ NK: (a) GD④ Phiếu đi đường, (b) GD⑤ Phiếu ngoại quan (KNQ), (c) GD⑤ Phiếu thông quan (TCMS)', '—', '2 luồng xử lý'],
        ['', 'FR-NK-03', 'Xử lý thừa/thiếu: lập HD & đơn hàng mới theo SL nhận thực tế, thay đơn gốc', '—', ''],
        ['', 'FR-NK-06', 'Tiếp nhận hàng 2 luồng: (a) KNQ → Phiếu ngoại quan; (b) thông quan → kho TCMS → Phiếu thông quan (= Phiếu nhập kho TCMS)', '—', 'Không có Phiếu nhập mua riêng'],
        ['Thanh toán', 'FR-NK-12', 'Tất toán SBLC: Mua hàng chuẩn bị HSTT → TCKT thanh toán', '—', ''],
    ];

    const nkTableData = [
        nkHeaders.map(h => makeHeaderCell(h)),
        ...nkRows.map(row => row.map(cell => makeCell(cell))),
    ];
    docx.createTable(nkTableData, { tableColWidth: 2000, tableSize: 16, borders: true, borderSize: 4 });

    p = docx.createP();
    p.addText('2.3. Các yêu cầu mở rộng Giai đoạn 2', { bold: true, font_size: 14, color: '2F5496' });

    const wHeaders = ['Mã', 'Tên phương án', 'Mô tả chi tiết', 'Ưu tiên', 'Phụ thuộc'];
    const wRows = [
        ['W-01', 'Vendor Portal', 'Cổng thông tin dành cho Nhà cung cấp: cho phép NCC đăng nhập xem YCMS/RFQ, tự cập nhật báo giá, cập nhật trạng thái tuyển dụng từng dòng hàng, theo dõi trạng thái đơn hàng. Deploy self-host on-premise', 'Should', 'Self-host on-premise'],
        ['W-02', 'Tích hợp NADIN', 'Kết nối API với hệ thống NADIN của SKODA: tự động đặt hàng theo xe, tiếp nhận BOM tự động, cập nhật trạng thái đơn hàng. Đợt 1 xử lý nhập tay', 'Should', 'API NADIN'],
        ['W-03', 'Khai báo hải quan ECUS-VNACCS', 'Tích hợp cổng hải quan Việt Nam ECUS-VNACCS/VCIS: tự động khai báo hải quan, tiếp nhận kết quả thông quan, cập nhật trạng thái lô hàng', 'Should', 'Cổng hải quan VN'],
        ['W-04', 'Tra cứu thuế GDT', 'Tích hợp API Tổng cục Thuế (GDT): tra cứu hóa đơn điện tử, xác minh hóa đơn đầu vào, đối chiếu dữ liệu tự động', 'Could', 'API GDT'],
        ['W-05', 'Hóa đơn IPA + eBanking', '(1) Hóa đơn điện tử đầu vào (IPA): nhận và xử lý hóa đơn điện tử từ NCC. (2) eBanking: thanh toán điện tử trực tiếp từ ERP qua kết nối ngân hàng', 'Could', 'API Thuế, API Ngân hàng'],
    ];

    const wTableData = [
        wHeaders.map(h => makeHeaderCell(h)),
        ...wRows.map(row => row.map(cell => makeCell(cell))),
    ];
    docx.createTable(wTableData, { tableColWidth: 2000, tableSize: 16, borders: true, borderSize: 4 });
}

// ============ BÁO CÁO 3 ============
function createReport3(docx) {
    let p = docx.createP({ align: 'center' });
    p.addText('BÁO CÁO 3', { bold: true, font_size: 28, color: '2F5496' });

    p = docx.createP({ align: 'center' });
    p.addText('KHẢO SÁT VÀ XÁC NHẬN YÊU CẦU PHÂN HỆ MUA HÀNG NHÀ THẦU', { bold: true, font_size: 14, color: '2F5496' });

    p = docx.createP();
    p.addText('A. Master Data (Danh mục/Master)', { bold: true, font_size: 14, color: '2F5496' });

    const mdHeaders = ['Mã', 'Tên yêu cầu', 'Mô tả chi tiết', 'Ưu tiên', 'Nguồn'];
    const mdRows = [
        ['FR-MD-01', 'Danh mục VTHH mở rộng', 'Bổ sung các trường: (1) Số ngày hàng về (leadtime), (2) Mục đích sử dụng, (3) Phân loại mục đích (vận hành/SXKD), (4) Mã tham chiếu nội bộ, (5) MOQ, (6) Danh mục nhỏ, (7) Leadtime', 'M', 'KS 18/06'],
        ['FR-MD-02', 'Nhóm HH/DV 2 cấp + quy định thời gian', 'Xây dựng cây phân loại 2 cấp: Phân loại Mục đích → Danh mục lớn → Danh mục nhỏ. Mỗi danh mục lớn gắn quy định: thời gian hoàn thành KH năm, leadtime thông thường, leadtime đặc biệt', 'S', 'Form KHMS'],
        ['FR-MD-03', 'Quy đổi đơn vị tính (UOM Conversion)', 'Cho phép chuyển đổi giữa các đơn vị tính của cùng một hàng hóa (VD: cái → lốc → thùng) với hệ số quy đổi', 'S', 'Deck Arito'],
    ];

    const mdTableData = [
        mdHeaders.map(h => makeHeaderCell(h)),
        ...mdRows.map(row => row.map(cell => makeCell(cell))),
    ];
    docx.createTable(mdTableData, { tableColWidth: 2000, tableSize: 16, borders: true, borderSize: 4 });

    p = docx.createP();
    p.addText('B. Kế hoạch mua sắm (KHMS)', { bold: true, font_size: 14, color: '2F5496' });

    const khHeaders = ['Mã', 'Tên yêu cầu', 'Mô tả chi tiết', 'Ưu tiên', 'Nguồn'];
    const khRows = [
        ['FR-KH-01', 'Lập KHMS 3 cấp', 'Hệ thống hỗ trợ lập kế hoạch 3 tầng: (1) Kế hoạch năm → (2) Kế hoạch tháng → (3) Kế hoạch chi tiết. Cho phép group theo nhóm HH/DV, theo thời gian, theo phòng ban', 'M', 'KS 24/06'],
        ['FR-KH-02', 'Tự sinh mã KHMS', 'Tự động sinh mã KHMS theo cấu trúc: KHMS/[Phòng]/[Năm]/[Số] — VD: KHMS/VT&KHSX/2026/KH07', 'M', 'KS 24/06'],
        ['FR-KH-03', 'Kế hoạch chi tiết đính kèm vật tư', 'Mỗi KHMS chi tiết cho phép đính kèm danh sách vật tư với các cột: Mã HH/DV, Tên, DVT, Số lượng, Thời gian cần hàng, Thời gian thanh toán, Đơn giá, Thành tiền, Phòng/Ban/Xưởng, Ghi chú', 'M', 'Form KHMS'],
        ['FR-KH-04', '4 cấp phê duyệt KHMS', 'Luồng phê duyệt: (1) Bộ phận chuyên môn rà soát → (2) TCKT rà soát tồn kho/chi phí → (3) Phòng Mua hàng rà soát → (4) Ban Lãnh đạo phê duyệt. Chọn bộ phận chuyên môn nếu cần', 'M', 'KS 24/06'],
        ['FR-KH-05', 'Điều chỉnh SL/chi tiết hàng hóa', 'Cho phép điều chỉnh số lượng hoặc chi tiết hàng hóa ngay trên dòng kế hoạch, đồng thời ghi chú lý do thay đổi và trả trạng thái chứng từ về cấp phê duyệt tương ứng để duyệt lại', 'M', 'KS 18/06, 24/06'],
        ['FR-KH-06', 'Bảng tổng hợp + quản lý phiên bản', 'Tạo bảng tổng hợp mua sắm theo năm/tháng để Ban Lãnh đạo duyệt theo hạng mục. Quản lý nhiều phiên bản (Ver00, Ver01…) với cột DIFF tự tính chênh lệch giữa các phiên bản', 'M', 'KS 18/06, Form'],
        ['FR-KH-07', 'Mẫu in Phiếu yêu cầu mua sắm', 'Thiết kế mẫu in Phiếu yêu cầu mua sắm / Phiếu KHMS theo định dạng của TCVH', 'S', 'KS 24/06'],
    ];

    const khTableData = [
        khHeaders.map(h => makeHeaderCell(h)),
        ...khRows.map(row => row.map(cell => makeCell(cell))),
    ];
    docx.createTable(khTableData, { tableColWidth: 2000, tableSize: 16, borders: true, borderSize: 4 });

    p = docx.createP();
    p.addText('C. Yêu cầu mua sắm (YCMS)', { bold: true, font_size: 14, color: '2F5496' });

    const ycHeaders = ['Mã', 'Tên yêu cầu', 'Mô tả chi tiết', 'Ưu tiên', 'Nguồn'];
    const ycRows = [
        ['FR-YC-01', '3 luồng YCMS', 'Hệ thống hỗ trợ 3 luồng: (2.1) Có kế hoạch — liên kết KHMS chi tiết đã duyệt & kế thừa dữ liệu; (2.2) Có kế hoạch nhưng thay đổi (thời gian/SL) — điều chỉnh và duyệt lại; (2.3) Không có kế hoạch — lập trực tiếp YCMS mà không cần KHMS', 'M', 'KS 24/06'],
        ['FR-YC-02', 'Kế thừa từ KHMS (luồng 2.1)', 'Khi tạo YCMS từ KHMS, hệ thống tự động kế thừa dữ liệu (mã vật tư, SL, thời gian, DVT…). Đồng thời tự động cập nhật trạng thái dòng KHMS chi tiết về "Đang lên YCMS"', 'M', 'KS 24/06'],
        ['FR-YC-03', 'Điều chỉnh kế hoạch (luồng 2.2)', 'Khi YCMS cần thay đổi so với KHMS (thay đổi SL hoặc thời gian), cho phép: (a) hủy duyệt KHMS → chỉnh sửa → duyệt lại, hoặc (b) điều chỉnh trên YCMS và theo dõi duyệt theo từng dòng', 'M', 'KS 24/06'],
        ['FR-YC-04', 'Tab NCC đề xuất', 'Tab hiển thị danh sách các Nhà cung cấp đề xuất. Tự động hiển thị các mã NCC đã từng được mua hàng cùng loại vật tư để người dùng tham khảo khi lập YCMS', 'S', 'KS 18/06'],
        ['FR-YC-05', 'Gửi mail tự động', 'Cho phép gửi email thông báo tự động cho khách hàng hoặc NCC ngay từ màn hình YCMS (VD: thông báo YCMS mới được tạo, duyệt, từ chối…)', 'S', 'KS 18/06'],
    ];

    const ycTableData = [
        ycHeaders.map(h => makeHeaderCell(h)),
        ...ycRows.map(row => row.map(cell => makeCell(cell))),
    ];
    docx.createTable(ycTableData, { tableColWidth: 2000, tableSize: 16, borders: true, borderSize: 4 });

    p = docx.createP();
    p.addText('3.2. Tổng hợp yêu cầu theo MoSCoW', { bold: true, font_size: 14, color: '2F5496' });

    const summaryRows = [
        [makeHeaderCell('Phân loại'), makeHeaderCell('Mô tả'), makeHeaderCell('Số lượng'), makeHeaderCell('Tỷ lệ')],
        [makeCell('M – Must'), makeCell('Bắt buộc phải có'), makeCell('27'), makeCell('64%')],
        [makeCell('S – Should'), makeCell('Nên có'), makeCell('9'), makeCell('21%')],
        [makeCell('C – Could'), makeCell('Có thể có'), makeCell('1'), makeCell('2%')],
        [makeCell("W – Won't (đợt này)", { fill: 'FFF2CC' }), makeCell('Giai đoạn 2', { fill: 'FFF2CC' }), makeCell('2', { fill: 'FFF2CC' }), makeCell('5%', { fill: 'FFF2CC' })],
        [makeCell('N/A'), makeCell('Ngoài phạm vi'), makeCell('1'), makeCell('2%')],
        [makeCell('Tổng', { fill: 'D9E2F3', bold: true }), makeCell('', { fill: 'D9E2F3' }), makeCell('42', { fill: 'D9E2F3', bold: true }), makeCell('100%', { fill: 'D9E2F3', bold: true })],
    ];
    docx.createTable(summaryRows, { tableColWidth: 3000, tableSize: 20, borders: true, borderSize: 4 });
}

// ============ MAIN ============
async function main() {
    // Tạo Report 1
    const doc1 = officegen('docx');
    doc1.on('error', (err) => console.error('Error:', err));
    createReport1(doc1);
    const out1 = fs.createWriteStream(OUTPUT_DIR + '\\BaoCao1_KhaoSatTinhThichUng.docx');
    doc1.generate(out1);
    console.log('Report 1 created: BaoCao1_KhaoSatTinhThichUng.docx');

    // Tạo Report 2
    const doc2 = officegen('docx');
    doc2.on('error', (err) => console.error('Error:', err));
    createReport2(doc2);
    const out2 = fs.createWriteStream(OUTPUT_DIR + '\\BaoCao2_RaiSoatQuyTrinh_DeXuatMoRong.docx');
    doc2.generate(out2);
    console.log('Report 2 created: BaoCao2_RaiSoatQuyTrinh_DeXuatMoRong.docx');

    // Tạo Report 3
    const doc3 = officegen('docx');
    doc3.on('error', (err) => console.error('Error:', err));
    createReport3(doc3);
    const out3 = fs.createWriteStream(OUTPUT_DIR + '\\BaoCao3_KhaoSatXacNhanYeuCau.docx');
    doc3.generate(out3);
    console.log('Report 3 created: BaoCao3_KhaoSatXacNhanYeuCau.docx');

    console.log('\nAll 3 reports created successfully!');
    console.log('Location: ' + OUTPUT_DIR);
}

main().catch(console.error);
