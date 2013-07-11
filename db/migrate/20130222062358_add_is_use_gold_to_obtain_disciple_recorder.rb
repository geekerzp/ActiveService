class AddIsUseGoldToObtainDiscipleRecorder < ActiveRecord::Migration
  def change
    add_column :obtain_disciple_recorders, :is_use_gold, :boolean, default: FALSE
  end
end
