# Pool OS — VS-01 Verification

## How to Run

```bash
cd pool_os
flutter pub get
flutter run
```

## Expected Flow

```
Welcome Screen
    ↓ Tap "Bắt đầu"
Assessment Screen (5 questions)
    ↓ Complete all 5
Assessment Result Screen
    ↓ Tap "Tiếp tục"
Coach Screen (Recommendation)
    ↓ Tap "Bắt đầu tập"
Session Screen (5 steps)
    ↓ Complete drill + verify
Reflection Screen (3 questions)
    ↓ Complete all 3
Closing Screen (NBA)
```

## Screenshots Required for PO Review

Take screenshots at each step:

1. Welcome Screen
2. Assessment Q1-Q5
3. Assessment Result
4. Coach Recommendation
5. Session Opening
6. Session Knowledge
7. Session Warmup
8. Session Drill (with score)
9. Session Verify (passed/failed)
10. Reflection Q1-Q3
11. Closing with NBA

## Golden Dataset Verification

Run tests:
```bash
flutter test test/golden_tests.dart
```

Expected: All 10 personas pass.

## Contract Tests Verification

Run tests:
```bash
flutter test test/contract_tests.dart
```

Expected: All 11 tests pass.

## Coach Dialogue Check

Coach should say in Vietnamese:
- "Chào bạn!"
- "Hôm nay chúng ta sẽ tập..."
- No "Sai" or negative language
- Encouraging tone
- Specific guidance

## Product Contract Check

✅ ONE recommendation only
✅ No comparison to others
✅ No "Practice more" (must be specific)
✅ NBA always present
✅ 5 questions in assessment
✅ 3 questions in reflection
