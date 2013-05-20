class AddServerTimeToDianbos < ActiveRecord::Migration
  def change
    add_column :dianbos, :server_time, :string
  end
end
