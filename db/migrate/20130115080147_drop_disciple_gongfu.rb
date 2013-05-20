class DropDiscipleGongfu < ActiveRecord::Migration
  def up
    drop_table :disciple_gongfus
  end

  def down
    create_table :disciple_gongfus
  end
end
