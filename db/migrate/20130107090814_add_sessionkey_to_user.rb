class AddSessionkeyToUser < ActiveRecord::Migration
  def change
    add_column :users, :session_key, :string
  end
end
