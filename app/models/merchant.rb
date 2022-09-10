# frozen_string_literal: true

class Merchant < ApplicationRecord
  has_many :payment_methods, dependent: :destroy

  validates :name, presence: true, uniqueness: :true
end
