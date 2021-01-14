class AddEncodingTypeToVideos < ActiveRecord::Migration[5.2]
  def change
    add_column :videos, :encoding_type, :integer, default: 1, comment: "编码类型：0英文，1简体，2繁体"
    add_column :infos, :encoding_type, :integer, default: 1, comment: "编码类型：0英文，1简体，2繁体"
    add_column :spider_origin_videos, :encoding_type, :integer, default: 1, comment: "编码类型：0英文，1简体，2繁体"
    add_column :spider_origin_infos, :encoding_type, :integer, default: 1, comment: "编码类型：0英文，1简体，2繁体"

    add_column :videos, :classification_id, :integer, comment: "分类"
    add_column :infos, :classification_id, :integer, comment: "分类"
    add_column :spider_origin_videos, :classification_id, :integer, comment: "分类"
    add_column :spider_origin_infos, :classification_id, :integer, comment: "分类"
    add_column :medial_spiders, :classification_id, :integer, comment: "分类"

    add_index :videos, :encoding_type
    add_index :infos, :encoding_type
    add_index :spider_origin_videos, :encoding_type
    add_index :spider_origin_infos, :encoding_type
    
    add_index :videos, :classification_id
    add_index :infos, :classification_id
    add_index :medial_spiders, :classification_id
  end
end
