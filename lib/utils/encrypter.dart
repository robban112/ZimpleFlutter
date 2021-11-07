import 'package:encrypt/encrypt.dart';

class TextEncrypter {
  //static const _key = '';
  static final _key = Key.fromUtf8('-&%MTAugdxtk7lyJ5zea1foSixVf1sk9');
  static final _iv = IV.fromLength(16);

  static String encryptText(String _text) {
    Encrypter encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(_text, iv: _iv);
    return encrypted.base64;
  }

  static String decryptText(String _text) {
    Encrypter encrypter = Encrypter(AES(_key));
    Encrypted enc = Encrypted.fromBase64(_text);
    final decrypted = encrypter.decrypt(enc, iv: _iv);
    return decrypted;
  }
}
