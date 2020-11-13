class CreateStrategySourceDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :strategy_source_details do |t|
      t.references :strategy_source, comment: "资源用户" 
      t.string :title, comment: "内容标题"
      t.string :link, comment: "内容链接"
      t.string :source_tags, comment: "不合规描述"
      t.string :source_keyword, comment: "违规关键字"
      t.string :source_view, comment: "播放热度"
      t.datetime :release_at, comment: "收录时间"
      t.timestamps
    end
    add_index :strategy_source_details, :title
    add_index :strategy_source_details, :release_at
  end
end
