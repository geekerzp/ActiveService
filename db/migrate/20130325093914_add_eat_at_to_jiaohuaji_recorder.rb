class AddEatAtToJiaohuajiRecorder < ActiveRecord::Migration
  def change
    add_column :jiaohuaji_recorders, :eat_at, :date
  end
end
