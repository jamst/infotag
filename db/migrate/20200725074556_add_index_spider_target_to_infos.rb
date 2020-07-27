class AddIndexSpiderTargetToInfos < ActiveRecord::Migration[5.2]
  def change
    add_index :infos, :spider_target_id
    add_index :videos, :spider_target_id
  end
end
