class Category < ApplicationRecord
  has_many :infos
  has_many :videos
  enum status: { disabled: -1, enabled: 0 }
  default_scope -> {where(is_delete: 0)}

  def self.init_migration
    Category.create(name:"推荐")
    Category.create(name:"国际")
    Category.create(name:"美食")
    Category.create(name:"旅游")
    Category.create(name:"科技")
    Category.create(name:"娱乐")
  end

  # 清楚分类修改导致不一致问题
  def self.crean_diff
    Category.all.each do |ca|
      Info.where("category_id != ?", ca.id).each do |info|
        $redis.srem("category_#{ca.id}_infos", info.id)
      end
      Video.where("category_id != ?", ca.id).each do |video|
        $redis.srem("category_#{ca.id}_videos", video.id)
      end
    end
  end

end