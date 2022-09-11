# frozen_string_literal: true

class CreditTransaction < BaseTransaction
  def initialize(payout:)
    @payout = payout
    @merchant = payout.merchant
  end

  def perform
    default_payment_method = @merchant.payment_methods.default.take
    if default_payment_method.bank?
      make_bank_payout(default_payment_method)
    else
      make_cc_payout(default_payment_method)
    end
  end

  private

  def make_bank_payout(payment_method)
    client.bank_payout(
      amount: @payout.total.to_s,
      routing_number: payment_method.routing_number,
      account_number: payment_method.account_number,
    )
  end

  def make_cc_payout(payment_method)
    client.cc_payout(
      amount: @payout.total.to_s,
      number: payment_method.number,
      cvv: payment_method.cvv,
      expiration: payment_method.expiration,
      zip: payment_method.zip
    )
  end
end
