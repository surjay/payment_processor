# frozen_string_literal: true

require 'rails_helper'

describe GeneratePayouts, type: :service do
  let(:merchant1) { Merchant.create name: "Test Merchant" }
  let(:merchant2) { Merchant.create name: "Other Corp" }

  let!(:payment_method1) do
    pm = PaymentMethod.new merchant: merchant1, method_type: :bank, default: true
    pm.set_bank_info(bank_info)
    pm.tap(&:save)
  end
  let(:bank_info) { { name: "Chase", routing_number: routing_number, account_number: account_number } }
  let(:routing_number) { "011000015" }
  let(:account_number) { 456 }
  let!(:payment_method2) do
    pm = PaymentMethod.new merchant: merchant2, method_type: :credit_card, default: true
    pm.set_cc_info(credit_card_info)
    pm.tap(&:save)
  end
  let(:credit_card_info) { { number: cc_number, cvv: "123", zip: "12345", expiration: 1.year.from_now } }
  let(:cc_number) { "42424242424242424242" }
  let(:bank_client) { instance_double(BankClient, bank_transfer: true, bank_payout: true, cc_transfer: true, cc_payout: true) }

  describe "#perform" do
    before do
      allow(BankClient).to receive(:new) { bank_client }
    end

    context "when from bank" do
      let(:payout_date) { 1.day.from_now }
      let!(:transaction1) do
        Transaction.create!(
          merchant: merchant1,
          to_merchant: merchant2,
          payment_method: payment_method1,
          amount: amount1,
          scheduled_type: :future,
          scheduled_date: payout_date
        )
      end
      let(:amount1) { 252323.91 }
      let(:debit_amount_1) { amount1 * 0.01 + 1 }
      let!(:transaction2) do
        Transaction.create!(
          merchant: merchant1,
          to_merchant: merchant2,
          payment_method: payment_method1,
          amount: amount2,
          scheduled_type: :future,
          scheduled_date: payout_date
        )
      end
      let(:amount2) { 1352.85 }
      let(:debit_amount_2) { amount2 * 0.01 + 1 }

      before { GeneratePayouts.new(payout_date: payout_date).perform }

      it "debits appropriate amounts" do
        expect(bank_client).to have_received(:bank_transfer).with(
          amount: debit_amount_1,
          routing_number: routing_number,
          account_number: account_number
        ).with(
          amount: debit_amount_2,
          routing_number: routing_number,
          account_number: account_number
        )
      end

      it "pays out full total" do
        expect(bank_client).to have_received(:cc_payout).with(
          amount: (debit_amount_1 + debit_amount_2).round(2).to_s,
          number: cc_number,
          cvv: "123",
          expiration: anything,
          zip: "12345"
        )
      end
    end

    context "when from cc" do
      let(:payout_date) { 1.day.from_now }
      let!(:transaction1) do
        Transaction.create!(
          merchant: merchant2,
          to_merchant: merchant1,
          payment_method: payment_method2,
          amount: amount1,
          scheduled_type: :future,
          scheduled_date: payout_date
        )
      end
      let(:amount1) { 3453.23 }
      let(:debit_amount_1) { amount1 * 0.029 + 0.30 }
      let!(:transaction2) do
        Transaction.create!(
          merchant: merchant2,
          to_merchant: merchant1,
          payment_method: payment_method2,
          amount: amount2,
          scheduled_type: :future,
          scheduled_date: payout_date
        )
      end
      let(:amount2) { 346363.32 }
      let(:debit_amount_2) { amount2 * 0.029 + 0.30 }

      before { GeneratePayouts.new(payout_date: payout_date).perform }

      it "debits appropriate amounts" do
        expect(bank_client).to have_received(:cc_transfer).with(
          amount: debit_amount_1,
          number: cc_number,
          cvv: "123",
          expiration: anything,
          zip: "12345"
        ).with(
          amount: debit_amount_2,
          number: cc_number,
          cvv: "123",
          expiration: anything,
          zip: "12345"
        )
      end

      it "pays out full total" do
        expect(bank_client).to have_received(:bank_payout).with(
          amount: (debit_amount_1 + debit_amount_2).round(2).to_s,
          routing_number: routing_number,
          account_number: account_number
        )
      end
    end
  end
end
