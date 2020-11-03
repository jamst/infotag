class AddTagsStrToSpiderOriginVideos < ActiveRecord::Migration[5.2]
  def change
    add_column :infos, :category_list, :string, comment: "资讯分类"
    add_column :videos, :category_list, :string, comment: "视频分类"
  end
end
