class AddCategoryListToSpiderOriginVideos < ActiveRecord::Migration[5.2]
  def change
    add_column :spider_origin_videos, :category_list, :string, comment: "视频分类"
    add_column :spider_origin_infos, :category_list, :string, comment: "资讯分类"
    add_column :spider_origin_videos, :tags_str, :string, comment: "视频标签"
    add_column :spider_origin_infos, :tags_str, :string, comment: "资讯标签"
  end
end
