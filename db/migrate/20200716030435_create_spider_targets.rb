class CreateSpiderTargets < ActiveRecord::Migration[5.2]
  def change
    create_table :spider_targets do |t|
      t.string :name, comment: "名称"
      t.string :url, comment: "网站url"
      t.string :logo_url, comment: "网站logo"
      t.integer :status, default: 1, comment: "状态"
      t.timestamps
    end
  end
end
