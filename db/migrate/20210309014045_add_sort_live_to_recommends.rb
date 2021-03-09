class AddSortLiveToRecommends < ActiveRecord::Migration[5.2]
  def change
    add_column :recommends, :sort_live, :integer, comment: "排序"
  end
end
