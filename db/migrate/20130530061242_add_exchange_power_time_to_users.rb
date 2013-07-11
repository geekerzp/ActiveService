class AddExchangePowerTimeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :exchange_power_time, :integer, :default => 0
  end
end
