import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:rally/services/api_client.dart';
import 'package:rally/services/auth_repository.dart';

/// Mock class for [AuthRepository].
class MockAuthRepository extends Mock implements AuthRepository {}

/// Mock class for [http.Client].
class MockHttpClient extends Mock implements http.Client {}

/// Mock class for [http.Response].
class FakeUri extends Fake implements Uri {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockHttpClient mockHttpClient;
  late ApiClient apiClient;

  setUpAll(() async {
    registerFallbackValue(FakeUri());

    // Initialize dotenv with test values
    dotenv.testLoad(fileInput: 'API_BACKEND_URL=http://test-api.example.com');
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockHttpClient = MockHttpClient();
    apiClient = ApiClient(
      authRepository: mockAuthRepository,
      httpClient: mockHttpClient,
    );

    // Default stub for getIdToken
    when(() => mockAuthRepository.getIdToken(forceRefresh: true))
        .thenAnswer((_) async => 'test-token');
  });

  tearDown(() {
    apiClient.dispose();
  });

  group('ApiClient', () {
    group('ApiException', () {
      test('creates exception with status code and message', () {
        final ApiException exception = ApiException(404, 'Not found');

        expect(exception.statusCode, equals(404));
        expect(exception.message, equals('Not found'));
      });

      test('toString returns formatted string', () {
        final ApiException exception = ApiException(500, 'Server error');

        expect(exception.toString(), equals('ApiException(500): Server error'));
      });
    });

    group('get', () {
      test('performs GET request with correct headers', () async {
        final Map<String, dynamic> responseData = <String, dynamic>{'data': 'test'};

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer(
          (_) async => http.Response(jsonEncode(responseData), 200),
        );

        final dynamic result = await apiClient.get('/test');

        expect(result, equals(responseData));

        verify(
          () => mockHttpClient.get(
            any(that: predicate<Uri>((Uri uri) => uri.path.contains('/test'))),
            headers: any(
              named: 'headers',
              that: predicate<Map<String, String>>((Map<String, String> h) =>
                  h['Authorization'] == 'Bearer test-token' &&
                  h['Content-Type'] == 'application/json'),
            ),
          ),
        ).called(1);
      });

      test('performs GET request with query parameters', () async {
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer(
          (_) async => http.Response('{"data": "test"}', 200),
        );

        await apiClient.get('/test', queryParams: <String, String>{'page': '1'});

        verify(
          () => mockHttpClient.get(
            any(
              that: predicate<Uri>(
                (Uri uri) => uri.queryParameters['page'] == '1',
              ),
            ),
            headers: any(named: 'headers'),
          ),
        ).called(1);
      });

      test('returns null for empty response body', () async {
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('', 200));

        final dynamic result = await apiClient.get('/test');

        expect(result, isNull);
      });

      test('throws ApiException on error response', () async {
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer(
          (_) async => http.Response('{"message": "Not found"}', 404),
        );

        expect(
          () => apiClient.get('/test'),
          throwsA(
            isA<ApiException>()
                .having((ApiException e) => e.statusCode, 'statusCode', 404)
                .having((ApiException e) => e.message, 'message', 'Not found'),
          ),
        );
      });

      test('throws ApiException with error field on error response', () async {
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer(
          (_) async => http.Response('{"error": "Unauthorized"}', 401),
        );

        expect(
          () => apiClient.get('/test'),
          throwsA(
            isA<ApiException>()
                .having((ApiException e) => e.statusCode, 'statusCode', 401)
                .having((ApiException e) => e.message, 'message', 'Unauthorized'),
          ),
        );
      });

      test('throws ApiException with raw body when JSON parse fails', () async {
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer(
          (_) async => http.Response('Plain text error', 500),
        );

        expect(
          () => apiClient.get('/test'),
          throwsA(
            isA<ApiException>()
                .having((ApiException e) => e.statusCode, 'statusCode', 500)
                .having((ApiException e) => e.message, 'message', 'Plain text error'),
          ),
        );
      });
    });

    group('post', () {
      test('performs POST request with body', () async {
        final Map<String, dynamic> requestBody = <String, dynamic>{'name': 'test'};
        final Map<String, dynamic> responseData = <String, dynamic>{'id': '123'};

        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(responseData), 201));

        final dynamic result = await apiClient.post('/test', body: requestBody);

        expect(result, equals(responseData));

        verify(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: jsonEncode(requestBody),
          ),
        ).called(1);
      });

      test('performs POST request without body', () async {
        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => http.Response('{}', 200));

        await apiClient.post('/test');

        verify(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: null,
          ),
        ).called(1);
      });
    });

    group('put', () {
      test('performs PUT request with body', () async {
        final Map<String, dynamic> requestBody = <String, dynamic>{'name': 'updated'};

        when(
          () => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => http.Response('{"success": true}', 200));

        final dynamic result = await apiClient.put('/test/123', body: requestBody);

        expect(result, equals(<String, dynamic>{'success': true}));

        verify(
          () => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: jsonEncode(requestBody),
          ),
        ).called(1);
      });
    });

    group('delete', () {
      test('performs DELETE request', () async {
        when(
          () => mockHttpClient.delete(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response('', 204));

        final dynamic result = await apiClient.delete('/test/123');

        expect(result, isNull);

        verify(
          () => mockHttpClient.delete(
            any(that: predicate<Uri>((Uri uri) => uri.path.contains('/test/123'))),
            headers: any(named: 'headers'),
          ),
        ).called(1);
      });
    });

    group('headers', () {
      test('includes token in Authorization header when available', () async {
        when(() => mockAuthRepository.getIdToken(forceRefresh: true))
            .thenAnswer((_) async => 'my-token');

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('{}', 200));

        await apiClient.get('/test');

        verify(
          () => mockHttpClient.get(
            any(),
            headers: any(
              named: 'headers',
              that: predicate<Map<String, String>>(
                (Map<String, String> h) => h['Authorization'] == 'Bearer my-token',
              ),
            ),
          ),
        ).called(1);
      });

      test('excludes Authorization header when token is null', () async {
        when(() => mockAuthRepository.getIdToken(forceRefresh: true))
            .thenAnswer((_) async => null);

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('{}', 200));

        await apiClient.get('/test');

        verify(
          () => mockHttpClient.get(
            any(),
            headers: any(
              named: 'headers',
              that: predicate<Map<String, String>>(
                (Map<String, String> h) => !h.containsKey('Authorization'),
              ),
            ),
          ),
        ).called(1);
      });
    });
  });
}
