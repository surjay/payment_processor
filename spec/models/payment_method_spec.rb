# frozen_string_literal: true

require 'rails_helper'

describe PaymentMethod, type: :model do
  subject { PaymentMethod.create merchant: merchant, method_type: :bank, data: data }
  let(:merchant) { Merchant.create name: "Test Merchant" }
  let(:data) { { bank_info: bank_info } }
  let(:bank_info) { { name: "Chase", routing_number: routing_number, account_number: account_number } }
  let(:routing_number) { 123 }
  let(:account_number) { 456 }

  it { is_expected.to belong_to(:merchant) }

  describe "#validate_bank_info" do
    context "with all fields" do
      it { is_expected.to be_valid }
    end

    context "without any data" do
      let(:bank_info) { nil }
      it { is_expected.not_to be_valid }
    end

    context "with bank info" do
      context "missing field" do
        let(:routing_number) { nil }
        it { is_expected.not_to be_valid }
      end
    end
  end
end
