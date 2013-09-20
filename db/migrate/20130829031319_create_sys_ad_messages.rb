class CreateSysAdMessages < ActiveRecord::Migration
  def change 
    create_table :sys_ad_messages, options: 'ENGINE=InnoDB, CHARSET=utf8' do |t|
      # 群发的系统消息表
      t.text        :message    # 系统消息
      t.integer     :m_type, :default => '0' # 是管理员添加还是客户端推送(0管理员添加，1客户端推送)
      t.string      :user_rule  # 可以接收系统消息的用户规则
      t.timestamp   :start_time, :default => '0000-00-00 00:00:00'  # 系统消息有效期开始时间
      t.timestamp   :end_time, :default => '0000-00-00 00:00:00'    # 系统消息有效期结束时间
      t.boolean     :deleted, :default => '0'   # 是否删除(0没有删除，1已经删除)
      t.timestamps
    end 
  end 
end
