import 'package:flutter_test/flutter_test.dart';
import 'package:rally/models/app_user.dart';

/// Unit tests for the [AppUser] model class.
void main() {
  group('AppUser', () {
    group('constructor', () {
      test('creates AppUser with required uid', () {
        const AppUser user = AppUser(uid: 'test-uid');

        expect(user.uid, equals('test-uid'));
        expect(user.id, isNull);
        expect(user.email, isNull);
        expect(user.username, isNull);
        expect(user.firstName, isNull);
        expect(user.lastName, isNull);
        expect(user.bioText, isNull);
        expect(user.avatarUrl, isNull);
        expect(user.isEmailVerified, isFalse);
        expect(user.isOnboarding, isTrue);
      });

      test('creates AppUser with all fields', () {
        const AppUser user = AppUser(
          uid: 'firebase-uid',
          id: 'mongo-id',
          email: 'test@example.com',
          username: 'testuser',
          firstName: 'John',
          lastName: 'Doe',
          bioText: 'A bio',
          avatarUrl: 'https://example.com/avatar.jpg',
          isEmailVerified: true,
          isOnboarding: false,
        );

        expect(user.uid, equals('firebase-uid'));
        expect(user.id, equals('mongo-id'));
        expect(user.email, equals('test@example.com'));
        expect(user.username, equals('testuser'));
        expect(user.firstName, equals('John'));
        expect(user.lastName, equals('Doe'));
        expect(user.bioText, equals('A bio'));
        expect(user.avatarUrl, equals('https://example.com/avatar.jpg'));
        expect(user.isEmailVerified, isTrue);
        expect(user.isOnboarding, isFalse);
      });
    });

    group('fromEmpty', () {
      test('creates AppUser with empty values', () {
        final AppUser user = AppUser.fromEmpty();

        expect(user.uid, equals(''));
        expect(user.id, equals(''));
        expect(user.email, equals(''));
        expect(user.username, equals(''));
        expect(user.firstName, equals(''));
        expect(user.lastName, equals(''));
        expect(user.bioText, equals(''));
        expect(user.avatarUrl, equals(''));
        expect(user.isEmailVerified, isFalse);
        expect(user.isOnboarding, isTrue);
      });
    });

    group('fromBackendProfile', () {
      test('creates AppUser from backend profile data', () {
        final AppUser user = AppUser.fromBackendProfile(
          firebaseUid: 'firebase-uid',
          profileData: <String, dynamic>{
            'id': 'mongo-id',
            'email': 'test@example.com',
            'username': 'testuser',
            'firstName': 'John',
            'lastName': 'Doe',
            'bioText': 'My bio',
            'avatarUrl': 'https://example.com/avatar.jpg',
            'isEmailVerified': true,
            'isOnboarding': false,
          },
        );

        expect(user.uid, equals('firebase-uid'));
        expect(user.id, equals('mongo-id'));
        expect(user.email, equals('test@example.com'));
        expect(user.username, equals('testuser'));
        expect(user.firstName, equals('John'));
        expect(user.lastName, equals('Doe'));
        expect(user.bioText, equals('My bio'));
        expect(user.avatarUrl, equals('https://example.com/avatar.jpg'));
        expect(user.isEmailVerified, isTrue);
        expect(user.isOnboarding, isFalse);
      });

      test('handles missing optional fields', () {
        final AppUser user = AppUser.fromBackendProfile(
          firebaseUid: 'firebase-uid',
          profileData: <String, dynamic>{
            'id': 'mongo-id',
          },
        );

        expect(user.uid, equals('firebase-uid'));
        expect(user.id, equals('mongo-id'));
        expect(user.email, isNull);
        expect(user.username, isNull);
        expect(user.isEmailVerified, isFalse);
        expect(user.isOnboarding, isTrue);
      });
    });

    group('needsProfileCompletion', () {
      test('returns true when username is null', () {
        const AppUser user = AppUser(
          uid: 'uid',
          id: 'mongo-id',
          username: null,
          firstName: 'John',
          lastName: 'Doe',
        );

        expect(user.needsProfileCompletion, isTrue);
      });

      test('returns true when username is empty', () {
        const AppUser user = AppUser(
          uid: 'uid',
          id: 'mongo-id',
          username: '',
          firstName: 'John',
          lastName: 'Doe',
        );

        expect(user.needsProfileCompletion, isTrue);
      });

      test('returns true when firstName is null', () {
        const AppUser user = AppUser(
          uid: 'uid',
          id: 'mongo-id',
          username: 'testuser',
          firstName: null,
          lastName: 'Doe',
        );

        expect(user.needsProfileCompletion, isTrue);
      });

      test('returns true when firstName is empty', () {
        const AppUser user = AppUser(
          uid: 'uid',
          id: 'mongo-id',
          username: 'testuser',
          firstName: '',
          lastName: 'Doe',
        );

        expect(user.needsProfileCompletion, isTrue);
      });

      test('returns true when lastName is null', () {
        const AppUser user = AppUser(
          uid: 'uid',
          id: 'mongo-id',
          username: 'testuser',
          firstName: 'John',
          lastName: null,
        );

        expect(user.needsProfileCompletion, isTrue);
      });

      test('returns true when lastName is empty', () {
        const AppUser user = AppUser(
          uid: 'uid',
          id: 'mongo-id',
          username: 'testuser',
          firstName: 'John',
          lastName: '',
        );

        expect(user.needsProfileCompletion, isTrue);
      });

      test('returns false when all required fields are filled', () {
        const AppUser user = AppUser(
          uid: 'uid',
          id: 'mongo-id',
          username: 'testuser',
          firstName: 'John',
          lastName: 'Doe',
        );

        expect(user.needsProfileCompletion, isFalse);
      });
    });

    group('displayName', () {
      test('returns firstName when available', () {
        const AppUser user = AppUser(
          uid: 'uid',
          firstName: 'John',
          username: 'testuser',
        );

        expect(user.displayName, equals('John'));
      });

      test('returns username when firstName is null', () {
        const AppUser user = AppUser(
          uid: 'uid',
          firstName: null,
          username: 'testuser',
        );

        expect(user.displayName, equals('testuser'));
      });

      test('returns username when firstName is empty', () {
        const AppUser user = AppUser(
          uid: 'uid',
          firstName: '',
          username: 'testuser',
        );

        expect(user.displayName, equals('testuser'));
      });

      test('returns "User" when firstName and username are null', () {
        const AppUser user = AppUser(
          uid: 'uid',
          firstName: null,
          username: null,
        );

        expect(user.displayName, equals('User'));
      });

      test('returns "User" when firstName and username are empty', () {
        const AppUser user = AppUser(
          uid: 'uid',
          firstName: '',
          username: '',
        );

        expect(user.displayName, equals('User'));
      });
    });

    group('toString', () {
      test('returns formatted string representation', () {
        const AppUser user = AppUser(
          uid: 'uid-123',
          id: 'id-456',
          email: 'test@example.com',
          username: 'testuser',
        );

        expect(
          user.toString(),
          equals('AppUser(uid: uid-123, id: id-456, email: test@example.com, username: testuser)'),
        );
      });
    });

    group('equality', () {
      test('two AppUsers with same values are equal', () {
        const AppUser user1 = AppUser(
          uid: 'uid',
          id: 'id',
          email: 'test@example.com',
          username: 'testuser',
          firstName: 'John',
          lastName: 'Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          isEmailVerified: true,
          isOnboarding: false,
        );

        const AppUser user2 = AppUser(
          uid: 'uid',
          id: 'id',
          email: 'test@example.com',
          username: 'testuser',
          firstName: 'John',
          lastName: 'Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          isEmailVerified: true,
          isOnboarding: false,
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('two AppUsers with different values are not equal', () {
        const AppUser user1 = AppUser(uid: 'uid1');
        const AppUser user2 = AppUser(uid: 'uid2');

        expect(user1, isNot(equals(user2)));
      });

      test('AppUser equals itself', () {
        const AppUser user = AppUser(uid: 'uid');

        expect(user, equals(user));
      });
    });
  });
}
