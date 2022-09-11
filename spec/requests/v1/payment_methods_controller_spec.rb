# frozen_string_literal: true

require 'rails_helper'

describe V1::PaymentMethodsController, type: :request do
  let!(:merchant) { Merchant.create name: "Test Co" }
  let!(:payment_method1) do
    pm = PaymentMethod.new merchant: merchant, method_type: :bank
    pm.set_bank_info(bank_info)
    pm.tap(&:save!)
  end
  let!(:payment_method2) do
    pm = PaymentMethod.new merchant: merchant, method_type: :credit_card
    pm.set_cc_info(credit_card_info)
    pm.tap(&:save!)
  end
  let(:bank_info) { { name: "Chase", routing_number: routing_number, account_number: account_number } }
  let(:credit_card_info) { { number: cc_number, cvv: "123", zip: "12345", expiration: 1.year.from_now } }
  let(:routing_number) { "011000015" }
  let(:account_number) { 456 }
  let(:cc_number) { "42424242424242424242" }

  describe "#index" do
    before { get v1_merchant_payment_methods_path(merchant) }

    it "is successful" do
      expect(response).to have_http_status(:ok)
    end

    it "returns a list of payment records" do
      merchant_ids = response.parsed_body["payment_methods"].map { |m| m["id"] }
      expect(merchant_ids).to match_array [payment_method1.id, payment_method2.id]
    end
  end

  describe "#show" do
    context "when successful" do
      before { get v1_merchant_payment_method_path(merchant, payment_method1) }

      it "is successful" do
        expect(response).to have_http_status(:ok)
      end

      it "returns a payment record" do
        expect(response.parsed_body.dig("payment_method", "id")).to eq payment_method1.id
      end
    end

    context "when unsuccessful" do
      before { get v1_merchant_payment_method_path(merchant, -1) }

      it "is unsuccessful" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body["message"]).to include "Couldn't find PaymentMethod"
      end
    end
  end

  describe "#create" do
    before { post v1_merchant_payment_methods_path(merchant), params: params }

    let(:params) { { method_type: method_type, bank_info: bank_info, credit_card_info: credit_card_info } }
    let(:method_type) { :bank }

    context "when successful" do
      it "is successful" do
        expect(response).to have_http_status(:created)
        json = response.parsed_body.dig("payment_method")
        expect(json.dig("method_type")).to eq method_type.to_s
      end
    end

    context "when unsuccessful" do
      let(:params) { { method_type: :bank, bank_info: nil } }

      it "is unsuccessful" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["message"]).to include "Validation failed"
      end
    end
  end

  describe "#update" do
    before { patch v1_merchant_payment_method_path(merchant, payment_method1), params: params }

    context "when successful" do
      let(:params) { { bank_info: { account_number: new_account_number } } }
      let(:new_account_number) { 987 }

      it "is successful" do
        expect(response).to have_http_status(:ok)
        account_number = response.parsed_body.dig("payment_method", "data", "bank_info", "account_number")
        expect(
          EncryptionService.decrypt(account_number)
        ).to eq new_account_number.to_s
      end
    end

    context "when unsuccessful" do
      let(:params) { { bank_info: { account_number: nil } } }

      it "is unsuccessful" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["message"]).to include "Validation failed"
      end
    end
  end

  describe "#destroy" do
    context "when successful" do
      before { delete v1_merchant_payment_method_path(merchant, payment_method1) }

      it "is successful" do
        expect(response).to have_http_status(:no_content)
        expect(Merchant.find_by(id: payment_method1.id)).to be_nil
      end
    end

    context "when unsuccessful" do
      before { delete v1_merchant_payment_method_path(merchant, -1) }

      it "is unsuccessful" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body["message"]).to include "Couldn't find PaymentMethod"
      end
    end
  end
end
