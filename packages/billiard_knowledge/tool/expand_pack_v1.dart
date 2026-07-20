import 'dart:convert';
import 'dart:io';

Map<String, dynamic> text(String en, String vi) => {'en': en, 'vi': vi};

Map<String, dynamic> entry({
  required String id,
  required String kind,
  required String level,
  required String topic,
  required String titleEn,
  required String titleVi,
  required String summaryEn,
  required String summaryVi,
  required String actionEn,
  required String actionVi,
  required String causeEn,
  required String causeVi,
  required String principleEn,
  required String principleVi,
  required String sourceId,
  List<String> aliases = const [],
  List<String> relations = const [],
  List<String> drillRefs = const [],
}) =>
    {
      'id': id,
      'kind': kind,
      'discipline': 'pool',
      'level': level,
      'reviewState': 'reviewed',
      'topic': topic,
      'categoryPath': ['pool', topic],
      'title': text(titleEn, titleVi),
      'summary': text(summaryEn, summaryVi),
      'aliases': aliases,
      'tags': [topic, level, ...aliases.take(2)],
      'layers': [
        {
          'depth': 'result',
          'heading': text('How to apply it', 'Cách thực hiện'),
          'paragraphs': [text(actionEn, actionVi)],
        },
        {
          'depth': 'cause',
          'heading': text('Why it works', 'Vì sao có tác dụng'),
          'paragraphs': [text(causeEn, causeVi)],
        },
        {
          'depth': 'principles',
          'heading': text('Underlying principle', 'Nguyên lý cốt lõi'),
          'paragraphs': [text(principleEn, principleVi)],
        },
      ],
      'relations': [
        for (final targetId in relations)
          {'targetId': targetId, 'type': 'related'},
      ],
      'drillRefs': drillRefs,
      'sourceIds': [sourceId],
      'revision': 1,
    };

Map<String, dynamic> path({
  required String id,
  required String titleEn,
  required String titleVi,
  required String descriptionEn,
  required String descriptionVi,
  required String level,
  required List<String> steps,
}) =>
    {
      'id': id,
      'title': text(titleEn, titleVi),
      'description': text(descriptionEn, descriptionVi),
      'level': level,
      'steps': [
        for (final entryId in steps)
          {
            'entryId': entryId,
            'minimumDepth': 'result',
            'drillRefs': <String>[],
          },
      ],
    };

