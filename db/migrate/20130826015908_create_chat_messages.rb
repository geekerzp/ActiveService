class CreateChatMessages < ActiveRecord::Migration
  def change 
    create_table :chat_messages, options: 'ENGINE=InnoDB, CHARSET=UTF8' do |t|
      t.references  :user           # 用户
      t.integer     :chat_type      # 聊天类型
      t.string      :message        # 聊天内容
      t.timestamps  
    end 

    add_index :chat_messages, :user_id
  end 
end
