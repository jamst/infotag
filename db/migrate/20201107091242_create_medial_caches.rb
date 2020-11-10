class CreateMedialCaches < ActiveRecord::Migration[5.2]
  def change
    create_table :medial_caches do |t|
      t.string :uuid, comment: "uuid"
      t.string :title, comment: "名称"
      t.string :link, comment: "链接"
      t.text :image_base64, default: "", comment: "图片内容"
      t.string :medial_source, default: "youtube", comment: "媒体资源"
      t.string :local_model, default: "Video", comment: "资源类型"
      t.string :local_id, default: 0, comment: "本地缓存ID"
      t.integer :status, default: 0, comment: "是否已审核"
      t.timestamps
    end
  end
end
