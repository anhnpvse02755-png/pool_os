# Billiard Knowledge V2 Actions

## Mục đích

File này chuyển feedback UAT về Billiard Knowledge thành đầu việc có thể giao
cho Codex/Claude/Cursor. Đây không phải Bible, RFC hay roadmap mới. Không đặt mục
tiêu "viết thêm 100 bài"; mục tiêu là chứng minh một hệ thống Layered Knowledge
có thể tìm kiếm, giảng dạy, liên kết Coach và mở rộng cho AI Vision.

## Kết luận sản phẩm

Knowledge V2 có bốn trục độc lập. Không gộp chúng thành một enum `level`:

1. `ExplanationDepth`: Level 1 Làm theo, Level 2 Vì sao, Level 3 Nguyên lý,
   Level 4 Vật lý, Level 5 Engine.
2. `Audience`: beginner đến professional, quyết định nội dung mặc định và độ
   khó bài tập.
3. `KnowledgeContext`: foundation, execution, practical, match, coach và pro.
4. `EvidenceSource`: manual log, drill result, match data, video hoặc table
   image; quyết định Coach được phép kết luận tới đâu.

Beginner Mode và Pro Mode là hai cách truy cập cùng một knowledge graph, không
phải hai thư viện bài viết trùng nhau.

`Audience` không đồng nhất với `ExplanationDepth`. Trình độ quyết định biến thể
nội dung và depth mở mặc định: beginner thấy điểm chạm/hành động; H-G hỏi cơ chế;
G+ thấy tác động của lực/cự ly; A thấy tương tác với thiết bị; Pro có thể đi tới
thực nghiệm, phương trình và mô hình. H-G/G+/A là hệ xếp hạng theo cộng đồng nên
phải map qua một `ProficiencyBand` ổn định, không hard-code các nhãn này như một
chuẩn toàn cầu.

Một technique không còn là trang dẫn thẳng tới drill. Nó là một hub trong graph:

`Technique -> Common mistake -> Physics/Math -> Real match -> Mental ->`
`Equipment -> Media -> AI analysis -> Drill -> Learning path -> Coach`

Các phần trên là `facet` và relation của knowledge graph, không phải thêm 11
explanation level. Ví dụ Stop Shot vẫn có năm mức giải thích, nhưng mỗi mức có
thể liên kết sang ảnh hưởng của lực, khoảng cách, đầu cơ, mặt nỉ, lỗi thực hiện,
tình huống trận và bài tập phù hợp.

Chiều sâu không được đo bằng độ dài bài. Một nhánh sâu phải trả lời được:

- Kiến thức này đúng trong điều kiện nào và thay đổi khi biến số nào đổi?
- Người chơi ở trình độ này cần hành động gì, hiểu gì và chưa cần thấy gì?
- Kết luận dựa trên nguồn/evidence nào và mức chắc chắn ra sao?
- Học xong đo bằng cách nào, có chuyển được sang trận thật hay không?

Các ví dụ vật lý do người dùng/Coach nêu là giả thuyết cần kiểm chứng. Chẳng hạn
không được mặc định viết "đầu cơ mềm có thời gian tiếp xúc dài hơn nên..." thành
sự thật nếu chưa có nguồn thực nghiệm phù hợp và effect size có ý nghĩa. Physics
sai nhưng trình bày sâu vẫn là knowledge kém.

## Baseline đã kiểm chứng ngày 2026-07-19

- Package hiện có 32 bài, 4 learning path và 5 explanation depth trong schema.
- Tất cả bài reviewed có Level 1-3; chỉ Stop Shot có Level 4-5.
- `KnowledgeEntry` đã có aliases, examples, `whenToUse`, mistakes, drill refs,
  media, relations, source và review state.
- Dữ liệu thực tế có 0/32 bài dùng `whenToUse`, 6/32 bài nối drill, 6/32 bài có
  mistake guide và 0/32 bài có media.
