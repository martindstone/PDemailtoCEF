class AddEmailToRoutingKey < ActiveRecord::Migration[6.0]
  def change
    add_column :routing_keys, :email, :string
    add_index :routing_keys, :email, unique: true
  end
end
