class CreateStrategySources < ActiveRecord::Migration[5.2]
  def change
    create_table :strategy_sources do |t|
      t.string :medial_source, default: "youtube", comment: "网站名称"
      t.string :web_user, comment: "用户名称"
      t.string :trouble_size, comment: "不合规内容数"
      t.datetime :release_at, comment: "收录时间"
      t.integer :user_status, default: 1, comment: "用户状态：0白名单，1黑名单"
      t.string :user_tags, comment: "用户标签"
      t.string :user_follow, comment: "用户关注数"
      t.string :user_view, comment: "用户播放热度"
      t.timestamps
    end
    add_index :strategy_sources, :medial_source
    add_index :strategy_sources, :web_user
    add_index :strategy_sources, :release_at
  end
end
