# frozen_string_literal: true

class DebitTransaction < BaseTransaction
  def initialize(transaction:)
    @transaction = transaction
    @payment_method = transaction.payment_method
  end

  def perform
    total = if @payment_method.bank?
              debit_bank
            else
              debit_cc
            end
    total
  end

  private

  def debit_bank
    total_amount = @transaction.amount * 0.01 + 1
    client.bank_transfer(
      amount: total_amount,
      routing_number: @payment_method.routing_number,
      account_number: @payment_method.account_number
    )
    total_amount
  end

  def debit_cc
    total_amount = @transaction.amount * 0.029 + 0.30
    client.cc_transfer(
      amount: total_amount,
      number: @payment_method.number,
      cvv: @payment_method.cvv,
      expiration: @payment_method.expiration,
      zip: @payment_method.zip
    )
    total_amount
  end
end
