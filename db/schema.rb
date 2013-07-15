# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130715080612) do

  create_table "admins", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "session_key"
  end

  add_index "admins", ["id"], :name => "index_admins_on_id"

  create_table "canbai_recorders", :force => true do |t|
    t.integer  "user_id"
    t.datetime "canbai_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "canbai_recorders", ["id"], :name => "index_canbai_recorders_on_id"

  create_table "canbai_reward_recorders", :force => true do |t|
    t.integer  "r_type",                      :default => 3
    t.integer  "user_id"
    t.integer  "accumulated_continuous_time", :default => 0
    t.date     "last_canbai_time",            :default => '1900-01-01'
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
  end

  add_index "canbai_reward_recorders", ["id"], :name => "index_canbai_reward_recorders_on_id"

  create_table "canzhang_grab_recorders", :force => true do |t|
    t.integer  "attacker_id"
    t.integer  "defender_id"
    t.integer  "who_win"
    t.string   "cz_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "canzhang_grab_recorders", ["id"], :name => "index_canzhang_grab_recorders_on_id"

  create_table "canzhangs", :force => true do |t|
    t.string   "cz_type",    :default => "-1"
    t.integer  "user_id",    :default => -1
    t.integer  "number",     :default => 0
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "canzhangs", ["id"], :name => "index_canzhangs_on_id"

  create_table "continuous_login_rewards", :force => true do |t|
    t.integer  "user_id"
    t.integer  "reward_1_type"
    t.integer  "reward_2_type"
    t.integer  "reward_3_type"
    t.integer  "continuous_login_time"
    t.integer  "receive_or_not"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "reward_1_id"
    t.string   "reward_2_id"
    t.string   "reward_3_id"
  end

  add_index "continuous_login_rewards", ["id"], :name => "index_continuous_login_rewards_on_id"

  create_table "dianbos", :force => true do |t|
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "user_id"
    t.integer  "dianbo_type"
    t.string   "server_time"
  end

  add_index "dianbos", ["id"], :name => "index_dianbos_on_id"

  create_table "disciples", :force => true do |t|
    t.integer  "user_id",       :default => -1
    t.integer  "level",         :default => 1
    t.integer  "experience",    :default => 0
    t.string   "d_type",        :default => ""
    t.float    "grow_blood",    :default => 0.0
    t.float    "grow_attack",   :default => 0.0
    t.float    "grow_defend",   :default => 0.0
    t.float    "grow_internal", :default => 0.0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "potential",     :default => 0
    t.integer  "break_time",    :default => 0
  end

  add_index "disciples", ["id"], :name => "index_disciples_on_id"

  create_table "equipment", :force => true do |t|
    t.string   "e_type",        :default => ""
    t.integer  "level",         :default => 1
    t.integer  "user_id",       :default => -1
    t.float    "grow_strength", :default => 0.0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "disciple_id"
    t.integer  "position",      :default => -1
  end

  add_index "equipment", ["id"], :name => "index_equipment_on_id"

  create_table "friend_apply_recorders", :force => true do |t|
    t.integer  "applicant_id"
    t.integer  "receiver_id"
    t.integer  "status"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "friend_apply_recorders", ["id"], :name => "index_friend_apply_recorders_on_id"

  create_table "giftbag_purchase_recorders", :force => true do |t|
    t.string   "name",       :default => ""
    t.integer  "number",     :default => 0
    t.integer  "user_id",    :default => -1
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "is_open",    :default => false
  end

  add_index "giftbag_purchase_recorders", ["id"], :name => "index_giftbag_purchase_recorders_on_id"

  create_table "gongfus", :force => true do |t|
    t.string   "gf_type",          :default => ""
    t.integer  "level",            :default => 0
    t.integer  "user_id",          :default => -1
    t.float    "grow_strength",    :default => 0.0
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "disciple_id"
    t.integer  "position",         :default => -1
    t.float    "grow_probability"
    t.boolean  "is_origin"
    t.integer  "experience",       :default => 0
  end

  add_index "gongfus", ["id"], :name => "index_gongfus_on_id"

  create_table "goods_purchase_recorders", :force => true do |t|
    t.string   "name",       :default => ""
    t.integer  "number",     :default => 0
    t.integer  "user_id",    :default => -1
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "goods_purchase_recorders", ["id"], :name => "index_goods_purchase_recorders_on_id"

  create_table "handbooks", :force => true do |t|
    t.integer  "object_type"
    t.integer  "exist_type"
    t.string   "object_id"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "handbooks", ["id"], :name => "index_handbooks_on_id"

  create_table "jianghu_recorders", :force => true do |t|
    t.integer  "user_id",    :default => -1
    t.integer  "scene_id",   :default => -1
    t.integer  "item_id",    :default => -1
    t.integer  "star",       :default => 0
    t.boolean  "is_finish",  :default => false
    t.integer  "fight_time", :default => 0
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "jianghu_recorders", ["id"], :name => "index_jianghu_recorders_on_id"
  add_index "jianghu_recorders", ["item_id"], :name => "index_jianghu_recorders_on_item_id"
  add_index "jianghu_recorders", ["scene_id"], :name => "index_jianghu_recorders_on_scene_id"
  add_index "jianghu_recorders", ["user_id"], :name => "index_jianghu_recorders_on_user_id"

  create_table "jianghu_reward_recorders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "scene_id"
    t.string   "reward"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "jianghu_reward_recorders", ["id"], :name => "index_jianghu_reward_recorders_on_id"

  create_table "jiaohuaji_recorders", :force => true do |t|
    t.integer  "r_type"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.date     "eat_at"
  end

  add_index "jiaohuaji_recorders", ["id"], :name => "index_jiaohuaji_recorders_on_id"

  create_table "lunjian_positions", :force => true do |t|
    t.integer  "user_id",          :default => -1
    t.integer  "position",         :default => 2147483647
    t.integer  "score",            :default => 0
    t.integer  "left_time",        :default => 0
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.boolean  "in_fighting"
    t.integer  "highest_position", :default => 1
  end

  add_index "lunjian_positions", ["id"], :name => "index_lunjian_positions_on_id"
  add_index "lunjian_positions", ["position"], :name => "index_lunjian_positions_on_position"
  add_index "lunjian_positions", ["user_id"], :name => "index_lunjian_positions_on_user_id"

  create_table "lunjian_recorders", :force => true do |t|
    t.integer  "attacker_id"
    t.integer  "defender_id"
    t.integer  "who_win"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "lunjian_recorders", ["attacker_id"], :name => "index_lunjian_recorders_on_attacker_id"
  add_index "lunjian_recorders", ["defender_id"], :name => "index_lunjian_recorders_on_defender_id"
  add_index "lunjian_recorders", ["id"], :name => "index_lunjian_recorders_on_id"

  create_table "lunjian_reward_recorders", :force => true do |t|
    t.integer  "user_id",    :default => -1
    t.integer  "position",   :default => -1
    t.integer  "reward",     :default => -1
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "lunjian_reward_recorders", ["id"], :name => "index_lunjian_reward_recorders_on_id"

  create_table "messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.string   "message"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "messages", ["id"], :name => "index_messages_on_id"

  create_table "obtain_disciple_recorders", :force => true do |t|
    t.integer  "user_id",          :default => -1
    t.integer  "od_type",          :default => -1
    t.string   "disciple_type",    :default => ""
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "disciple_or_soul", :default => 1
    t.boolean  "is_use_gold",      :default => false
  end

  add_index "obtain_disciple_recorders", ["id"], :name => "index_obtain_disciple_recorders_on_id"

  create_table "orders", :force => true do |t|
    t.string   "csid"
    t.string   "oid"
    t.string   "gid"
    t.integer  "user_id"
    t.string   "ginfo"
    t.integer  "gcount",                                   :default => 0
    t.decimal  "ogmoney",    :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "omoney",     :precision => 8, :scale => 2, :default => 0.0
    t.string   "type"
    t.integer  "status",                                   :default => 0
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
  end

  create_table "pay_recorders", :force => true do |t|
    t.integer  "p_type",     :default => -1
    t.integer  "user_id",    :default => -1
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "pay_recorders", ["id"], :name => "index_pay_recorders_on_id"

  create_table "recharge_recorders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "gold",       :default => 0, :null => false
    t.integer  "silver",     :default => 0, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "relationships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.integer  "relation_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "relationships", ["id"], :name => "index_relationships_on_id"

  create_table "servers", :force => true do |t|
    t.string   "name",       :default => ""
    t.string   "address",    :default => "127.0.0.1"
    t.integer  "state",      :default => 1
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "servers", ["id"], :name => "index_servers_on_id"

  create_table "souls", :force => true do |t|
    t.integer  "user_id",    :default => -1
    t.integer  "potential",  :default => 0
    t.integer  "number",     :default => 0
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "s_type",     :default => ""
  end

  add_index "souls", ["id"], :name => "index_souls_on_id"

  create_table "system_reward_recorders", :force => true do |t|
    t.string   "system_message"
    t.string   "reward_type"
    t.integer  "user_id"
    t.integer  "receive_or_not"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "system_reward_recorders", ["id"], :name => "index_system_reward_recorders_on_id"

  create_table "team_members", :force => true do |t|
    t.integer  "user_id",     :default => -1
    t.integer  "disciple_id", :default => -1
    t.integer  "position",    :default => -1
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "team_members", ["id"], :name => "index_team_members_on_id"

  create_table "user_goods", :force => true do |t|
    t.string   "g_type",     :default => "-1"
    t.integer  "user_id",    :default => -1
    t.integer  "number",     :default => 0
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "user_goods", ["id"], :name => "index_user_goods_on_id"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.string   "name",                 :default => ""
    t.integer  "vip_level",            :default => 1
    t.integer  "level",                :default => 1
    t.integer  "prestige",             :default => 0
    t.integer  "gold",                 :default => 0
    t.integer  "silver",               :default => 0
    t.integer  "power",                :default => 0
    t.integer  "experience",           :default => 0
    t.integer  "sprite",               :default => 0
    t.string   "last_login_ip"
    t.datetime "last_login_time"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "status"
    t.string   "session_key"
    t.integer  "direction_step"
    t.integer  "npc_or_not"
    t.integer  "upgrade_3_reward"
    t.integer  "upgrade_5_reward"
    t.integer  "upgrade_10_reward"
    t.integer  "upgrade_15_reward"
    t.integer  "exchange_power_time",  :default => 0
    t.integer  "exchange_sprite_time", :default => 0
    t.datetime "power_time"
    t.datetime "sprite_time"
  end

  add_index "users", ["id"], :name => "index_users_on_id"
  add_index "users", ["session_key"], :name => "index_users_on_session_key"
  add_index "users", ["username"], :name => "index_users_on_username"

  create_table "zhangmenjues", :force => true do |t|
    t.integer  "z_type"
    t.integer  "level",      :default => 0
    t.integer  "poli",       :default => 0
    t.integer  "score",      :default => 0
    t.integer  "user_id",    :default => -1
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "zhangmenjues", ["id"], :name => "index_zhangmenjues_on_id"

end