- Trong 26 thuật ngữ mẫu từ UAT, chỉ `throw` có kết quả. 25 thuật ngữ còn lại
  chưa có: mềm tay, cứng tay, dứt tay, đẩy cơ, chích, quăng tay, ghì cơ, kéo cơ,
  thả cơ, đi xuyên, chạm bi, ra ngắn, ra dài, trô, cu lê, 1/2/3 tip, spin chết,
  spin sống, squirt, swerve, deflection, inside English và outside English.
- Coach có `KnowledgeRegistry`, nhưng mới chỉ có bốn article mapping chính xác;
  phần lớn recommendation rơi về nhóm drill.
- `CoachAction` chỉ mang `knowledgeId`; chưa chỉ được section, lỗi, checklist hay
  mức giải thích cần mở.
- Match chỉ ghi một miss reason do người dùng chọn. Không đủ dữ liệu để tự kết
  luận sai cầu tay, tempo, cue path hoặc head movement.
- Drill đã có instructions, target score, repetition, common mistakes và table
  layout dạng text. Knowledge chưa có assessment criteria và layout có cấu trúc.
- Skill hiện là điểm tổng hợp theo nhóm rộng như Stroke/Position/Pattern, có
  history nhưng không có prerequisite graph hoặc mastery theo knowledge node.
- Không có bảng Coach memory/assignment history. Coach dựng recent/prior trend
  từ dữ liệu, nhưng chưa nhớ một điểm yếu theo chủ đề trong nhiều tháng và chưa
  có cơ chế giảm lặp recommendation.
- Pack có `packVersion` và mỗi entry có `revision`; chưa có changelog có cấu trúc
  hoặc màn hình "Có gì mới".
- Match Objective đã được lưu và chấm theo trọng số Win 70/30,
  Training 20/80, Mixed 50/50. Phản hồi hiện mới giải thích trọng số và dùng
  accuracy tổng quát; chưa đánh giá riêng Position/Routine/Spin/Pattern theo
  mục tiêu như ví dụ Race to 9.
- Chưa có pipeline video, nhận dạng bi, tái dựng bàn, mô phỏng hay bot chơi bida.

## Phạm vi V2

V2 phải hoàn thành bảy vertical slice dưới đây theo thứ tự. Mỗi slice phải chạy
được end-to-end trước khi mở rộng số lượng nội dung.

### BK2-01 - Hợp đồng dữ liệu AI-ready

Mở rộng package hiện tại, không tạo knowledge model thứ hai.

Thêm các cấu trúc machine-readable tối thiểu:

- Stable `skillRefs` cho kỹ năng được cải thiện.
- `ProficiencyBand` và `AudienceVariant` để cùng một facet có hướng dẫn/độ sâu
  phù hợp trình độ mà không nhân bản toàn bộ entry.
- Stable ID cho content layer, mistake và checklist item để Coach deep-link.
- `PracticePrescription`: drill refs, repetitions/duration và instruction depth.
- `AssessmentCriterion`: metric ID, target, minimum attempts và đơn vị.
- `TriggerCondition`: signal ID, nguồn bằng chứng, điều kiện, minimum samples và
  minimum confidence.
- `KnowledgeScenario`: discipline, structured table state, shot objective và các
  lựa chọn có outcome/risk; dùng cho Practical/Pro và table-photo trong tương lai.
- `KnowledgeFacet` và typed relations để một technique liên kết được mistake,
  physics/math, match, mental, equipment, media, AI, drill, path và Coach mà
  không nhét mọi nội dung vào một object khổng lồ.
- `KnowledgeRelease`: semantic version, ngày phát hành, entry thêm/sửa/ngừng
  dùng và release note song ngữ. Entry revision phải truy ngược được release đã
  thay đổi nó.

Guardrail:

- Trigger metadata mô tả khi nào bài liên quan; Coach engine vẫn chịu trách
  nhiệm đánh giá dữ liệu và confidence.
- Không lưu câu lệnh AI hoặc text kết luận tự do làm business logic.
- Migration phải đọc được pack 1.x; field mới có default an toàn.

Acceptance:

- Validator bắt unknown skill/drill/article references, duplicate stable IDs và
  criterion thiếu metric/target.
