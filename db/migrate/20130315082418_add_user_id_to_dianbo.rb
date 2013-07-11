class AddUserIdToDianbo < ActiveRecord::Migration
  def change
    add_column :dianbos, :user_id, :integer
  end
end
