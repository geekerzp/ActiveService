class RenameColumnOnJianghuRecorders < ActiveRecord::Migration
  def up
    rename_column :jianghu_recorders, :failed_time, :fight_time
  end

  def down
    rename_column :jianghu_recorders, :fight_time, :failed_time
  end
end