- JSON round-trip và backward-compatibility tests đạt.
- Một bài mẫu có trigger, checklist, drill và assessment được render đầy đủ.
- Catalog hiển thị changelog giữa hai pack version và "Có gì mới" không dựa vào
  việc so sánh text tự do.

### BK2-02 - Vietnamese Billiard Glossary

Tạo first-class `terminology` entries; không chỉ giấu từ đời trong aliases của
bài tiếng Anh.

Seed bắt buộc là toàn bộ 26 thuật ngữ UAT ở baseline. Mỗi entry hoặc nhóm đồng
nghĩa phải có:

- Từ người chơi nói, biến thể vùng miền/cách viết và thuật ngữ chuẩn tương ứng.
- Nghĩa trong ngữ cảnh, dấu hiệu quan sát được và ví dụ câu nói ngoài bàn.
- Điều dễ hiểu sai; đặc biệt `1 tip`, `2 tip`, `3 tip` không được mô tả như đại
  lượng vật lý tuyệt đối.
- Relation tới kỹ thuật, common mistake và drill liên quan.
- Nguồn và review state. Thuật ngữ đời cần một vòng review với người chơi/HLV
  Việt Nam; nguồn tiếng Anh không đủ để xác minh cách dùng tiếng Việt.

Acceptance:

- Search không dấu tìm được mọi seed term và hiển thị thuật ngữ người chơi làm
  kết quả chính.
- Các cặp throw/squirt/swerve/deflection và trô/cu lê được phân biệt rõ.
- Test khóa toàn bộ seed term để generator không vô tình làm mất coverage.

### BK2-03 - Skill Tree + Mastery

Xây skill graph trên stable `skillRefs`, không dùng thứ tự cứng trong UI.

Vertical slice đầu tiên:

`Cue Ball Control -> Stop Shot -> Draw/Follow -> Natural Angle -> Side Spin ->`
`Three Rail Position`

Mỗi edge phải nêu loại quan hệ (`prerequisite`, `recommendedBefore`,
`advancedInto`) và mastery tối thiểu nếu có. Coach dùng graph để khuyến nghị:
người chưa ổn Draw không bị đẩy thẳng tới Force Follow. Đây là recommendation,
không phải khóa cứng; người dùng vẫn có thể mở bài nâng cao.

Mastery là trạng thái của `playerId + skillRef`, tách khỏi việc đã đọc. Tối thiểu
phải lưu/derive:

- Exposure: đã xem hoặc hoàn thành Level nào.
- Execution: kết quả drill theo assessment criterion.
- Consistency: lặp lại qua nhiều buổi và recency.
- Transfer: có cải thiện trong match/ghost hay chưa.
- Confidence/sample size: độ tin cậy của mastery.

Điểm hiển thị 0-100 là composite có version, không phải phần trăm nội dung đã
đọc. Khi thiếu mẫu phải hiện `provisional`, không hiển thị 55% như một số đo
chính xác giả tạo.

Acceptance:

- Graph validator bắt cycle prerequisite và unknown skill refs.
- Stop Shot đạt mastery không tự động làm Draw/Follow thành mastered.
- Mastery giảm confidence theo thời gian không tập nhưng không xóa lịch sử.
- Coach chọn prerequisite gần nhất chưa đạt và giải thích vì sao chưa đề xuất
  node nâng cao.
- Migration không trộn điểm Skill Dashboard hiện tại với Knowledge Mastery.

### BK2-04 - Beginner + Practical vertical slice

Hoàn thành một luồng học cho người mới từ foundation tới quyết định thực chiến:

1. Đứng, cầm cơ, cầu tay, ngắm và pre-shot routine.
2. Execution ở Level 1: làm gì, bi sẽ đi thế nào, làm bao nhiêu lần.
3. Checklist ngắn trước cú đánh; không hiển thị physics mặc định.
4. Drill có số lần lặp và tiêu chí pass/fail đo được.
5. Bốn scenario mẫu: stop hay follow; một băng hay ba băng; trái hay phải;
   inside hay outside English.

Mỗi scenario phải chứa setup bàn, mục tiêu, lựa chọn, trade-off và lý do phù hợp
với trình độ. Không viết quy tắc tuyệt đối khi đáp án phụ thuộc tốc độ bàn, góc,
traffic hoặc khả năng người chơi.

