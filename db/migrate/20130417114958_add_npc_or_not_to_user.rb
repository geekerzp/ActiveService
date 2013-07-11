class AddNpcOrNotToUser < ActiveRecord::Migration
  def change
    add_column :users, :npc_or_not, :integer
  end
end
