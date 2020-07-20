class Tag < ApplicationRecord
  has_and_belongs_to_many :infos, through: :info_tags
  has_and_belongs_to_many :videos, through: :tags_videos
  has_many :keywords
  serialize :connection_tags
end