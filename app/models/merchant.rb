# frozen_string_literal: true

class Merchant < ApplicationRecord
  validates :name, presence: true, uniqueness: :true
end
