# frozen_string_literal: true

require 'rails_helper'

describe V1::MerchantsController, type: :request do
  let!(:merchant) { Merchant.create name: name }
  let(:name) { "Test Co" }
  let(:new_name) { "New Company" }

  describe "#index" do
    before { get v1_merchants_path }

    it "is successful" do
      expect(response).to have_http_status(:ok)
    end

    it "returns a list of merchants" do
      merchant_ids = response.parsed_body["merchants"].map { |m| m["id"] }
      expect(merchant_ids).to include merchant.id
    end
  end

  describe "#show" do
    context "when successful" do
      before { get v1_merchant_path(merchant) }

      it "is successful" do
        expect(response).to have_http_status(:ok)
      end

      it "returns a merchant" do
        expect(response.parsed_body.dig("merchant", "id")).to eq merchant.id
      end
    end

    context "when unsuccessful" do
      before { get v1_merchant_url(-1) }

      it "is unsuccessful" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body["message"]).to include "Couldn't find Merchant"
      end
    end
  end

  describe "#create" do
    before { post v1_merchants_path, params: params }

    context "when successful" do
      let(:params) { { name: new_name } }

      it "is successful" do
        expect(response).to have_http_status(:created)
        expect(response.parsed_body.dig("merchant", "name")).to eq new_name
      end
    end

    context "when unsuccessful" do
      let(:params) { {} }

      it "is unsuccessful" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["message"]).to include "Validation failed"
      end
    end
  end

  describe "#update" do
    before { patch v1_merchant_path(merchant), params: params }

    context "when successful" do
      let(:params) { { name: new_name } }

      it "is successful" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.dig("merchant", "name")).to eq new_name
        expect(merchant.reload.name).to eq new_name
      end
    end

    context "when unsuccessful" do
      let(:params) { { name: other_merchant.name } }
      let(:other_merchant) { Merchant.create name: new_name }

      it "is unsuccessful" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["message"]).to include "Validation failed"
      end
    end
  end

  describe "#destroy" do
    context "when successful" do
      before { delete v1_merchant_path(merchant) }

      it "is successful" do
        expect(response).to have_http_status(:no_content)
        expect(Merchant.find_by(id: merchant.id)).to be_nil
      end
    end

    context "when unsuccessful" do
      before { delete v1_merchant_url(-1) }

      it "is unsuccessful" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body["message"]).to include "Couldn't find Merchant"
      end
    end
  end
end
