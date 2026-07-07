# POOL OS - Domain Definitions Reference

> Tài liệu tham khảo nội bộ. Được cập nhật khi đọc từng file definition.

---

## 01_MATCH.md

### 1. MATCH
- **EN**: Match | **VI**: Trận đấu
- **DB Value**: `match`
- **Definition (EN)**: A Match begins with the first break and ends when one player reaches the target race.
- **Definition (VI)**: Một trận đấu bắt đầu từ cú phá đầu tiên và kết thúc khi một người chơi đạt số ván thắng mục tiêu.
- **Example**: Race to 5, Final Score 5 - 3

### 2. SESSION
- **EN**: Session | **VI**: Buổi chơi
- **DB Value**: `session`
- **Definition (EN)**: A Session may contain multiple matches and multiple training activities.
- **Definition (VI)**: Một buổi chơi có thể bao gồm nhiều trận đấu và nhiều bài tập luyện.
- **Example**: Saturday Morning → Training 30 minutes → Race to 5 → Race to 7 → Review (all one Session)

### 3. RACE
- **EN**: Race | **VI**: Chạm
- **DB Value**: `race_to`
- **Definition (EN)**: Race indicates how many racks a player must win.
- **Definition (VI)**: Race là số ván thắng cần đạt để chiến thắng trận đấu.
- **Example**: Race to 5, Race to 7, Race to 9, Race to 15

### 4. RACK
- **EN**: Rack | **VI**: Ván đấu
- **DB Value**: `rack`
- **Definition (EN)**: One rack starts after the balls are racked and ends when the game-winning ball is pocketed or a foul ends the rack.
- **Definition (VI)**: Một ván đấu bắt đầu sau khi xếp bi và kết thúc khi bi quyết định được đưa vào lỗ hợp lệ hoặc trận kết thúc theo luật.

### 5. RACK WIN
- **EN**: Rack Win | **VI**: Thắng ván
- **DB Value**: `true`

### 6. RACK LOSS
- **EN**: Rack Loss | **VI**: Thua ván
- **DB Value**: `false`

### 7. MATCH WIN
- **EN**: Match Win | **VI**: Thắng trận
- **DB Value**: `won`
- **Definition (EN)**: Player reaches the target race first.

### 8. MATCH LOSS
- **EN**: Match Loss | **VI**: Thua trận
- **DB Value**: `lost`
- **Definition (EN)**: Opponent reaches the target race first.

### 9. SCORE
- **EN**: Score | **VI**: Tỷ số
- **Definition (EN)**: Current rack score inside a match.
- **Definition (VI)**: Số ván thắng hiện tại của hai người chơi.
- **Example**: 4 - 3, 10 - 8, 15 - 7

### 10. HILL
- **EN**: Hill | **VI**: Chạm điểm
- **Definition (EN)**: A player needs only one more rack to win.
- **Definition (VI)**: Người chơi chỉ cần thắng thêm một ván nữa để thắng trận.
- **Example**: Race to 7, Score 6 - 4 → Player is on the hill

### 11. HILL-HILL
- **EN**: Hill-Hill | **VI**: Đồi đối đồi / Chạm đều
- **Definition (EN)**: Both players need one more rack to win.
- **Definition (VI)**: Cả hai người chơi đều chỉ cần thắng thêm một ván để kết thúc trận đấu.
- **Example**: Race to 7, Score 6 - 6

### 12. BREAK SHOT
- **EN**: Break Shot | **VI**: Cú phá
- **DB Value**: `break`
- **Definition (EN)**: The first shot of a rack.

### 13. GOLDEN BREAK
- **EN**: Golden Break | **VI**: Phá thắng
- **DB Value**: `golden_break`
- **Definition (EN)**: Player legally pockets the game-winning ball directly from the break.
- **Example**: 9-ball, Pocket 9 on break, Legal break → Rack won immediately

### 14. PUSH OUT
- **EN**: Push Out | **VI**: Push Out
- **DB Value**: `push_out`
- **Definition (EN)**: Special shot immediately after a legal break according to 9-ball rules.

### 15. BREAK FOUL
- **EN**: Break Foul | **VI**: Phá lỗi
- **DB Value**: `break_foul`
- **Definition (EN)**: Illegal break according to game rules.
- **Examples**: Scratch, Not enough balls reach rail, Cue ball off table, Wrong break

### 16. SCRATCH
- **EN**: Scratch | **VI**: Chết bi cái
- **DB Value**: `scratch`
- **Definition (EN)**: Cue ball is pocketed or leaves the table.

### 17. RUN OUT
- **EN**: Run Out | **VI**: Đi hết hình
- **DB Value**: `run_out`
- **Definition (EN)**: Player clears all remaining balls after gaining the table without giving the turn back.
- **Example**: Opponent misses 2-ball → Player pockets 2, 3, 4, 5, 6, 7, 8, 9 → Rack over → Run Out

### 18. LONGEST RUN
- **EN**: Longest Run | **VI**: Chuỗi ăn bi dài nhất
- **Definition (EN)**: Maximum number of consecutive balls pocketed during a single visit to the table.
- **Definition (VI)**: Số bi liên tiếp nhiều nhất người chơi ăn được trong một lượt đứng bàn.
- **IMPORTANT**: Longest Run is NOT total balls pocketed. Longest Run counts only consecutive successful pots.
- **Example**: Visit 1: Pocket 1,2,3 → Miss → Longest Run = 3. Visit 2: Pocket 5,6,7,8,9 → Longest Run = 5. Database stores 5.

### 19. TOTAL BALLS POCKETED
- **EN**: Total Balls Pocketed | **VI**: Tổng số bi ăn
- **Definition (EN)**: Total number of balls legally pocketed during an entire match.
- **Definition (VI)**: Tổng số bi hợp lệ người chơi ăn được trong toàn bộ trận đấu.
- **Different From**: Longest Run
- **Example**: Longest Run = 5, Total Balls Pocketed = 38

### 20. MATCH OBJECTIVE
- **EN**: Match Objective | **VI**: Mục tiêu trận đấu
- **Purpose**: Record why the player played this match.
- **Allowed Values**: Competition, Training, Testing Equipment, Mental Practice, Position Practice, Stroke Practice, Break Practice, Fun, Mixed
- **Definition (VI)**: Mục tiêu chính của trận đấu trước khi bắt đầu.
- **Example**: 70% Training, 30% Winning → Helps Coach AI evaluate decisions

### VALIDATION RULES (MATCH)
- One Match contains one or more Racks.
- One Session contains one or more Matches.
- Longest Run can never exceed the number of object balls in the game.
- Total Balls Pocketed must always be greater than or equal to Longest Run.
- Every Match must belong to exactly one Session.
- Every Rack must belong to exactly one Match.

---

## 02_POSITION.md

### 1. PLANNED POSITION
- **EN**: Planned Position | **VI**: Vị trí bi cái dự kiến
- **DB Value**: `planned_position`
- **Definition (EN)**: The ideal cue ball location selected before shooting.
- **Definition (VI)**: Vị trí người chơi mong muốn bi cái dừng lại trước khi thực hiện cú đánh.
- **Example**: Player plans to stop cue ball 25 cm below the 4-ball.

### 2. ACTUAL POSITION
- **EN**: Actual Position | **VI**: Vị trí bi cái thực tế
- **DB Value**: `actual_position`
- **Definition (EN)**: The actual resting position of the cue ball after all balls stop moving.
- **Definition (VI)**: Vị trí cuối cùng của bi cái sau khi tất cả bi trên bàn đã dừng.

### 3. POSITION QUALITY
- **EN**: Position Quality | **VI**: Chất lượng điều bi
- **DB Value**: `position_quality`
- **Definition (EN)**: Measures how successful the player controlled cue ball according to the original plan.
- **Definition (VI)**: Đánh giá mức độ thành công của cú điều bi so với kế hoạch ban đầu.
- **Available Values**: Perfect, Good, Playable, Recovery, Bad
- **Purpose**: Evaluate cue ball control. Does NOT evaluate whether the next ball was pocketed.

### 4. PERFECT POSITION
- **EN**: Perfect Position | **VI**: Điều bi hoàn hảo
- **DB Value**: `perfect`
- **Definition (EN)**: Cue ball finishes inside the intended target area. Original plan remains unchanged.
- **Definition (VI)**: Bi cái dừng đúng vùng mục tiêu đã dự kiến. Không cần thay đổi phương án đánh.
- **Typical Error**: 0~20 cm
- **Expected Pot Success**: 95%+
- **Difficulty Increase**: None
- **Example**: Planned 30 cm below object ball, Actual 25 cm below → Perfect.

### 5. GOOD POSITION
- **EN**: Good Position | **VI**: Điều bi tốt
- **DB Value**: `good`
- **Definition (EN)**: Cue ball finishes slightly outside the target area. The original shot selection remains unchanged.
- **Definition (VI)**: Bi cái lệch nhẹ khỏi vùng mục tiêu. Người chơi vẫn giữ nguyên kế hoạch đánh.
- **Typical Error**: 20~50 cm
- **Expected Pot Success**: 80~95%
- **Difficulty Increase**: Low
- **Example**: Still same pocket, Same route, Slightly longer distance.

### 6. PLAYABLE POSITION
- **EN**: Playable Position | **VI**: Điều bi có thể xử lý
- **DB Value**: `playable`
- **Definition (EN)**: Cue ball misses the planned area. Player must adjust the original plan. No advanced recovery technique is required.
- **Definition (VI)**: Bi cái không dừng đúng vùng mong muốn. Người chơi phải thay đổi phương án đánh. Tuy nhiên vẫn có thể tiếp tục chạy bàn với tỷ lệ thành công cao.
- **Typical Error**: 50~100 cm
- **Expected Pot Success**: 60~80%
- **Difficulty Increase**: Medium
- **Important**: Playable does NOT mean bad. Many players intentionally accept Playable Position during training.

### 7. RECOVERY POSITION
- **EN**: Recovery Position | **VI**: Điều bi cứu
- **DB Value**: `recovery`
- **Definition (EN)**: Player must use advanced cue ball control or shot making skills to continue the run.
- **Definition (VI)**: Người chơi buộc phải sử dụng kỹ thuật để tiếp tục chạy bàn.
- **Examples**: Heavy draw, Power follow, Rail first, Side spin, Thin cut, Jump, Kick
- **Expected Pot Success**: 30~60%
- **Difficulty Increase**: High
- **Example**: Cue ball hooked. Need one-rail escape.

### 8. BAD POSITION
- **EN**: Bad Position | **VI**: Điều bi lỗi
- **DB Value**: `bad`
- **Definition (EN)**: The original run-out plan is no longer realistic. Attack percentage becomes very low. Safety is usually preferred.
- **Definition (VI)**: Đường hình ban đầu đã hỏng. Khả năng chạy bàn rất thấp. Thông thường nên chuyển sang thủ hoặc đánh an toàn.
- **Expected Pot Success**: Below 30%
- **Difficulty Increase**: Very High

### 9. DISTANCE ERROR
- **EN**: Distance Error | **VI**: Sai số khoảng cách
- **DB Value**: `distance_error_cm`
- **Definition (EN)**: Distance between planned cue ball position and actual cue ball position.
- **Definition (VI)**: Khoảng cách giữa vị trí dự định và vị trí thực tế của bi cái.
- **DB Unit**: Centimeter

### 10. ANGLE ERROR
- **EN**: Angle Error | **VI**: Sai số góc
- **DB Value**: `angle_error_degree`
- **Definition (EN)**: Difference between intended shot angle and actual shot angle.
- **Definition (VI)**: Sai lệch giữa góc đánh dự kiến và góc đánh thực tế.
- **DB Unit**: Degree

### 11. POSITION EXECUTION
- **EN**: Position Execution | **VI**: Thực hiện điều bi
- **Definition (EN)**: Evaluate execution quality regardless of pot result.
- **Definition (VI)**: Đánh giá chất lượng điều bi, không phụ thuộc vào việc có ăn bi hay không.
- **Purpose**: Separate cue ball control from potting ability.

### 12. POSITION PLAN SUCCESS
- **EN**: Position Plan Success | **VI**: Thành công theo kế hoạch
- **DB Value**: `true` / `false`
- **Definition (EN)**: Player finishes in the intended zone.

### 13. POSITION PLAN CHANGED
- **EN**: Position Plan Changed | **VI**: Thay đổi phương án
- **Definition (EN)**: Player intentionally changes to another shot because cue ball finishes differently.
- **Definition (VI)**: Người chơi chủ động đổi phương án do vị trí bi cái không như mong muốn.
- **Important**: This is NOT automatically considered a mistake.

### 14. POSITION IMPROVED BY ACCIDENT
- **EN**: Lucky Position | **VI**: Điều bi may mắn
- **DB Value**: `lucky_position`
- **Definition (EN)**: Execution misses the intended target but accidentally creates a better opportunity.
- **Definition (VI)**: Điều bi không đúng kế hoạch nhưng vô tình tạo ra phương án tốt hơn.
- **Purpose**: Coach AI should distinguish luck from skill.
- **Example**: Planned angle 70%, Actual different angle → Next shot becomes 95%. Record as Lucky Position.

### 15. NATURAL ROUTE
- **EN**: Natural Route | **VI**: Đường bi tự nhiên
- **DB Value**: `natural_route`
- **Definition (EN)**: Cue ball path without requiring side spin.
- **Definition (VI)**: Đường chạy của bi cái chỉ sử dụng tâm bi, trô hoặc cu lê, không dùng áp phê ngang.
- **Purpose**: Track player's natural cue ball control ability.

### 16. SPIN ASSISTED POSITION
- **EN**: Spin Assisted Position | **VI**: Điều bi bằng áp phê
- **DB Value**: `spin_position`
- **Definition (EN)**: Cue ball reaches desired position using side spin.
- **Definition (VI)**: Bi cái đạt vị trí mong muốn nhờ sử dụng áp phê ngang.
- **Purpose**: Measure dependence on side spin.

### 17. POSITION DIFFICULTY
- **EN**: Position Difficulty | **VI**: Độ khó điều bi
- **Allowed Values**: Easy, Medium, Hard, Extreme
- **Purpose**: Measure execution difficulty before the shot.
- **Definition (VI)**: Đánh giá độ khó của cú điều bi trước khi thực hiện.

### VALIDATION RULES (POSITION)
- Position Quality evaluates cue ball control ONLY.
- Pot success must not affect Position Quality.
- Lucky Position must never be counted as Perfect Position.
- Natural Route and Spin Assisted Position are independent metrics.
- A shot may be: Perfect Position + Miss, Bad Position + Pot, Playable Position + Run Out, Recovery Position + Successful.
- Coach AI must evaluate Position independently from Potting.

---

## 03_STROKE.md

