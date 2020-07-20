class CreateMedialSpiders < ActiveRecord::Migration[5.2]
  def change
    create_table :medial_spiders do |t|
      t.references :spider_target, comment: "网站名称"
      t.string :url, comment: "网址url"
      t.string :web_site, comment: "网站模块"
      t.integer :medial_type, comment: "内容类型:0资讯,1视频"
      t.references :category, comment: "分类栏目"
      t.string :tags_str, comment: "过滤时间"
      t.string :tags_str, comment: "标签"
      t.integer :status, default: 0, comment: "状态：-1禁用,0启用"
      t.integer :is_delete, default: 0, comment: "是否删除"
      t.text :mark, comment: "描述"
      t.datetime :release_at, comment: "指定过滤时间"
      t.timestamps
    end
  end
end
