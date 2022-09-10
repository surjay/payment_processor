# frozen_string_literal: true

class PaymentMethod < ApplicationRecord
  belongs_to :merchant

  enum method_type: {
    bank: 0,
    credit_card: 1,
  }

  store_accessor :data, :bank_info, :credit_card_info

  BANK_FIELDS = %w[name routing_number account_number].freeze
  CC_FIELDS = %w[number cvv expiration zip].freeze

  validate :validate_bank_info, if: :bank?
  validate :validate_credit_card_info, if: :credit_card?

  private

  def validate_bank_info
    bank_hash = bank_info.to_h.with_indifferent_access
    return if BANK_FIELDS.all? { |f| bank_hash[f].present? }

    errors.add(:bank_info, :invalid)
  end

  def validate_credit_card_info
    cc_hash = credit_card_info.to_h.with_indifferent_access
    return if CC_FIELDS.all? { |f| cc_hash[f].present? }

    errors.add(:credit_card_info, :invalid)
  end
end
