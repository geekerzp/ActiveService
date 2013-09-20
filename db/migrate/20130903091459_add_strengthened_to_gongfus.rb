class AddStrengthenedToGongfus < ActiveRecord::Migration
  def change
    add_column :gongfus, :strengthened_token, :string
  end
end