### 1. STROKE
- **EN**: Stroke | **VI**: Động tác ra cơ
- **DB Value**: `stroke`
- **Definition (EN)**: The complete forward movement of the cue from the end of the backswing until the follow-through finishes.
- **Definition (VI)**: Toàn bộ chuyển động của cơ từ khi kết thúc kéo cơ về sau cho đến khi kết thúc động tác theo cơ.

### 2. STROKE QUALITY
- **EN**: Stroke Quality | **VI**: Chất lượng ra cơ
- **DB Value**: `stroke_quality`
- **Definition (EN)**: Measure how stable and repeatable the stroke is.
- **Definition (VI)**: Đánh giá mức độ ổn định và khả năng lặp lại của động tác ra cơ.
- **Allowed Values**: Excellent, Good, Average, Poor, Very Poor
- **Purpose**: Evaluate execution quality. Independent from shot result.

### 3. SMOOTH STROKE
- **EN**: Smooth Stroke | **VI**: Ra cơ mượt
- **DB Value**: `smooth`
- **Definition (EN)**: Forward stroke is continuous, relaxed and without interruption.
- **Characteristics**: Stable acceleration, Relaxed grip, Straight cue path, Natural follow through.

### 4. STROKE HITCH
- **EN**: Stroke Hitch | **VI**: Khựng khi ra cơ
- **DB Value**: `stroke_hitch`
- **Definition (EN)**: The forward stroke loses smoothness before or during cue ball contact.
- **Definition (VI)**: Động tác ra cơ bị khựng hoặc đổi tốc độ trước hoặc ngay khi chạm bi cái.
- **Purpose**: Detect stroke inconsistency.
- **IMPORTANCE**: This is one of the most important metrics inside Pool OS.

### 5. SLIGHT HITCH
- **EN**: Slight Hitch | **VI**: Khựng nhẹ
- **DB Value**: `slight_hitch`
- **Definition (VI)**: Người chơi cảm nhận cú ra cơ chưa thật sự mượt nhưng vẫn kiểm soát được hướng cơ.
- **Characteristics**: Player feels it, Observer hard to notice, Pot success still high.

### 6. NOTICEABLE HITCH
- **EN**: Noticeable Hitch | **VI**: Khựng rõ
- **DB Value**: `noticeable_hitch`
- **Definition (VI)**: Khựng đủ lớn để ảnh hưởng đến đường cơ hoặc lực đánh.
- **Characteristics**: Player feels clearly, Visible on video, Starts affecting long shots.

### 7. JERKY STROKE
- **EN**: Jerky Stroke | **VI**: Ra cơ giật cục
- **DB Value**: `jerky`
- **Definition (EN)**: The cue changes speed or direction significantly during the forward stroke.

### 8. STRAIGHT STROKE
- **EN**: Straight Stroke | **VI**: Ra cơ thẳng
- **DB Value**: `straight`
- **Definition (EN)**: Cue travels along the intended line without unwanted lateral movement.

### 9. STEERING
- **EN**: Steering | **VI**: Lái cơ
- **DB Value**: `steering`
- **Definition (EN)**: The player unintentionally changes cue direction during delivery.
- **Common Cause**: Stress, Wanting to "steer" ball into pocket, Grip too tight.

### 10. FOLLOW THROUGH
- **EN**: Follow Through | **VI**: Theo cơ
- **DB Value**: `follow_through`
- **Definition (EN)**: Cue continues naturally after cue ball contact.
- **Allowed Values**: Very Short, Short, Normal, Long

### 11. BACKSWING
- **EN**: Backswing | **VI**: Kéo cơ
- **DB Value**: `backswing`
- **Definition (EN)**: Backward movement before the forward stroke.

### 12. TEMPO
- **EN**: Stroke Tempo | **VI**: Nhịp ra cơ
- **DB Value**: `tempo`
- **Definition (EN)**: Overall rhythm of the stroke.

### 13. GRIP PRESSURE
- **EN**: Grip Pressure | **VI**: Lực nắm chuôi
- **DB Value**: `grip_pressure`
- **Definition (EN)**: Amount of force applied by the grip hand.
- **Allowed Values**: Very Light, Light, Normal, Firm, Tight

### 14. STROKE CONFIDENCE
- **EN**: Stroke Confidence | **VI**: Độ tự tin khi ra cơ
- **DB Value**: `stroke_confidence`
- **Definition (EN)**: Player's confidence immediately before the stroke.
- **Scale**: 1~10

### 15. STROKE COMMITMENT
- **EN**: Stroke Commitment | **VI**: Mức độ dứt khoát
- **DB Value**: `stroke_commitment`
- **Definition (EN)**: Whether the player fully commits to the chosen shot.
- **Allowed Values**: Committed, Slightly Hesitant, Hesitant

### 16. STROKE STABILITY
- **EN**: Stroke Stability | **VI**: Độ ổn định của động tác
- **DB Value**: `stroke_stability`
- **Definition (EN)**: Consistency of stroke over multiple shots.
- **Purpose**: Used to detect fatigue and pressure.

### 17. POWER CONTROL
- **EN**: Power Control | **VI**: Kiểm soát lực
- **DB Value**: `power_control`
- **Definition (EN)**: Ability to deliver intended cue speed.

### 18. STROKE FEEDBACK
- **EN**: Stroke Feedback | **VI**: Cảm nhận sau khi ra cơ
- **DB Value**: `stroke_feedback`
- **Definition (EN)**: Player's immediate feeling after cue delivery.
- **Allowed Values**: Perfect, Good, Slight Hitch, Noticeable Hitch, Poor
- **Purpose**: Self-evaluation metric. Recorded before observing shot result.

### VALIDATION RULES (STROKE)
- Stroke Quality must be evaluated BEFORE shot result.
- Do not use pot success to evaluate Stroke.
- Long Pot statistics should be correlated with Stroke Hitch.
- Stroke Feedback should always come from the player.
- Coach AI must prioritize Stroke consistency over short-term results.

### COACH AI NOTES (STROKE)
- Stroke Hitch increases → Long Pot Success decreases → Recommend 50 Long Straight Drill
- Grip Pressure becomes Tight → Power Control decreases → Recommend Soft Grip Practice
- Stroke Confidence decreases → Miss rate increases → Recommend Reduce shot speed and simplify shot selection.

---

## 04_SHOT.md

### 1. SHOT
- **EN**: Shot | **VI**: Cú đánh
- **DB Value**: `shot`
- **Definition (EN)**: A single legal cue strike executed by the player.
- **Definition (VI)**: Một lần người chơi thực hiện đánh bi bằng đầu cơ.
- **Purpose**: The smallest recorded action in Pool OS.

### 2. SHOT TYPE
- **EN**: Shot Type | **VI**: Loại cú đánh
- **DB Value**: `shot_type`
- **Definition (EN)**: Classifies the intention of a shot.
- **Definition (VI)**: Phân loại mục đích của cú đánh.
- **Allowed Values**: Pot, Safety, Break, Jump, Kick, Bank, Combination, Push Out, Jump-Masse, Two-Way Shot

### 3. SHOT RESULT
- **EN**: Shot Result | **VI**: Kết quả cú đánh
- **DB Value**: `shot_result`
- **Definition (EN)**: Outcome after executing the shot.
- **Definition (VI)**: Kết quả cuối cùng của cú đánh.
- **Allowed Values**: Success, Miss, Scratch, Foul, Lucky, Hooked

### 4. EASY SHOT
- **EN**: Easy Shot | **VI**: Bi dễ
- **DB Value**: `easy`
- **Definition (EN)**: A shot expected to be pocketed by the player's current skill level with a success rate above 90%.
- **Important**: Easy Shot depends on player level. The same shot may be Easy for one player and Hard for another.

### 5. MEDIUM SHOT
- **EN**: Medium Shot | **VI**: Bi trung bình
- **DB Value**: `medium`
- **Definition (EN)**: A shot requiring normal concentration and execution.
- **Expected Success**: 60~90%

### 6. HARD SHOT
- **EN**: Hard Shot | **VI**: Bi khó
- **DB Value**: `hard`
- **Definition (EN)**: A shot requiring above-average execution.
- **Expected Success**: 30~60%

### 7. EXTREME SHOT
- **EN**: Extreme Shot | **VI**: Bi cực khó
- **DB Value**: `extreme`
- **Definition (EN)**: A shot with very low expected success even if executed correctly.
- **Expected Success**: Below 30%

### 8. LONG POT
- **EN**: Long Pot | **VI**: Bi xa
- **DB Value**: `long_pot`
- **Definition (EN)**: A pot where cue ball travels a long distance before contacting the object ball.
- **Purpose**: Track long-distance potting ability.

### 9. THIN CUT
- **EN**: Thin Cut | **VI**: Cắt mỏng
- **DB Value**: `thin_cut`
- **Definition (EN)**: A shot with a very small contact angle.

### 10. THICK CUT
- **EN**: Thick Cut | **VI**: Cắt dày
- **DB Value**: `thick_cut`
- **Definition (EN)**: A shot with a large contact angle.

### 11. STRAIGHT SHOT
- **EN**: Straight Shot | **VI**: Bi thẳng
- **DB Value**: `straight`
- **Definition (EN)**: Cue ball, object ball and pocket are nearly aligned.

### 12. STUN SHOT
- **EN**: Stun Shot | **VI**: Bi dừng
- **DB Value**: `stun`
- **Definition (EN)**: Cue ball slides without forward or backward rotation after impact.

### 13. STOP SHOT
- **EN**: Stop Shot | **VI**: Đánh chết bi cái
- **DB Value**: `stop`
- **Definition (EN)**: Cue ball stops immediately after impact.

### 14. FOLLOW SHOT
- **EN**: Follow Shot | **VI**: Cu lê
- **DB Value**: `follow`
- **Definition (EN)**: Cue ball continues forward after contact.

### 15. DRAW SHOT
- **EN**: Draw Shot | **VI**: Retro
- **DB Value**: `draw`
- **Definition (EN)**: Cue ball returns backward after contact.

### 16. SIDE SPIN
- **EN**: Side Spin | **VI**: Áp phê ngang
- **DB Value**: `side_spin`
- **Definition (EN)**: Horizontal spin applied to cue ball.
- **Purpose**: Measure spin dependency.

### 17. NATURAL SHOT
- **EN**: Natural Shot | **VI**: Đường bi tự nhiên
- **DB Value**: `natural`
- **Definition (EN)**: Shot executed without side spin.

### 18. SHOT COMMITMENT
- **EN**: Shot Commitment | **VI**: Mức độ dứt khoát
- **DB Value**: `commitment`
- **Definition (EN)**: Whether the player fully commits to the chosen shot.
- **Allowed Values**: Committed, Slight Hesitation, Hesitation

### 19. SHOT EXECUTION
- **EN**: Shot Execution | **VI**: Chất lượng thực hiện
- **DB Value**: `execution`
- **Definition (EN)**: Measures whether the player executed the intended shot correctly.
- **Purpose**: Separate execution quality from result.

### 20. SHOT CONFIDENCE
- **EN**: Shot Confidence | **VI**: Độ tự tin
- **DB Value**: `confidence`
- **Definition (EN)**: Player's confidence before taking the shot.
- **Scale**: 1~10

### VALIDATION RULES (SHOT)
- Shot Difficulty depends on player level.
- Do not classify every missed shot as Hard.
- Execution Quality is independent from Shot Result.
- Coach AI should compare Shot Difficulty with Success Rate.
- Natural Shot and Side Spin Shot must be tracked separately.
- Long Pot statistics should only include shots classified as Long Pot.
- Confidence should be recorded before execution.

### COACH AI NOTES (SHOT)
- Easy Shot Miss Rate > 15% → Recommend Straight Stroke Drill
- Long Pot Success decreases → Check Stroke Hitch, Sleep, Fatigue
- Side Spin Usage > 40% + Natural Route Success < 50% → Recommend Natural Position Training

---

## 05_DECISION.md

### 1. DECISION
- **EN**: Decision | **VI**: Quyết định
- **DB Value**: `decision`
- **Definition (EN)**: The player's selected action before delivering the cue.
- **Definition (VI)**: Lựa chọn của người chơi trước khi thực hiện cú đánh.
- **Purpose**: The strategy chosen before executing a shot.
- **IMPORTANT**: Pool OS evaluates the quality of the decision itself, NOT whether the shot was successful.

### 2. DECISION TYPE
- **EN**: Decision Type | **VI**: Loại quyết định
- **DB Value**: `decision_type`
- **Allowed Values**: Attack, Safety, Two-Way Shot, Combination, Kick, Bank, Jump, Push Out, Intentional Foul, Break

### 3. ATTACK
- **EN**: Attack | **VI**: Đánh công
- **DB Value**: `attack`
- **Definition (EN)**: Attempt to legally pocket the object ball.
- **Definition (VI)**: Chủ động ăn bi để tiếp tục lượt đánh.

### 4. SAFETY
- **EN**: Safety | **VI**: Đánh thủ
- **DB Value**: `safety`
- **Definition (EN)**: Intentionally leave the opponent in a difficult position.
- **Definition (VI)**: Chủ động đưa đối thủ vào thế khó thay vì cố gắng ăn bi.

### 5. TWO-WAY SHOT
- **EN**: Two-Way Shot | **VI**: Công thủ kết hợp
- **DB Value**: `two_way`
- **Definition (EN)**: An attacking shot designed to become a safety if the pot misses.
- **Example**: Attempt difficult pot. If miss, cue ball hides behind another ball.

### 6. COMBINATION SHOT
- **EN**: Combination Shot | **VI**: Ghép bi
- **DB Value**: `combination`
- **Definition (EN)**: Pocketing a target ball by first contacting another object ball.
- **Example**: 9-ball combination.

### 7. KICK SHOT
- **EN**: Kick Shot | **VI**: Đánh băng vào bi
- **DB Value**: `kick`
- **Definition (EN)**: Cue ball contacts one or more rails before hitting the object ball.

### 8. BANK SHOT
- **EN**: Bank Shot | **VI**: Đánh băng bi mục tiêu
- **DB Value**: `bank`
- **Definition (EN)**: Object ball contacts a rail before entering the pocket.

### 9. PUSH OUT
- **EN**: Push Out | **VI**: Push Out
- **DB Value**: `push_out`
- **Definition (EN)**: Special tactical shot after the break according to 9-ball rules.

### 10. DECISION QUALITY
- **EN**: Decision Quality | **VI**: Chất lượng quyết định
- **DB Value**: `decision_quality`
- **Definition (EN)**: Measures if the chosen decision was optimal based on available information.
- **Allowed Values**: Excellent, Good, Acceptable, Poor, Critical Mistake
- **Purpose**: Evaluate whether the selected strategy was correct.
- **IMPORTANT**: Decision Quality is one of the most important metrics in Coach AI.

