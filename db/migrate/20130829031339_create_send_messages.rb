class CreateSendMessages < ActiveRecord::Migration
  def change 
    create_table :send_messages, options: 'ENGINE=InnoDB, CHARSET=utf8' do |t|
      # 点对点的系统消息表
      t.text        :message      # 系统消息
      t.integer     :m_type, :default => '0' # 是管理员发送还是用户发送(0管理员发送，1用户发送)
      t.integer     :sender_id    # 发送者id
      t.integer     :receiver_id  # 接收者id
      t.timestamp   :send_time    # 发送时间
      t.timestamp   :receive_time, :default => '0000-00-00 00:00:00' # 接收时间
      t.integer     :status, :default => '0' # 是否成功接收(0失败，1成功)
      t.timestamps
    end 

    add_index :send_messages, :sender_id
    add_index :send_messages, :receiver_id
  end 
end
