class AddIndeces < ActiveRecord::Migration
  def change
    add_index :lunjian_positions, :position
    add_index :lunjian_positions, :user_id

    add_index :lunjian_recorders, :attacker_id
    add_index :lunjian_recorders, :defender_id

    add_index :jianghu_recorders, :user_id
    add_index :jianghu_recorders, :scene_id
    add_index :jianghu_recorders, :item_id

    add_index :users, :username
    add_index :users, :session_key
  end
end
