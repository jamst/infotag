class AddLocationSourceToVideos < ActiveRecord::Migration[5.2]
  def change
    add_column :videos, :is_location_source, :integer, default: 0, comment: "0:非本地资源，1:有本地资源"
    add_column :videos, :location_source_url, :string, comment: "本地资源url"
    add_column :videos, :ads, :integer, default: 0, comment: "0:非广告流，1:广告流"
    add_column :videos, :ads_index, :integer, default: 0, comment: "广告排序"
  end
end
