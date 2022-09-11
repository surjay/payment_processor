# frozen_string_literal: true

require 'rails_helper'

describe PaymentMethod, type: :model do
  subject do
    pm = PaymentMethod.new merchant: merchant, method_type: :bank
    pm.set_bank_info(bank_info)
    pm.tap(&:save)
  end
  let(:merchant) { Merchant.create name: "Test Merchant" }
  let(:bank_info) { { name: "Chase", routing_number: routing_number, account_number: account_number } }
  let(:routing_number) { "011000015" }
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

    context "with invalid routing number" do
      let(:routing_number) { "123456" }
      it { is_expected.not_to be_valid }
    end
  end

  describe "#validate_credit_card_info" do
    subject do
      pm = PaymentMethod.new merchant: merchant, method_type: :credit_card
      pm.set_cc_info(credit_card_info)
      pm.tap(&:save)
    end
    let(:credit_card_info) do
      {
         number: number,
         cvv: "123",
         expiration: 1.year.from_now,
         zip: "12345"
      }
    end
    let(:number) { "4242424242424242" }

    context "with all fields" do
      it { is_expected.to be_valid }
    end

    context "without any data" do
      let(:credit_card_info) { nil }
      it { is_expected.not_to be_valid }
    end

    context "missing field" do
      let(:number) { nil }
      it { is_expected.not_to be_valid }
    end

    context "with invalid cc number" do
      let(:number) { "11112222444445555" }
      it { is_expected.not_to be_valid }
    end
  end
end
