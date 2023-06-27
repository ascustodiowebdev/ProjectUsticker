class AddQuantityToOrdersStickers < ActiveRecord::Migration[7.0]
  def change
    add_column :orders_stickers, :quantity, :integer, default: 1
  end
end
