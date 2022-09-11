# frozen_string_literal: true

require "csv"

class PaymentMethod < ApplicationRecord
  belongs_to :merchant

  enum method_type: {
    bank: 0,
    credit_card: 1,
  }

  scope :default, -> { where(default: true) }

  store_accessor :data, :bank_info, :credit_card_info

  INVALID_CC_NUMBERS = %w[1111 8888].freeze
  BANK_FIELDS = %w[name routing_number account_number].freeze
  CC_FIELDS = %w[number cvv expiration zip].freeze

  validate :validate_bank_info, if: :bank?
  validate :validate_credit_card_info, if: :credit_card?

  def set_bank_info(args)
    self.bank_info = {} if self.bank_info.blank?

    args.to_h.each_pair do |key, value|
      bank_info[key.to_s] = value.present? ? EncryptionService.encrypt(value) : nil
    end
  end

  def set_cc_info(args)
    self.credit_card_info = {} if self.credit_card_info.blank?

    args.to_h.each_pair do |key, value|
      credit_card_info[key.to_s] = value.present? ? EncryptionService.encrypt(value) : nil
    end
  end

  BANK_FIELDS.each do |field|
    define_method(field) do
      value = bank_info.to_h[field]
      value.present? ? EncryptionService.decrypt(value) : nil
    end
  end

  CC_FIELDS.each do |field|
    define_method(field) do
      value = credit_card_info.to_h[field]
      value.present? ? EncryptionService.decrypt(value) : nil
    end
  end

  private

  def validate_bank_info
    bank_hash = bank_info.to_h.with_indifferent_access
    if BANK_FIELDS.any? { |f| bank_hash[f].blank? }
      errors.add(:bank_info, :invalid)
      return
    end

    return if valid_routing_number?
    errors.add(:bank_info, "invalid routing number")
  end

  def validate_credit_card_info
    cc_hash = credit_card_info.to_h.with_indifferent_access
    if CC_FIELDS.any? { |f| cc_hash[f].blank? }
      errors.add(:credit_card_info, :invalid)
      return
    end

    return if valid_cc_number?
    errors.add(:credit_card_info, "invalid number")
  end

  def valid_routing_number?
    return false if routing_number.blank?

    path = Rails.root.join("lib", "finances", "valid_routing_numbers.csv")
    routing_numbers = CSV.foreach(path, encoding: "bom|utf-8").map { |row| row[0].to_s }
    routing_numbers.include? routing_number
  end

  def valid_cc_number?
    return false if number.blank?

    INVALID_CC_NUMBERS.none? { |n| number.starts_with? n }
  end
end
