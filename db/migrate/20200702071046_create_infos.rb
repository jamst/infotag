class CreateInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :infos do |t|
      t.string :title, comment: "标题"
      t.string :url, comment: "目标url"
      t.string :image_url, comment: "图片url"
      t.string :local_image_url, comment: "本地视频封面图片url"
      t.references :category, comment: "类型"
      t.references :medial_spider, comment: "爬虫设置"
      t.string :tags_str, comment: "标签"
      t.integer :weight, default: 0, comment: "权重：0随机，1置顶"
      t.integer :click_count, comment: "点击数量"
      t.integer :status, default: 0, comment: "状态：-1禁用,0启用"
      t.integer :is_delete, default: 0, comment: "是否删除"
      t.datetime :release_at, comment: "发布时间"
      t.string :author, comment: "发布者名称"
      t.text :mark, comment: "描述"
      t.integer :medial_type, default: 0, comment: "内容类型:0资讯,1视频"
      t.integer :approve_status, default: 0, comment: "状态：-1已拒绝,0待审核,1已通过"
      t.timestamps
    end
    add_index :infos, :release_at
  end
end
