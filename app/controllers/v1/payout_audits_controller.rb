module V1
  class PayoutAuditsController < ApplicationController
    def index
      payouts = Payout.all
      json_response({ payouts: payouts })
    end
  end
end
