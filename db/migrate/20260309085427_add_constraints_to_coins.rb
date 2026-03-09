class AddConstraintsToCoins < ActiveRecord::Migration[8.0]
  def change
    add_index :coins, :denomination, unique: true

    # Stock >= 0 constraint
    execute <<-SQL.squish
      ALTER TABLE coins 
      ADD CONSTRAINT check_stock_positive 
      CHECK (stock >= 0)
    SQL
  end
end
