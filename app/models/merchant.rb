# frozen_string_literal: true

class Merchant < ApplicationRecord
  has_many :payment_methods, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :to_transactions, class_name: "Transaction", foreign_key: :to_merchant_id
  has_many :payouts, dependent: :destroy

  validates :name, presence: true, uniqueness: :true
end
