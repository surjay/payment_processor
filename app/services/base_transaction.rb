# frozen_string_literal: true

class BaseTransaction
  private

  def client
    @client ||= BankClient.new(
      routing_number: company_routing_number,
      account_number: company_account_number
    )
  end

  private

  def company_routing_number
    ENV["COMPANY_ROUTING_NUMBER"].presence || "011000138"
  end

  def company_account_number
    ENV["COMPANY_ACCOUNT_NUMBER"].presence || "123352523"
  end
end