### 11. EXPECTED SUCCESS
- **EN**: Expected Success | **VI**: Tỷ lệ thành công dự kiến
- **DB Value**: `expected_success`
- **Definition (EN)**: Player's estimated probability before shooting.
- **Scale**: 0~100%
- **Example**: Attack 40%, Safety 85%, Combination 20%

### 12. EXPECTED VALUE (EV)
- **EN**: Expected Value | **VI**: Giá trị kỳ vọng
- **DB Value**: `expected_value`
- **Purpose**: Evaluate which decision provides the highest long-term winning probability.
- **Definition (EN)**: Expected overall value considering all possible outcomes.

### 13. DECISION CONFIDENCE
- **EN**: Decision Confidence | **VI**: Độ tự tin với quyết định
- **DB Value**: `decision_confidence`
- **Definition (EN)**: Player confidence after selecting the strategy.
- **Scale**: 1~10

### 14. EXECUTION MATCH
- **EN**: Execution Match | **VI**: Thực hiện đúng ý đồ
- **DB Value**: `execution_match`
- **Allowed Values**: Yes, No, Partial
- **Definition (EN)**: Whether execution followed the original decision.
- **Example**: Planned Safety → Actually attacked → Execution Match = No

### 15. RISK LEVEL
- **EN**: Risk Level | **VI**: Mức độ rủi ro
- **DB Value**: `risk_level`
- **Definition (EN)**: Overall risk accepted before taking the shot.
- **Allowed Values**: Very Low, Low, Medium, High, Very High

### 16. AGGRESSIVE DECISION
- **EN**: Aggressive Decision | **VI**: Quyết định mạo hiểm
- **DB Value**: `aggressive`
- **Definition (EN)**: A decision prioritizing immediate advantage despite increased risk.

### 17. CONSERVATIVE DECISION
- **EN**: Conservative Decision | **VI**: Quyết định an toàn
- **DB Value**: `conservative`
- **Definition (EN)**: A decision prioritizing table control over immediate scoring.

### 18. PRESSURE DECISION
- **EN**: Pressure Decision | **VI**: Quyết định dưới áp lực
- **DB Value**: `pressure`
- **Definition (EN)**: Decision made under psychological pressure.
- **Examples**: Hill-Hill, Match Ball, Tournament Point

### 19. TRAINING DECISION
- **EN**: Training Decision | **VI**: Quyết định phục vụ luyện tập
- **DB Value**: `training`
- **Definition (EN)**: A decision intentionally chosen for learning rather than maximizing winning percentage.
- **Examples**: Practice long pot, Avoid side spin, Force natural routes, Attempt difficult position play
- **Purpose**: Coach AI must NOT classify these decisions as mistakes.

### 20. RESULT-ORIENTED DECISION
- **EN**: Result-Oriented Decision | **VI**: Quyết định ưu tiên chiến thắng
- **DB Value**: `winning`
- **Definition (EN)**: A decision intended to maximize winning probability.

### VALIDATION RULES (DECISION)
- Decision Quality must be evaluated BEFORE the shot result.
- A successful shot does NOT automatically mean a correct decision.
- A missed shot does NOT automatically mean a poor decision.
- Training Decisions must never reduce Decision Quality.
- Expected Success is estimated BEFORE the shot.
- Coach AI should compare: Expected Success → Actual Result → Decision Quality → Execution Quality as four independent metrics.

### COACH AI NOTES (DECISION)
- Attack 20% vs Safety 90% → Player chooses Attack → Decision Quality = Poor
- Combination 15% + Player intentionally practices → Match Objective = Training → Decision Quality = Excellent
- Hill-Hill → Player avoids high-risk bank → Chooses safety → Decision Quality = Excellent

---

## 06_SAFETY.md

### 1. SAFETY
- **EN**: Safety | **VI**: Đánh thủ
- **DB Value**: `safety`
- **Definition (EN)**: A shot whose primary objective is to leave the opponent in a difficult situation.
- **Definition (VI)**: Một cú đánh mà mục tiêu chính là đưa đối thủ vào thế khó thay vì cố gắng ăn bi.
- **Purpose**: Sacrifice immediate scoring to gain tactical advantage.
- **IMPORTANT**: Safety Quality is evaluated by the position left to the opponent, NOT whether the opponent eventually misses.

### 2. SAFETY ATTEMPT
- **EN**: Safety Attempt | **VI**: Thực hiện cú thủ
- **DB Value**: `safety_attempt`
- **Definition (EN)**: A shot intentionally executed as a safety.

### 3. SAFETY SUCCESS
- **EN**: Safety Success | **VI**: Thủ thành công
- **DB Value**: `success`
- **Definition (EN)**: The opponent receives a significantly more difficult table.

### 4. SAFETY FAILURE
- **EN**: Safety Failure | **VI**: Thủ lỗi
- **DB Value**: `failure`
- **Definition (EN)**: The opponent receives an easier opportunity than intended.

### 5. EXCELLENT SAFETY
- **EN**: Excellent Safety | **VI**: Thủ hoàn hảo
- **DB Value**: `excellent`
- **Definition (EN)**: Opponent has no direct legal shot and must escape.
- **Expected Opponent Success**: Below 20%

### 6. GOOD SAFETY
- **EN**: Good Safety | **VI**: Thủ tốt
- **DB Value**: `good`
- **Definition (EN)**: Opponent has a legal shot but with very low success probability.
- **Expected Opponent Success**: 20~40%

### 7. PLAYABLE SAFETY
- **EN**: Safety With Pressure | **VI**: Thủ tạo áp lực
- **DB Value**: `playable`
- **Definition (EN)**: Opponent has a playable shot but position is uncomfortable.
- **Expected Opponent Success**: 40~70%

### 8. FAILED SAFETY
- **EN**: Failed Safety | **VI**: Thủ hở
- **DB Value**: `bad`
- **Definition (EN)**: Opponent receives an easy attacking opportunity.
- **Expected Opponent Success**: Above 70%

### 9. SNOOKER
- **EN**: Snooker / Hook | **VI**: Đui bi
- **DB Value**: `snooker`
- **Definition (EN)**: Cue ball has no direct path to the legal object ball.

### 10. FULL SNOOKER
- **EN**: Full Snooker | **VI**: Đui hoàn toàn
- **DB Value**: `full_snooker`
- **Definition (EN)**: No direct legal contact is possible.

### 11. PARTIAL SNOOKER
- **EN**: Partial Snooker | **VI**: Đui một phần
- **DB Value**: `partial_snooker`
- **Definition (EN)**: Only part of the object ball is visible.

### 12. DISTANCE SAFETY
- **EN**: Distance Safety | **VI**: Thủ khoảng cách
- **DB Value**: `distance`
- **Definition (EN)**: Safety created mainly by increasing cue ball distance.

### 13. HIDDEN SAFETY
- **EN**: Hidden Safety | **VI**: Thủ giấu bi
- **DB Value**: `hidden`
- **Definition (EN)**: Safety created by hiding the cue ball behind another ball.

### 14. TWO-WAY SAFETY
- **EN**: Two-Way Safety | **VI**: Công thủ kết hợp
- **DB Value**: `two_way_safety`
- **Definition (EN)**: An attacking shot designed to become a safety if missed.
- **Important**: Two-Way Safety belongs to both Decision and Safety modules.

### 15. SAFETY DIFFICULTY
- **EN**: Safety Difficulty | **VI**: Độ khó của cú thủ
- **DB Value**: `safety_difficulty`
- **Allowed Values**: Easy, Medium, Hard, Extreme
- **Purpose**: Measure execution difficulty before the shot.

### 16. OPPONENT RESPONSE
- **EN**: Opponent Response | **VI**: Phản ứng của đối thủ
- **DB Value**: `opponent_response`
- **Allowed Values**: Kick, Jump, Bank, Attack, Safety, Foul, Miss
- **Definition (EN)**: The action taken by the opponent after receiving the safety.

### 17. SAFETY EFFECTIVENESS
- **EN**: Safety Effectiveness | **VI**: Hiệu quả của cú thủ
- **DB Value**: `safety_effectiveness`
- **Definition (EN)**: Measures how much the safety reduced the opponent's winning chances.
- **Scale**: 1~10

### 18. INTENTIONAL SAFETY
- **EN**: Intentional Safety | **VI**: Chủ động thủ
- **DB Value**: `intentional`
- **Definition (EN)**: The player clearly chooses safety before shooting.

### 19. ACCIDENTAL SAFETY
- **EN**: Accidental Safety | **VI**: Thủ ngoài ý muốn
- **DB Value**: `accidental`
- **Definition (EN)**: A missed attacking shot that accidentally leaves the opponent safe.
- **Purpose**: Coach AI should not reward accidental success as tactical skill.

### 20. SAFETY CHAIN
- **EN**: Safety Exchange | **VI**: Chuỗi đấu thủ
- **DB Value**: `safety_chain`
- **Definition (EN)**: A sequence of consecutive safety shots between players.
- **Purpose**: Measure tactical ability.

### VALIDATION RULES (SAFETY)
- Safety Quality depends on the table left to the opponent.
- Do not evaluate Safety based only on whether the opponent missed.
- Accidental Safety must be tracked separately.
- Excellent Safety should be rare.

### COACH AI NOTES (SAFETY)
- Safety Success 82% vs Attack Success 48% → Continue using safety on low-percentage shots.
- Excellent Safety 8%, Failed Safety 42% → Practice cue ball hiding drills.
- Player rarely chooses Safety when Attack Success < 35% → Increase tactical awareness and evaluate Expected Value before attacking.

---

## 07_BREAK.md

### 1. BREAK SHOT
- **EN**: Break Shot | **VI**: Cú phá
- **DB Value**: `break`
- **Definition (EN)**: The first legal shot used to scatter the racked balls.
- **Purpose**: The opening shot of a rack.

### 2. LEGAL BREAK
- **EN**: Legal Break | **VI**: Phá hợp lệ
- **DB Value**: `legal`
- **Definition (EN)**: A break satisfying all official rule requirements.

### 3. BREAK FOUL
- **EN**: Break Foul | **VI**: Phá lỗi
- **DB Value**: `break_foul`
- **Definition (EN)**: A break violating official rules.
- **Examples**: Scratch, No rail reached, Wrong ball contacted, Cue ball off table.

### 4. GOLDEN BREAK
- **EN**: Golden Break | **VI**: Phá thắng
- **DB Value**: `golden_break`
- **Definition (EN)**: Pocketing the game-winning ball directly on a legal break.

### 5. BALLS POCKETED ON BREAK
- **EN**: Balls Pocketed | **VI**: Số bi ăn khi phá
- **DB Value**: `balls_on_break`
- **Definition (EN)**: Number of object balls legally pocketed on the break.

### 6. BREAK SUCCESS
- **EN**: Successful Break | **VI**: Phá thành công
- **DB Value**: `successful_break`
- **Definition (EN)**: At least one object ball is pocketed and the player keeps the table.

### 7. DRY BREAK
- **EN**: Dry Break | **VI**: Phá không ăn bi
- **DB Value**: `dry_break`
- **Definition (EN)**: No object ball is pocketed after a legal break.

### 8. BREAK SPREAD
- **EN**: Break Spread | **VI**: Độ tơi của hình
- **DB Value**: `break_spread`
- **Allowed Values**: Excellent, Good, Average, Poor, Clustered
- **Purpose**: Evaluate how open the table becomes.
- **Definition (EN)**: Measures how well the balls separate after the break.

### 9. CLUSTER
- **EN**: Cluster | **VI**: Cụm bi
- **DB Value**: `cluster`
- **Definition (EN)**: Two or more object balls remaining close together after the break.

### 10. OPEN TABLE
- **EN**: Open Table | **VI**: Hình mở
- **DB Value**: `open_table`
- **Definition (EN)**: A table where most balls have clear paths to pockets.

### 11. BREAK CONTROL
- **EN**: Break Control | **VI**: Kiểm soát cú phá
- **DB Value**: `break_control`
- **Definition (EN)**: Ability to consistently produce a desired break result.

### 12. CUE BALL CONTROL ON BREAK
- **EN**: Cue Ball Control | **VI**: Kiểm soát bi cái khi phá
- **DB Value**: `break_cue_control`
- **Definition (EN)**: Ability to stop the cue ball in a favorable position after the break.

### 13. HEAD BALL BREAK
- **EN**: Head Ball Break | **VI**: Phá thẳng bi đầu
- **DB Value**: `head_ball_break`
- **Definition (EN)**: Cue ball strikes the head ball nearly full.

### 14. CUT BREAK
- **EN**: Cut Break | **VI**: Phá cắt
- **DB Value**: `cut_break`
- **Definition (EN)**: Cue ball contacts the head ball with a cut angle.

### 15. SECOND BALL BREAK
- **EN**: Second Ball Break | **VI**: Phá bi số hai
- **DB Value**: `second_ball_break`
- **Definition (EN)**: Cue ball intentionally contacts the second ball first.

### 16. BREAK POWER
- **EN**: Break Power | **VI**: Lực phá
- **DB Value**: `break_power`
- **Allowed Values**: Very Soft, Soft, Medium, Firm, Power, Maximum
- **Definition (EN)**: Relative power used during the break shot.

### 17. BREAK ACCURACY
- **EN**: Break Accuracy | **VI**: Độ chính xác cú phá
- **DB Value**: `break_accuracy`
- **Definition (EN)**: How accurately the cue ball contacts the intended point.

### 18. BREAK OBJECTIVE
- **EN**: Break Objective | **VI**: Mục tiêu cú phá
- **DB Value**: `break_objective`
- **Allowed Values**: Pocket Wing Ball, Pocket One Ball, Control Cue Ball, Maximum Spread, Soft Break, Practice
- **Definition (EN)**: The player's intended outcome before breaking.

### 19. PUSH OUT OPPORTUNITY
- **EN**: Push Out Opportunity | **VI**: Cơ hội Push Out
- **DB Value**: `push_out_opportunity`
- **Definition (EN)**: Whether the table after the break creates a strategic Push Out decision.

### 20. BREAK QUALITY
- **EN**: Break Quality | **VI**: Chất lượng cú phá
- **DB Value**: `break_quality`
- **Allowed Values**: Excellent, Good, Average, Poor
- **Purpose**: Overall evaluation of the break.
- **Definition (EN)**: Overall quality considering legality, cue ball control, spread and offensive opportunity.

### VALIDATION RULES (BREAK)
- Break Quality must NOT depend only on balls pocketed.
- A Dry Break can still receive a Good Break Quality if: Cue ball is well controlled, Table is open, Opponent has no easy opening shot.
- Break Spread and Cue Ball Control are evaluated independently.
- Golden Break is recorded separately.
- Coach AI should identify repeated break patterns instead of evaluating individual breaks only.

