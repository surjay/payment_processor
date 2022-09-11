# README

* Ruby 2.7; Rails 5.2; postgres

Setup
- bundle install
- bin/rails db:migrate

Run Specs
- bundle exec rspec spec/

Endpoints/Flow

- Create Merchant
```ruby
POST /v1/merchants
{
  name: "Company Name",
}
```
- Create PaymentMethod
```ruby
POST /v1/merchants/:merchant_id/payment_methods 
{
  method_type: "bank",
  bank_info: {
    name: "Chase",
    routing_number: "011000015",
    account_number: "456"
  }
}
```
- Create Transaction 
```ruby
POST /v1/merchants/:merchant_id/transactions 
{
  to_merchant_id: 2, 
  scheduled_type: "future", 
  payment_method_id: 1, 
  amount: "5252.23", 
  scheduled_date: "2012-12-22"
}
```

- Manually Generate Payouts 
```ruby
GeneratePayouts.new(payout_date: "2012-12-22").perform
```

This can be hooked up to a cron in the future (ie Heroku Advanced Scheduler, AWS Cloudwatch Scheduled Events, Sidekiq Scheduled Jobs, etc.)
