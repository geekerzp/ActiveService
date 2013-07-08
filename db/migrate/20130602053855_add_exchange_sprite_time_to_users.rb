class AddExchangeSpriteTimeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :exchange_sprite_time, :integer, :default => 0
  end
end
