class ChangeTypeToRTypeInJiaohuajiRecorder < ActiveRecord::Migration
  def up
    rename_column :jiaohuaji_recorders, :type, :r_type
  end

  def down
    rename_column :jiaohuaji_recorders, :r_type, :type
  end
end
