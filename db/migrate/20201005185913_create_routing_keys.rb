class CreateRoutingKeys < ActiveRecord::Migration[6.0]
  def change
    create_table :routing_keys do |t|
      t.string :routing_key
      t.string :token
      t.boolean :verified

      t.timestamps
    end
  end
end