Acceptance:

- Beginner mở bài thấy Level 1 và prescription trước; Level 4-5 không cản luồng.
- Người dùng có thể đi `Knowledge -> Drill -> ghi kết quả -> đánh giá criterion`.
- Scenario UI cho phép so sánh ít nhất hai lựa chọn trên cùng setup.
- Không cần ảnh/video thật để pass slice này; structured placeholder hợp lệ.

### BK2-05 - Coach Knowledge closed loop + Memory

Thay mapping `knowledgeId -> article` đơn giản bằng hợp đồng deep-link:

`findingId -> articleId -> sectionId/depth -> checklist -> drill -> assessment`

Vertical slice đầu tiên dùng lỗi `lifting_head` vì dễ hiểu và phù hợp AI Vision
cấp 1 sau này. Nội dung khi bấm từ Coach phải hiện:

- Quan sát/evidence mà Coach thực sự có.
- Các nguyên nhân có thể xảy ra, không khẳng định nguyên nhân chưa được đo.
- Checklist sửa lỗi, sai thường gặp, media placeholder và drill.
- Tiêu chí đánh giá lại sau khi tập.

Sau đó mapping tám miss reason đang được lưu: aim, speed, position, english,
kick, rush, nerves và bad decision. Với manual miss reason, UI phải ghi rõ đây
là lý do người chơi đã chọn, không phải AI Vision phát hiện.

Acceptance:

- Mọi actionable Coach finding có destination hợp lệ hoặc fallback rõ ràng.
- Test thất bại nếu article/section/drill được mapping không tồn tại.
- Bấm Coach action mở đúng section và depth, không chỉ mở đầu bài hoặc danh mục.
- Coach không kết luận cue path/head/bridge/tempo từ dữ liệu Hit/Miss đơn thuần.

Thêm Coach Memory dưới dạng dữ liệu có cấu trúc, không lưu "ký ức" bằng đoạn văn
LLM tự viết:

- Topic/skill, evidence window, first seen, last seen, frequency và confidence.
- Assignment đã giao, số lần nhắc, completion, outcome và cooldown.
- Trạng thái persistent/resolved/relapsed để theo dõi lỗi quay lại.
- Preference có nguồn rõ ràng: người dùng nói, hành vi quan sát hoặc Coach suy
  luận; ba loại này không được nhập làm một.

Acceptance bổ sung:

- Query 90 ngày xác định được Long Pot là điểm yếu lặp lại khi dữ liệu đủ mẫu.
- Coach ưu tiên điểm yếu persistent hơn một lỗi nhỏ mới xuất hiện, nhưng vẫn có
  recency/critical override rõ ràng.
- Coach không lặp cùng một lời khuyên liên tục khi assignment đang mở/cooldown.
- Xóa dữ liệu người chơi phải xóa Coach Memory tương ứng.

### BK2-06 - Pro + Match Objective vertical slice

Chứng minh Knowledge phục vụ người chơi lâu năm bằng một cụm liên kết:

- Pattern selection và decision tree.
- Expected position và position margin.
- Risk management và safety expected value.
- Break strategy.
- Tournament routine, peak performance và pressure handling.

Match review phải phân tách ba lớp:

1. `Observed`: dữ liệu đã ghi hoặc Vision nhìn thấy.
2. `Attributed`: nguyên nhân người chơi tự chọn hoặc Coach suy luận kèm confidence.
3. `Recommended`: bài Knowledge/drill phù hợp để kiểm tra giả thuyết.

Match Objective phải thay đổi câu hỏi đánh giá chứ không chỉ thay đổi một điểm:

- `Training`: thắng/thua vẫn được báo, nhưng Coach ưu tiên execution dimensions
  đã chọn trước trận như Position, Routine hoặc Spin.
- `Win`: kết quả có trọng số cao, nhưng Coach vẫn chỉ ra hành vi thắng ngắn hạn
  có thể không nâng trình như pattern kém hoặc phụ thuộc cú khó.
- `Mixed`: cân bằng hai nhóm và nói rõ trade-off.

