class AddSpiderTargetItToInfos < ActiveRecord::Migration[5.2]
  def change
    add_column :infos, :spider_target_id, :integer, comment: "信息来源"
    add_column :videos, :spider_target_id, :integer, comment: "信息来源"
  end
end
