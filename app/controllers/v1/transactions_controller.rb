module V1
  class TransactionsController < ApplicationController
    def index
      transactions = merchant.transactions
      json_response({ transactions: transactions })
    end

    def show
      json_response({ transaction: transaction })
    end

    def create
      new_transaction = merchant.transactions.new transaction_params
      new_transaction.save!
      json_response({ transaction: new_transaction }, status: :created)
    end

    def update
      transaction.update! transaction_params
      json_response({ transaction: transaction })
    end

    def destroy
      transaction.destroy!
      json_response({}, status: :no_content)
    end

    private

    def merchant
      @merchant ||= Merchant.find params[:merchant_id]
    end

    def transaction
      @transaction ||= merchant.transactions.find params[:id]
    end

    def transaction_params
      params.permit(:to_merchant_id, :scheduled_type, :payment_method_id, :amount, :scheduled_date)
    end
  end
end