Ví dụ Race to 9 chỉ được nói "ghép 9 quá nhiều" nếu hệ thống đã ghi/quan sát
được hành vi đó. Không suy ra pattern chỉ từ tỷ số thắng.

Acceptance:

- Một match review mẫu deep-link được từ sai lực, sai spin, sai routine và sai
  quyết định tới đúng section; các nguyên nhân kỹ thuật không quan sát được phải
  hiển thị `chưa đủ bằng chứng`.
- Một scenario pro có nhiều option, risk và expected outcome; không giả độ chính
  xác xác suất khi chưa có model/calibration.
- Nội dung pro vẫn dùng chung entry/relation/source system với beginner.
- Regression test bao phủ cả thắng/thua cho `Training` và `Win`; cùng một tỷ số
  phải tạo emphasis khác nhau nhưng không phủ nhận dữ liệu thực tế.

### BK2-07 - AI Vision readiness, chưa phải production AI

V2 chỉ xây hợp đồng dữ liệu và feasibility spikes. Không tuyên bố đã có AI
Vision hoặc bot chơi bida.

- Cấp 1: video bài tập, quan sát stroke, bridge, follow-through, head movement,
  alignment và cue path.
- Cấp 2: video cú lỗi, liên kết observation với các nguyên nhân khả dĩ, cách sửa
  và bài kiểm tra xác nhận.
- Cấp 3: ảnh bàn sau phá, tái dựng table state rồi mới nghiên cứu route, pattern,
  safety và xác suất theo trình độ.

Mỗi cấp cần spike riêng cho dataset/label, metric accuracy, camera constraints,
latency, privacy, chi phí, confidence threshold và fallback UX. Cấp 3 còn cần
rule engine/physics/search policy; một mô hình ngôn ngữ nhìn ảnh không đủ làm
nguồn chân lý cho đường bi tối ưu.

Acceptance để đưa một cấp vào backlog production:

- Có bộ dữ liệu đại diện và ground truth có thể chấm.
- Có precision/recall hoặc error metric theo từng signal, không chỉ demo đẹp.
- Output luôn mang evidence và confidence; dưới ngưỡng phải trả `không chắc`.
- Người dùng có thể sửa kết quả nhận dạng trước khi Coach lưu hoặc suy luận.
- Có chính sách lưu/xóa video, ảnh và dữ liệu sinh trắc học liên quan.

## Thứ tự giao việc

Claude/Cursor chỉ nhận một slice tại một thời điểm:

1. BK2-01 schema + validator + migration tests.
2. BK2-02 glossary seed + search tests.
3. BK2-03 skill tree + mastery.
4. BK2-04 beginner/practical end-to-end.
5. BK2-05 Coach deep-link + memory closed loop.
6. BK2-06 pro/match objective slice.
7. BK2-07 feasibility spikes; không trộn vào implementation của 01-06.

Không bắt đầu bằng bulk content. Sau mỗi slice phải chạy package tests, app tests
và analyzer; chỉ mở rộng catalog khi vertical slice đã pass acceptance.

## Definition of Done cho Knowledge V2

- Người mới có thể tìm bằng ngôn ngữ đời, làm theo Level 1, tập drill và biết đã
  đạt hay chưa.
- Người chơi khá có thể hiểu khi nào dùng một kỹ thuật trong tình huống bàn cụ
  thể, không chỉ đọc định nghĩa.
- Người chơi lâu năm có ít nhất một decision tree thực chiến với risk/outcome.
- Skill Tree ngăn Coach khuyến nghị nhảy cóc; Mastery phản ánh thực hành,
  consistency và match transfer thay vì chỉ `đã đọc`.
- Coach nhớ được điểm yếu dài hạn và lịch sử assignment mà không phụ thuộc vào
  conversation text.
- Coach action mở đúng bằng chứng, lỗi, checklist, drill và assessment.
- Match/Vision không biến giả thuyết thành kết luận khi thiếu bằng chứng.
- Knowledge release có changelog; người dùng xem được nội dung thêm/sửa mới.
- Nội dung có provenance, review state và liên kết machine-readable; không có
  knowledge model song song trong app.
