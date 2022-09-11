# frozen_string_literal: true

require 'rails_helper'

describe V1::TransactionsController, type: :request do
  let(:merchant1) { Merchant.create name: "Test Co" }
  let(:merchant2) { Merchant.create name: "Other Corp" }
  let(:payment_method) do
    pm = PaymentMethod.new merchant: merchant1, method_type: :bank
    pm.set_bank_info(bank_info)
    pm.tap(&:save!)
  end
  let(:bank_info) { { name: "Chase", routing_number: "011000015", account_number: 456 } }
  let!(:transaction1) do
    Transaction.create(
      merchant: merchant1,
      to_merchant: merchant2,
      payment_method: payment_method,
      amount: amount,
      scheduled_type: scheduled_type,
      scheduled_date: scheduled_date
    )
  end
  let!(:transaction2) do
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
  let(:scheduled_type) { :future }
  let(:scheduled_date) { 1.month.from_now }

  describe "#index" do
    before { get v1_merchant_transactions_path(merchant1) }

    it "is successful" do
      expect(response).to have_http_status(:ok)
    end

    it "returns a list of records" do
      ids = response.parsed_body["transactions"].map { |m| m["id"] }
      expect(ids).to match_array [transaction1.id, transaction2.id]
    end
  end

  describe "#show" do
    context "when successful" do
      before { get v1_merchant_transaction_path(merchant1, transaction1) }

      it "is successful" do
        expect(response).to have_http_status(:ok)
      end

      it "returns a transaction record" do
        expect(response.parsed_body.dig("transaction", "id")).to eq transaction1.id
      end
    end

    context "when unsuccessful" do
      before { get v1_merchant_transaction_path(merchant1, -1) }

      it "is unsuccessful" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body["message"]).to include "Couldn't find Transaction"
      end
    end
  end

  describe "#create" do
    before { post v1_merchant_transactions_path(merchant1), params: params }

    let(:params) do
      {
        to_merchant_id: merchant2.id,
        payment_method_id: payment_method.id,
        amount: amount,
        scheduled_type: :now,
        scheduled_date: 2.months.from_now
      }
    end
    let(:amount) { 123.93 }

    context "when successful" do
      it "is successful" do
        expect(response).to have_http_status(:created)
        json = response.parsed_body.dig("transaction")
        expect(json.dig("amount")).to eq amount.to_s
      end
    end

    context "when unsuccessful" do
      let(:params) { { } }

      it "is unsuccessful" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["message"]).to include "Validation failed"
      end
    end
  end

  describe "#update" do
    before { patch v1_merchant_transaction_path(merchant1, transaction1), params: params }

    context "when successful" do
      let(:params) { { amount: new_amount } }
      let(:new_amount) { 987.68 }

      it "is successful" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.dig("transaction", "amount")).to eq new_amount.to_s
      end
    end

    context "when unsuccessful" do
      let(:params) { { amount: nil } }

      it "is unsuccessful" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["message"]).to include "Validation failed"
      end
    end
  end

  describe "#destroy" do
    context "when successful" do
      before { delete v1_merchant_transaction_path(merchant1, transaction1) }

      it "is successful" do
        expect(response).to have_http_status(:no_content)
        expect(Transaction.find_by(id: transaction1.id)).to be_nil
      end
    end

    context "when unsuccessful" do
      before { delete v1_merchant_transaction_path(merchant1, -1) }

      it "is unsuccessful" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body["message"]).to include "Couldn't find Transaction"
      end
    end
  end
end
