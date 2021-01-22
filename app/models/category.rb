class Category < ApplicationRecord
  has_many :infos
  has_many :videos
  has_many :category_conditions
  enum status: { disabled: -1, enabled: 0 }
  default_scope -> {where(is_delete: 0)}
  accepts_nested_attributes_for :category_conditions, allow_destroy: true, :reject_if => :all_blank

  def self.init_migration
    Category.create(name:"推荐")
    Category.create(name:"国际")
    Category.create(name:"美食")
    Category.create(name:"旅游")
    Category.create(name:"科技")
    Category.create(name:"娱乐")
  end

  # 清除分类修改导致不一致问题
  def self.crean_diff
    Category.all.each do |ca|
      $redis.del("category_#{ca.id}_infos")
      $redis.del("category_#{ca.id}_videos")
    end
  end

  # up_category
  def self.up_category
    Category.all.each do |ca|
      $redis.sadd("category_#{ca.id}_infos",Info.where("category_id = ?", ca.id).ids)
      $redis.sadd("category_#{ca.id}_videos",Video.where("category_id = ?", ca.id).ids)
    end
  end

  # 同步爬取设置分类
  def self.up_medial_spider
    MedialSpider.info.each do |medial|
      Info.where("medial_spider_id = ?", medial.id).each do |info|
        info.update(category_id:medial.category_id)
      end
    end

    MedialSpider.video.each do |medial|
      Video.where("medial_spider_id = ?", medial.id).each do |video|
        video.update(category_id:medial.category_id)
      end
    end
  end

  # 类型占比缓存
  def cache_condition
    redis_cache_conditions = {}
    cache_conditions = []
    category_conditions.each do |category_condition|
      condition = {}
      condition[:classification_id] = category_condition.classification_id
      condition[:weight] = category_condition.weight
      condition[:tags_str] = category_condition.tags_str.to_s
      cache_conditions << condition
    end
    redis_cache_conditions[:cache] = cache_conditions
    $redis.set("cache_category_condition_#{id}",redis_cache_conditions.to_json)
  end


  # 获取类型占比缓存
  def get_cache_condition
    cache_category_condition = $redis.get("cache_category_condition_#{id}")
    unless cache_category_condition.present?
      cache_category_condition = cache_condition
    end
    cache_category_condition
  end


end