class GeneratePayouts
  def initialize(payout_date:)
    @payout_date = payout_date
  end

  def perform
    Merchant.where(id: merchant_ids).find_each do |merchant|
      generate_payout(merchant)
    end
  end

  private

  def merchant_ids
    @merchant_ids ||= Transaction.pending.future.where(scheduled_date: @payout_date).pluck(:to_merchant_id)
  end

  def generate_payout(merchant)
    pending_transactions = merchant.to_transactions.pending.future.where(scheduled_date: @payout_date)
    return unless pending_transactions.any?

    totals = []
    pending_transactions.find_each do |transaction|
      totals << DebitTransaction.new(transaction: transaction).perform
    end

    total = totals.sum
    payout = merchant.payouts.create! transaction_ids: pending_transactions.map(&:id), total: total
    CreditTransaction.new(payout: payout).perform
  end
end
