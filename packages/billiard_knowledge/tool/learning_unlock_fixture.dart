import 'dart:io';

import 'learning_dependency_fixture.dart';

const lr4FixtureSpec = LearningFixtureSpec(
  fixtureDirectory: 'lr_4',
  fixtureName: 'LR-4 Unlock Expression Contract',
  candidateId: 'lr-4-unlock-all-of',
  reviewer: 'LR-4 Conformance Reviewer',
  expectedEntryCount: 4,
  expectedDependencyCount: 3,
);

void main(List<String> args) {
  final packageRoot = Directory.current.absolute;
  final check = args.contains('--check');
  try {
    final build = buildLearningDependencyFixture(
      packageRoot,
      spec: lr4FixtureSpec,
    );
    final outputRoot = Directory(
      _joinMany(
        packageRoot.path,
        ['test', 'fixtures', 'lr_4', 'generated'],
      ),
    );
    if (check) {
      final actual = outputRoot
          .listSync()
          .whereType<File>()
          .map((file) => file.uri.pathSegments.last)
          .toSet();
      if (actual.length != build.artifacts.length ||
          !actual.containsAll(build.artifacts.keys)) {
        throw StateError('LR-4 generated artifact set drift.');
      }
      for (final artifact in build.artifacts.entries) {
        final current = File(_join(outputRoot.path, artifact.key))
            .readAsStringSync()
            .replaceAll('\r\n', '\n');
        if (current != artifact.value) {
          throw StateError('LR-4 artifact drift: ${artifact.key}.');
        }
      }
      stdout.writeln(
        'LR-4 Fixture Check PASS: ${build.proof['entryCount']} entries, '
        '${build.proof['candidatePackDigest']}.',
      );
    } else {
      outputRoot.createSync(recursive: true);
      for (final artifact in build.artifacts.entries) {
        File(_join(outputRoot.path, artifact.key))
            .writeAsStringSync(artifact.value);
      }
      stdout.writeln('Generated LR-4 fixture -> ${outputRoot.path}');
    }
  } on Object catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}

String _join(String first, String second) =>
    '$first${Platform.pathSeparator}$second';

String _joinMany(String first, Iterable<String> rest) =>
    rest.fold(first, (path, segment) => _join(path, segment));