### COACH AI NOTES (BREAK)
- Break Spread = Excellent, Cue Ball Control = Poor → Reduce break power by 5-10%, Focus on cue ball stopping near table center.
- Dry Break Rate = 52%, Wing Ball Pocket Rate = 8% → Adjust break position by 2-5 cm, Review head ball contact accuracy.
- Break Spread = Excellent, Push Out Required = 45% → Improve one-ball control after break instead of increasing break power.

---

## 08_TRAINING.md

### 1. TRAINING SESSION
- **EN**: Training Session | **VI**: Buổi luyện tập
- **DB Value**: `training_session`
- **Definition (EN)**: A session whose primary objective is skill improvement.
- **Important**: Pool OS distinguishes Training from Competition. During Training, success is NOT measured only by winning.

### 2. MATCH SESSION
- **EN**: Competition Session | **VI**: Buổi thi đấu
- **DB Value**: `competition`
- **Definition (EN)**: A session focused on maximizing winning probability.

### 3. HYBRID SESSION
- **EN**: Hybrid Session | **VI**: Buổi vừa tập vừa thi đấu
- **DB Value**: `hybrid`
- **Definition (EN)**: A session containing both competition and practice objectives.
- **Example**: Race 9 → Race 15 → Last 6 racks become training.

### 4. TRAINING OBJECTIVE
- **EN**: Training Objective | **VI**: Mục tiêu luyện tập
- **DB Value**: `training_goal`
- **Allowed Values**: Stroke, Position, Break, Safety, Long Pot, Natural Route, Draw, Follow, Center Ball, Bridge, Mental, Pattern Play, Decision Making, Kick, Bank, Jump, Combination

### 5. PRIMARY OBJECTIVE
- **EN**: Primary Objective | **VI**: Mục tiêu chính
- **Definition**: The most important skill practiced today.
- **Example**: Natural Route

### 6. SECONDARY OBJECTIVE
- **EN**: Secondary Objective | **VI**: Mục tiêu phụ
- **Definition**: Additional skill practiced.
- **Example**: Long Pot

### 7. TRAINING CONSTRAINT
- **EN**: Training Constraint | **VI**: Giới hạn luyện tập
- **DB Value**: `constraint`
- **Examples**: No Side Spin, No Combination, Only Center Ball, Only Follow, Only Draw, Only Safety, Break Cue Only, No Jump

### 8. TRAINING SUCCESS
- **EN**: Training Success | **VI**: Hoàn thành mục tiêu luyện tập
- **DB Value**: `training_success`
- **Definition (EN)**: The player successfully follows the intended practice objective.
- **Important**: Training Success is NOT Match Win.

### 9. TRAINING VIOLATION
- **EN**: Training Violation | **VI**: Vi phạm mục tiêu luyện tập
- **DB Value**: `training_violation`
- **Definition**: Player breaks the selected training rule.
- **Example**: Goal = No Side Spin → Player uses Side Spin.

### 10. SKILL FOCUS
- **EN**: Skill Focus | **VI**: Kỹ năng trọng tâm
- **Definition**: The skill receiving the highest practice volume.

### 11. EXPERIMENT
- **EN**: Experiment | **VI**: Thử nghiệm
- **DB Value**: `experiment`
- **Definition**: Trying a new technique regardless of short-term results.
- **Examples**: New Break, New Grip, New Cue, New Stance

### 12. LEARNING SHOT
- **EN**: Learning Shot | **VI**: Cú đánh học kỹ thuật
- **DB Value**: `learning_shot`
- **Definition**: A shot intentionally chosen for improvement instead of highest winning percentage.
- **Example**: Attack difficult 10-ball, Avoid easy safety.

### 13. REPETITION
- **EN**: Repetition | **VI**: Lần lặp
- **Definition**: Number of repetitions of the same training objective.
- **Purpose**: Track deliberate practice.

### 14. TRAINING QUALITY
- **EN**: Training Quality | **VI**: Chất lượng buổi tập
- **Definition**: Overall quality of today's practice.
- **Allowed Values**: Excellent, Good, Average, Poor

### 15. LEARNING PROGRESS
- **EN**: Learning Progress | **VI**: Tiến bộ
- **DB Value**: `learning_progress`
- **Definition**: Measured improvement compared with previous sessions.

### 16. FATIGUE EFFECT
- **EN**: Fatigue Effect | **VI**: Ảnh hưởng của mệt mỏi
- **Definition**: Performance reduction caused by physical or mental fatigue.
- **Purpose**: Separate skill decline from fatigue.

### 17. ADAPTATION
- **EN**: Adaptation | **VI**: Khả năng thích nghi
- **DB Value**: `adaptation`
- **Examples**: Rasson, Aileex, Diamond, House Cue, Carbon Cue

### 18. TRAINING NOTE
- **EN**: Training Note | **VI**: Ghi chú luyện tập
- **Definition**: Player's own reflection after practice.
- **Purpose**: Coach AI uses this to understand hidden context.

### 19. BREAKTHROUGH
- **EN**: Breakthrough | **VI**: Đột phá
- **DB Value**: `breakthrough`
- **Definition**: A noticeable improvement in a previously weak skill.
- **Examples**: Long Pot, 10-ball, Natural Route

### 20. LEARNING STAGE
- **EN**: Learning Stage | **VI**: Giai đoạn học
- **Allowed Values**: Learning, Understanding, Applying, Consistent, Automatic, Mastery
- **Purpose**: Coach AI estimates current development stage.

### VALIDATION RULES (TRAINING)
- Training Success must never depend on Match Result.
- Learning Shot should not reduce Decision Quality.
- Training Constraint violations should be tracked separately.
- Coach AI must prioritize Learning Progress over Win Rate during Training Sessions.
- Practice objectives should always override competitive EV when Session Type = Training.

### COACH AI NOTES (TRAINING)
- Training Goal: No Side Spin → Player wins only 40% → Natural Route improves 42% → 71% → Training Quality = Excellent, NOT Poor.
- Training Goal: 10-ball Position → Player intentionally chooses harder routes → Decision Quality remains Excellent.
- Training Goal: Break Cue Pattern Play → Run Out decreases → Stroke consistency improves → Training Success = High.

---

## 09_COACH_AI_RULEBOOK_PART_01.md

**Purpose**: Defines how Coach AI thinks. Coach AI is NOT a statistics engine; it behaves like a professional pool coach.

### CORE PRINCIPLE 1: Skill over Result
- **EN**: Never evaluate a player by today's score.
- **VI**: Không bao giờ đánh giá người chơi chỉ bằng tỷ số của một buổi.
- **Rule**: Coach AI always prioritizes Skill Growth over Win Rate.

### CORE PRINCIPLE 2: Execution over Outcome
- **EN**: A correct execution that misses is better than a lucky shot.
- **VI**: Một cú đánh thực hiện đúng nhưng hụt có giá trị hơn một cú đánh sai nhưng may mắn ăn.
- **Rule**: Separate Decision, Stroke, Position, Execution, Result into independent metrics.

### CORE PRINCIPLE 3: Consistency over Peak
- **EN**: One great shot means nothing. One hundred repeatable shots mean everything.
- **VI**: Một cú đánh xuất sắc không nói lên điều gì. Một trăm cú đánh ổn định mới phản ánh trình độ.
- **Rule**: Coach AI always searches for Repeatability.

### CORE PRINCIPLE 4: Improvement over Talent
- **EN**: Coach AI rewards improvement, not natural talent.
- **VI**: AI đánh giá cao sự tiến bộ hơn năng khiếu.
- **Example**: Week 1 Long Pot 42% → Week 4 Long Pot 58% = Excellent Progress.

### CORE PRINCIPLE 5: Training overrides Winning
- **Rule**: If Session Type = Training, Coach AI changes evaluation logic. Winning becomes secondary, Learning becomes primary.

### CORE PRINCIPLE 6: Player Context Matters
- **EN**: Coach AI must know Today's objective, Fatigue, Equipment, Table, Sleep, Mental state, Health before evaluating performance.
- **Example**: Sleep 5 hours → Stroke unstable → Do NOT recommend changing technique immediately.

### CORE PRINCIPLE 7: Equipment is Context
- **Rule**: Changing Cue, Tip, Cloth, Table, Balls, Lighting, Glasses must be recorded. Coach AI must not confuse adaptation with regression.

### CORE PRINCIPLE 8: Intent Matters
- **Rule**: If the player intentionally avoids side spin, practices break cue, avoids combination shots, chooses difficult routes → Coach AI must never classify those choices as mistakes.

### CORE PRINCIPLE 9: Every Skill Evolves Independently
- **Skills**: Stroke, Position, Break, Safety, Decision, Long Pot, Mental, Pattern Play, Natural Route, Kick, Bank, Jump, Combination
- **Each skill has**: Current Level, Trend, Confidence, Learning Stage

### CORE PRINCIPLE 10: Improvement is Non-linear
- **EN**: Coach AI expects Plateau, Regression, Breakthrough, Plateau, Regression, Breakthrough. This is normal.
- **Rule**: Never panic after one bad session.

### CORE PRINCIPLE 11: Player Feedback is Data
- **EN**: The player's feeling is valid information, even if Shot Success remains high.
- **Rule**: Coach AI combines Objective statistics + Subjective feeling.

### CORE PRINCIPLE 12: Trust Large Sample Size
- **Default Minimum Samples**:
  - Stroke: 50 shots
  - Long Pot: 100 shots
  - Break: 30 breaks
  - Safety: 30 attempts
  - Position: 100 shots
  - Decision: 50 situations
  - Pattern: 30 racks
- **Rule**: Below this, confidence decreases.

---

## 09_COACH_AI_RULEBOOK_PART_02.md

**Purpose**: Defines how Coach AI evaluates every shot. Coach AI evaluates the complete thinking process, NOT just the result.

### EVALUATION PIPELINE (Order)
1. Player Context
2. Training Objective
3. Table Situation
4. Decision
5. Execution
6. Stroke
7. Cue Ball Control
8. Position Result
9. Shot Result
10. Learning Value

**Rule**: Result is only one part of the evaluation.

### RULE 1: Context First
- **Rule**: Coach AI must always check context before evaluating.
- **Context includes**: Sleep, Health, Fatigue, Equipment, New Table, Lighting, Stress, Tournament, Training
- **Example**: Player slept only 5 hours → Stroke becomes unstable → Recommendation: Rest, NOT Change Stroke Technique.

### RULE 2: Training Overrides Winning
- **Rule**: If Session Type = Training, Winning becomes secondary.
- **Example**: Training Goal = No Side Spin → Player loses → Natural Route improves → Training Score = Excellent.

### RULE 3: Intent Before Execution
- **Rule**: Coach AI asks "What was the player trying to do?" before "What actually happened?"
- **Example**: Player intentionally chooses Long Position Route instead of Easy Stop Shot. Execution fails → Decision remains Good.

### RULE 4: Separate Decision from Execution
- **Rule**: Bad execution ≠ Bad decision. Good execution ≠ Good decision.
- **Example**: Attack Success 25%, Safety Success 90%. Player attacks. Ball drops → Execution = Excellent, Decision = Poor.

### RULE 5: Reward Correct Thinking
- **Rule**: Coach AI rewards correct process, not lucky outcome.
- **Example**: Player chooses 95% Safety. Opponent kicks and flukes → Safety remains Excellent.

### RULE 6: Punish Repeat Mistakes
- **Rule**: Single mistake = Ignore. Pattern = Coach.
- **Default trigger**: 3 similar mistakes within 5 sessions.
- **Examples**: Scratch, Wrong Speed, Over Position, Bridge Error, Steering, Stroke Hitch

### RULE 7: Identify Root Cause
- **Rule**: Coach AI must never recommend solutions before identifying causes.
- **Example**: Long Pot decreases. Possible causes: Poor Stroke, Fatigue, New Table, Different Cloth, Wrong Tip, Mental Pressure, Eye Alignment, Glasses, Bridge Length. Only after identifying the most likely cause should Coach AI generate advice.

### RULE 8: Separate Skill from Adaptation
- **Rule**: Changing equipment is NOT regression.
- **Examples**: House Cue, Different Tip, Rasson, Diamond, New Cloth, Humidity, Temperature, Glasses
- **Action**: All should be marked as Adaptation Sessions.

### RULE 9: Use Player Feedback
- **Rule**: Player feedback has high priority.
- **Example**: Player reports "I feel stroke hitch." Even if Pot Success remains high → Coach AI should Increase Stroke Monitoring.

### RULE 10: Learning Value
- **Rule**: Every shot receives Learning Value.
- **Allowed Values**: Very High, High, Medium, Low, None
- **Examples**: Simple Stop Shot → Low. New Long Draw → Very High.

### RULE 11: Difficulty is Relative
- **Rule**: Difficulty depends on player. Coach AI must learn Player Profile.
- **Example**: Combination Shot → Player A 95% = Easy. Player B 20% = Hard.
- **Rule**: Never use fixed difficulty tables.

### RULE 12: Trust Long-Term Trends
- **Rule**: Coach AI should compare Today → Last Week → Last Month → Three Months → Six Months → Career Average.
- **Rule**: One bad session should never generate major recommendations.

### RULE 13: Recognize Breakthroughs
- **Rule**: Coach AI should detect sudden improvements.
- **Examples**: Stroke Hitch almost disappears, Long Pot +15%, Natural Route Position Quality increases, Break Wing Ball increases.
- **Action**: Mark Breakthrough.

### RULE 14: Detect Plateau
- **Rule**: If Skill changes less than 2% during 8 sessions, mark Plateau.
- **Recommendation**: Change Practice Method, NOT Practice More.

### RULE 15: Personalized Coaching
- **Rule**: Two players with identical statistics may receive different advice.
- **Reason**: Different Goals, Weaknesses, Playing Styles, Training Objectives.
- **Rule**: Coach AI must always personalize recommendations.

### COACH AI DECISION TREE
Before every recommendation, AI asks:
1. What is today's goal?
2. Was the player following the goal?
3. Was the decision correct?
4. Was execution correct?
5. Is this a pattern?
6. What is the root cause?
7. What recommendation creates the highest long-term improvement?

**Only then generate coaching advice.**

---

## 09_COACH_AI_RULEBOOK_PART_03.md

**Purpose**: Defines the Skill Rating Engine. Coach AI maintains independent ratings for every core skill.

### CORE SKILLS (20 Skills)
Stroke, Decision Making, Position Play, Cue Ball Control, Pattern Play, Break, Safety, Long Pot, Short Pot, Draw Shot, Follow Shot, Stun Shot, Rail Shot, Kick Shot, Bank Shot, Jump Shot, Combination Shot, Mental Game, Match Management, Adaptability, Consistency.

### SKILL STRUCTURE
Every skill contains: Current Rating, Trend, Confidence, Learning Stage, Sample Size, Last Improvement, Coach Priority.

