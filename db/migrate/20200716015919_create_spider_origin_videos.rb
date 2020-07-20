class CreateSpiderOriginVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :spider_origin_videos do |t|
      t.string :spider_medial_id, comment: "爬虫配置id"
      t.string :url, comment: "目标url"
      t.string :title, comment: "标题"
      t.string :overlay_time, comment: "时长"
      t.string :play_count, comment: "播放量"
      t.datetime :release_at, comment: "发布时间"
      t.string :author, comment: "发布者名称"
      t.string :image_url, comment: "视频封面图片url"
      t.timestamps
    end
  end
end
