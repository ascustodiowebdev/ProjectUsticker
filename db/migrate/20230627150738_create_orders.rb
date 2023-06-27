class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.string :full_name
      t.string :email
      t.text :address
      t.string :phonenumber
      t.timestamps
    end
  end
end