### RATING SCALE
- 0-20: Beginner
- 21-40: Developing
- 41-60: Intermediate
- 61-75: Advanced
- 76-90: Competitive
- 91-100: Elite
- **Important Rule**: Ratings are NOT percentages. A Stroke Rating of 82 means Coach AI estimates the player's stroke ability at Level 82, NOT 82% pot success.

### CONFIDENCE SCORE
- Depends on: Sample Size, Consistency, Recent Sessions, Equipment Stability, Training Context
- Example: Stroke 82, Confidence 97% = Reliable. Jump 78, Confidence 24% = Need More Data.

### TREND
- **Allowed Values**: Rapid Improvement, Improving, Stable, Plateau, Declining, Rapid Decline
- Calculated from: Last 10 Sessions, Last Month, Career Average

### LEARNING STAGE
- **Allowed Values**: Learning, Understanding, Applying, Consistent, Automatic, Mastery
- **Rule**: Coach AI should NOT recommend advanced drills before Applying Stage.

### COACH PRIORITY
- **Values**: Critical, High, Medium, Low, Completed
- Depends on: Weakness, Importance, Training Goal, Current Trend

### SAMPLE SIZE (Default Minimum)
- Stroke: 300 shots
- Position: 300 shots
- Break: 100 breaks
- Safety: 100 attempts
- Decision: 200 decisions
- Long Pot: 200 shots
- Jump: 50 attempts
- Bank: 100 attempts
- Combination: 100 attempts

### SKILL UPDATE RULES
- Maximum rating change per session: ±2
- Large improvements require consistent evidence.
- **Breakthrough**: If improvement continues for 5 sessions → Mark Breakthrough.
- **Regression**: One bad day = Ignore. Three bad sessions = Warning. Five bad sessions = Regression.

### SPECIAL MODES
- **Adaptation Mode**: When player changes Cue, Tip, Table, Balls, Lighting, Bridge, Glasses → Coach AI enters Adaptation Mode. Ratings update slower to avoid false regression.
- **Fatigue Mode**: Sleep <6 hours OR Health Poor → Fatigue Mode. Coach AI reduces rating sensitivity.
- **Training Mode**: If Session Type = Training → Coach AI evaluates Skill Growth instead of Winning Rate.

### PLAYER PROFILE
- Coach AI gradually learns Natural Playing Style: Aggressive, Defensive, Pattern Player, Power Breaker, Shot Maker, Creative, Tactical, Natural Route, Spin Heavy.
- Player Profile must evolve automatically.

### COACH AI OUTPUT (For Every Session)
- Top 3 Improvements
- Top 3 Weaknesses
- Hidden Progress
- Regression Risks
- Recommended Drills
- Training Focus
- Confidence Level

### GOLDEN RULE
- Coach AI must never compare Today's Player with Professional Players.
- Coach AI compares Today's Player with Yesterday's Player.
- Continuous self-improvement is the only success metric.

---

## 09_COACH_AI_RULEBOOK_PART_04.md

**Purpose**: Defines the Root Cause Analysis Engine. Coach AI must never recommend a solution before identifying the root cause.

### ANALYSIS FLOW
Symptom → Collect Context → Find Possible Causes → Rank Probability → Verify with History → Generate Recommendation.

### RULE 1: Never Analyze a Single Shot
- **Minimum sample**: Miss 3+, Scratch 3+, Position Error 10+, Stroke Hitch 10+, Break 20+.

### RULE 2: Every Symptom Has Multiple Causes
- **Example**: Long Pot Miss → Possible causes: Stroke Hitch, Poor Alignment, Fatigue, Wrong Speed, Eye Alignment, Bridge Too Long, Equipment Change, Pressure, Wrong Decision.
- **Rule**: Never assume one cause.

### RULE 3: Context Before Technique
- Always check Sleep, Health, Mental, Equipment, Table, Lighting, Glasses, Travel, Temperature, Humidity before Technique.

### RULE 4: Technique Before Strategy
- If Stroke is unstable → Do NOT analyze Position.
- If Position is unstable → Do NOT analyze Decision.
- **Rule**: Coach AI always fixes the foundation first.

### RULE 5: One Cause Can Create Many Symptoms
- **Example**: Stroke Hitch → Miss Long Pot → Bad Position → Scratch → Mental Pressure.
- **Rule**: Coach AI should identify Stroke Hitch as Root Cause.

### RULE 6: Separate Primary Cause and Secondary Cause
- **Primary Cause**: Main reason.
- **Secondary Cause**: Makes the problem worse.
- **Example**: Primary = Fatigue. Secondary = New Table.

### RULE 7: Historical Verification
- Coach AI compares Today → Last Week → Last Month → Career.
- If symptom appears only today → Temporary.
- If repeated → Pattern.

### RULE 8: Probability Score
- Every possible cause receives Probability 0~100%.
- **Example**: Long Pot Miss → Stroke 68%, Fatigue 18%, Lighting 8%, Pressure 6%.

### RULE 9: Root Cause Confidence
- Coach AI reports confidence.
- **Example**: Root Cause = Stroke Hitch, Confidence = 91%.
- **Example**: Root Cause = Equipment, Confidence = 37% → Need More Data.

### RULE 10: Multiple Root Causes
- Coach AI may identify up to 3 causes.
- **Example**: Primary = Fatigue, Secondary = Stroke, Third = New Table.

### COMMON SYMPTOMS
Miss Easy Shot, Miss Long Pot, Scratch, Poor Position, Break Decline, Wrong Speed, Mental Collapse, Safety Failure, Bad Decision, Loss of Confidence.

### ROOT CAUSE LIBRARY
Stroke Hitch, Grip Too Tight, Bridge Instability, Wrong Alignment, Eye Movement, Head Movement, Fatigue, Sleep, Health, Equipment, Lighting, Pressure, Wrong Pattern, Poor Planning, Overthinking, Wrong Speed, Poor Cue Ball Control, Table Adaptation, New Cloth, New Balls, Humidity, Temperature.

### CAUSE RELATIONSHIPS
Stroke Hitch → Long Pot Miss → Confidence Drop → Steering → More Misses. Coach AI should detect chains instead of isolated events.

### RECOVERY ENGINE
After identifying the root cause, Coach AI generates: Immediate Action, Next Session Focus, Weekly Drill, Long-term Goal.
- **Example**: Root Cause = Grip Too Tight → Immediate = Reduce grip pressure, Next Session = 50 Stop Shots, Weekly = Straight Stroke Drill.

### DO NOT
- Never recommend "Practice More."
- Recommendations must be specific.
- **Wrong**: Practice Stroke.
- **Correct**: 50 Long Straight Shots using only Center Ball with slow follow through.

### PRIORITY ORDER
Coach AI always fixes:
1. Health
2. Mental
3. Stroke
4. Position
5. Decision
6. Advanced Skills

### GOLDEN RULE
Fix the cause. Never chase the symptom.

### EXAMPLE
- Observed: Long Pot ↓, Scratch ↑, Position ↓, Confidence ↓
- Context: Sleep 5 hours, New Table, Glasses
- Player Feedback: "I feel Stroke Hitch."
- Coach AI: Root Cause = Fatigue + Stroke Hitch
- Recommendation: Do not change technique. Recover physically. Recheck stroke next session.

---

## 09_COACH_AI_RULEBOOK_PART_05.md

**Purpose**: Defines the Recommendation Engine. Coach AI must recommend the NEXT BEST ACTION for long-term improvement.

### CORE PRINCIPLE
- Coach AI never asks "What did the player do?"
- Coach AI asks "What should the player do next?"

### RECOMMENDATION PRIORITY (Order)
1. Health
2. Mental
3. Stroke
4. Decision
5. Cue Ball Control
6. Position Play
7. Pattern Play
8. Break
9. Advanced Skills
10. Equipment

### MAXIMUM RECOMMENDATIONS
- Maximum 3 recommendations per session.
- Too many recommendations reduce learning efficiency.

### RECOMMENDATION TYPES
- **Immediate Fix**: Applied immediately (e.g., Reduce grip pressure, Slow down pre-shot routine, Use shorter bridge, Rest today, Drink water)
- **Next Session**: Main objective for the next practice session
- **Weekly Focus**: Highest priority skill this week
- **Long-term Development**: Skill expected to improve over months

### TRAINING LOAD
- **Allowed Values**: Recovery, Light, Normal, High, Intensive
- **Depends on**: Sleep, Fatigue, Recent Sessions, Mental, Tournament Schedule

### SESSION OBJECTIVE
- Every session should have ONE Primary Goal.
- Optional ONE Secondary Goal.
- Never train 5-6 skills simultaneously.

### DRILL RECOMMENDATION (Must Include)
- Drill Name
- Purpose
- Repetitions
- Success Criteria
- Expected Improvement
- **Example**: 50 Long Straight Shots / Improve Stroke Stability / 50 reps / 90% success / +2 Stroke Rating

### TRAINING CONSTRAINTS
- Coach AI may intentionally limit skills: No Side Spin, Only Center Ball, Only Follow, Only Draw, Only Safety, Break Cue Only, No Combination
- **Purpose**: Accelerate learning.

### ADAPTIVE TRAINING
- If success >85% → Increase difficulty
- If success <50% → Reduce difficulty
- **Target Success Rate**: 65~80% (optimal learning zone)

### MICRO GOALS
- Every practice should contain measurable goals.
- **Bad**: Practice Stroke.
- **Good**: Pocket 30 consecutive straight shots without Stroke Hitch.

### SPECIAL MODES
- **Fatigue Protection**: Sleep <6 hours OR Fatigue High → Reduce Training Load, avoid new techniques
- **Breakthrough Mode**: Breakthrough detected → Focus Consolidation instead of Learning new skills
- **Plateau Mode**: Skill unchanged for 8 sessions → Change training method, NOT training volume
- **Regression Mode**: Skill declines for 5 sessions → Return to fundamentals
- **Equipment Mode**: Player changes Cue/Tip/Table/Balls → Recommend Adaptation Drills

### PERSONALIZATION
- Two players with identical statistics may receive different recommendations.
- Depends on: Player Style, Training Goal, Weakness, Strength, History, Confidence, Equipment, Mental State

### SUMMARY OUTPUTS
- **Daily Summary**: Biggest Improvement, Biggest Problem, Root Cause, Next Session Goal, Confidence Level, One Sentence Advice
- **Weekly Summary**: Most Improved Skill, Most Repeated Mistake, Breakthrough, Regression, Next Week Focus, Training Load
- **Monthly Summary**: Skill Ratings, Trend, Learning Stage, Coach Comments, Next Month Goal

### GOLDEN RULE
Never recommend what the player already does well. Always recommend the highest Return On Investment skill.

### ROI PRINCIPLE
- Coach AI estimates Improvement Impact.
- **Example**: Improve Break +1% vs Improve Stroke +8% → Recommend Stroke.

### RECOMMENDATION CONFIDENCE
- **Values**: Low, Medium, High, Very High
- **Example**: Recommendation = Improve Stroke Stability, Confidence = 95%, Reason = Observed across 8 sessions, 642 shots

### DO NOT
- Never say "Practice More", "Play More", "Keep Going".
- Recommendations must always be: Specific, Measurable, Personalized, Actionable.

---

## 09_COACH_AI_RULEBOOK_PART_06.md

**Purpose**: Defines the Session Intelligence Engine. Transforms raw match data into meaningful coaching insights that explain WHY the session happened.

### SESSION REPORT STRUCTURE (10 Sections)
1. Session Overview
2. Performance Summary
3. Key Improvements
4. Key Problems
5. Root Cause Analysis
6. Learning Value
7. Training Objective Completion
8. Coach Recommendation
9. Next Session Plan
10. Confidence Level

### SECTION 1: SESSION OVERVIEW
- Display: Session Type (Match/Training/Hybrid), Duration, Total Racks, Win/Lose, Table, Cue, Tip, Sleep, Fatigue, Health, Equipment Change, Environment

### SECTION 2: PERFORMANCE SUMMARY
- Coach AI summarizes performance, NOT statistics.
- Example: "Excellent tactical discipline. Long pot slightly declined. Natural routes improved. Stroke less stable than usual. Break spread excellent."

### SECTION 3: KEY IMPROVEMENTS
- Maximum 3 items.
- Every improvement contains: Evidence, Confidence, Trend.

### SECTION 4: KEY PROBLEMS
- Maximum 3 items.
- Do not overload users.

### SECTION 5: ROOT CAUSE ANALYSIS
- Every problem must include: Observed Symptom → Possible Causes → Most Probable Cause → Confidence → Recommended Action
- **Example**: Symptom = Long Pot Miss → Cause = Fatigue → Confidence = 87% → Recommendation = Recovery, NOT Stroke Change.

### SECTION 6: LEARNING VALUE
- Every session receives Learning Value: Very High, High, Medium, Low, Very Low.
- Depends on: Training Objective, Experiment, Difficulty, Breakthrough, New Skills.
- NOT Win Rate.

### SECTION 7: TRAINING OBJECTIVE
- Coach AI checks: Did the player follow today's plan?
- **Example**: Goal = No Side Spin → Result = 96% Success. Goal = 10-ball Position → Result = Practiced 41 situations → Success.

### SECTION 8: COACH COMMENTS
- Coach AI writes a human-like summary (maximum 250 words).
- Structure: Praise → Observation → Improvement → Focus.
- Never criticize. Never use negative language.
- **Example**: "Today's session showed clear improvement in natural cue ball control. Although position quality decreased slightly, this was expected because side spin was intentionally avoided. The most encouraging sign was increased confidence when recovering from playable positions. Continue building this foundation before introducing more side spin."

### SECTION 9: NEXT SESSION PLAN
- Contains: Primary Goal, Secondary Goal, Training Load, Suggested Drills, Estimated Duration, Expected Improvement
- **Example**: Primary = Stroke Stability, Secondary = Natural Route, Training Load = Normal, Drills = 50 Long Straight, 20 Stop Shot, 15 Break

### SECTION 10: SESSION SCORE
- Coach AI generates FIVE independent scores: Skill Growth, Execution, Decision, Discipline, Learning.
- Scale: 0-100.
- **NO Overall Score**. Avoid reducing player performance to one number.

### SESSION CONFIDENCE
- Every report includes AI Confidence.
- **Example 94%**: Reason = Large sample size, Consistent conditions.
- **Example 41%**: Reason = New cue, New table, Limited sample.

### BREAKTHROUGH DETECTION
- Coach AI detects today's breakthrough: Stroke, Break, Natural Route, Safety, Decision, Pattern Play.
- **Example**: Today's biggest breakthrough = Recovery Position confidence.

### REGRESSION DETECTION
- Regression requires at least 3 sessions.
- Never report regression after one bad day.

### HIDDEN PROGRESS
- Coach AI searches for progress invisible to statistics: More confident, Better decisions, Less panic, Improved rhythm, Cleaner stroke, Better pattern selection.
- These improvements should always be highlighted.

