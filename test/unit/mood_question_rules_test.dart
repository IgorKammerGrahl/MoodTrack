import 'package:flutter_test/flutter_test.dart';
import 'package:moodtrack/domain/mood_question_rules.dart';

void main() {
  group('MoodQuestionRules', () {
    test('returns questions for all mood levels 1-5', () {
      for (int level = 1; level <= 5; level++) {
        final questions = MoodQuestionRules.getQuestions(level);
        expect(
          questions,
          isNotEmpty,
          reason: 'Level $level should have questions',
        );
        expect(
          questions.length,
          greaterThanOrEqualTo(2),
          reason: 'Level $level should have at least 2 questions',
        );
      }
    });

    test('questions are non-empty strings', () {
      for (int level = 1; level <= 5; level++) {
        final questions = MoodQuestionRules.getQuestions(level);
        for (var q in questions) {
          expect(q, isNotEmpty);
          expect(
            q.endsWith('?'),
            isTrue,
            reason: 'Question "$q" should end with ?',
          );
        }
      }
    });

    test('low moods have different questions than high moods', () {
      final lowQuestions = MoodQuestionRules.getQuestions(1);
      final highQuestions = MoodQuestionRules.getQuestions(5);
      expect(lowQuestions, isNot(equals(highQuestions)));
    });

    test('unknown mood level falls back to level 3', () {
      final questions = MoodQuestionRules.getQuestions(99);
      final level3Questions = MoodQuestionRules.getQuestions(3);
      expect(questions, equals(level3Questions));
    });
  });
}
