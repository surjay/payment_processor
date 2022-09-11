class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.references :merchant, foreign_key: true, index: true
      t.references :payment_method, foreign_key: true, index: true
      t.references :to_merchant, foreign_key: { to_table: :merchants }, index: true
      t.integer :scheduled_type, default: 0, index: true
      t.integer :status, default: 0, index: true
      t.date :scheduled_date, index: true
      t.decimal :amount, precision: 20, scale: 2
      t.timestamps
    end
    add_index :transactions, [:scheduled_type, :scheduled_date, :status], name: "index_transactions_on_type_and_date_and_status"
  end
end