### SESSION COMPARISON
- Compare Today → Previous Session → 7-Day Average → 30-Day Average.
- Show Improving, Stable, Declining for each major skill.

### PLAYER REFLECTION
- The player may answer: What felt good today? What felt wrong today? What surprised you?
- Coach AI uses this information for future analysis.

### GOLDEN RULE
- Statistics explain WHAT happened.
- Coach AI explains WHY it happened and WHAT should happen next.

---

## 10_STATISTICS_ENGINE_PART_01.md

**Purpose**: Defines the Statistics Engine. Converts raw session data into reliable performance metrics. NEVER provides coaching advice.

### DESIGN PRINCIPLES
Accuracy, Consistency, Repeatability, Transparency, Low Noise, Historical Tracking. Every statistic must be reproducible.

### DATA HIERARCHY
Player → Career → Season → Month → Week → Session → Rack → Shot → Event. The Shot is the smallest statistical unit.

### STATISTIC TYPES
- **Raw Statistics**: Collected directly from user input (Shot Type, Shot Result, Position Quality, Stroke Feedback, Sleep Hours, Fatigue, Table, Cue, Tip, Mental State, Training Goal). These values are never modified.
- **Calculated Statistics**: Generated from raw data (Pot Success %, Break Success %, Safety Success %, Scratch %, Run Out %, Position Quality %, Natural Route %, Side Spin Usage %). Deterministic.
- **Derived Statistics**: Calculated from multiple statistics (Stroke Consistency, Decision Quality, Position Efficiency, Break Efficiency, Mental Stability, Learning Speed). Uses weighted formulas.
- **AI Statistics**: Generated by Coach AI (Skill Rating, Trend, Confidence, Coach Priority, Learning Stage, Breakthrough, Regression). Probabilistic.

### SAMPLE SIZE RULE
Every statistic contains: Value, Sample Size, Confidence. Never display percentages without sample size.

### CONFIDENCE CALCULATION
Depends on: Sample Size, Recent Sessions, Equipment Stability, Training Consistency, Environmental Stability.
Scale: Very Low, Low, Medium, High, Very High.

### ROLLING WINDOWS
- Current Session
- Last 5 Sessions
- Last 10 Sessions
- Last 30 Days
- Last 90 Days
- Career
**Rule**: Never rely on one session only.

### TREND DETECTION
Compares Current Window vs Previous Window. Allowed Values: Rapid Improvement, Improving, Stable, Plateau, Declining, Rapid Decline. Trend requires minimum sample size.

### OUTLIER DETECTION
One abnormal session must not distort statistics. Possible Outliers: House Cue, New Tip, New Table, Tournament Pressure, Sleep <5h, Health Issue, Equipment Failure. Outliers are marked but never deleted.

### WEIGHTED SESSIONS
- Competition: Weight = 1.0
- Hybrid: Weight = 0.8
- Training: Weight = 0.6
- Experiment: Weight = 0.4
- Recovery: Weight = 0.3
**Purpose**: Prevent experimental practice from corrupting true skill statistics.

### ADAPTATION WINDOW
After changing Cue, Tip, Table, Balls, Glasses, Bridge → Pool OS enters Adaptation Mode (Default 3 sessions). During this period: Trend sensitivity decreases, Skill Ratings update more slowly.

### MISSING DATA
Missing values are NEVER estimated. Display: Unknown, Not Recorded, Insufficient Data. Never invent data.

### SESSION COMPLETENESS
- 100%: All required data
- 75%: Minor fields missing
- 50%: Several important fields missing
- Below 50%: Low statistical confidence (Coach AI should reduce recommendation confidence)

### DATA VALIDATION
Every session must pass validation. Examples: Scratch count <= Total shots, Run Out <= Total racks, Golden Break <= Break count, Break count == Rack count. Invalid records are rejected.

### HISTORICAL IMMUTABILITY
Past sessions are immutable. If edited, Version History must be preserved. Coach AI should know when historical data changed.

### EXPORT FORMAT
Every statistic must be exportable as JSON, CSV, SQLite, PostgreSQL. Future API compatibility is mandatory.

### GOLDEN RULE
Statistics describe reality. They never explain it. Only Coach AI explains WHY.

---

## 10_STATISTICS_ENGINE_PART_02.md

**Purpose**: Defines every statistical formula used by Pool OS. Every metric must be deterministic. The same input must always produce the same output.

### GENERAL RULES
- All percentages use: Successful Events / Total Attempts
- All values are stored as: Raw Count, Percentage, Rolling Average, Career Average, Trend, Confidence
- **Golden Rule**: Statistics measure WHAT happened. They NEVER decide WHY.

### STROKE METRICS
| Metric | Formula | Notes |
|--------|---------|-------|
| Stroke Success Rate | Successful Stroke / Total Stroke | Stroke success is NOT pot success |
| Stroke Hitch Rate | Stroke Hitch Count / Total Stroke | Lower is better |
| Steering Rate | Steering Count / Total Stroke | Cue changes direction during delivery |
| Grip Tension Warning | Grip Error / Total Stroke | Early detection of tight grip |

### POTTING METRICS
| Metric | Formula |
|--------|---------|
| Overall Pot Success | Pocketed Balls / Pot Attempts |
| Long Pot Success | Successful Long Pots / Long Pot Attempts |
| Short Pot Success | Successful Short Pots / Short Pot Attempts |
| Rail Pot Success | Successful Rail Pots / Rail Pot Attempts |
| Thin Cut Success | Successful Thin Cuts / Thin Cut Attempts |

### POSITION PLAY METRICS
| Metric | Formula |
|--------|---------|
| Perfect Position | Perfect / Position Attempts |
| Good Position | Good / Position Attempts |
| Playable Position | Playable / Position Attempts |
| Recovery Position | Recovery / Position Attempts |
| Bad Position | Bad / Position Attempts |
| **Position Score** | Perfect×100 + Good×80 + Playable×60 + Recovery×35 + Bad×0, then average |

### BREAK METRICS
| Metric | Formula |
|--------|---------|
| Break Success | Successful Break / Break Attempts |
| Dry Break | Dry Break / Break Attempts |
| Golden Break | Golden Break / Break Attempts |
| Average Balls Pocketed | Balls Pocketed / Break Attempts |
| Cue Ball Control | Controlled Cue Ball / Break Attempts |
| Break Spread | Excellent=100, Good=80, Average=60, Poor=30, Cluster=0, then average |

### SAFETY METRICS
| Metric | Formula |
|--------|---------|
| Safety Success | Successful Safety / Safety Attempts |
| Hook Success | Successful Hooks / Safety Attempts |
| Escape Success | Successful Escapes / Escape Attempts |

### DECISION METRICS
| Metric | Formula |
|--------|---------|
| Correct Decision | Correct Decision / Decision Count |
| Attack Success | Successful Attack / Attack Attempts |
| Safety Decision Rate | Safety Decision / Decision Count |
| Training Decision Rate | Training Decision / Decision Count |

### PATTERN PLAY METRICS
| Metric | Formula |
|--------|---------|
| Run Out | Successful Run Outs / Opportunities |
| Longest Run | Maximum Consecutive Balls (stored separately, NOT averaged) |
| Average Balls Per Visit | Pocketed Balls / Visits |
| Pattern Error | Pattern Mistake / Pattern Opportunities |

### SPIN METRICS
| Metric | Formula |
|--------|---------|
| Side Spin Usage | Side Spin Shots / Total Shots |
| Natural Route Usage | Natural Route / Position Attempts |
| Center Ball Usage | Center Ball / Total Shots |
| Draw Usage | Draw / Total Shots |
| Follow Usage | Follow / Total Shots |

### MENTAL METRICS
| Metric | Formula |
|--------|---------|
| Confidence | Scale 1-10, Rolling Average |
| Focus | Scale 1-10, Rolling Average |
| Pressure Performance | Successful Pressure Shots / Pressure Attempts |

### LEARNING METRICS
| Metric | Formula |
|--------|---------|
| Training Completion | Completed Goals / Training Goals |
| Constraint Compliance | Constraint Followed / Constraint Opportunities |
| Experiment Success | Useful Experiments / Experiments |

### CONSISTENCY METRICS
| Metric | Formula |
|--------|---------|
| Session Consistency | 100 - (Standard Deviation × Weight), Higher = Better |
| Week Consistency | Average of Last 5 Sessions |
| Month Consistency | Average of Last 20 Sessions |

### ROLLING AVERAGES (Every Metric Stores)
- Current Session
- Last 5 Sessions
- Last 10 Sessions
- Last 30 Days
- Career Average
- Trend
- Confidence

### MINIMUM SAMPLE SIZES
| Metric | Minimum Sample |
|--------|---------------|
| Stroke | 300 |
| Break | 100 |
| Position | 300 |
| Safety | 100 |
| Decision | 200 |
| Long Pot | 200 |
| Pattern | 100 |
| Jump | 50 |
| Bank | 100 |
| Combination | 100 |

Before reaching minimum sample → Display: Low Confidence.

---

## 10_STATISTICS_ENGINE_PART_03.md

**Purpose**: Defines the Event Engine. Every shot is represented by a collection of Events. Coach AI analyzes Events, NOT shots.

### CORE PRINCIPLE
One Shot → Many Events. Example: Long Pot + Thin Cut + Natural Route + Center Ball + Perfect Position + Good Stroke + Training Constraint Followed.

### EVENT HIERARCHY
Player → Session → Rack → Shot → Events. Events are always attached to ONE Shot.

### EVENT CATEGORIES (10 Categories)
1. **Execution**: Stroke Smooth, Stroke Hitch, Grip Tight, Grip Loose, Steering, Head Lift, Bridge Stable, Bridge Unstable, Follow Through Complete, Follow Through Short, Tip Contact Center/High/Low/Left/Right, Miscue, Double Hit, Push Shot, Cue Slip
2. **Position**: Perfect/Good/Playable/Recovery/Bad Position, Natural Route, Force Route, Unexpected Kiss, Traffic, Cluster Created/Solved, Scratch Risk, Scratch, Cue Ball Frozen
3. **Decision**: Correct/Incorrect Decision, Attack, Safety, Two Way Shot, Kick, Bank, Jump, Combination, Intentional Foul, Push Out
4. **Pattern**: Run Out Opportunity/Success, Pattern Error, Wrong Key Ball, Wrong Break Ball, Recovery Pattern, Early Problem Solved, Late Problem Created, Cluster Management
5. **Break**: Legal Break, Dry Break, Golden Break, Wing Ball, One Ball Pocketed, Cue Ball Controlled, Scratch On Break, Power Break, Soft Break, Cut Break, Head Ball Break, Second Ball Break, Excellent Spread, Poor Spread
6. **Mental**: Confident, Hesitation, Rushed, Overthinking, Calm, Focused, Frustrated, Tilt, Momentum, Pressure Shot, Clutch Shot
7. **Training**: No Side Spin, Center Ball Only, Draw Only, Follow Only, Natural Route, Break Cue Practice, 10-ball Practice, Safety Practice, Experiment, Constraint Violated, Learning Shot
8. **Equipment**: Carbon/Wood/House Cue, Break Cue, New/Old Tip, New Cloth, New Balls, New Table, Glasses, Bridge Extension, Mechanical Bridge
9. **Environment**: Cold/Hot Room, Humidity, Tournament, Practice, Match, Noise, Audience, Time Pressure
10. **Special**: Lucky Pot, Lucky Safety, Fluke Position, Kick In, Double Kiss, Unexpected Scratch, Golden Opportunity, Missed Opportunity, Breakthrough Shot, Highlight Shot

### EVENT PROPERTIES
- Event ID, Category, Timestamp, Rack Number, Shot Number, Severity, Confidence, Player Note, AI Note

### EVENT SEVERITY
- Allowed Values: Info, Minor, Moderate, Major, Critical
- Example: Stroke Hitch = Major, Scratch = Critical, Natural Route = Info

### EVENT CONFIDENCE
- Every detected event contains confidence (e.g., Stroke Hitch 92%, Bridge Instability 61%, Overthinking 38%).

### MULTIPLE EVENTS
- One shot may contain unlimited events.

### EVENT TIMELINE
- Coach AI stores event order (e.g., Pre Shot → Stroke Hitch → Pot Success → Unexpected Kiss → Recovery Position → Mental Confidence).

### EVENT FREQUENCY
- Every event tracks: Today, Last 5 Sessions, Last Month, Career, Trend, Confidence.

### EVENT CORRELATION
Pool OS automatically detects relationships. Examples:
- Stroke Hitch → Long Pot Miss (84%)
- Grip Tight → Steering (79%)
- Fatigue → Decision Error (66%)
- Natural Route → Position Success (88%)

### EVENT CHAINS
- Coach AI analyzes sequences instead of isolated events.
- Example: Fatigue → Grip Tight → Stroke Hitch → Miss → Mental Pressure → Bad Decision

### EVENT TAGS
Examples: Long Pot, Pressure, Tournament, Training, Breakthrough, Recovery, Creative, High EV, Low EV.

### EVENT FILTERS
Player can filter by: Category, Session, Date, Equipment, Training Goal, Mental State, Table, Cue, Difficulty.

### GOLDEN RULE
- Events are facts.
- Statistics summarize Events.
- Coach AI explains Events.

---

## 10_INTELLIGENCE_ENGINE.md

**Purpose**: Transforms statistics and events into insights. Does NOT generate coaching advice. Discovers patterns, relationships, and hidden information. Coach AI consumes these insights to produce recommendations.

### ENGINE PIPELINE
Raw Data → Events → Statistics Engine → Intelligence Engine → Coach AI → Recommendation

### RESPONSIBILITIES (6 Major Tasks)
1. Pattern Detection
2. Trend Analysis
3. Correlation Analysis
4. Root Cause Discovery
5. Progress Detection
6. Risk Prediction

### PATTERN DETECTION
- Purpose: Find repeated behaviors (Repeated Scratch, Repeated Stroke Hitch, Repeated Over Position, Repeated Wrong Speed, Repeated Bad Decision, Repeated Bridge Error, Repeated Long Pot Miss, Repeated Safety Error).
- A pattern requires: Minimum 3 occurrences within 5 sessions.
- Output: Pattern Name, Frequency, Confidence, Trend, Severity.

### TREND ANALYSIS
- Purpose: Determine whether a skill is improving or declining.
- Compares: Current Session → Last 5 Sessions → Last 10 Sessions → Last Month → Career.
- Allowed Values: Rapid Improvement, Improving, Stable, Plateau, Declining, Rapid Decline.

### CORRELATION ANALYSIS
Pool OS discovers relationships. Examples:
- Stroke Hitch → Long Pot Miss (87%)
- Fatigue → Decision Error (74%)
- No Side Spin → Natural Route Improvement (91%)
- Break Spread → Run Out Opportunity (82%)
- Cue Change → Stroke Consistency (66%)
**Rule**: Coach AI uses correlations instead of assumptions.

