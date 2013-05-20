class AddIndexInAllTables < ActiveRecord::Migration
  def up
    add_index :admins, :id
    add_index :canbai_recorders, :id
    add_index :canbai_reward_recorders, :id
    add_index :canzhang_grab_recorders, :id
    add_index :canzhangs, :id
    add_index :continuous_login_rewards, :id
    add_index :dianbos, :id
    add_index :disciples, :id
    add_index :equipment, :id
    add_index :friend_apply_recorders, :id
    add_index :giftbag_purchase_recorders, :id
    add_index :gongfus, :id
    add_index :goods_purchase_recorders, :id
    add_index :handbooks, :id
    add_index :jianghu_recorders, :id
    add_index :jianghu_reward_recorders, :id
    add_index :jiaohuaji_recorders, :id
    add_index :lunjian_positions, :id
    add_index :lunjian_recorders, :id
    add_index :lunjian_reward_recorders, :id
    add_index :messages, :id
    add_index :obtain_disciple_recorders, :id
    add_index :pay_recorders, :id
    add_index :relationships, :id
    add_index :servers, :id
    add_index :souls, :id
    add_index :system_reward_recorders, :id
    add_index :team_members, :id
    add_index :user_goods, :id
    add_index :users, :id
    add_index :zhangmenjues, :id
  end

  def down
    remove_index :admins, :id
    remove_index :canbai_recorders, :id
    remove_index :canbai_reward_recorders, :id
    remove_index :canzhang_grab_recorders, :id
    remove_index :canzhangs, :id
    remove_index :continuous_login_rewards, :id
    remove_index :dianbos, :id
    remove_index :disciples, :id
    remove_index :equipment, :id
    remove_index :friend_apply_recorders, :id
    remove_index :giftbag_purchase_recorders, :id
    remove_index :gongfus, :id
    remove_index :goods_purchase_recorders, :id
    remove_index :handbooks, :id
    remove_index :jianghu_recorders, :id
    remove_index :jianghu_reward_recorders, :id
    remove_index :jiaohuaji_recorders, :id
    remove_index :lunjian_positions, :id
    remove_index :lunjian_recorders, :id
    remove_index :lunjian_reward_recorders, :id
    remove_index :messages, :id
    remove_index :obtain_disciple_recorders, :id
    remove_index :pay_recorders, :id
    remove_index :relationships, :id
    remove_index :servers, :id
    remove_index :souls, :id
    remove_index :system_reward_recorders, :id
    remove_index :team_members, :id
    remove_index :user_goods, :id
    remove_index :users, :id
    remove_index :zhangmenjues, :id
  end
end
