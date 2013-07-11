class AddDiscipleidToGongfu < ActiveRecord::Migration
  def change
    add_column :gongfus, :disciple_id, :integer
  end
end
