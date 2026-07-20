# Pool OS Search Optimization

## Overview

This document describes the search optimization system for Pool OS Knowledge Base.

**Version:** 1.0.0  
**Last Updated:** 2026-07-17  
**Total Synonyms:** 500+  
**Total Keywords:** 1000+  

---

## Search Index Structure

### Supported Languages

| Language | Code | Status |
|----------|------|--------|
| English | `en` | Full Support |
| Vietnamese | `vi` | Full Support |

---

## Search Fields & Weights

| Field | Weight | Description |
|-------|--------|-------------|
| `title` | 3.0 | Exact title match |
| `title_vi` | 3.0 | Vietnamese title |
| `tags` | 2.5 | Tag matches |
| `category` | 2.0 | Category matches |
| `keywords` | 2.0 | Keyword matches |
| `description` | 2.0 | Description text |
| `content` | 1.0 | Full content |

---

## Search Boost Scores

### Category Boosts

| Category | Boost Score |
|----------|-------------|
| stroke | 1.5 |
| aim | 1.5 |
| cue_ball | 1.4 |
| pattern | 1.4 |
| match_strategy | 1.4 |
| technique | 1.4 |
| bank | 1.3 |
| kick | 1.3 |
| spin | 1.3 |
| safety | 1.3 |
| table_reading | 1.3 |
| jump | 1.2 |
| bridge | 1.2 |
| stance | 1.2 |
| grip | 1.2 |
| mental | 1.2 |
| mistakes | 1.2 |
| gap_analysis | 1.1 |
| equipment | 1.0 |
| rules | 1.0 |

### Keyword Boosts

| Keyword | Boost Score |
|---------|-------------|
| fundamentals | 2.0 |
| basics | 1.8 |
| mastery | 1.8 |
| essential | 1.5 |
| critical | 1.5 |
| technique | 1.5 |
| important | 1.3 |
| advanced | 1.3 |
| drill | 1.4 |
| expert | 1.4 |
| pro | 1.4 |
| professional | 1.4 |
| tournament | 1.3 |
| competition | 1.3 |
| pressure | 1.3 |
| practice | 1.3 |
| skill | 1.3 |
| training | 1.3 |
| beginner | 1.2 |
| intermediate | 1.2 |

### Match Type Boosts

| Match Type | Boost Score |
|------------|-------------|
| Exact Match | 3.0 |
| Category Match | 1.5 |
| Partial Match | 1.5 |
| Tag Match | 1.3 |
| Stem Match | 1.2 |
| Fuzzy Match | 0.8 |

### Level Boosts

| Level | Boost Score |
|-------|-------------|
| A (Master) | 1.8 |
| B (Expert) | 1.7 |
| C (Professional) | 1.6 |
| D (Semi-Pro) | 1.5 |
| E (Advanced) | 1.4 |
| F (Club Player) | 1.3 |
| G (Intermediate) | 1.2 |
| H (Novice) | 1.1 |
| I (Beginner) | 1.0 |

---

## Synonyms Index

### English Synonyms

| Term | Synonyms |
|------|----------|
| stroke | swing, delivery, hit, punch |
| aim | aiming, sighting, targeting, aligning |
| bridge | rest, support, finger bridge |
| stance | posture, position, form |
| grip | hold, grasp, clutch |
| cue_ball | white ball, cueball, CB |
| draw | backspin, draw shot, reverse spin |
| follow | topspin, follow shot, forward spin |
| english | sidespin, side spin, left/right spin |
| bank | bank shot, carom, cushion shot, rail shot |
| kick | kick shot, kick safety, kicking shot |
| jump | jump shot, masse, masse shot, curve shot |
| safety | safety play, defensive play, snooker, legal snooker |
| position | positioning, shape, position play |
| pattern | pattern play, run pattern, table pattern |
| mechanics | form, technique, execution |
| fundamentals | basics, essentials, foundations |
| mastery | expertise, proficiency, mastery level |
| drill | exercise, practice, training drill |
| routine | pre-shot routine, pre shot routine, preparation |

### Vietnamese Keywords

