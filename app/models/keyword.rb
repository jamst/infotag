class Keyword < ApplicationRecord
  belongs_to :tag
  # 用户标签来源明细记录
  has_many :user_tag_details, as: :from_entity
end