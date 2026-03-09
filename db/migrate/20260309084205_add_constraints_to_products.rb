class AddConstraintsToProducts < ActiveRecord::Migration[8.0]
  def change
    add_index :products, :name, unique: true

    # Stock >= 0 constraint
    execute <<-SQL.squish
      ALTER TABLE products 
      ADD CONSTRAINT check_stock_positive 
      CHECK (stock >= 0)
    SQL
    
    # Price >= 0 constraint  
    execute <<-SQL.squish
      ALTER TABLE products 
      ADD CONSTRAINT check_price_positive 
      CHECK (price >= 0)
    SQL
  end
end
