import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/runtime_validation_contracts.dart';

void main() {
  const artifacts = {'composition': 'c', 'pipeline': 'p', 'graph': 'g', 'state': 's', 'transition': 't'};
  test('validation is immutable and deterministic', () { final first = const RuntimeValidator().validate(artifactDigests: artifacts, expectedDigests: const {'graph': 'old'}); final second = const RuntimeValidator().validate(artifactDigests: {'transition': 't', 'state': 's', 'graph': 'g', 'pipeline': 'p', 'composition': 'c'}, expectedDigests: const {'graph': 'old'}); expect(second.digest, first.digest); expect(() => first.issues.add(first.issues.first), throwsUnsupportedError); });
  test('missing artifact fails closed', () => expect(() => const RuntimeValidator().validate(artifactDigests: const {'composition': 'c'}), throwsArgumentError));
  test('stale artifact is reported', () { final result = const RuntimeValidator().validate(artifactDigests: artifacts, expectedDigests: const {'graph': 'old'}); expect(result.summary.failed, 1); expect(result.issues.single.code, 'stale-artifact'); });
  test('matching artifacts produce no issues', () => expect(const RuntimeValidator().validate(artifactDigests: artifacts, expectedDigests: artifacts).issues, isEmpty));
  test('empty digest fails closed', () => expect(() => const RuntimeValidator().validate(artifactDigests: const {'composition': '', 'pipeline': 'p', 'graph': 'g', 'state': 's', 'transition': 't'}), throwsArgumentError));
  test('validation summary counts five artifact boundaries', () => expect(const RuntimeValidator().validate(artifactDigests: artifacts).summary.checked, 5));
  test('validation does not mutate inputs', () { final before = artifacts.toString(); const RuntimeValidator().validate(artifactDigests: artifacts); expect(artifacts.toString(), before); });
}