void main() {
  final file = File('assets/pack_v1.json');
  final pack = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  pack['packVersion'] = '1.2.0';
  pack['generatedAt'] = '2026-07-19T00:00:00Z';

  final sources = (pack['sources'] as List).cast<Map<String, dynamic>>();
  const addedSourceIds = {
    'source.drdave.cue_control',
    'source.drdave.aiming',
    'source.drdave.strategy',
    'source.drdave.break',
  };
  sources.removeWhere((source) => addedSourceIds.contains(source['id']));
  sources.addAll([
    {
      'id': 'source.drdave.cue_control',
      'title': 'Cue Ball Control',
      'publisher': 'Dr. Dave Pool Info',
      'url': 'https://drdavepoolinfo.com/tutorial/cue-ball-control/',
      'sourceType': 'instructional_reference',
      'accessedAt': '2026-07-19T00:00:00Z',
    },
    {
      'id': 'source.drdave.aiming',
      'title': 'Aiming',
      'publisher': 'Dr. Dave Pool Info',
      'url': 'https://drdavepoolinfo.com/faq/aiming/',
      'sourceType': 'instructional_reference',
      'accessedAt': '2026-07-19T00:00:00Z',
    },
    {
      'id': 'source.drdave.strategy',
      'title': 'Strategy',
      'publisher': 'Dr. Dave Pool Info',
      'url': 'https://drdavepoolinfo.com/tutorial/strategy/',
      'sourceType': 'instructional_reference',
      'accessedAt': '2026-07-19T00:00:00Z',
    },
    {
      'id': 'source.drdave.break',
      'title': 'Break Shot',
      'publisher': 'Dr. Dave Pool Info',
      'url': 'https://drdavepoolinfo.com/faq/break/',
      'sourceType': 'instructional_reference',
      'accessedAt': '2026-07-19T00:00:00Z',
    },
  ]);

  final additions = <Map<String, dynamic>>[
    entry(
      id: 'fundamental.bridge.closed',
      kind: 'technique',
      level: 'fundamental',
      topic: 'bridge',
      titleEn: 'Closed bridge',
      titleVi: 'Cầu tay kín',
      summaryEn:
          'Guide the shaft through a stable finger loop when extra containment is useful.',
      summaryVi:
          'Dẫn thân cơ qua vòng ngón tay ổn định khi cần giữ cơ chắc hơn.',
      actionEn:
          'Plant the bridge hand, form a loose loop around the shaft, and confirm that the cue still slides without binding.',
      actionVi:
          'Đặt chắc tay cầu, tạo vòng ngón tay lỏng quanh thân cơ và kiểm tra cơ vẫn trượt tự do.',
      causeEn:
          'The loop limits lateral escape while preserving forward movement.',
      causeVi:
          'Vòng ngón tay hạn chế cơ lệch ngang nhưng vẫn cho phép chuyển động tới.',
      principleEn:
          'A bridge should constrain direction without adding friction or tension.',
      principleVi: 'Cầu tay cần giữ hướng mà không tạo ma sát hoặc căng thừa.',
      sourceId: 'source.drdave.fundamentals',
      aliases: ['closed bridge', 'cau tay kin'],
      relations: ['fundamental.bridge.open', 'fundamental.stroke.delivery'],
    ),
    entry(
      id: 'fundamental.pause.delivery',
      kind: 'technique',
      level: 'fundamental',
      topic: 'stroke',
      titleEn: 'Set and pause',
      titleVi: 'Dừng trước khi ra cơ',
      summaryEn: 'Use a brief settled moment before the final forward stroke.',
      summaryVi: 'Dùng một nhịp dừng ngắn và ổn định trước cú ra cơ cuối.',
      actionEn:
          'Finish the last warm-up stroke, settle at the cue ball, complete the backswing, then deliver without rushing the transition.',
      actionVi:
          'Kết thúc nhịp cơ thử, ổn định gần bi cái, hoàn thành kéo cơ rồi ra cơ mà không giật chuyển hướng.',
      causeEn: 'A clear transition reduces the urge to snatch the cue forward.',
      causeVi: 'Chuyển pha rõ ràng làm giảm xu hướng giật cơ về phía trước.',
      principleEn:
          'Repeatable timing is more valuable than copying one fixed pause length.',
      principleVi:
          'Nhịp điệu lặp lại quan trọng hơn việc bắt chước một thời lượng dừng cố định.',
      sourceId: 'source.drdave.fundamentals',
      aliases: ['pause', 'set pause finish', 'dung nhip'],
      relations: [
        'fundamental.routine.pre_shot',
        'fundamental.stroke.delivery'
      ],
    ),
    entry(
      id: 'aim.ghost_ball',
      kind: 'concept',
      level: 'fundamental',
      topic: 'aiming',
      titleEn: 'Ghost-ball aiming',
      titleVi: 'Ngắm bằng bi ảo',
      summaryEn:
          'Visualize the cue-ball center at the contact position that sends the object ball along the target line.',
      summaryVi:
          'Hình dung tâm bi cái tại vị trí tiếp xúc để đưa bi mục tiêu đi theo đường đã chọn.',
      actionEn:
          'Trace the object-ball line to the pocket, locate the contact point, then visualize a cue ball touching that point and aim its center.',
      actionVi:
          'Kẻ đường từ bi mục tiêu tới lỗ, xác định điểm chạm rồi hình dung một bi cái tiếp xúc tại đó và ngắm vào tâm bi ảo.',
      causeEn:
          'The image converts an object-ball target line into a cue-ball center line.',
      causeVi:
          'Hình ảnh này chuyển đường đi của bi mục tiêu thành đường tâm của bi cái.',
      principleEn:
          'It is a geometric starting point; throw, spin, speed, and perception can require adjustment.',
      principleVi:
          'Đây là điểm xuất phát hình học; độ ném, xoáy, tốc độ và thị giác có thể đòi hỏi hiệu chỉnh.',
      sourceId: 'source.drdave.aiming',
      aliases: ['ghost ball', 'bi ao'],
      relations: [
        'aim.cut_angle',
        'physics.throw.awareness',
        'fundamental.alignment.visual'
      ],
    ),
    entry(
      id: 'aim.cut_angle',
      kind: 'concept',
      level: 'fundamental',
      topic: 'aiming',
      titleEn: 'Cut angle',
      titleVi: 'Góc cắt',
      summaryEn:
          'Understand how full or thin contact changes the object-ball direction.',
      summaryVi: 'Hiểu mức chạm dày hoặc mỏng làm thay đổi hướng bi mục tiêu.',
      actionEn:
          'Compare the incoming cue-ball line with the desired object-ball line and identify whether the hit is full, half-ball-like, or thin.',
      actionVi:
          'So sánh đường bi cái đi vào với đường bi mục tiêu mong muốn và nhận diện cú chạm dày, gần nửa bi hay mỏng.',
      causeEn:
          'Changing the overlap changes the contact normal and therefore the object-ball path.',
      causeVi:
          'Thay đổi độ che phủ làm thay đổi phương pháp tuyến tiếp xúc và đường đi của bi mục tiêu.',
      principleEn:
          'Cut angle describes geometry, while actual pocketing also depends on throw and pocket acceptance.',
      principleVi:
          'Góc cắt mô tả hình học, còn khả năng vào lỗ thực tế còn phụ thuộc độ ném và độ nhận bi của lỗ.',
      sourceId: 'source.drdave.aiming',
      aliases: ['cut shot', 'goc cat', 'thin hit'],
      relations: ['aim.ghost_ball', 'physics.throw.awareness'],
    ),
    entry(
      id: 'physics.throw.awareness',
      kind: 'concept',
      level: 'intermediate',
      topic: 'aiming',
      titleEn: 'Throw awareness',
      titleVi: 'Nhận biết độ ném bi',
      summaryEn:
          'Account for friction-induced object-ball direction changes at contact.',
      summaryVi: 'Tính đến thay đổi hướng bi mục tiêu do ma sát tại va chạm.',
      actionEn:
          'Treat the geometric aim as a baseline and observe recurring misses under different speed, cut, and spin conditions.',
      actionVi:
          'Dùng đường ngắm hình học làm mốc rồi quan sát sai lệch lặp lại ở các tốc độ, góc cắt và xoáy khác nhau.',
      causeEn:
          'Friction between the balls can push the object ball away from its purely geometric line.',
      causeVi:
          'Ma sát giữa hai bi có thể đẩy bi mục tiêu lệch khỏi đường hình học thuần túy.',
      principleEn:
          'Throw is condition-dependent; avoid applying one fixed correction to every shot.',
      principleVi:
          'Độ ném phụ thuộc điều kiện; không áp dụng một mức bù cố định cho mọi cú.',
      sourceId: 'source.drdave.aiming',
      aliases: ['throw', 'contact induced throw', 'do nem'],
      relations: ['aim.ghost_ball', 'aim.cut_angle'],
    ),
    entry(
      id: 'control.stop_shot',
      kind: 'technique',
      level: 'fundamental',
      topic: 'cue_ball_control',
      titleEn: 'Stop shot',
      titleVi: 'Cú dừng bi cái',
      summaryEn:
          'Make the cue ball stop near the collision point after a straight hit.',
      summaryVi: 'Làm bi cái dừng gần điểm va chạm sau cú đánh thẳng.',
      actionEn:
          'For a short straight shot, start about half a tip below center at roughly 35% speed. Keep the cue level, deliver smoothly through the cue ball, and do not jab. Adjust from this starting point for distance and cloth.',
      actionVi:
          'Với cú thẳng cự ly ngắn, bắt đầu ở khoảng nửa đầu cơ dưới tâm, lực khoảng 35%. Giữ cơ tương đối ngang, ra cơ mượt xuyên qua bi cái và không giật tay. Điều chỉnh từ mốc này theo cự ly và nỉ.',
      causeEn:
          'With no rotational tendency and a full hit, most forward motion transfers to the object ball.',
      causeVi:
          'Khi không có xu hướng xoay và chạm đầy, phần lớn chuyển động tiến truyền sang bi mục tiêu.',
      principleEn:
          'The required tip height and speed depend on distance and cloth friction.',
      principleVi:
          'Độ cao chạm đầu cơ và tốc độ cần thiết phụ thuộc cự ly và ma sát nỉ.',
      sourceId: 'source.drdave.cue_control',
      aliases: ['stop shot', 'stun stop', 'dung bi'],
      relations: [
        'control.follow_shot',
        'control.draw_shot',
        'control.tangent_line'
      ],
      drillRefs: ['straightShot'],
    ),
    entry(
      id: 'control.follow_shot',
      kind: 'technique',
      level: 'fundamental',
      topic: 'cue_ball_control',
      titleEn: 'Follow shot',
      titleVi: 'Cú xoáy tiến',
      summaryEn:
          'Keep forward roll on the cue ball so it continues after contact.',
      summaryVi: 'Giữ xoáy tiến để bi cái tiếp tục chạy sau va chạm.',
      actionEn:
          'Strike above center with a smooth delivery and enough distance or speed for forward rotation to remain at contact.',
      actionVi:
          'Đánh trên tâm bằng cú ra cơ mượt, với cự ly hoặc tốc độ đủ để còn xoáy tiến lúc va chạm.',
      causeEn:
          'Forward rotation carries the cue ball beyond the collision instead of leaving it on the tangent path.',
      causeVi:
          'Xoáy tiến kéo bi cái đi tiếp sau va chạm thay vì chỉ đi theo tiếp tuyến.',
      principleEn:
          'More tip offset is not always more control; combine spin with appropriate speed.',
      principleVi:
          'Chạm cao hơn không phải lúc nào cũng kiểm soát tốt hơn; cần phối hợp xoáy với tốc độ phù hợp.',
      sourceId: 'source.drdave.cue_control',
      aliases: ['follow', 'topspin', 'xoay tien'],
      relations: ['control.stop_shot', 'control.tangent_line'],
    ),
    entry(
      id: 'control.draw_shot',
      kind: 'technique',
      level: 'intermediate',
      topic: 'cue_ball_control',
      titleEn: 'Draw shot',
      titleVi: 'Cú kéo bi cái',
      summaryEn:
          'Preserve backspin to bring the cue ball backward after contact.',
      summaryVi: 'Giữ xoáy lùi để bi cái quay ngược sau va chạm.',
      actionEn:
          'Strike below center with a level, accelerating cue and enough backspin to survive the trip to the object ball.',
      actionVi:
          'Đánh dưới tâm với cơ tương đối ngang, tăng tốc mượt và tạo đủ xoáy lùi còn lại khi tới bi mục tiêu.',
      causeEn:
          'Residual backspin reverses the cue ball after its forward speed is reduced by the collision.',
      causeVi:
          'Xoáy lùi còn lại kéo bi cái quay ngược sau khi tốc độ tiến bị giảm bởi va chạm.',
      principleEn:
          'Draw depends on spin at impact, not simply on hitting low or hard.',
      principleVi:
          'Kéo bi phụ thuộc xoáy còn lại lúc va chạm, không chỉ là đánh thấp hoặc mạnh.',
      sourceId: 'source.drdave.cue_control',
      aliases: ['draw shot', 'backspin', 'keo bi'],
      relations: ['control.stop_shot', 'control.speed'],
    ),
    entry(
      id: 'control.speed',
      kind: 'technique',
      level: 'fundamental',
      topic: 'cue_ball_control',
      titleEn: 'Speed control',
      titleVi: 'Kiểm soát tốc độ',
      summaryEn:
          'Deliver repeatable cue-ball travel instead of relying on one vague soft or hard stroke.',
      summaryVi:
          'Tạo cự ly chạy bi cái lặp lại thay vì chỉ cảm nhận mơ hồ nhẹ hoặc mạnh.',
      actionEn:
          'Practice fixed routes at several named speeds and judge the final resting zone, not only whether the ball was pocketed.',
      actionVi:
          'Tập cùng một đường bi ở vài mức tốc độ có tên và đánh giá vùng dừng cuối, không chỉ việc bi có vào lỗ.',
      causeEn:
          'Position errors often come from excess or missing speed even when aim is correct.',
      causeVi:
          'Lỗi điều bi thường đến từ thừa hoặc thiếu tốc độ dù đường ngắm đúng.',
      principleEn:
          'Speed is part of shot selection because it changes position, throw, spin retention, and pocket acceptance.',
      principleVi:
          'Tốc độ là một phần của lựa chọn cú vì nó ảnh hưởng thế bi, độ ném, lượng xoáy còn lại và độ nhận lỗ.',
      sourceId: 'source.drdave.cue_control',
      aliases: ['speed control', 'pace', 'luc danh'],
      relations: ['control.stop_shot', 'position.zone_planning'],
      drillRefs: ['position'],
    ),
    entry(
      id: 'control.tangent_line',
      kind: 'concept',
      level: 'intermediate',
      topic: 'cue_ball_control',
      titleEn: 'Tangent line',
      titleVi: 'Đường tiếp tuyến',
      summaryEn:
          'Use the stun-path reference to predict the cue ball immediately after contact.',
      summaryVi:
          'Dùng đường đi của cú stun để dự đoán bi cái ngay sau va chạm.',
      actionEn:
          'For a sliding cue ball, visualize the initial path roughly perpendicular to the object-ball line, then adjust for follow or draw.',
      actionVi:
          'Với bi cái đang trượt, hình dung đường đi ban đầu gần vuông góc với đường bi mục tiêu rồi hiệu chỉnh theo xoáy tiến hoặc lùi.',
      causeEn:
          'At impact, the normal component transfers while the tangential component continues with the cue ball.',
      causeVi:
          'Khi va chạm, thành phần pháp tuyến được truyền đi còn thành phần tiếp tuyến tiếp tục cùng bi cái.',
      principleEn:
          'The tangent line is an initial reference; rolling, backspin, speed, and subsequent rails curve or redirect the route.',
      principleVi:
          'Tiếp tuyến là mốc ban đầu; lăn, xoáy lùi, tốc độ và băng sau đó sẽ bẻ cong hoặc đổi đường.',
      sourceId: 'source.drdave.cue_control',
      aliases: ['90 degree rule', 'tangent line', 'tiep tuyen'],
      relations: [
        'control.stop_shot',
        'control.follow_shot',
        'control.draw_shot'
      ],
    ),
    entry(
      id: 'position.zone_planning',
      kind: 'strategy',
      level: 'fundamental',
      topic: 'position_play',
      titleEn: 'Position zones',
      titleVi: 'Vùng điều bi',
      summaryEn:
          'Plan for a useful area rather than an unrealistically exact cue-ball point.',
      summaryVi:
          'Lập kế hoạch vào một vùng hữu ích thay vì một điểm bi cái chính xác thiếu thực tế.',
      actionEn:
          'Mark the acceptable angle range for the next ball, choose the largest safe zone, and select speed and route to enter it.',
      actionVi:
          'Xác định khoảng góc chấp nhận cho bi tiếp theo, chọn vùng an toàn lớn nhất rồi chọn tốc độ và đường vào vùng.',
      causeEn:
          'A zone tolerates normal execution variation while preserving the next shot.',
      causeVi:
          'Một vùng cho phép sai số thực hiện bình thường mà vẫn giữ được cú tiếp theo.',
      principleEn:
          'Good position maximizes margin and future options, not visual perfection.',
      principleVi:
          'Thế bi tốt tối đa hóa biên an toàn và lựa chọn tiếp theo, không phải vẻ hoàn hảo.',
      sourceId: 'source.drdave.strategy',
      aliases: ['position zone', 'vung dieu bi'],
      relations: ['control.speed', 'strategy.pattern.three_ball'],
      drillRefs: ['position'],
    ),
    entry(
      id: 'strategy.pattern.three_ball',
      kind: 'strategy',
      level: 'intermediate',
      topic: 'pattern_play',
      titleEn: 'Three-ball planning',
      titleVi: 'Lập kế hoạch ba bi',
      summaryEn:
          'Choose the current shot by considering the next shot and the one after it.',
      summaryVi: 'Chọn cú hiện tại bằng cách xét cú tiếp theo và cú sau nữa.',
      actionEn:
          'Identify the key ball, work backward three balls, and prefer routes that keep natural angles and avoid crossing small zones.',
      actionVi:
          'Xác định bi then chốt, tính ngược ba bi và ưu tiên đường giữ góc tự nhiên, tránh cắt ngang vùng nhỏ.',
      causeEn:
          'Looking one ball farther prevents a good immediate position from creating a difficult transition later.',
      causeVi:
          'Nhìn xa thêm một bi tránh việc có thế tốt ngay trước mắt nhưng chuyển tiếp khó ở cú sau.',
      principleEn:
          'Pattern play is constraint management: angle, speed, traffic, and recovery options matter together.',
      principleVi:
          'Đi bài là quản lý ràng buộc: góc, tốc độ, bi cản và phương án cứu phải được xét cùng nhau.',
      sourceId: 'source.drdave.strategy',
      aliases: ['pattern play', 'three ball plan', 'di bai'],
      relations: ['position.zone_planning', 'strategy.safety.objective'],
    ),
    entry(
      id: 'strategy.safety.objective',
      kind: 'strategy',
      level: 'fundamental',
      topic: 'safety',
      titleEn: 'Safety objective',
      titleVi: 'Mục tiêu của cú thủ',
      summaryEn:
          'Leave the opponent a low-percentage shot while controlling both balls and risk.',
      summaryVi:
          'Để đối thủ một cú xác suất thấp bằng cách kiểm soát cả hai bi và rủi ro.',
      actionEn:
          'Before shooting, choose where the cue ball and object ball should finish and what reply you are willing to allow.',
      actionVi:
          'Trước khi đánh, chọn vùng dừng cho cả bi cái lẫn bi mục tiêu và xác định cú trả nào có thể chấp nhận.',
      causeEn:
          'Controlling only one ball often leaves an easy bank, kick, or direct shot.',
      causeVi:
          'Chỉ kiểm soát một bi thường để lại cú băng, đá hoặc cú thẳng dễ.',
      principleEn:
          'A safety is successful by the quality of the opponent response it forces, not by whether it looks hidden.',
      principleVi:
          'Cú thủ thành công được đo bằng chất lượng cú trả buộc đối thủ phải chơi, không chỉ bằng việc có che khuất hay không.',
      sourceId: 'source.drdave.strategy',
      aliases: ['safety', 'defense', 'danh thu'],
      relations: ['strategy.safety.distance', 'strategy.pattern.three_ball'],
      drillRefs: ['safety'],
    ),
    entry(
      id: 'strategy.safety.distance',
      kind: 'strategy',
      level: 'intermediate',
      topic: 'safety',
      titleEn: 'Distance and separation',
      titleVi: 'Khoảng cách và tách bi khi thủ',
      summaryEn:
          'Use distance and ball separation to reduce the opponent margin for error.',
      summaryVi:
          'Dùng khoảng cách và độ tách bi để giảm biên sai số của đối thủ.',
      actionEn:
          'When a full hook is risky, send the cue ball and object ball to different areas and maximize the length of the next shot.',
      actionVi:
          'Khi che kín quá rủi ro, đưa bi cái và bi mục tiêu về hai vùng khác nhau và kéo dài cự ly cú tiếp theo.',
      causeEn:
          'Longer distance magnifies aiming and speed errors and can make position recovery harder.',
      causeVi:
          'Cự ly dài khuếch đại lỗi ngắm và tốc độ, đồng thời làm điều bi hồi phục khó hơn.',
      principleEn:
          'Effective safety combines obstruction, distance, rail position, and limited return options.',
      principleVi:
          'Cú thủ hiệu quả kết hợp che bi, khoảng cách, vị trí sát băng và hạn chế phương án trả.',
      sourceId: 'source.drdave.strategy',
      aliases: ['distance safety', 'tach bi'],
      relations: ['strategy.safety.objective', 'control.speed'],
      drillRefs: ['safety'],
    ),
    entry(
      id: 'break.controlled_power',
      kind: 'technique',
      level: 'fundamental',
      topic: 'break',
      titleEn: 'Controlled break',
      titleVi: 'Cú phá bi có kiểm soát',
      summaryEn:
          'Prioritize a square hit, legal requirements, and cue-ball control before maximum speed.',
      summaryVi:
          'Ưu tiên chạm chuẩn, yêu cầu hợp lệ và kiểm soát bi cái trước tốc độ tối đa.',
      actionEn:
          'Use a stable bridge and balanced finish, strike the intended rack ball accurately, and observe the cue ball and spread after every break.',
      actionVi:
          'Dùng cầu tay ổn định và kết thúc cân bằng, đánh chính xác bi mục tiêu trong rack rồi quan sát bi cái và độ tản sau mỗi cú phá.',
      causeEn:
          'Extra speed is wasted when the hit is inaccurate or the cue ball scratches.',
      causeVi: 'Tốc độ tăng thêm bị lãng phí nếu chạm sai hoặc bi cái vào lỗ.',
      principleEn:
          'The best break is game- and table-dependent; optimize repeatable outcomes rather than raw power.',
      principleVi:
          'Cú phá tốt phụ thuộc nội dung và bàn; tối ưu kết quả lặp lại thay vì sức mạnh thô.',
      sourceId: 'source.drdave.break',
      aliases: ['break shot', 'pha bi'],
      relations: ['fundamental.stroke.delivery', 'control.speed'],
      drillRefs: ['break'],
    ),
    entry(
      id: 'rule.legal_shot.basic',
      kind: 'rule',
      level: 'beginner',
      topic: 'rules',
      titleEn: 'Legal shot basics',
      titleVi: 'Điều kiện cơ bản của cú hợp lệ',
      summaryEn:
          'Contact the required ball first and then satisfy the pocket-or-rail requirement unless a rule exception applies.',
      summaryVi:
          'Chạm đúng bi yêu cầu trước, sau đó đáp ứng điều kiện vào lỗ hoặc chạm băng trừ khi luật có ngoại lệ.',
      actionEn:
          'Identify the legal first-contact ball before shooting and verify that a ball is pocketed or reaches a rail after contact.',
      actionVi:
          'Xác định bi phải chạm đầu tiên trước khi đánh và kiểm tra có bi vào lỗ hoặc chạm băng sau tiếp xúc.',
      causeEn:
          'These conditions distinguish a completed legal stroke from a no-rail or wrong-ball foul.',
      causeVi:
          'Các điều kiện này phân biệt cú hợp lệ với lỗi không chạm băng hoặc chạm sai bi.',
      principleEn:
          'Game-specific rules and announced-shot requirements still apply, so use the active rule set.',
      principleVi:
          'Luật riêng từng nội dung và yêu cầu gọi cú vẫn áp dụng, vì vậy phải dùng đúng bộ luật đang thi đấu.',
      sourceId: 'source.wpa.rules',
      aliases: ['legal shot', 'cu hop le'],
      relations: ['rule.rail_after_contact', 'rule.scratch.basic'],
    ),
    entry(
      id: 'rule.rail_after_contact',
      kind: 'rule',
      level: 'beginner',
      topic: 'rules',
      titleEn: 'Rail after contact',
      titleVi: 'Chạm băng sau tiếp xúc',
      summaryEn:
          'When no ball is pocketed, at least one ball generally must reach a rail after legal first contact.',
      summaryVi:
          'Khi không có bi vào lỗ, thông thường ít nhất một bi phải chạm băng sau lần chạm hợp lệ đầu tiên.',
      actionEn:
          'Plan enough speed for the cue ball or an object ball to reach a rail after the required first contact.',
      actionVi:
          'Tính đủ tốc độ để bi cái hoặc một bi mục tiêu chạm băng sau lần chạm đúng đầu tiên.',
      causeEn:
          'A pre-contact rail does not by itself satisfy the post-contact requirement.',
      causeVi:
          'Việc chạm băng trước tiếp xúc tự nó không đáp ứng điều kiện băng sau tiếp xúc.',
      principleEn:
          'Check the exact game rules for exceptions such as a legal push out.',
      principleVi:
          'Đối chiếu luật nội dung cụ thể cho các ngoại lệ như push out hợp lệ.',
      sourceId: 'source.wpa.rules',
      aliases: ['no rail foul', 'loi khong bang'],
      relations: ['rule.legal_shot.basic', 'rule.nine_ball.push_out'],
    ),
    entry(
      id: 'rule.nine_ball.push_out',
      kind: 'rule',
      level: 'intermediate',
      topic: 'nine_ball_rules',
      titleEn: 'Nine-ball push out',
      titleVi: 'Push out trong 9 bi',
      summaryEn:
          'After a legal break, the incoming player may announce a push out under nine-ball rules.',
      summaryVi:
          'Sau cú phá hợp lệ, người vào bàn có thể thông báo push out theo luật 9 bi.',
      actionEn:
          'Announce the push out before the shot; afterward the opponent chooses who takes the next shot.',
      actionVi:
          'Thông báo push out trước cú đánh; sau đó đối thủ chọn ai sẽ thực hiện cú tiếp theo.',
      causeEn:
          'The option provides a controlled response when the post-break layout offers no reasonable legal attack.',
      causeVi:
          'Lựa chọn này tạo cách xử lý có kiểm soát khi thế bi sau phá không có cú tấn công hợp lý.',
      principleEn:
          'Push-out restrictions and consequences are specific to nine-ball and the current WPA rule wording.',
      principleVi:
          'Giới hạn và hệ quả của push out dành riêng cho 9 bi và phải theo câu chữ luật WPA hiện hành.',
      sourceId: 'source.wpa.rules',
      aliases: ['push out', 'push-out', 'day bi'],
      relations: ['rule.legal_shot.basic', 'rule.rail_after_contact'],
    ),
    entry(
      id: 'mistake.head_movement',
      kind: 'commonMistake',
      level: 'beginner',
      topic: 'stroke_errors',
      titleEn: 'Moving up during delivery',
      titleVi: 'Nhổm đầu khi ra cơ',
      summaryEn:
          'Body or head movement during the final stroke can disturb the cue line.',
      summaryVi:
          'Chuyển động đầu hoặc thân trong nhịp cuối có thể làm lệch đường cơ.',
      actionEn:
          'Finish the stroke, hold the body position briefly, and let the eyes observe before standing up.',
      actionVi:
          'Hoàn thành cú ra cơ, giữ thân người ngắn một nhịp rồi quan sát trước khi đứng lên.',
      causeEn:
          'Early movement changes the stable reference used by the bridge, grip, and eyes.',
      causeVi: 'Nhổm sớm làm thay đổi mốc ổn định của cầu tay, tay cầm và mắt.',
      principleEn:
          'Staying down is useful because it preserves delivery conditions, not because stillness after impact changes the ball.',
      principleVi:
          'Giữ người có ích vì bảo toàn điều kiện ra cơ, không phải vì đứng yên sau va chạm làm đổi đường bi.',
      sourceId: 'source.drdave.fundamentals',
      aliases: ['lifting head', 'nhom dau'],
      relations: ['fundamental.stance.basic', 'fundamental.stroke.delivery'],
    ),
    entry(
      id: 'mistake.cue_steering',
      kind: 'commonMistake',
      level: 'fundamental',
      topic: 'stroke_errors',
      titleEn: 'Steering the cue',
      titleVi: 'Lái cơ khi ra cơ',
      summaryEn:
          'A late sideways correction redirects the cue instead of fixing the original aim.',
      summaryVi:
          'Hiệu chỉnh ngang ở phút cuối làm đổi hướng cơ thay vì sửa đường ngắm ban đầu.',
      actionEn:
          'If the picture looks wrong while down, stand up and restart instead of forcing the cue onto a new line.',
      actionVi:
          'Nếu hình ngắm sai khi đã cúi, hãy đứng lên làm lại thay vì ép cơ sang đường mới.',
      causeEn:
          'The body attempts to rescue uncertain aim during acceleration, creating side motion.',
      causeVi:
          'Cơ thể cố cứu đường ngắm thiếu chắc chắn trong lúc tăng tốc và tạo chuyển động ngang.',
      principleEn:
          'Decision and alignment belong before delivery; the final stroke should execute, not redesign, the shot.',
      principleVi:
          'Quyết định và căn chỉnh phải xong trước khi ra cơ; nhịp cuối dùng để thực hiện, không thiết kế lại cú.',
      sourceId: 'source.drdave.fundamentals',
      aliases: ['steering', 'cue swipe', 'lai co'],
      relations: [
        'fundamental.alignment.visual',
        'fundamental.routine.pre_shot'
      ],
    ),
    entry(
      id: 'equipment.chalk.tip',
      kind: 'equipment',
      level: 'beginner',
      topic: 'equipment',
      titleEn: 'Chalk and tip contact',
      titleVi: 'Lơ và bề mặt đầu cơ',
      summaryEn:
          'Maintain an even chalk layer and a serviceable tip to reduce avoidable miscues.',
      summaryVi:
          'Giữ lớp lơ đều và đầu cơ hoạt động tốt để giảm trượt cơ có thể tránh.',
      actionEn:
          'Inspect the tip, apply chalk evenly without drilling the cube, and rechalk before shots with meaningful tip offset.',
      actionVi:
          'Kiểm tra đầu cơ, thoa lơ đều không khoan sâu viên lơ và thoa lại trước cú chạm lệch tâm đáng kể.',
      causeEn:
          'Chalk increases friction capacity at the tip-ball contact, while damaged tip shape reduces reliable contact.',
      causeVi:
          'Lơ tăng khả năng ma sát tại tiếp xúc đầu cơ-bi, còn đầu cơ hỏng làm tiếp xúc kém tin cậy.',
      principleEn:
          'Chalk supports sound technique; it cannot compensate for excessive offset or an inaccurate stroke.',
      principleVi:
          'Lơ hỗ trợ kỹ thuật đúng; nó không bù được chạm quá lệch tâm hoặc cú ra cơ thiếu chính xác.',
      sourceId: 'source.drdave.fundamentals',
      aliases: ['chalk', 'cue tip', 'lo dau co'],
      relations: ['fundamental.stroke.delivery', 'control.draw_shot'],
    ),
    entry(
      id: 'mental.reset_after_error',
      kind: 'mental',
      level: 'fundamental',
      topic: 'mental_game',
      titleEn: 'Reset after an error',
      titleVi: 'Đặt lại sau lỗi',
      summaryEn:
          'Separate a completed mistake from the decision required on the next opportunity.',
      summaryVi:
          'Tách lỗi đã xảy ra khỏi quyết định cần thực hiện ở cơ hội tiếp theo.',
      actionEn:
          'Name one factual lesson, release the previous result, breathe once, and restart the normal pre-shot routine.',
      actionVi:
          'Gọi tên một bài học thực tế, bỏ kết quả cũ, thở một nhịp rồi khởi động lại quy trình trước cú.',
      causeEn:
          'A short reset prevents emotional replay from consuming attention needed for the current table.',
      causeVi:
          'Nhịp đặt lại ngắn ngăn việc tua lại cảm xúc chiếm sự chú ý cần cho thế bàn hiện tại.',
      principleEn:
          'Useful reflection is specific and time-bounded; technical analysis belongs after the match when possible.',
      principleVi:
          'Rút kinh nghiệm hữu ích phải cụ thể và có giới hạn; phân tích kỹ thuật nên để sau trận khi có thể.',
      sourceId: 'source.drdave.strategy',
      aliases: ['mental reset', 'reset routine', 'bo qua loi'],
      relations: [
        'fundamental.routine.pre_shot',
        'strategy.pattern.three_ball'
      ],
    ),
  ];

  final stopShot = additions.singleWhere(
    (item) => item['id'] == 'control.stop_shot',
  );
  final stopShotLayers = stopShot['layers'] as List<Map<String, Object>>;
  stopShotLayers.addAll(<Map<String, Object>>[
    {
      'depth': 'physics',
      'heading': text('Physics model', 'Mô hình vật lý'),
      'paragraphs': [
        text(
          'At object-ball impact, the cue ball has forward linear velocity but approximately no forward or backward angular tendency. In an ideal full collision between equal-mass balls, most momentum along the collision normal transfers to the object ball. Residual topspin or backspin makes the cue ball creep forward or draw back.',
          'Khi chạm bi mục tiêu, bi cái có vận tốc tịnh tiến về phía trước nhưng gần như không còn xu hướng xoáy tiến hoặc xoáy lùi. Trong va chạm đầy lý tưởng giữa hai bi cùng khối lượng, phần lớn động lượng theo pháp tuyến va chạm truyền sang bi mục tiêu. Xoáy tiến hoặc xoáy lùi còn dư sẽ làm bi cái trôi tới hoặc kéo về.',
        ),
        text(
          'Cloth friction changes the cue ball angular velocity before impact. Therefore the required tip offset depends on shot distance, speed, cloth, and ball condition. The useful target is near-zero rolling tendency at impact, not one universal tip position.',
          'Ma sát nỉ làm thay đổi vận tốc góc của bi cái trước va chạm. Vì vậy độ lệch đầu cơ cần thiết phụ thuộc cự ly, tốc độ, nỉ và tình trạng bi. Mục tiêu hữu ích là xu hướng lăn gần bằng không tại va chạm, không phải một vị trí đầu cơ cố định cho mọi cú.',
        ),
      ],
      'keyPoints': [
        text(
          'Momentum is transferred mainly along the collision normal.',
          'Động lượng chủ yếu truyền theo pháp tuyến va chạm.',
        ),
        text(
          'Residual angular velocity determines forward or backward drift.',
          'Vận tốc góc còn dư quyết định bi trôi tới hay kéo về.',
        ),
      ],
    },
    {
      'depth': 'engine',
      'heading': text('Simulation model', 'Mô hình mô phỏng'),
      'paragraphs': [
        text(
          'Represent each ball with position, linear velocity, angular velocity, radius, mass, and material coefficients. Integrate cloth sliding and rolling resistance until contact, resolve the ball-ball impulse along the collision normal with restitution and contact friction, then continue the simulation with the post-collision state.',
          'Biểu diễn mỗi bi bằng vị trí, vận tốc tịnh tiến, vận tốc góc, bán kính, khối lượng và các hệ số vật liệu. Tích phân lực cản trượt và lăn của nỉ tới lúc tiếp xúc, giải xung lực bi-bi theo pháp tuyến va chạm với hệ số đàn hồi và ma sát tiếp xúc, rồi tiếp tục mô phỏng từ trạng thái sau va chạm.',
        ),
        text(
          'Classify the result as a stop shot when cue-ball speed remains below a calibrated threshold for a short time after impact. Use a fixed time step or continuous collision detection so fast balls do not pass through each other between frames.',
          'Phân loại là cú dừng khi tốc độ bi cái duy trì dưới một ngưỡng đã hiệu chỉnh trong khoảng ngắn sau va chạm. Dùng bước thời gian cố định hoặc phát hiện va chạm liên tục để bi chạy nhanh không xuyên qua nhau giữa hai khung hình.',
        ),
      ],
      'keyPoints': [
        text(
          'State: position, linear velocity, angular velocity, and material properties.',
          'Trạng thái: vị trí, vận tốc tịnh tiến, vận tốc góc và thuộc tính vật liệu.',
        ),
        text(
          'Pipeline: integrate motion, detect contact, resolve impulse, classify outcome.',
          'Chuỗi tính: tích phân chuyển động, phát hiện tiếp xúc, giải xung lực, phân loại kết quả.',
        ),
      ],
    },
  ]);

  final entries = (pack['entries'] as List).cast<Map<String, dynamic>>();
  final addedIds = additions.map((item) => item['id']).toSet();
  entries.removeWhere((item) => addedIds.contains(item['id']));
  entries.addAll(additions);

  final legacyLayers = <String, List<Map<String, dynamic>>>{
    'term.cue_ball': [
      {
        'depth': 'cause',
        'heading': text('Why the term matters', 'Vì sao thuật ngữ quan trọng'),
        'paragraphs': [
          text(
            'The cue ball is the only ball struck directly by the cue in normal play, so many fouls and control concepts refer specifically to it.',
            'Bi cái là bi duy nhất được đầu cơ đánh trực tiếp trong diễn biến thông thường, nên nhiều lỗi và khái niệm điều khiển gắn riêng với nó.',
          )
        ],
      },
      {
        'depth': 'principles',
        'heading': text('Rule principle', 'Nguyên lý luật'),
        'paragraphs': [
          text(
            'The game rules determine where the cue ball may be placed, which ball it must contact first, and what happens after a foul.',
            'Luật từng nội dung xác định nơi được đặt bi cái, bi phải chạm đầu tiên và hệ quả sau lỗi.',
          )
        ],
      },
    ],
    'term.object_ball': [
      {
        'depth': 'cause',
        'heading': text('Why the term matters', 'Vì sao thuật ngữ quan trọng'),
        'paragraphs': [
          text(
            'Calling a ball an object ball separates the intended target from the cue ball used to deliver the shot.',
            'Gọi một bi là bi mục tiêu giúp phân biệt đích của cú đánh với bi cái dùng để thực hiện cú.',
          )
        ],
      },
      {
        'depth': 'principles',
        'heading': text('Rule principle', 'Nguyên lý luật'),
        'paragraphs': [
          text(
            'Which object ball is legal, called, or scoring depends on the discipline and current table state.',
            'Bi mục tiêu nào hợp lệ, cần gọi hoặc ghi điểm phụ thuộc nội dung và trạng thái bàn hiện tại.',
          )
        ],
      },
    ],
    'rule.scratch.basic': [
      {
        'depth': 'cause',
        'heading': text('Why it is a foul', 'Vì sao đây là lỗi'),
        'paragraphs': [
          text(
            'Pocketing or driving the cue ball off the table removes the ball required to continue legal play.',
            'Đưa bi cái vào lỗ hoặc ra khỏi bàn làm mất quả bi cần thiết để tiếp tục lượt chơi hợp lệ.',
          )
        ],
      },
      {
        'depth': 'principles',
        'heading': text('Rule principle', 'Nguyên lý luật'),
        'paragraphs': [
          text(
            'A scratch is consistently a foul, but cue-ball placement and other consequences must be read from the active game rules.',
            'Scratch luôn là lỗi, nhưng vị trí đặt lại bi cái và hệ quả khác phải theo luật nội dung đang áp dụng.',
          )
        ],
      },
    ],
    'rule.ball_in_hand': [
      {
        'depth': 'cause',
        'heading': text('Why it matters', 'Vì sao quyền này quan trọng'),
        'paragraphs': [
          text(
            'Placement lets the incoming player choose a legal starting position after the preceding foul.',
            'Quyền đặt bi cho phép người vào bàn chọn vị trí bắt đầu hợp lệ sau lỗi của lượt trước.',
          )
        ],
      },
      {
        'depth': 'principles',
        'heading': text('Rule principle', 'Nguyên lý luật'),
        'paragraphs': [
          text(
            'The allowed placement area is defined by the game and situation; it should never be assumed without checking the rule set.',
            'Phạm vi được đặt bi do nội dung và tình huống quy định; không nên tự giả định nếu chưa kiểm tra bộ luật.',
          )
        ],
      },
    ],
  };
  for (final item in entries) {
    final extension = legacyLayers[item['id']];
    if (extension == null) continue;
    final layers = (item['layers'] as List).cast<Map<String, dynamic>>();
    layers.removeWhere(
      (layer) => layer['depth'] == 'cause' || layer['depth'] == 'principles',
    );
    layers.addAll(extension);
    item['revision'] = 2;
  }

  pack['paths'] = [
    path(
      id: 'path.beginner.fundamentals',
      titleEn: 'Beginner fundamentals',
      titleVi: 'Nền tảng cho người mới',
      descriptionEn: 'Build a repeatable setup, aim, and straight delivery.',
      descriptionVi:
          'Xây dựng tư thế, đường ngắm và cú ra cơ thẳng có thể lặp lại.',
      level: 'beginner',
      steps: [
        'fundamental.stance.basic',
        'fundamental.bridge.open',
        'fundamental.grip.relaxed',
        'fundamental.alignment.visual',
        'fundamental.routine.pre_shot',
        'fundamental.pause.delivery',
        'fundamental.stroke.delivery',
        'control.stop_shot'
      ],
    ),
    path(
      id: 'path.fundamental.cue_control',
      titleEn: 'Cue-ball control',
      titleVi: 'Kiểm soát bi cái',
      descriptionEn:
          'Progress from stop to follow, draw, speed, and position zones.',
      descriptionVi:
          'Tiến từ dừng bi tới xoáy tiến, kéo, tốc độ và vùng điều bi.',
      level: 'fundamental',
      steps: [
        'control.stop_shot',
        'control.follow_shot',
        'control.draw_shot',
        'control.tangent_line',
        'control.speed',
        'position.zone_planning'
      ],
    ),
    path(
      id: 'path.intermediate.pattern_safety',
      titleEn: 'Aiming, patterns, and safety',
      titleVi: 'Ngắm, đi bài và đánh thủ',
      descriptionEn:
          'Connect potting geometry to position routes and defensive choices.',
      descriptionVi:
          'Kết nối hình học vào lỗ với đường điều bi và lựa chọn phòng thủ.',
      level: 'intermediate',
      steps: [
        'aim.ghost_ball',
        'aim.cut_angle',
        'physics.throw.awareness',
        'position.zone_planning',
        'strategy.pattern.three_ball',
        'strategy.safety.objective',
        'strategy.safety.distance'
      ],
    ),
    path(
      id: 'path.beginner.match_essentials',
      titleEn: 'Match essentials',
      titleVi: 'Kiến thức thiết yếu khi thi đấu',
      descriptionEn:
          'Learn core rules, a controlled break, and a practical mental reset.',
      descriptionVi:
          'Học luật cốt lõi, cú phá có kiểm soát và cách đặt lại tâm lý thực tế.',
      level: 'beginner',
      steps: [
        'term.cue_ball',
        'term.object_ball',
        'rule.legal_shot.basic',
        'rule.rail_after_contact',
        'rule.scratch.basic',
        'rule.ball_in_hand',
        'break.controlled_power',
        'mental.reset_after_error'
      ],
    ),
  ];

  file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(pack)}\n');
}
