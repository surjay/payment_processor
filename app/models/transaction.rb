# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :merchant
  belongs_to :payment_method
  belongs_to :to_merchant, class_name: "Merchant"

  enum status: {
    pending: 0,
    complete: 1,
    canceled: 2,
  }

  enum scheduled_type: {
    future: 0,
    now: 1,
  }

  validates :amount, presence: true
  validates :scheduled_date, presence: true, if: :future?
  validate :validate_scheduled_date, if: :future?, on: :create

  private

  def validate_scheduled_date
    return unless scheduled_date.present?
    return if scheduled_date > Date.current

    errors.add(:scheduled_date, :invalid)
  end
end