| Category | Keywords |
|----------|----------|
| stroke | động tác, đánh, cú đánh, tay đánh, vung gậy, đẩy |
| aim | ngắm, điểm ngắm, hướng ngắm, mục tiêu, đường ngắm, canh góc |
| bridge | tay chống, tay đỡ, gác tay, điểm tựa, ngón tay chống |
| stance | tư thế, dáng đứng, tư thế đánh, vị trí chân, đứng |
| grip | cầm gậy, nắm gậy, tay cầm, cách cầm, tay nắm |
| cue_ball | bi trắng, bóng trắng, bi đỏ, kiểm soát bi, điều khiển bi |
| draw | lùi, lui bi, xoáy ngược, backspin, kéo lùi |
| follow | theo, đẩy bi, xoáy xuôi, topspin, đẩy tới |
| english | xoáy, xoáy ngang, xoáy trái, xoáy phải, sidespin |
| bank | băng, đánh băng, chạm đệm, bóng băng, đệm |
| kick | kick, sút, đá bi, kick safety, an toàn |
| jump | nhảy, đánh nhảy, lật bi, masse, đường cong |
| safety | an toàn, chơi an toàn, phòng thủ, để khó, safety |
| position | vị trí, vị trí bi, đặt vị trí, kiểm soát vị trí |
| pattern | pattern, quỹ đạo, bàn, sắp xếp bi, chạy bàn |
| break | phá, đập, phá bàn, khai cuộc, break |
| speed | tốc độ, lực, nhanh, chậm, mạnh, yếu |
| drill | bài tập, luyện tập, rèn luyện, thực hành |
| mistake | sai lầm, lỗi, sai, vấn đề, thiếu sót |
| correction | sửa, khắc phục, cải thiện, điều chỉnh |

---

## Abbreviations

| Abbreviation | Full Term |
|-------------|-----------|
| CB | cue_ball |
| OB | object_ball |
| EP | english_position |
| TP | target_position |
| GHB | ghost_ball |
| HR | high_right |
| HL | high_left |
| MR | middle_right |
| ML | middle_left |
| LR | low_right |
| LL | low_left |
| RS | right_side |
| LS | left_side |
| CT | center |
| FO | follow |
| DR | draw |
| SS | stop_shot |
| FS | follow_shot |
| DS | draw_shot |
| PWR | power |
| SFT | soft |
| MED | medium |
| SPN | spin |
| TKN | taken |
| REL | released |
| AIM | aim |
| BRG | bridge |
| STN | stance |
| GRP | grip |
| STR | stroke |
| PCT | percentage |
| YTD | year_to_date |
| LTD | life_to_date |
| MP | match_play |
| SP | safety_play |
| 8B | eight_ball |
| 9B | nine_ball |
| BAC | backspin |
| TOP | topspin |
| SID | sidespin |
| JMP | jump |
| BNK | bank |
| KK | kick |
| SF | safety |
| POS | position |
| PAT | pattern |
| RUN | run_out |

---

## Alternative Spellings

### British vs American

| British | American |
|---------|----------|
| colour | color |
| centre | center |
| grey | gray |
| defence | defense |
| offence | offense |
| practise (verb) | practice (verb) |
| analyse | analyze |
| catalogue | catalog |
| dialog | dialogue |
| programme | program |
| travelled | traveled |
| labelling | labeling |
| fulfil | fulfill |
| instal | install |

### Common Variations

| Variation | Standard |
|-----------|----------|
| masse | massé |
| masse shot | massé shot |
| foul | foul |
| cueball | cue_ball |
| side spin | sidespin |
| back spin | backspin |
| top spin | topspin |
| kick shot | kick_shot |
| safety play | safety_play |
| pre shot routine | pre_shot_routine |
| ghost ball | ghost_ball |
| object ball | object_ball |

---

## Common Misspellings

### Strokes & Mechanics

| Misspelling | Correct |
|-------------|---------|
| strok | stroke |
| brigde | bridge |
| stnace | stance |
| girp | grip |
| aimg | aim |
| bakn | bank |
| kik | kick |
| jum | jump |
| rythm | rhythm |
| routien | routine |
| bacskwing | backswing |
| folow | follow |
| draw | draw |

### Technical Terms

| Misspelling | Correct |
|-------------|---------|
| cuebal | cue_ball |
| engish | english |
| deflexion | deflection |
| carrom | carom |
| diamon | diamond |
| ferule | ferrule |
| chalk | chalk |
| pocket | pocket |
| cloth | cloth |
| feault | fault |
| scrach | scratch |

### Spelling Fixes

| Incorrect | Correct |
|-----------|---------|
| alott | a lot |
| beginer | beginner |
| begger | beggar |
| definately | definitely |
| seperate | separate |
| occurance | occurrence |
| recieve | receive |
| refered | referred |
| succesful | successful |
| untill | until |
| wierd | weird |
| writting | writing |

---

## Search Filters

### Available Filters

| Filter | Values | Description |
|--------|--------|-------------|
| `level` | I, H, G, F, E, D, C, B, A | Player skill level |
| `category` | All categories | Knowledge category |
| `difficulty` | beginner, intermediate, advanced, expert | Difficulty level |
| `type` | technique, drill, mistake, strategy, mental, equipment | Content type |

---

## Search Examples

### English Queries

