class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :name, comment: "名称"
      t.integer :parent_id, comment: "父节点"
      t.integer :status, default: 1, comment: "状态"
      t.integer :sort_live, comment: "排序"
      t.timestamps
    end
  end
end
