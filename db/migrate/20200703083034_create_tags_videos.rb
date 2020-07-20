class CreateTagsVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :tags_videos do |t|
      t.references "video", comment: "视频"
      t.references "tag", comment: "标签"
    end
  end
end
