class CreateInfosCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :info_categories do |t|
      t.references "info", comment: "咨讯"
      t.references "category", comment: "分类"
    end
  end
end
