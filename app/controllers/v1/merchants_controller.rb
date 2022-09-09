module V1
  class MerchantsController < ApplicationController
    def index
      merchants = Merchant.all
      json_response({ merchants: merchants })
    end

    def show
      json_response({ merchant: merchant })
    end

    def create
      new_merchant = Merchant.new merchant_params
      new_merchant.save!
      json_response({ merchant: new_merchant }, status: :created)
    end

    def update
      merchant.update! merchant_params
      json_response({ merchant: merchant })
    end

    def destroy
      merchant.destroy!
      json_response({}, status: :no_content)
    end

    private

    def merchant
      @merchant ||= Merchant.find params[:id]
    end

    def merchant_params
      params.permit(:name)
    end
  end
end
