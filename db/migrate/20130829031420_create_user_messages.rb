class CreateUserMessages < ActiveRecord::Migration
  def change 
    create_table :user_messages, options: 'ENGINE=InnoDB, CHARSET=utf8' do |t|
      # 用户系统消息收件箱
      t.references  :user           # 关联用户
      t.integer     :m_type           # 消息类型(群发消息或点对点消息)
      t.integer     :rel_id, :default => '0'  # 关联的message的id 
      t.boolean     :deleted, :default => '0' # 是否删除(0没有删除，1已经删除)
      t.timestamps
    end 

    add_index :user_messages, :user_id 
    add_index :user_messages, :rel_id
  end 
end
