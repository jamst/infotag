class CreateMarks < ActiveRecord::Migration[5.2]
  def change
    create_table :marks do |t|
      t.string :title, comment: "名称"
      t.string :url, comment: "图片地址"
      t.integer :is_delete, default: 0, comment: "是否删除"
      t.integer :status, default: 0, comment: "状态：-1禁用,0启用"
      t.timestamps
    end
  end
end
