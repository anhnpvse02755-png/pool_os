import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/coach_conversation_service.dart';
import '../domain/brain/coach_output.dart';

final coachConversationServiceProvider = Provider<CoachConversationService>(
  (ref) => CoachConversationService(),
);

final coachConversationProvider =
    StateNotifierProvider<CoachConversationNotifier, CoachConversationState>(
        (ref) {
  return CoachConversationNotifier(ref.watch(coachConversationServiceProvider));
});

final class CoachConversationState {
  CoachConversationState({
    List<CoachConversationTurn> turns = const [],
    this.isSubmitting = false,
    this.errorCode,
  }) : turns = List.unmodifiable(turns);

  final List<CoachConversationTurn> turns;
  final bool isSubmitting;
  final String? errorCode;

  CoachConversationState copyWith({
    List<CoachConversationTurn>? turns,
    bool? isSubmitting,
    String? errorCode,
    bool clearError = false,
  }) {
    return CoachConversationState(
      turns: turns ?? this.turns,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorCode: clearError ? null : errorCode ?? this.errorCode,
    );
  }
}

final class CoachConversationNotifier
    extends StateNotifier<CoachConversationState> {
  CoachConversationNotifier(this._service) : super(CoachConversationState());

  final CoachConversationService _service;

  Future<void> ask(
    CoachConversationIntent intent,
    CoachOutput output,
  ) async {
    if (state.isSubmitting) return;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final turn = await _service.ask(intent: intent, output: output);
      state = CoachConversationState(turns: [...state.turns, turn]);
    } on StateError catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorCode: error.message.toString(),
      );
    }
  }

  void clear() => state = CoachConversationState();
}
