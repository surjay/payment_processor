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
      method_type = payment_method_params[:method_type]
      new_payment_method = merchant.payment_methods.new method_type: method_type
      if method_type.to_s == "bank"
        new_payment_method.set_bank_info(payment_method_params[:bank_info])
      else
        new_payment_method.set_cc_info(payment_method_params[:credit_card_info])
      end
      new_payment_method.save!
      json_response({ payment_method: new_payment_method }, status: :created)
    end

    def update
      if payment_method.bank?
        payment_method.set_bank_info(params[:bank_info].permit!)
      else
        payment_method.set_cc_info(params[:credit_card_info].permit!)
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
