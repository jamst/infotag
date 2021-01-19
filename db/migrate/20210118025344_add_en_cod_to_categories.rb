class AddEnCodToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :en_cod, :integer, default: 0, comment: "外语"
    add_column :categories, :cnjt_cod, :integer, default: 0, comment: "简体"
    add_column :categories, :cnft_cod, :integer, default: 0, comment: "繁体"
  end
end
