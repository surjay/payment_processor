class EncryptionService
  # TODO: Move to ENV variables or secrets, etc
  ENCRYPTION_KEY = "+1SuaKaIJg6xkwYeVskZuw=="
  ENCRYPTION_SALT = "\x7FM\t\xE6\xF5\xFF\x11\x80\xDD\xC6\xAB\xE0?o\x01O\x18\x7F\x06\x88qJ\x14\x81\xA0,\a4\x87\xADe\xFD"
  KEY = ActiveSupport::KeyGenerator.new(ENCRYPTION_KEY).generate_key(ENCRYPTION_SALT, ActiveSupport::MessageEncryptor.key_len).freeze

  private_constant :KEY

  delegate :encrypt_and_sign, :decrypt_and_verify, to: :encryptor

  def self.encrypt(value)
    new.encrypt_and_sign(value)
  end

  def self.decrypt(value)
    new.decrypt_and_verify(value)
  end

  private

  def encryptor
    ActiveSupport::MessageEncryptor.new(KEY)
  end
end
