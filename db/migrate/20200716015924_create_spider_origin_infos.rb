class CreateSpiderOriginInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :spider_origin_infos do |t|
      t.string :spider_medial_id, comment: "爬虫配置id"
      t.string :url, comment: "目标url"
      t.string :title, comment: "标题"
      t.datetime :release_at, comment: "发布时间"
      t.string :image_url, comment: "视频封面图片url"
      t.text :mark, comment: "描述"
      t.timestamps
    end
  end
end
