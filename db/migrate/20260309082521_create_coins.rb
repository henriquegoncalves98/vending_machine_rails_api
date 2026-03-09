class CreateCoins < ActiveRecord::Migration[8.0]
  def change
    create_table :coins do |t|
      t.integer :denomination, null: false
      t.integer :stock, null: false

      t.timestamps
    end
  end
end
