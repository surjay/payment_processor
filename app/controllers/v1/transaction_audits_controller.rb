module V1
  class TransactionAuditsController < ApplicationController
    def index
      transactions = Transaction.where(scheduled_date: params[:scheduled_date])
      json_response({ transactions: transactions })
    end
  end
end
