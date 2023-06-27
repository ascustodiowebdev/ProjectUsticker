class CreateJoinTableOrderSticker < ActiveRecord::Migration[7.0]
  def change
    create_join_table :orders, :stickers do |t|
      # t.index [:order_id, :sticker_id]
      # t.index [:sticker_id, :order_id]
    end
  end
end
