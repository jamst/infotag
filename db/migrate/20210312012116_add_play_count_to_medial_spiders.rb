class AddPlayCountToMedialSpiders < ActiveRecord::Migration[5.2]
  def change
    add_column :medial_spiders, :play_count, :string, default: 5000, comment: "播放量"
  end
end
