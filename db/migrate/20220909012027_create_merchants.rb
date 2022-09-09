class CreateMerchants < ActiveRecord::Migration[5.2]
  def change
    create_table :merchants do |t|
      t.string :name, null: false, index: true, unique: true

      t.timestamps
    end
  end
end
