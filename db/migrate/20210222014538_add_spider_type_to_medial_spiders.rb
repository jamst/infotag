class AddSpiderTypeToMedialSpiders < ActiveRecord::Migration[5.2]
  def change
    add_column :medial_spiders, :spider_type, :integer, default: 0, comment: "0频道爬取，1视频爬取"
  end
end
