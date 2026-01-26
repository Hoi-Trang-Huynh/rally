import 'package:flutter_test/flutter_test.dart';
import 'package:rally/utils/validation_constants.dart';

/// Unit tests for validation constants and utility classes.
///
/// These tests verify the validation logic independently of the UI layer.
/// The actual Validators class uses localized strings, so we test the
/// underlying validation constants directly.
void main() {
  group('EmailRegex', () {
    test('accepts valid email addresses', () {
      expect(emailRegex.hasMatch('test@example.com'), isTrue);
      expect(emailRegex.hasMatch('user.name@domain.co'), isTrue);
      expect(emailRegex.hasMatch('user+tag@example.org'), isTrue);
      expect(emailRegex.hasMatch('user123@test.domain.com'), isTrue);
    });

    test('rejects invalid email addresses', () {
      expect(emailRegex.hasMatch(''), isFalse);
      expect(emailRegex.hasMatch('invalid'), isFalse);
      expect(emailRegex.hasMatch('invalid@'), isFalse);
      expect(emailRegex.hasMatch('@domain.com'), isFalse);
      expect(emailRegex.hasMatch('user@domain'), isFalse);
      expect(emailRegex.hasMatch('user@.com'), isFalse);
    });
  });

  group('UsernameValidation', () {
    test('minLength is 5', () {
      expect(UsernameValidation.minLength, equals(5));
    });

    test('maxLength is 15', () {
      expect(UsernameValidation.maxLength, equals(15));
    });

    group('hasValidCharacters', () {
      test('accepts valid usernames starting with letter', () {
        expect(UsernameValidation.hasValidCharacters('user1'), isTrue);
        expect(UsernameValidation.hasValidCharacters('User_name'), isTrue);
        expect(UsernameValidation.hasValidCharacters('abc123'), isTrue);
        expect(UsernameValidation.hasValidCharacters('A_b_c'), isTrue);
      });

      test('rejects usernames starting with number', () {
        expect(UsernameValidation.hasValidCharacters('1user'), isFalse);
        expect(UsernameValidation.hasValidCharacters('123abc'), isFalse);
      });

      test('rejects usernames starting with underscore', () {
        expect(UsernameValidation.hasValidCharacters('_user'), isFalse);
      });

      test('rejects usernames with special characters', () {
        expect(UsernameValidation.hasValidCharacters('user@name'), isFalse);
        expect(UsernameValidation.hasValidCharacters('user-name'), isFalse);
        expect(UsernameValidation.hasValidCharacters('user.name'), isFalse);
        expect(UsernameValidation.hasValidCharacters('user name'), isFalse);
      });
    });

    group('hasValidLength', () {
      test('accepts usernames within valid length range', () {
        expect(UsernameValidation.hasValidLength('abcde'), isTrue); // 5 chars (min)
        expect(UsernameValidation.hasValidLength('abcdefghijklmno'), isTrue); // 15 chars (max)
        expect(UsernameValidation.hasValidLength('username'), isTrue); // 8 chars
      });

      test('rejects usernames below minimum length', () {
        expect(UsernameValidation.hasValidLength(''), isFalse);
        expect(UsernameValidation.hasValidLength('abc'), isFalse);
        expect(UsernameValidation.hasValidLength('abcd'), isFalse); // 4 chars
      });

      test('rejects usernames above maximum length', () {
        expect(UsernameValidation.hasValidLength('abcdefghijklmnop'), isFalse); // 16 chars
        expect(UsernameValidation.hasValidLength('verylongusername'), isFalse);
      });
    });

    group('isValid', () {
      test('returns true for valid usernames', () {
        expect(UsernameValidation.isValid('user1'), isTrue);
        expect(UsernameValidation.isValid('ValidUser'), isTrue);
        expect(UsernameValidation.isValid('user_name1'), isTrue);
      });

      test('returns false for invalid usernames', () {
        expect(UsernameValidation.isValid('ab'), isFalse); // too short
        expect(UsernameValidation.isValid('1user'), isFalse); // starts with number
        expect(UsernameValidation.isValid('user@name'), isFalse); // invalid char
        expect(UsernameValidation.isValid('verylongusername123'), isFalse); // too long
      });
    });
  });

  group('FirstNameValidation', () {
    test('minLength is 2', () {
      expect(FirstNameValidation.minLength, equals(2));
    });

    test('maxLength is 15', () {
      expect(FirstNameValidation.maxLength, equals(15));
    });
  });

  group('LastNameValidation', () {
    test('minLength is 2', () {
      expect(LastNameValidation.minLength, equals(2));
    });

    test('maxLength is 15', () {
      expect(LastNameValidation.maxLength, equals(15));
    });
  });

  group('BioValidation', () {
    test('maxLength is 50', () {
      expect(BioValidation.maxLength, equals(50));
    });
  });

  group('PasswordValidation', () {
    test('minLength is 8', () {
      expect(PasswordValidation.minLength, equals(8));
    });

    test('maxLength is 128', () {
      expect(PasswordValidation.maxLength, equals(128));
    });

    group('hasUppercase', () {
      test('returns true when password contains uppercase', () {
        expect(PasswordValidation.hasUppercase('Password'), isTrue);
        expect(PasswordValidation.hasUppercase('passworD'), isTrue);
        expect(PasswordValidation.hasUppercase('ALLCAPS'), isTrue);
      });

      test('returns false when password has no uppercase', () {
        expect(PasswordValidation.hasUppercase('password'), isFalse);
        expect(PasswordValidation.hasUppercase('123456'), isFalse);
        expect(PasswordValidation.hasUppercase(''), isFalse);
      });
    });

    group('hasLowercase', () {
      test('returns true when password contains lowercase', () {
        expect(PasswordValidation.hasLowercase('password'), isTrue);
        expect(PasswordValidation.hasLowercase('PASSWORd'), isTrue);
        expect(PasswordValidation.hasLowercase('a'), isTrue);
      });

      test('returns false when password has no lowercase', () {
        expect(PasswordValidation.hasLowercase('PASSWORD'), isFalse);
        expect(PasswordValidation.hasLowercase('123456'), isFalse);
        expect(PasswordValidation.hasLowercase(''), isFalse);
      });
    });

    group('hasDigit', () {
      test('returns true when password contains digit', () {
        expect(PasswordValidation.hasDigit('password1'), isTrue);
        expect(PasswordValidation.hasDigit('1password'), isTrue);
        expect(PasswordValidation.hasDigit('pass5word'), isTrue);
      });

      test('returns false when password has no digit', () {
        expect(PasswordValidation.hasDigit('password'), isFalse);
        expect(PasswordValidation.hasDigit('PASSWORD'), isFalse);
        expect(PasswordValidation.hasDigit(''), isFalse);
      });
    });

    group('hasMinLength', () {
      test('returns true when password meets minimum length', () {
        expect(PasswordValidation.hasMinLength('12345678'), isTrue); // exactly 8
        expect(PasswordValidation.hasMinLength('123456789'), isTrue); // 9 chars
        expect(PasswordValidation.hasMinLength('longerpassword'), isTrue);
      });

      test('returns false when password is too short', () {
        expect(PasswordValidation.hasMinLength(''), isFalse);
        expect(PasswordValidation.hasMinLength('1234567'), isFalse); // 7 chars
        expect(PasswordValidation.hasMinLength('short'), isFalse);
      });
    });

    group('isValid', () {
      test('returns true for valid passwords', () {
        expect(PasswordValidation.isValid('Password1'), isTrue);
        expect(PasswordValidation.isValid('SecureP@ss1'), isTrue);
        expect(PasswordValidation.isValid('MyPass123'), isTrue);
        expect(PasswordValidation.isValid('Abcdefg1'), isTrue);
      });

      test('returns false when missing uppercase', () {
        expect(PasswordValidation.isValid('password1'), isFalse);
      });

      test('returns false when missing lowercase', () {
        expect(PasswordValidation.isValid('PASSWORD1'), isFalse);
      });

      test('returns false when missing digit', () {
        expect(PasswordValidation.isValid('Passwordd'), isFalse);
      });

      test('returns false when too short', () {
        expect(PasswordValidation.isValid('Pass1'), isFalse);
        expect(PasswordValidation.isValid('Abcdef1'), isFalse); // 7 chars
      });
    });
  });
}
