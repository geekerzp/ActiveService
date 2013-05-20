class AddSessionKeyToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :session_key, :string
  end
end
