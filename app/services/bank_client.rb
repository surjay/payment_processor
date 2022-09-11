# Fake Bank Client
class BankClient
  # PaymentProcessor Company Creds
  def initialize(account_number:, routing_number:)
  end

  def bank_transfer(amount:, account_number:, routing_number:)
    true
  end

  def bank_payout(amount:, account_number:, routing_number:)
    true
  end

  def cc_transfer(amount:, number:, cvv:, zip:, expiration:)
    true
  end

  def cc_payout(amount:, number:, cvv:, zip:, expiration:)
    true
  end
end