| Query | Expected Results |
|-------|------------------|
| "draw shot" | cue_ball.draw, stroke.speed_control |
| "bank shot technique" | bank.fundamentals, bank.one_rail_bank |
| "pre shot routine" | mental.pre_shot_routine, stroke.trigger |
| "safety play defense" | safety.fundamentals, safety.safety_battle |
| "position planning" | pattern.position_planning, aim.cue_ball_path |
| "how to aim" | aim.fundamentals, aim.ghost_ball |
| "fix bridge" | bridge.fundamentals, bridge.errors |
| "grip pressure" | grip.fundamentals, bridge.pressure |

### Vietnamese Queries

| Query | Expected Results |
|-------|------------------|
| "cách đánh lùi bi" | cue_ball.draw, stroke.speed_control |
| "kỹ thuật băng" | bank.fundamentals, bank.one_rail_bank |
| "thói quen trước khi đánh" | mental.pre_shot_routine, stroke.trigger |
| "chơi an toàn" | safety.fundamentals, safety.safety_battle |
| "vị trí và quỹ đạo" | pattern.position_planning, aim.cue_ball_path |
| "cách ngắm bắn" | aim.fundamentals, aim.ghost_ball |
| "sửa tay chống" | bridge.fundamentals, bridge.errors |
| "cách cầm gậy" | grip.fundamentals, stroke.fundamentals |

---

## Fuzzy Matching

### Configuration

| Setting | Value |
|---------|-------|
| Enabled | true |
| Fuzziness | AUTO |
| Max Expansions | 50 |
| Prefix Length | 2 |
| Transpositions | true |
| Similarity Threshold | 0.8 |

### Example Fuzzy Matches

| Search Term | Possible Matches |
|-------------|------------------|
| strok | stroke, stuck, stock |
| bridg | bridge, ridges, badges |
| stanc | stance, stains, saints |
| grip | grip, gripes, GRIP |
| aimg | aiming, aim |
| bank | bank, banks, dank |

---

## Stop Words

### English Stop Words

```
the, a, an, and, or, but, in, on, at, to, for, 
of, with, by, is, are, was, were, be, been, 
being, have, has, had, do, does, did, will, 
would, could, should, may, might, must, shall, 
can, need, it, its, this, that, these, those, 
i, you, he, she, we, they, what, which, who, 
whom, whose, where, when, why, how, all, each, 
every, both, few, more, most, other, some, such, 
no, nor, not, only, own, same, so, than, too, 
very
```

### Vietnamese Stop Words

```
của, và, là, có, được, trong, cho, với, này, 
đó, những, các, khi, ở, để, từ, vào, ra, lên, 
xuống, hơn, kém, nhất, một, hai, ba, bốn, năm, 
sáu, bảy, tám, chín, mười, tôi, bạn, anh, chị, 
em, ông, bà, ai, gì, đâu, nào, sao, vì, nên, 
nếu, mà, thì, vẫn, còn, đã, đang, sẽ, không, 
phải, đó, kia, hết, tất
```

---

## Tokenizer Configuration

### Standard Tokenizer

```json
{
  "type": "standard",
  "maxTokenLength": 255
}
```

### Vietnamese Tokenizer

```json
{
  "type": "vi_tokenizer",
  "ignoreCase": true
}
```

---

## Implementation Notes

### Search Algorithm Priority

1. **Exact Match** (score: 3.0)
   - Title matches exactly
   - ID matches exactly

2. **Category/Tag Match** (score: 1.5-2.5)
   - Category field match
   - Tag array match

3. **Keyword Match** (score: 1.2-2.0)
   - Synonym expansion
   - Keyword field match

4. **Content Match** (score: 1.0)
   - Full text search
   - Fuzzy matching

5. **Boost Application**
   - Category boost
   - Level boost
   - Keyword boost

### Performance Considerations

- Index refresh: Real-time on updates
- Cache: 5-minute TTL for frequent queries
- Max results: 100 items per query
- Pagination: 20 items per page

---

## Testing Queries

### Basic Tests

```javascript
// Test 1: Basic search
search("draw shot") 
// Expected: cue_ball.draw, stroke.speed_control

// Test 2: Vietnamese search
search("đánh băng")
// Expected: bank.fundamentals, bank.one_rail_bank

// Test 3: With filter
search("stroke", {level: "G", category: "stroke"})
// Expected: stroke.* filtered by level G
```

### Edge Cases

```javascript
// Test 4: Misspelling
search("strok")
// Expected: stroke, stuck, stock

// Test 5: Abbreviation
search("CB")
// Expected: cue_ball.fundamentals

// Test 6: Empty result handling
search("xyz123")
// Expected: No results, suggest similar terms
```

---

## Future Enhancements

- [ ] Voice search support
- [ ] Image-based search (search by uploaded photo)
- [ ] Personalized search based on user level
- [ ] Search analytics and trending queries
- [ ] Autocomplete suggestions
- [ ] Search history and favorites

---

*Generated: 2026-07-17*
*Pool OS Knowledge Base v1.0*
