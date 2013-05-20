class CreateObtainDiscipleRecorders < ActiveRecord::Migration
  def change
    create_table :obtain_disciple_recorders, options: 'ENGINE=INNODB, CHARSET=UTF8' do |t|
      t.integer :user_id, default: -1
      t.integer :od_type, default: -1
      t.string :disciple_type, default: ''

      t.timestamps
    end
  end
end
