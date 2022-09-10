module V1
  class PaymentMethodsController < ApplicationController
    def index
      payment_methods = merchant.payment_methods
      json_response({ payment_methods: payment_methods })
    end

    def show
      json_response({ payment_method: payment_method })
    end

    def create
      new_payment_method = merchant.payment_methods.new payment_method_params
      new_payment_method.save!
      json_response({ payment_method: new_payment_method }, status: :created)
    end

    def update
      if payment_method.bank?
        bank_info = params[:bank_info].permit!
        bank_info.each_pair { |k, v| payment_method.bank_info[k] = v }
      else
        cc_info = params[:credit_card_info].permit!
        cc_info.each_pair { |k, v| payment_method.credit_card_info[k] = v }
      end
      payment_method.save!

      json_response({ payment_method: payment_method })
    end

    def destroy
      payment_method.destroy!
      json_response({}, status: :no_content)
    end

    private

    def merchant
      @merchant ||= Merchant.find params[:merchant_id]
    end

    def payment_method
      @payment_method ||= merchant.payment_methods.find params[:id]
    end

    def payment_method_params
      params.permit(
        :method_type,
        bank_info: PaymentMethod::BANK_FIELDS,
        credit_card_info: PaymentMethod::CC_FIELDS,
      )
    end
  end
end
