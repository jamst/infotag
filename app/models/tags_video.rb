class TagsVideo < ApplicationRecord
  has_many :tags
  has_many :videos
end