### ROOT CAUSE DISCOVERY
- Purpose: Estimate the most probable cause.
- Inputs: Statistics, Events, Player Notes, Equipment, Context.
- Outputs: Primary Cause, Secondary Cause, Confidence, Evidence.
- **Rule**: Never use only one event.

### PROGRESS DETECTION
- Purpose: Identify improvements invisible to win rate.
- Examples: Recovery Position ↑, Decision Quality ↑, Mental Stability ↑, Natural Route Usage ↑, Side Spin Dependency ↓.
- Output: Improvement, Evidence, Confidence.

### RISK PREDICTION
- Purpose: Predict future problems before they appear.
- Examples:
  - Stroke Hitch frequency increasing → High Risk
  - Long Pot decline next week
  - Fatigue accumulating → High Mental Risk
  - Break becoming inconsistent → Medium Risk
  - Pattern becoming predictable → Medium Tactical Risk

### ADAPTATION DETECTION
- Purpose: Recognize adaptation periods.
- Triggers: New Cue, New Tip, New Glasses, New Table, New Balls, New Cloth, Travel, Tournament.
- Output: Adaptation Active, Expected Duration, Confidence.

### BREAKTHROUGH DETECTION
- Conditions: Improvement ≥ 5 consecutive sessions AND Confidence > 80%.
- Output: Breakthrough, Skill, Evidence, Suggested Action.

### PLATEAU DETECTION
- Conditions: Trend = Stable for 8 sessions.
- Output: Plateau, Recommendation = Change Practice Method.

### REGRESSION DETECTION
- Conditions: Decline ≥ 5 sessions AND Confidence > 80%.
- Output: Regression, Possible Causes, Risk Level.

### CONSISTENCY ANALYSIS
- Purpose: Measure stability (Stroke, Decision, Position, Break, Mental).
- **Rule**: High consistency is rewarded more than isolated peak performance.

### PLAYER PROFILE UPDATE
The engine continuously updates:
- Playing Style, Risk Appetite, Preferred Position, Spin Dependency, Break Style, Decision Style, Mental Profile, Learning Speed, Adaptability.
- Player profile evolves automatically.

### INSIGHT OBJECT
Each insight contains: Insight ID, Category, Priority, Confidence, Evidence, Supporting Events, Supporting Statistics, Timestamp.

**Example**: Insight = Stroke Hitch Increasing, Priority = High, Confidence = 92%, Evidence = 18 events, 6 sessions.

### INSIGHT PRIORITY
- Critical, High, Medium, Low, Informational.
- **Rule**: Coach AI should only display Top 5 insights per session.

### GOLDEN RULE
- The Intelligence Engine never gives advice.
- It only discovers truth.
- Coach AI decides what to do with that truth.

---

## 11_DATABASE_SCHEMA_PART_01.md

**Purpose**: Defines core database schema. Supports Statistics Engine, Event Engine, Intelligence Engine, Coach Engine. Hierarchy: Player → Session → Rack → Shot → Event.

### DATABASE DESIGN PRINCIPLES
- UUID Primary Keys (v4)
- Soft Delete (deleted_at, never permanently delete)
- CreatedAt, UpdatedAt, Version
- Audit Friendly
- Offline First
- SQLite Compatible, PostgreSQL Compatible
- JSON fields allowed only for metadata_json and future_extensions

### TABLES

**Player**: id (UUID), name, nickname, dominant_hand, language, country, avatar, created_at, updated_at

**Equipment**: id, player_id, type (Playing Cue, Break Cue, Jump Cue, House Cue), brand, model, shaft, tip, weight, length, balance_point, joint, is_active, created_at

**Session**: id, player_id, session_type (Practice, Competition, Hybrid, Recovery, Experiment), training_goal, date, location, table_brand, cloth, balls, cue_used, sleep_hours, fatigue, mental_state, duration, notes, created_at

**Rack**: id, session_id, rack_number, game_type (8 Ball, 9 Ball, 10 Ball), break_player, winner, break_result, run_out, golden_break, created_at

**Shot**: id, rack_id, shot_number, shot_type, result (Pocketed, Missed, Safety, Foul, Scratch, Push, Jump, Kick, Combination), difficulty, position_quality, cue_ball_control, decision, confidence_before, confidence_after, player_note, created_at

**Event**: id, shot_id, category, event_type, severity (Info, Minor, Moderate, Major, Critical), confidence, value, metadata_json, created_at

**TrainingGoal**: id, name_en, name_vi, category, description, active

**Constraint**: id, name, description (training limitations like No Side Spin, Center Ball Only, etc.)

**EquipmentChange**: id, session_id, equipment_type, old_value, new_value, reason (tracks adaptation)

**CoachInsight**: id, session_id, category, priority, confidence, title, description, supporting_events, supporting_statistics, created_at

**CoachRecommendation**: id, session_id, priority, type (Immediate, Next Session, Weekly, Monthly, Long Term), title, description, expected_gain, confidence, completed, created_at

**SkillRating**: id, player_id, skill, rating, confidence, trend, learning_stage, last_updated

**SessionSummary**: id, session_id, overall_learning, overall_execution, overall_decision, overall_discipline, overall_consistency, breakthrough, regression, coach_summary, next_focus, created_at

### RELATIONSHIPS
- Player → Equipment
- Player → Session → Rack → Shot → Event
- Session → CoachInsight → CoachRecommendation → SessionSummary
- Player → SkillRating

### INDEXES
Create indexes for: player_id, session_id, rack_id, shot_id, created_at, skill, event_type, training_goal, session_type

### GOLDEN RULE
- Database stores facts.
- Database never stores assumptions.
- Coach AI creates assumptions.

---

## 03_DOMAIN_DEFINITIONS_DRILLS_PART_01.md

**Purpose**: Defines the Drill System. A Drill is a structured practice activity designed to improve specific skills. Drills are first-class objects in Pool OS.

### CORE PRINCIPLE
- Matches measure performance.
- Drills build performance.
- Both are equally important.

### DRILL STRUCTURE (Every Drill Contains)
Name, Category, Difficulty, Target Skills, Setup, Objective, Rules, Success Criteria, Recommended Repetitions, Estimated Duration, Coach Notes.

### DRILL CATEGORIES
Stroke, Position, Cue Ball Control, Pattern Play, Break, Safety, Kick, Bank, Jump, Combination, Mental, Decision Making, Competition, Custom.

### DIFFICULTY LEVELS
1. Foundation
2. Beginner
3. Intermediate
4. Advanced
5. Elite

### TARGET SKILLS
Each Drill trains one Primary Skill + optional Secondary Skills.
Example: Long Straight Drill → Primary: Stroke, Secondary: Mental, Consistency.

### DRILL SESSION FLOW
Warm Up → Practice Sets → Rest → Evaluation → Reflection.

### REPETITION
Each drill contains Recommended Sets × Recommended Repetitions.
Example: 5 Sets × 20 Shots.

### SUCCESS CRITERIA
Every drill must define success. Examples:
- Pocket 18 / 20
- Position Score ≥ 80
- No Stroke Hitch for 30 consecutive shots

### FAILURE CRITERIA
Examples: Scratch, Miss, Wrong Speed, Wrong Position, Constraint Violation, Stroke Hitch.

### DRILL MODES
Normal, Timed, Challenge, Competition, Random, Constraint, Adaptive.

### ADAPTIVE MODE
Coach AI automatically changes difficulty.
- If Success > 85% → Increase difficulty.
- If Success < 60% → Reduce difficulty.
- Target: 70~80% Success Rate.

### CONSTRAINT MODE EXAMPLES
Center Ball Only, No Side Spin, One Rail Minimum, Draw Only, Follow Only, Weak Hand, Bridge Extension, House Cue, Break Cue Only.

### DRILL SCORE
Each drill records: Execution, Position, Decision, Discipline, Consistency, Learning.
**No Overall Score**.

### DRILL METRICS
Attempts, Success, Success %, Average Position, Average Time, Consistency, Trend, Confidence.

### DRILL HISTORY
Coach AI stores: Today, Last Week, Last Month, Career, Best Record, Personal Best.

### PERSONAL BEST EXAMPLES
- 42 Consecutive Stop Shots
- 27 Long Pots
- 18 Perfect Positions
- 12 Successful Breaks

### BREAKTHROUGH
Coach AI detects: New Personal Best → Highlight Achievement.

### PLATEAU
No improvement for 8 Drill Sessions → Suggest New Drill.

### DRILL TAGS
Stroke, Position, Recovery, Pressure, Long Pot, Short Pot, Rail, Natural Route, Side Spin, Center Ball, Break, Pattern, Competition, Custom.

### GOLDEN RULE
- Drills are the fastest path to improvement.
- Pool OS must prioritize drill performance over isolated match results.

### BUILT-IN DRILLS (20 Default Drills)
1. Stop Shot Drill
2. Long Straight Drill
3. Wagon Wheel
4. Mighty X
5. Line Drill
6. L Drill
7. Circle Drill
8. Progressive Draw Drill
9. Progressive Follow Drill
10. Break Accuracy Drill
11. Break Speed Drill
12. Cue Ball Box Drill
13. Safety Distance Drill
14. Kick System Drill
15. Bank Shot Drill
16. Ghost Challenge
17. Race Simulation
18. Pressure Shot Drill
19. Recovery Position Drill
20. Pattern Recognition Drill

---

## 12_API_SPECIFICATION_PART_01.md

**Purpose**: Defines internal API contracts. All UI components communicate ONLY through these APIs. Business logic must never exist inside UI components.

### API DESIGN PRINCIPLES
- REST-like service architecture
- Strong typing
- Immutable input
- Predictable output
- Error-first handling
- Async ready

### SERVICES (13 Modules)
1. **PlayerService**: createPlayer(), updatePlayer(), getPlayer(), deletePlayer(), getPlayerProfile(), getCareerSummary()
2. **EquipmentService**: createEquipment(), updateEquipment(), deleteEquipment(), setActiveCue(), getEquipmentHistory(), recordEquipmentChange()
3. **SessionService**: createSession(), updateSession(), finishSession(), deleteSession(), getSession(), getRecentSessions(), duplicateSession()
   - Session Object: id, sessionType, date, location, trainingGoal, equipment, notes, status
4. **RackService**: createRack(), finishRack(), deleteRack(), getRack(), updateRack()
   - Rack Object: rackNumber, gameType, winner, breakPlayer, breakResult, runOut, goldenBreak
5. **ShotService**: createShot(), updateShot(), deleteShot(), undoShot(), redoShot(), getShot(), getShotsByRack()
   - Shot Object: shotType, potResult, position, cueBallControl, decision, confidence, note, events[]
6. **EventService**: addEvent(), removeEvent(), updateEvent(), getEvents(), getEventTimeline(), getEventsByCategory()
   - Event Object: category, eventType, severity, confidence, metadata
7. **StatisticsService**: calculateSession(), calculateCareer(), calculateRollingAverage(), calculateTrend(), calculateConsistency(), calculateSkillScore(), rebuildStatistics()
8. **InsightService**: generateInsights(), detectPatterns(), detectCorrelations(), detectBreakthrough(), detectRegression(), detectPlateau()
9. **CoachService**: generateSessionReview(), generateRecommendations(), generateWeeklyReview(), generateMonthlyReview(), generateTrainingPlan(), generateRecoveryPlan()
10. **DrillService**: getBuiltInDrills(), createCustomDrill(), recordDrill(), evaluateDrill(), getPersonalBest(), recommendNextDrill()
11. **TrainingProgramService**: createProgram(), generateProgram(), updateProgram(), completeProgram(), getCurrentWeek(), getCurrentDay(), recommendTodayTraining()
12. **DashboardService**: getDashboard(), getQuickStats(), getRecentTrend(), getSkillRadar(), getHeatMap(), getAchievements()
13. **ExportService**: exportCSV(), exportJSON(), exportSQLite(), backupDatabase(), restoreDatabase()

### STANDARD RESPONSE
Every API returns: `{ success, data, error, timestamp, version }`

### ERROR CODES
- 400: Validation Error
- 401: Unauthorized
- 404: Not Found
- 409: Conflict
- 422: Invalid State
- 500: Unexpected Error

### VERSIONING
- API Version: v2
- Future changes must remain backward compatible.

### GOLDEN RULE
- UI never accesses the database directly.
- Every action must pass through the Service Layer.

---

## 13_FOLDER_STRUCTURE.md

**Purpose**: Defines complete project structure. Every file must belong to a clearly defined layer. Business logic must never be mixed with UI.

### ARCHITECTURE
Feature First + Clean Architecture + Domain Driven Design.

### ROOT STRUCTURE
```
src/
  app/
  core/
  features/
  shared/
  services/
  database/
  ai/
  hooks/
  utils/
  constants/
  assets/
  types/
```

