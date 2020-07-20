class CreateKeywords < ActiveRecord::Migration[5.2]
  def change
    create_table :keywords do |t|
      t.string :name, comment: "名称"
      t.references :tag, comment: "标签"
      t.integer :click_count, comment: "点击数量"
      t.integer :status, default: 0, comment: "状态：-1禁用,0启用"
      t.integer :is_delete, default: 0, comment: "是否删除"
      t.timestamps
    end
  end
end
