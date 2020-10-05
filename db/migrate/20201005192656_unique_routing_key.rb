class UniqueRoutingKey < ActiveRecord::Migration[6.0]
  def change
    add_index :routing_keys, :routing_key, :unique => true
  end
end
