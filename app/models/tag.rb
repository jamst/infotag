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

  # 标签删除关联删除用户tag，资讯tag
  def srem_tag_list
    # 删除标签下的新闻信息
    info_ids = $redis.smembers("tags_#{id}_infos")
    infos = Info.where(id:info_ids)
    infos.each do |info|
      info.tags_str = (info.tags_str.to_s.split(",")-[name]).join(",")
      info.save
      $redis.srem("tags_#{id}_infos", info.id)
    end
    # 删除标签下的视频信息
    video_ids = $redis.smembers("tags_#{id}_videos")
    videos = Video.where(id:video_ids)
    videos.each do |video|
      video.tags_str = (video.tags_str.to_s.split(",")-[name]).join(",")
      video.save
      $redis.srem("tags_#{id}_videos", video.id)
    end
    # 遍历用户列表删除用户身上标签
    users_lists = $redis.smembers("users_lists")
    users_lists.each do |user_id|
      $redis.srem("users_#{user_id}", id.to_s)
    end
  end
  
end