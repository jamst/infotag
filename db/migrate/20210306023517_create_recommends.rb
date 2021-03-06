class CreateRecommends < ActiveRecord::Migration[5.2]
  def change
    create_table :recommends do |t|
      t.string :title, comment: "标题"
      t.string :url, comment: "目标url"
      t.references :employee, default: 1, comment: "上传对象"
      t.integer :recommend_type, default: 0, comment: "分类：0外网头条，1综合推荐"
      t.references :mark, comment: "标注"
      t.integer :is_delete, default: 0, comment: "是否删除"
      t.integer :status, default: 0, comment: "状态：-1禁用,0启用"
      t.timestamps
    end
  end
end
