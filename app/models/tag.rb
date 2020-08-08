class Tag < ApplicationRecord
  has_and_belongs_to_many :infos, through: :info_tags
  has_and_belongs_to_many :videos, through: :tags_videos
  has_many :keywords
  serialize :connection_tags
  enum status: { disabled: -1, enabled: 0 }
  default_scope -> {where(is_delete: 0)}

  before_save :auto_change_type

  def auto_change_type
    self.connection_tags = self.connection_tags&.split(',') unless self.connection_tags.is_a?(Array)
  end

  # 访问次数
  def incr_size
    $redis.get("tag_incr_#{self.id}").to_i
  end
  
end