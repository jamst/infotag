class CreateCategoryConditions < ActiveRecord::Migration[5.2]
  def change
    create_table :category_conditions do |t|
      t.references :category, comment: "栏目"
      t.references :classification, comment: "分类"
      t.integer :weight, default: 0, comment: "权重：10%,20%,30%,40%,50%,60%,70%,80%,90%,100%"
      t.string :tags_str, comment: "关键词"
      t.timestamps
    end
  end
end
