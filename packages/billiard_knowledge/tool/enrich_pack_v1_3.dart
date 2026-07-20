import 'dart:convert';
import 'dart:io';

Map<String, dynamic> localized(String en, String vi) => {'en': en, 'vi': vi};

Map<String, dynamic> layer(
  String depth,
  String headingEn,
  String headingVi,
  String paragraphEn,
  String paragraphVi, {
  List<Map<String, dynamic>> keyPoints = const [],
}) =>
    {
      'depth': depth,
      'heading': localized(headingEn, headingVi),
      'paragraphs': [localized(paragraphEn, paragraphVi)],
      if (keyPoints.isNotEmpty) 'keyPoints': keyPoints,
    };

Map<String, dynamic> source({
  required String id,
  required String title,
  required String publisher,
  required String url,
  required String sourceType,
}) =>
    {
      'id': id,
      'title': title,
      'publisher': publisher,
      'url': url,
      'sourceType': sourceType,
      'accessedAt': '2026-07-19T00:00:00Z',
    };

Map<String, dynamic> fiveLayerEntry({
  required String id,
  required String kind,
  required String level,
  required String reviewState,
  required String topic,
  required String titleEn,
  required String titleVi,
  required String summaryEn,
  required String summaryVi,
  required List<String> aliases,
  required List<Map<String, dynamic>> layers,
  required List<Map<String, dynamic>> relations,
  required List<String> sourceIds,
}) =>
    {
      'id': id,
      'kind': kind,
      'discipline': 'pool',
      'level': level,
      'reviewState': reviewState,
      'topic': topic,
      'categoryPath': ['pool', topic],
      'title': localized(titleEn, titleVi),
      'summary': localized(summaryEn, summaryVi),
      'aliases': aliases,
      'tags': [topic, level, ...aliases.take(3)],
      'layers': layers,
      'relations': relations,
      'drillRefs': <String>[],
      'sourceIds': sourceIds,
      'revision': 1,
    };

void upsertById(List<Map<String, dynamic>> items, Map<String, dynamic> item) {
  items.removeWhere((existing) => existing['id'] == item['id']);
  items.add(item);
}

void addSourceIds(Map<String, dynamic> entry, Iterable<String> sourceIds) {
  final ids = (entry['sourceIds'] as List).map((item) => '$item').toSet();
  ids.addAll(sourceIds);
  entry['sourceIds'] = ids.toList();
}

void addDeepLayers(
  List<Map<String, dynamic>> entries,
  String entryId,
  Map<String, dynamic> physics,
  Map<String, dynamic> engine,
  List<String> sourceIds,
) {
  final entry = entries.singleWhere((item) => item['id'] == entryId);
  final layers = (entry['layers'] as List).cast<Map<String, dynamic>>();
  layers.removeWhere(
    (item) => item['depth'] == 'physics' || item['depth'] == 'engine',
  );
  layers.addAll([physics, engine]);
  addSourceIds(entry, sourceIds);
  entry['revision'] = 2;
}

