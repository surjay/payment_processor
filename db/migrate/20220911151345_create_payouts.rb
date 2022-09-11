class CreatePayouts < ActiveRecord::Migration[5.2]
  def change
    create_table :payouts do |t|
      t.references :merchant, foreign_key: true, index: true
      t.integer :transaction_ids, array: true, default: []
      t.decimal :total, precision: 20, scale: 2
      t.timestamps
    end
  end
end
