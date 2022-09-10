class CreatePaymentMethods < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_methods do |t|
      t.references :merchant, foreign_key: true, index: true
      t.integer :method_type, default: 0, null: false, index: true
      t.jsonb :data, default: {}

      t.timestamps
    end
  end
end
