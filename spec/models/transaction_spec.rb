# frozen_string_literal: true

require 'rails_helper'

describe Transaction, type: :model do
  subject do
    Transaction.create(
      merchant: merchant1,
      to_merchant: merchant2,
      payment_method: payment_method,
      amount: amount,
      scheduled_type: scheduled_type,
      scheduled_date: scheduled_date
    )
  end
  let(:amount) { 4566.98 }
  let(:merchant1) { Merchant.create name: "Co1" }
  let(:merchant2) { Merchant.create name: "Co2" }
  let(:payment_method) do
    PaymentMethod.create bank_info: { name: "Chase", account_number: 123, routing_numbe: 456 }
  end
  let(:scheduled_type) { :future }
  let(:scheduled_date) { 1.month.from_now }

  it { is_expected.to belong_to(:merchant) }
  it { is_expected.to belong_to(:payment_method) }
  it { is_expected.to belong_to(:to_merchant).class_name("Merchant") }
  it { is_expected.to validate_presence_of(:amount) }

  context "when future" do
    it { is_expected.to validate_presence_of(:scheduled_date) }

    describe "#validate_scheduled_date" do
      context "when date is in the future" do
        let(:scheduled_date) { 1.month.from_now }
        it { is_expected.to be_valid }
      end

      context "when date is in the past" do
        let(:scheduled_date) { 1.month.ago }
        it { is_expected.not_to be_valid }
      end

      context "when date is today" do
        let(:scheduled_date) { Date.current }
        it { is_expected.not_to be_valid }
      end
    end
  end

  context "when now" do
    let(:scheduled_type) { :now }
      it { is_expected.not_to validate_presence_of(:scheduled_date) }
  end
end