### LAYER RESPONSIBILITIES
- **app/**: Application bootstrap, Routing, Theme, Localization, Navigation, Splash, Authentication
- **core/**: Business models, Enums, Interfaces, Base Classes, Domain Objects. No UI, No API.
- **features/**: Everything user sees. Each feature is independent.
  - Structure: components/, pages/, hooks/, services/, repository/, models/, types/, constants/, utils/
  - Examples: dashboard/, session/, rack/, shot/, event/, drill/, coach/, statistics/, analytics/, equipment/, profile/, settings/
- **shared/**: Reusable UI components (Button, Card, Dialog, Modal, Loading, Chart, Progress, Avatar, Badge). No business logic.
- **database/**: schema/, migrations/, repositories/, sqlite/, seed/. Only database code.
- **ai/**: coach/, insight/, recommendation/, statistics/, prompts/, parser/. Never import UI.
- **services/**: Application services (player, session, rack, shot, event, statistics, coach, drill).
- **hooks/**: Reusable hooks (useSession, useShot, useStatistics, useCoach, useTheme).
- **utils/**: Pure functions only (Date, Math, Formatting, UUID, Parser, Validation).
- **constants/**: Colors, Spacing, Icons, Routes, Animation, Training Goals.
- **assets/**: Images, Icons, Fonts, Lottie.
- **types/**: Global TypeScript types. Never duplicate interfaces.

### IMPORT RULES
**Allowed**: Feature → Shared → Core → Utils
**Forbidden**: Shared → Feature, Core → Feature, AI → UI

### DEPENDENCY FLOW
- UI → Feature → Service → Repository → Database
- AI → Statistics → Database

### FILE SIZE TARGETS
- Target: 200 lines
- Warning: 400 lines
- Maximum: 600 lines (split afterwards)

### COMPONENT SIZE
- Small: <100 lines
- Medium: 100~250 lines
- Large: 250~400 lines
- Very Large: Split immediately

### NAMING CONVENTIONS
- Components: PascalCase
- Hooks: camelCase
- Interfaces: IPlayer
- Enums: SessionType
- Files: kebab-case

### TESTS
Every feature contains `__tests__/`

### GOLDEN RULE
- A developer should locate any file within 30 seconds without documentation.

---

## 14_CODING_STANDARDS.md

**Purpose**: Defines mandatory coding standards for the entire project. Consistency is more important than personal coding style.

### GENERAL PRINCIPLES
- Readable > Clever
- Simple > Complex
- Explicit > Implicit
- Maintainable > Fast
- Correct > Short

### LANGUAGE
- TypeScript Only
- Strict Mode Enabled
- Never use `any`
- Prefer interfaces over type aliases when modeling entities

### COMMENTS
- Write code that explains itself
- Only comment WHY
- Never comment WHAT
- Bad: `// increment counter`
- Good: `// Prevent duplicate session creation after reconnect`

### FUNCTION RULES
- One responsibility per function
- Return predictable results
- Avoid hidden side effects
- Target: < 40 lines
- Maximum: 80 lines

### COMPONENT RULES
- One responsibility per React Component
- Target: < 150 lines
- Maximum: 300 lines
- Split immediately after maximum

### FILE RULES
- Target: 200 lines
- Maximum: 500 lines
- Split by responsibility

### VARIABLE NAMES
- Use descriptive names
- Good: `sessionStatistics`, `shotHistory`, `trainingGoal`
- Bad: `data`, `temp`, `value`, `item`, `abc`

### BOOLEAN NAMES
- Always start with: `is`, `has`, `can`, `should`, `allow`
- Examples: `isFinished`, `hasScratch`, `canUndo`, `shouldAnalyze`

### CONSTANTS
- Use UPPER_SNAKE_CASE
- Example: `MAX_SESSION_LENGTH`, `MIN_SAMPLE_SIZE`, `DEFAULT_LANGUAGE`

### ENUMS
- Use PascalCase
- Examples: `SessionType`, `ShotResult`, `PositionQuality`, `SkillCategory`

### INTERFACES
- Prefix with `I`
- Examples: `IPlayer`, `ISession`, `IShot`, `IEvent`

### CLASSES
- Use only when necessary
- Prefer: Pure Functions, Composition

### HOOKS
- Prefix with `use`
- Examples: `useSession`, `useStatistics`, `useCoach`, `useDashboard`

### ASYNC
- Always use `async/await`
- Never use nested promises

### ERROR HANDLING
- Never ignore errors
- Always return meaningful messages
- Never expose internal stack traces to UI

### NULL SAFETY
- Never assume data exists
- Always validate
- Prefer: Optional Chaining (`?.`), Nullish Coalescing (`??`)

### IMMUTABILITY
- Never mutate state directly
- Always create new objects

### STATE MANAGEMENT
- Global: Only when necessary
- Local: Preferred

### BUSINESS LOGIC
- Never inside UI
- Never inside Components
- Never inside Pages
- Business Logic belongs to Services

### DATABASE ACCESS
- Never access database directly from UI
- Always: UI → Repository → Service → Database

### AI RULES
- AI never writes to database directly
- AI only consumes Services

### IMPORT ORDER
1. React
2. Third-party
3. Core
4. Features
5. Shared
6. Styles

### TYPES
- Never duplicate interfaces
- Reuse existing models

### MAGIC NUMBERS
- Forbidden
- Create constants instead
- Bad: `if(score > 83)`
- Good: `if(score > SKILL_BREAKTHROUGH_THRESHOLD)`

### LOGGING
- Development: Verbose
- Production: Errors only

### PERFORMANCE
- Lazy load pages
- Memoize expensive calculations
- Avoid unnecessary re-renders

### TESTABILITY
- Every service should be testable independently
- No hidden dependencies

### NAMING CONVENTIONS
- PascalCase: Components, Classes, Enums
- camelCase: Functions, Variables, Hooks
- UPPER_SNAKE_CASE: Constants

### GIT COMMIT MESSAGES
- `feat:`
- `fix:`
- `refactor:`
- `docs:`
- `test:`
- `style:`
- `chore:`

### GOLDEN RULE
- Every generated code should be understandable by another developer after six months without additional explanation.

---

## 15_COMPONENT_LIBRARY.md

**Purpose**: Defines every reusable UI component. All screens must be built by composing existing components. Never duplicate UI.

### DESIGN PRINCIPLES
Simple, Reusable, Composable, Responsive, Accessible, Bilingual Ready, Dark Mode Ready, Light Mode Ready.

### DESIGN SYSTEM
**Colors**: Primary (Red), Secondary (Gray), Background (White), Surface (Light Gray), Danger (Red), Warning (Orange), Success (Green), Info (Blue).

**Spacing**: 4, 8, 12, 16, 24, 32, 48, 64. Never use arbitrary spacing.

**Border Radius**: Small (8), Medium (12), Large (16), Card (20).

**Shadow**: Light, Medium, Heavy. Only predefined shadows.

### UI COMPONENTS
- **Button**: Primary, Secondary, Danger, Ghost, Outline, Icon, Loading, Disabled
- **Card**: Statistic Card, Session Card, Coach Card, Equipment Card, Insight Card, Goal Card
- **StatCard**: Title, Value, Trend, Icon, Confidence
- **ProgressBar**: For Skill Rating, Learning, Completion, Confidence, Target, Trend
- **SkillBar**: 0~100, Animated, Color by score
- **Charts**: Line Chart, Bar Chart, Radar Chart, Heat Map, Timeline, Distribution. Avoid Pie Chart, 3D Chart.
- **ListItem**: Avatar, Title, Subtitle, Right Value, Chevron, Optional Badge
- **SectionHeader**: Title, Subtitle, Optional Action
- **Modal**: Confirmation, Editor, Selection, Statistics, Coach Review
- **BottomSheet**: Quick Actions, Filters, Shot Entry, Event Selection
- **Input**: Text, Number, Dropdown, Slider, Toggle, Search, Tag Selector, Rating
- **ShotEntryCard**: Shot Type, Result, Position, Events, Notes, Quick Save
- **EventChip**: Event Icon, Event Name, Severity, Tap to edit
- **CoachCard**: Priority, Title, Description, Confidence, Action Button
- **SessionSummary**: Overview, Statistics, Insights, Coach, Next Focus
- **SkillRadar**: Stroke, Position, Decision, Break, Safety, Mental, Pattern
- **AchievementCard**: Title, Date, Description, Progress
- **EmptyState**: Helpful illustration, Explanation, Suggested action. Never show blank pages.
- **LoadingState**: Skeleton Loading, Progress Indicator, Estimated Time. Never freeze UI.
- **ErrorState**: Friendly Message, Retry Button, Details

### BILINGUAL
Every component accepts: `label_en`, `label_vi`, `description_en`, `description_vi`. Never hardcode UI text.

### ACCESSIBILITY
Minimum Touch Size: 44px. High Contrast, Dynamic Font, Screen Reader Labels, Keyboard Support.

### RESPONSIVE
Desktop, Tablet, Mobile. Must adapt automatically.

### ANIMATION
Fast (150ms), Normal (250ms), Slow (350ms). Use subtle animation only.

### ICONOGRAPHY
Lucide Icons. Consistent size: 20, 24, 32. Avoid mixing icon libraries.

### GOLDEN RULE
- Users should immediately recognize every screen as part of the Pool OS ecosystem.

---

## 20_PRODUCT_BACKLOG_PART_01.md

**Purpose**: Defines the implementation backlog for Pool OS. Every feature is represented as a User Story, implemented incrementally through Sprints.

### PRIORITY SCALE
- P0 = Critical
- P1 = High
- P2 = Medium
- P3 = Low

### COMPLEXITY
XS, S, M, L, XL

### EPICS AND USER STORIES

**EPIC 01 - PLAYER**
- US-001: Create Player Profile (P0, XS)
- US-002: Player Preferences (P1, S)

**EPIC 02 - EQUIPMENT**
- US-003: Create Equipment (P0, S)
- US-004: Switch Equipment (P1, XS)

**EPIC 03 - SESSION**
- US-005: Create Session (P0, S)
- US-006: Finish Session (P0, S)
- US-007: Delete Session (P1, XS)
- US-008: Duplicate Session (P2, XS)

**EPIC 04 - RACK**
- US-009: Create Rack (P0, XS)
- US-010: Finish Rack (P0, XS)
- US-011: Delete Rack (P2, XS)

**EPIC 05 - SHOT**
- US-012: Add Shot (P0, S)
- US-013: Edit Shot (P0, S)
- US-014: Delete Shot (P1, XS)
- US-015: Undo Shot (P1, M)
- US-016: Redo Shot (P1, M)

**EPIC 06 - EVENT**
- US-017: Attach Event (P0, S)
- US-018: Edit Event (P1, XS)
- US-019: Delete Event (P1, XS)
- US-020: Multiple Events (P0, M) - One shot supports unlimited events

**EPIC 07 - STATISTICS**
- US-021: Session Statistics (P0, M)
- US-022: Career Statistics (P1, L)
- US-023: Rolling Average (P1, L)
- US-024: Trend (P1, M)
- US-025: Consistency (P1, M)

**EPIC 08 - DASHBOARD**
- US-026: Today Dashboard (P0, M)
- US-027: Skill Dashboard (P1, M)
- US-028: Trend Dashboard (P1, M)
- US-029: Session History (P0, S)

**EPIC 09 - DRILL**
- US-030: Drill Library (P1, M)
- US-031: Start Drill (P1, M)
- US-032: Record Drill (P1, L)
- US-033: Personal Best (P2, M)

**EPIC 10 - EXPORT**
- US-034: Export JSON (P2, S)
- US-035: Export CSV (P2, S)
- US-036: Backup Database (P2, M)

### SPRINT MVP PLAN
- **Sprint 1**: US-001, US-003, US-005, US-009, US-012, US-017, US-021, US-026, US-029 → Working MVP
- **Sprint 2**: Statistics, Dashboard, Drill
- **Sprint 3**: Intelligence, Coach
- **Sprint 4**: Training Program, Achievements, Career

### DEFINITION OF DONE
A User Story is completed only if:
- Code completed
- UI completed
- Database updated

---

## 21_DEVELOPMENT_ROADMAP.md

**Purpose**: Defines the implementation order of Pool OS. Every Sprint must produce a usable product. Ship early, iterate fast.

### DEVELOPMENT PRINCIPLES
1. Working Software First
2. MVP Before AI
3. Data Before Intelligence
4. Intelligence Before Coach
5. Coach Before Automation

### PHASES

**PHASE 1 - FOUNDATION (2 Weeks)**
- Features: Player, Equipment, Session, Rack, Shot, Event, Local Database, Dashboard
- Deliverable: Pool OS can completely record one session

**PHASE 2 - STATISTICS (2 Weeks)**
- Features: Rolling Average, Trend, Position Score, Stroke Score, Break Score, Natural Route %, Side Spin %, Longest Run, Career Statistics
- Deliverable: Complete statistics dashboard

**PHASE 3 - DRILL (2 Weeks)**
- Features: Drill Library, Drill Session, Personal Best, Constraint Mode, Adaptive Difficulty
- Deliverable: Practice Mode

**PHASE 4 - INTELLIGENCE (3 Weeks)**
- Features: Pattern Detection, Trend Detection, Correlation, Root Cause, Breakthrough, Regression, Plateau
- Deliverable: Insights Page

**PHASE 5 - COACH AI (3 Weeks)**
- Features: Session Review, Recommendation, Weekly Review, Monthly Review, Learning Report
- Deliverable: Coach Screen

**PHASE 6 - TRAINING PROGRAM (2 Weeks)**
- Features: 4 Week Program, Adaptive Weekly Plan, Today's Mission, Recovery Mode, Program Progress
- Deliverable: Training Center

**PHASE 7 - CAREER (2 Weeks)**
- Features: Skill History, Achievements, Career Timeline, Milestones, Records
- Deliverable: Career Dashboard

**PHASE 8 - POLISH (2 Weeks)**
- Features: Animations, Dark Mode, Performance, Accessibility, Localization, Export, Backup, Crash Recovery
- Deliverable: Release Candidate

### MILESTONES
- M1: Session Logging
- M2: Statistics Engine
- M3: Drill System
- M4: Intelligence Engine
- M5: Coach AI
- M6: Training Program
- M7: Career Mode
- M8: Production Release

### SUCCESS METRICS
- Session Recording Time: < 2 Minutes
- App Startup: < 2 Seconds
- Dashboard Loading: < 500ms
- Crash Rate: < 0.5%
- AI Response: < 3 Seconds

### TECHNICAL DEBT
- Allowed: Minor UI Issues
- Not Allowed: Database Rewrite, Architecture Rewrite, State Management Rewrite

### REFACTOR POLICY
Refactor only if: Repeated code, Architecture violation, Performance bottleneck, Bug-prone logic. Otherwise: Ship first.

### RELEASE STRATEGY
Alpha (Internal) → Beta (Personal Daily Use) → RC (Stable Testing) → V2.0 (Public Release)

### VISION
Pool OS is not a score tracker. Pool OS is a complete operating system for pool players.

---

*Đã ghi nhận: 01_MATCH.md (20 terms), 02_POSITION.md (17 terms), 03_STROKE.md (18 terms), 04_SHOT.md (20 terms), 05_DECISION.md (20 terms), 06_SAFETY.md (20 terms), 07_BREAK.md (20 terms), 08_TRAINING.md (20 terms), 09_COACH_AI_RULEBOOK_PART_01.md (12 principles), 09_COACH_AI_RULEBOOK_PART_02.md (15 rules), 09_COACH_AI_RULEBOOK_PART_03.md (Skill Rating Engine), 09_COACH_AI_RULEBOOK_PART_04.md (Root Cause Analysis Engine), 09_COACH_AI_RULEBOOK_PART_05.md (Recommendation Engine), 09_COACH_AI_RULEBOOK_PART_06.md (Session Intelligence Engine), 10_STATISTICS_ENGINE_PART_01.md (Statistics Engine), 10_STATISTICS_ENGINE_PART_02.md (Calculation Specifications), 10_STATISTICS_ENGINE_PART_03.md (Event Engine), 10_INTELLIGENCE_ENGINE.md (Intelligence Engine), 11_DATABASE_SCHEMA_PART_01.md (Core Data Model), 03_DOMAIN_DEFINITIONS_DRILLS_PART_01.md (Drill System), 12_API_SPECIFICATION_PART_01.md (API Specification), 13_FOLDER_STRUCTURE.md (Folder Structure), 14_CODING_STANDARDS.md (Coding Standards), 15_COMPONENT_LIBRARY.md (Component Library), 20_PRODUCT_BACKLOG_PART_01.md (Product Backlog), 21_DEVELOPMENT_ROADMAP.md (Development Roadmap)*
*Cập nhật khi đọc thêm các file tiếp theo.*
