class AddDefaultToPaymentMethods < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_methods, :default, :boolean, default: false
  end
end