void main() {
  final file = File('assets/pack_v1.json');
  final pack = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  pack['packVersion'] = '1.4.0';
  pack['generatedAt'] = '2026-07-19T00:00:00Z';

  final sources = (pack['sources'] as List).cast<Map<String, dynamic>>();
  for (final item in <Map<String, dynamic>>[
    source(
      id: 'source.drdave.throw',
      title: 'Throw - cut-induced and spin-induced throw',
      publisher: 'Dr. Dave Pool Info',
      url: 'https://drdavepoolinfo.com/faq/throw/',
      sourceType: 'instructional_technical_reference',
    ),
    source(
      id: 'source.drdave.squirt',
      title: 'Squirt (cue-ball deflection)',
      publisher: 'Dr. Dave Pool Info',
      url: 'https://drdavepoolinfo.com/faq/squirt/',
      sourceType: 'instructional_technical_reference',
    ),
    source(
      id: 'source.drdave.swerve',
      title: 'Swerve',
      publisher: 'Dr. Dave Pool Info',
      url: 'https://drdavepoolinfo.com/faq/swerve/',
      sourceType: 'instructional_technical_reference',
    ),
    source(
      id: 'source.mathavan.collision_2014',
      title:
          'Numerical simulations of frictional collisions of solid balls on a rough surface',
      publisher: 'Sports Engineering / Loughborough University',
      url:
          'https://billiards.colostate.edu/physics_articles/Mathavan_Sports_2014.pdf',
      sourceType: 'peer_reviewed_research',
    ),
    source(
      id: 'source.mathavan.cushion_2010',
      title:
          'A theoretical analysis of billiard ball dynamics under cushion impacts',
      publisher: 'Loughborough University Research Repository',
      url:
          'https://repository.lboro.ac.uk/articles/journal_contribution/A_theoretical_analysis_of_billiard_ball_dynamics_under_cushion_impacts/9561458',
      sourceType: 'peer_reviewed_research',
    ),
    source(
      id: 'source.pooltool.joss',
      title: 'Pooltool: A Python package for realistic billiards simulation',
      publisher: 'Journal of Open Source Software',
      url: 'https://joss.theoj.org/papers/10.21105/joss.07301',
      sourceType: 'peer_reviewed_software',
    ),
    source(
      id: 'source.vietnam.rules_2002',
      title:
          'Quyet dinh 2025/QD-UBTDTT ban hanh Luat thi dau Billiard - Snooker',
      publisher: 'Uy ban The duc The thao / Thu Vien Phap Luat',
      url:
          'https://thuvienphapluat.vn/van-ban/The-thao-Y-te/Quyet-dinh-2025-QD-UBTDTT-Luat-thi-dau-Billiard-Snooker-93966.aspx',
      sourceType: 'vietnamese_official_rule_archive',
    ),
    source(
      id: 'source.vietnam.glossary',
      title: 'A-Z thuat ngu trong bida',
      publisher: 'The Gioi Bida',
      url:
          'https://thegioibida.vn/a-z-thuat-ngu-trong-bida-day-du-chi-tiet-nhat/',
      sourceType: 'vietnamese_community_terminology',
    ),
    source(
      id: 'source.vietnam.cule',
      title: 'Ky thuat cule bida co ban cho nguoi moi choi',
      publisher: 'Bida Trong Hieu',
      url: 'https://bidatronghieu.com/ky-thuat-cule-bida/',
      sourceType: 'vietnamese_instructional_usage',
    ),
  ]) {
    upsertById(sources, item);
  }

  final entries = (pack['entries'] as List).cast<Map<String, dynamic>>();

  addDeepLayers(
    entries,
    'control.follow_shot',
    layer(
      'physics',
      'Physics model',
      'Mô hình vật lý',
      'At impact, forward angular velocity can remain after the collision removes much of the cue ball linear velocity. Friction at the cloth then drives the slipping contact point toward rolling, so the cue ball continues forward. The amount of follow depends on spin and speed at impact, not tip height alone.',
      'Khi va chạm, vận tốc góc theo chiều xoáy tiến có thể còn lại sau khi va chạm lấy đi phần lớn vận tốc tịnh tiến của bi cái. Ma sát với nỉ sau đó đưa điểm tiếp xúc đang trượt dần về trạng thái lăn, làm bi cái tiếp tục đi tới. Lượng cu lê phụ thuộc xoáy và tốc độ tại lúc chạm, không chỉ phụ thuộc độ cao đầu cơ.',
    ),
    layer(
      'engine',
      'Simulation model',
      'Mô hình mô phỏng',
      'Track linear velocity and angular velocity separately. Resolve the ball-ball collision, then evaluate the cue ball cloth-contact slip velocity and integrate sliding friction until rolling or rest. A follow outcome is forward displacement after contact, not merely positive spin in the state vector.',
      'Theo dõi riêng vận tốc tịnh tiến và vận tốc góc. Giải va chạm bi-bi, sau đó tính vận tốc trượt tại điểm bi cái tiếp xúc nỉ và tích phân ma sát trượt tới khi bi lăn hoặc dừng. Kết quả cu lê là quãng đường đi tới sau va chạm, không chỉ là một giá trị xoáy dương trong trạng thái mô phỏng.',
    ),
    ['source.mathavan.collision_2014', 'source.pooltool.joss'],
  );

  addDeepLayers(
    entries,
    'control.draw_shot',
    layer(
      'physics',
      'Physics model',
      'Mô hình vật lý',
      'Draw requires backspin to survive until object-ball contact. After the collision reduces forward translation, the backward-moving cloth contact point produces a friction impulse that can reverse the cue ball before the motion transitions toward rolling. Distance, speed, cloth friction, ball cleanliness, and cut angle all change the result.',
      'Cú trô cần giữ được xoáy lùi tới lúc chạm bi mục tiêu. Sau khi va chạm làm giảm chuyển động tịnh tiến về trước, điểm tiếp xúc với nỉ đang chuyển động ngược tạo xung ma sát có thể đảo chiều bi cái trước khi chuyển động tiến dần về trạng thái lăn. Cự ly, tốc độ, ma sát nỉ, độ sạch của bi và góc cắt đều làm thay đổi kết quả.',
    ),
    layer(
      'engine',
      'Simulation model',
      'Mô hình mô phỏng',
      'Initialize the cue ball with forward velocity and backspin from the cue-impact model. Integrate pre-impact sliding, resolve the ball collision, then continue cloth friction from the residual state. Classify draw from measurable backward displacement after contact and calibrate coefficients against table tests.',
      'Khởi tạo bi cái với vận tốc tiến và xoáy lùi từ mô hình va chạm đầu cơ. Tích phân giai đoạn trượt trước va chạm, giải va chạm bi rồi tiếp tục tính ma sát nỉ từ trạng thái còn lại. Phân loại cú trô bằng quãng đường lùi đo được sau va chạm và hiệu chỉnh các hệ số bằng thử nghiệm trên bàn.',
    ),
    ['source.mathavan.collision_2014', 'source.pooltool.joss'],
  );

  addDeepLayers(
    entries,
    'control.tangent_line',
    layer(
      'physics',
      'Physics model',
      'Mô hình vật lý',
      'For an ideal collision of equal balls, the component of cue ball velocity along the line of centers is transferred mainly to the object ball, while the tangential component remains with the cue ball. The familiar 90-degree reference applies to a sliding or stun cue ball immediately after contact; follow, draw, contact friction, and non-ideal losses modify the path.',
      'Trong va chạm lý tưởng giữa hai bi giống nhau, thành phần vận tốc bi cái dọc đường nối tâm chủ yếu truyền sang bi mục tiêu, còn thành phần tiếp tuyến ở lại với bi cái. Mốc 90 độ quen thuộc áp dụng cho bi cái đang trượt hoặc stun ngay sau va chạm; xoáy tiến, xoáy lùi, ma sát tiếp xúc và tổn hao thực tế sẽ làm thay đổi đường đi.',
    ),
    layer(
      'engine',
      'Simulation model',
      'Mô hình mô phỏng',
      'Build the collision normal from the two ball centers and decompose relative velocity into normal and tangential components. Apply restitution and frictional impulses, update both linear and angular velocities, then continue table motion. The tangent line should be exposed as a reference overlay, not forced as the simulated trajectory.',
      'Dựng pháp tuyến va chạm từ hai tâm bi và tách vận tốc tương đối thành thành phần pháp tuyến, tiếp tuyến. Áp dụng xung đàn hồi và xung ma sát, cập nhật vận tốc tịnh tiến lẫn vận tốc góc rồi tiếp tục mô phỏng trên nỉ. Đường tiếp tuyến chỉ nên là lớp tham chiếu, không được ép thành quỹ đạo mô phỏng.',
    ),
    ['source.mathavan.collision_2014', 'source.pooltool.joss'],
  );

  addDeepLayers(
    entries,
    'physics.throw.awareness',
    layer(
      'physics',
      'Physics model',
      'Mô hình vật lý',
      'Throw comes from a tangential friction impulse during ball-ball contact. Cut-induced throw arises from relative sliding at an angled hit; spin-induced throw changes that relative surface speed with sidespin. Direction and magnitude depend on cut angle, speed, spin, and surface condition, so one fixed aiming allowance is not reliable.',
      'Throw sinh ra từ xung ma sát theo phương tiếp tuyến trong lúc hai bi tiếp xúc. Throw do góc cắt xuất hiện từ trượt tương đối ở cú chạm xiên; throw do xoáy thay đổi vận tốc bề mặt tương đối bằng xoáy ngang. Hướng và độ lớn phụ thuộc góc cắt, tốc độ, xoáy và tình trạng bề mặt, nên một mức bù ngắm cố định không đáng tin cậy.',
    ),
    layer(
      'engine',
      'Simulation model',
      'Mô hình mô phỏng',
      'Resolve a normal collision impulse and a bounded tangential friction impulse using the relative velocity at the contact point, including both balls angular velocities. Validate object-ball departure angles over cut, speed, and spin grids; a frictionless collision model cannot reproduce throw.',
      'Giải xung va chạm pháp tuyến và xung ma sát tiếp tuyến có giới hạn từ vận tốc tương đối tại điểm tiếp xúc, bao gồm vận tốc góc của cả hai bi. Kiểm chứng góc rời của bi mục tiêu theo lưới góc cắt, tốc độ và xoáy; mô hình va chạm không ma sát không thể tái tạo throw.',
    ),
    [
      'source.drdave.throw',
      'source.mathavan.collision_2014',
      'source.pooltool.joss',
    ],
  );

  addDeepLayers(
    entries,
    'control.speed',
    layer(
      'physics',
      'Physics model',
      'Mô hình vật lý',
      'Speed changes how long the cue ball spends sliding, how much spin remains at each collision, and how far it travels under rolling resistance. Sliding friction and rolling resistance are different regimes; table and ball condition therefore matter when transferring a familiar stroke to another table.',
      'Tốc độ làm thay đổi thời gian bi cái trượt, lượng xoáy còn lại ở mỗi va chạm và quãng đường bi đi dưới lực cản lăn. Ma sát trượt và lực cản lăn là hai chế độ khác nhau; vì vậy tình trạng bàn và bi ảnh hưởng lớn khi mang một cú quen thuộc sang bàn khác.',
    ),
    layer(
      'engine',
      'Simulation model',
      'Mô hình mô phỏng',
      'Use motion-state transitions such as sliding, rolling, spinning, and stationary, each with calibrated resistance. Event-based simulation can advance to the next collision or state transition instead of relying only on display frames. Report uncertainty when cloth coefficients are not calibrated for the current table.',
      'Dùng các chuyển trạng thái như trượt, lăn, xoay tại chỗ và đứng yên, mỗi trạng thái có lực cản đã hiệu chỉnh. Mô phỏng theo sự kiện có thể tiến thẳng tới va chạm hoặc lần chuyển trạng thái kế tiếp thay vì chỉ phụ thuộc khung hình hiển thị. Phải báo độ bất định khi hệ số nỉ chưa được hiệu chỉnh cho bàn hiện tại.',
    ),
    [
      'source.mathavan.collision_2014',
      'source.mathavan.cushion_2010',
      'source.pooltool.joss',
    ],
  );

  final additions = <Map<String, dynamic>>[
    fiveLayerEntry(
      id: 'term.tro',
      kind: 'terminology',
      level: 'fundamental',
      reviewState: 'draft',
      topic: 'vietnamese_glossary',
      titleEn: '“Trô” (Vietnamese draw-shot term)',
      titleVi: 'Trô',
      summaryEn:
          'A Vietnamese table term commonly used for drawing the cue ball backward after contact.',
      summaryVi:
          'Cách nói trên bàn thường chỉ cú làm bi cái lùi lại sau khi chạm bi mục tiêu.',
      aliases: ['trô', 'tro', 'trô bi', 'draw'],
      layers: [
        layer(
            'result',
            'Do it',
            'Làm theo',
            'On a short, nearly straight setup, strike below center with a level cue and smooth delivery. Observe whether the cue ball comes back after contact; adjust speed and tip offset gradually.',
            'Với hình bi ngắn, gần thẳng, đánh dưới tâm bằng cơ tương đối ngang và ra cơ mượt. Quan sát bi cái có lùi sau va chạm hay không rồi chỉnh dần lực và độ thấp điểm chạm.'),
        layer(
            'cause',
            'What players mean',
            'Người chơi muốn nói gì',
            '“Trô” usually describes the backward cue-ball result, not a guarantee created merely by aiming low. The backspin must still be present at object-ball contact.',
            '“Trô” thường mô tả kết quả bi cái lùi về, không phải cứ ngắm thấp là chắc chắn trô. Xoáy lùi phải còn tồn tại lúc chạm bi mục tiêu.'),
        layer(
            'principles',
            'Practical principle',
            'Nguyên lý thực hành',
            'Longer distance and cloth friction consume backspin. A harder stroke can preserve spin but also increases position error, so train repeatable distances instead of chasing maximum draw.',
            'Cự ly dài hơn và ma sát nỉ làm hao xoáy lùi. Đánh mạnh hơn có thể giữ xoáy nhưng cũng tăng sai số điều bi, vì vậy nên tập cự ly lùi lặp lại thay vì chỉ cố trô tối đa.'),
        layer(
            'physics',
            'Physics model',
            'Mô hình vật lý',
            'Residual backspin and the post-collision friction impulse can reverse cue-ball translation. The result depends on the complete impact state: linear speed, angular speed, cut angle, and surface friction.',
            'Xoáy lùi còn dư cùng xung ma sát sau va chạm có thể đảo chiều chuyển động tịnh tiến của bi cái. Kết quả phụ thuộc toàn bộ trạng thái va chạm: tốc độ tiến, tốc độ góc, góc cắt và ma sát bề mặt.'),
        layer(
            'engine',
            'Simulation model',
            'Mô hình mô phỏng',
            'Use the same state transition and collision model as the draw-shot node. Keep “trô” as a Vietnamese search and Coach vocabulary mapping, not as a separate physical law.',
            'Dùng cùng mô hình chuyển trạng thái và va chạm với nút Draw Shot. Giữ “trô” như từ vựng tìm kiếm và ngôn ngữ Coach bằng tiếng Việt, không biến nó thành một định luật vật lý riêng.'),
      ],
      relations: [
        {'targetId': 'control.draw_shot', 'type': 'related'},
        {'targetId': 'control.speed', 'type': 'related'},
      ],
      sourceIds: [
        'source.vietnam.glossary',
        'source.drdave.cue_control',
        'source.mathavan.collision_2014',
        'source.pooltool.joss',
      ],
    ),
    fiveLayerEntry(
      id: 'term.cu_le',
      kind: 'terminology',
      level: 'fundamental',
      reviewState: 'draft',
      topic: 'vietnamese_glossary',
      titleEn: '“Cu lê” (Vietnamese follow-shot term)',
      titleVi: 'Cu lê',
      summaryEn:
          'A Vietnamese table term commonly used when the cue ball continues forward after contact.',
      summaryVi:
          'Cách nói trên bàn thường chỉ cú làm bi cái tiếp tục đi tới sau khi chạm bi mục tiêu.',
      aliases: ['cu lê', 'cule', 'coule', 'xoáy tiến'],
      layers: [
        layer(
            'result',
            'Do it',
            'Làm theo',
            'On a short, nearly straight setup, strike above center with a smooth level delivery. Start with moderate speed and measure the cue ball forward travel after contact.',
            'Với hình bi ngắn, gần thẳng, đánh trên tâm bằng cú ra cơ mượt và tương đối ngang. Bắt đầu với lực vừa rồi đo quãng đường bi cái đi tới sau va chạm.'),
        layer(
            'cause',
            'What players mean',
            'Người chơi muốn nói gì',
            '“Cu lê” describes forward cue-ball travel caused by forward roll remaining at impact. It is the practical follow-shot result, not simply the instruction to hit high.',
            '“Cu lê” mô tả bi cái đi tới nhờ xoáy tiến còn lại lúc va chạm. Đây là kết quả thực tế của follow shot, không chỉ là câu lệnh đánh cao.'),
        layer(
            'principles',
            'Practical principle',
            'Nguyên lý thực hành',
            'Tip height, speed, distance, and cloth jointly determine the follow distance. More spin is not automatically better if it sends the cue ball beyond the intended position zone.',
            'Độ cao đầu cơ, lực, cự ly và nỉ cùng quyết định quãng cu lê. Nhiều xoáy hơn không tự động tốt hơn nếu bi cái đi quá vùng vị trí dự kiến.'),
        layer(
            'physics',
            'Physics model',
            'Mô hình vật lý',
            'Forward angular velocity left after collision makes the cloth contact point slip backward relative to the table; friction then drives the cue ball forward toward rolling.',
            'Vận tốc góc theo chiều tiến còn lại sau va chạm làm điểm tiếp xúc nỉ trượt ngược tương đối so với bàn; ma sát sau đó đẩy bi cái đi tới để tiến về trạng thái lăn.'),
        layer(
            'engine',
            'Simulation model',
            'Mô hình mô phỏng',
            'Map “cu lê” to the follow-shot state and outcome model. The engine should predict forward displacement from calibrated spin, collision, and cloth parameters rather than from the word itself.',
            'Ánh xạ “cu lê” vào mô hình trạng thái và kết quả của Follow Shot. Engine phải dự đoán quãng đi tới từ xoáy, va chạm và tham số nỉ đã hiệu chỉnh, không suy ra từ chính từ ngữ.'),
      ],
      relations: [
        {'targetId': 'control.follow_shot', 'type': 'related'},
        {'targetId': 'control.speed', 'type': 'related'},
      ],
      sourceIds: [
        'source.vietnam.cule',
        'source.drdave.cue_control',
        'source.mathavan.collision_2014',
        'source.pooltool.joss',
      ],
    ),
    fiveLayerEntry(
      id: 'physics.squirt',
      kind: 'concept',
      level: 'advanced',
      reviewState: 'reviewed',
      topic: 'cue_ball_physics',
      titleEn: 'Squirt (cue-ball deflection)',
      titleVi: 'Squirt - lệch bi cái ngay khi chạm',
      summaryEn:
          'The immediate cue-ball deflection opposite the side of an off-center cue strike.',
      summaryVi:
          'Độ lệch tức thời của bi cái về phía ngược với bên đánh xoáy ngang.',
      aliases: ['squirt', 'cue ball deflection', 'deflection', 'lệch bi cái'],
      layers: [
        layer(
            'result',
            'Do it',
            'Làm theo',
            'When using sidespin, begin with the smallest offset needed and test the cue on a repeatable straight reference shot. Do not copy one compensation value between shafts.',
            'Khi dùng xoáy ngang, bắt đầu với độ lệch tâm nhỏ nhất cần thiết và thử cơ trên một cú thẳng có thể lặp lại. Không sao chép một mức bù ngắm cho mọi loại cán.'),
        layer(
            'cause',
            'Why the cue ball starts off-line',
            'Vì sao bi cái rời đường ngắm',
            'An off-center cue impact creates sidespin and a lateral reaction during the brief tip-ball collision. The cue ball initially deflects opposite the tip offset.',
            'Va chạm lệch tâm tạo xoáy ngang và phản lực ngang trong thời gian đầu cơ tiếp xúc bi rất ngắn. Bi cái ban đầu lệch về phía ngược với độ lệch đầu cơ.'),
        layer(
            'principles',
            'Practical principle',
            'Nguyên lý thực hành',
            'Squirt happens at cue impact and must be distinguished from swerve, which curves the ball later on the cloth. Shaft front-end behavior, tip offset, speed, and cue elevation influence the observed result.',
            'Squirt xảy ra ngay lúc đầu cơ chạm bi và phải phân biệt với swerve, là độ cong xuất hiện sau đó trên nỉ. Phần đầu cán, độ lệch điểm chạm, tốc độ và độ nâng cơ ảnh hưởng kết quả quan sát.'),
        layer(
            'physics',
            'Physics model',
            'Mô hình vật lý',
            'The off-axis cue-tip impulse couples cue-ball translation and rotation while the shaft end also moves laterally. Effective end mass is an important design variable, but real compensation should be measured for the cue and shot conditions.',
            'Xung đầu cơ lệch trục ghép chuyển động tịnh tiến với chuyển động quay của bi cái, đồng thời phần đầu cán dịch chuyển ngang. Khối lượng hiệu dụng phần đầu cán là biến thiết kế quan trọng, nhưng mức bù thực tế cần được đo cho từng cơ và điều kiện cú đánh.'),
        layer(
            'engine',
            'Simulation model',
            'Mô hình mô phỏng',
            'A cue-impact model takes cue speed, elevation, azimuth, tip offset, ball properties, and shaft calibration, then outputs cue-ball linear and angular velocity. Keep squirt as the immediate launch-angle change before table-motion integration.',
            'Mô hình đầu cơ nhận tốc độ cơ, độ nâng, phương ngang, độ lệch đầu cơ, thuộc tính bi và hiệu chỉnh cán rồi xuất vận tốc tịnh tiến, vận tốc góc của bi cái. Squirt phải là thay đổi góc phóng tức thời trước khi tích phân chuyển động trên nỉ.'),
      ],
      relations: [
        {'targetId': 'physics.swerve', 'type': 'related'},
        {'targetId': 'physics.throw.awareness', 'type': 'related'},
      ],
      sourceIds: ['source.drdave.squirt', 'source.pooltool.joss'],
    ),
    fiveLayerEntry(
      id: 'physics.swerve',
      kind: 'concept',
      level: 'advanced',
      reviewState: 'reviewed',
      topic: 'cue_ball_physics',
      titleEn: 'Swerve',
      titleVi: 'Swerve - đường bi cong do xoáy',
      summaryEn:
          'The cue ball curves on the cloth after an elevated, sidespin shot.',
      summaryVi: 'Bi cái cong đường trên nỉ sau cú có nâng cơ và xoáy ngang.',
      aliases: ['swerve', 'cue ball curve', 'đường bi cong', 'cong bi'],
      layers: [
        layer(
            'result',
            'Do it',
            'Làm theo',
            'Keep the cue as level as the shot permits when predictable sidespin is the goal. If elevation is unavoidable, allow more distance for the curve and test the table speed first.',
            'Giữ cơ ngang trong mức hình bi cho phép khi cần xoáy ngang dễ dự đoán. Nếu buộc phải nâng cơ, chừa đủ cự ly cho đường cong và thử tốc độ bàn trước.'),
        layer(
            'cause',
            'Why the path curves',
            'Vì sao đường bi cong',
            'Cue elevation gives the spin axis a vertical component. As the spinning ball interacts with the cloth under gravity, friction changes the horizontal direction over time.',
            'Nâng cơ làm trục xoáy có thành phần theo phương đứng. Khi bi xoay tương tác với nỉ dưới tác dụng trọng lực, ma sát làm đổi hướng chuyển động ngang theo thời gian.'),
        layer(
            'principles',
            'Practical principle',
            'Nguyên lý thực hành',
            'Swerve develops during travel, unlike immediate squirt. More elevation, more sidespin, more travel time, and slower speed generally make the curve more visible, but table conditions matter.',
            'Swerve phát triển trong lúc bi chạy, khác với squirt xảy ra tức thời. Nâng cơ nhiều hơn, xoáy ngang nhiều hơn, thời gian chạy dài hơn và tốc độ chậm hơn thường làm đường cong rõ hơn, nhưng điều kiện bàn vẫn rất quan trọng.'),
        layer(
            'physics',
            'Physics model',
            'Mô hình vật lý',
            'The cloth friction force acts at the ball-table contact point while gravity maintains the normal load. With a tilted spin axis, that friction changes both angular and linear velocity, producing a curved planar trajectory until the motion state changes.',
            'Lực ma sát nỉ tác dụng tại điểm bi tiếp xúc bàn trong khi trọng lực duy trì phản lực pháp tuyến. Với trục xoáy nghiêng, ma sát làm thay đổi cả vận tốc góc lẫn vận tốc tịnh tiến, tạo quỹ đạo cong trên mặt bàn tới khi trạng thái chuyển động đổi.'),
        layer(
            'engine',
            'Simulation model',
            'Mô hình mô phỏng',
            'Initialize the full three-dimensional angular velocity from cue elevation and offset, then integrate cloth-contact friction and motion-state transitions. Validate lateral displacement by distance and speed; a one-time launch-angle correction models squirt but cannot model swerve.',
            'Khởi tạo vận tốc góc ba chiều từ độ nâng cơ và độ lệch đầu cơ rồi tích phân ma sát tiếp xúc nỉ cùng các chuyển trạng thái. Kiểm chứng độ lệch ngang theo cự ly và tốc độ; một lần sửa góc phóng chỉ mô hình hóa squirt, không thể mô hình hóa swerve.'),
      ],
      relations: [
        {'targetId': 'physics.squirt', 'type': 'related'},
        {'targetId': 'physics.throw.awareness', 'type': 'related'},
      ],
      sourceIds: ['source.drdave.swerve', 'source.pooltool.joss'],
    ),
  ];

  for (final item in additions) {
    upsertById(entries, item);
  }

  for (final entry in entries.where((item) =>
      item['kind'] == 'rule' ||
      item['id'] == 'term.cue_ball' ||
      item['id'] == 'term.object_ball')) {
    addSourceIds(entry, ['source.vietnam.rules_2002']);
  }

  // v1.4 Mastery contract: guided practice uses exact Drill codes. Broad
  // category refs would grant one run to several unrelated lessons.
  const exactDrills = <String, String>{
    'fundamental.stance.basic': 'B001',
    'fundamental.bridge.open': 'B001',
    'fundamental.bridge.closed': 'B001',
    'fundamental.grip.relaxed': 'B001',
    'fundamental.alignment.visual': 'B001',
    'fundamental.routine.pre_shot': 'I007',
    'fundamental.pause.delivery': 'B001',
    'fundamental.stroke.delivery': 'B001',
    'control.stop_shot': 'B002',
    'control.follow_shot': 'B005',
    'control.draw_shot': 'B005',
    'control.tangent_line': 'I003',
    'control.speed': 'B005',
    'position.zone_planning': 'B005',
    'aim.ghost_ball': 'B003',
    'aim.cut_angle': 'B003',
    'physics.throw.awareness': 'B003',
    'strategy.pattern.three_ball': 'A006',
    'strategy.safety.objective': 'I004',
    'strategy.safety.distance': 'I004',
    'break.controlled_power': 'I005',
    'mental.reset_after_error': 'I007',
    'mistake.head_movement': 'B001',
    'mistake.cue_steering': 'B001',
  };
  for (final entry in entries) {
    final drill = exactDrills[entry['id']];
    if (drill != null) entry['drillRefs'] = [drill];
  }
  for (final path in (pack['paths'] as List).cast<Map<String, dynamic>>()) {
    for (final step in (path['steps'] as List).cast<Map<String, dynamic>>()) {
      final drill = exactDrills[step['entryId']];
      step['drillRefs'] = drill == null ? <String>[] : [drill];
    }
  }

  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
  );
}
