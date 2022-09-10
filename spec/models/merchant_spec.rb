# frozen_string_literal: true

require 'rails_helper'

describe Merchant, type: :model do
  subject { Merchant.create name: "Test Merchant" }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to have_many(:payment_methods).dependent(:destroy) }
end
