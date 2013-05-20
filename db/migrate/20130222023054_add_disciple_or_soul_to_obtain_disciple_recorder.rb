class AddDiscipleOrSoulToObtainDiscipleRecorder < ActiveRecord::Migration
  def change
    add_column :obtain_disciple_recorders, :disciple_or_soul, :integer, default: 1
  end
end
