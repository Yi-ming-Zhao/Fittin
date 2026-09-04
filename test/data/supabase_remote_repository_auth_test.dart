import 'package:fittin_v2/src/data/remote/supabase_remote_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('authenticated backend request refreshes and retries one 401', () async {
    final authorizations = <String?>[];
    var requests = 0;
    var refreshes = 0;
    final repository = SupabaseRemoteRepository.http(
      baseUrl: 'https://api.example.test',
      accessTokenLoader: () async => 'expired-access',
      accessTokenRefresher: (failedAccessToken) async {
        expect(failedAccessToken, 'expired-access');
        refreshes += 1;
        return 'fresh-access';
      },
      httpClient: MockClient((request) async {
        requests += 1;
        authorizations.add(request.headers['authorization']);
        return requests == 1
            ? http.Response(
                '{"error":"expired","code":"access_token_expired"}',
                401,
              )
            : http.Response('{"ok":true}', 200);
      }),
    );

    await repository.upsertRow(table: 'plans', row: const {'id': 'plan-1'});

    expect(requests, 2);
    expect(refreshes, 1);
    expect(authorizations, ['Bearer expired-access', 'Bearer fresh-access']);
  });

  test('authenticated backend request never retries a second 401', () async {
    var requests = 0;
    final repository = SupabaseRemoteRepository.http(
      baseUrl: 'https://api.example.test',
      accessTokenLoader: () async => 'expired-access',
      accessTokenRefresher: (_) async => 'fresh-access',
      httpClient: MockClient((request) async {
        requests += 1;
        return http.Response(
          '{"error":"revoked","code":"session_revoked"}',
          401,
        );
      }),
    );

    await expectLater(
      repository.upsertRow(table: 'plans', row: const {'id': 'plan-1'}),
      throwsA(
        isA<RemoteRepositoryException>().having(
          (error) => error.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
    expect(requests, 2);
  });
}
