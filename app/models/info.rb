class Info < ApplicationRecord
  has_and_belongs_to_many :tags, through: :infos_tags
  belongs_to :category
  belongs_to :medial_spider
  # 用户标签来源明细记录
  has_many :user_tag_details, as: :from_entity

  has_one :file_attachment, as: :attachment_entity

  enum status: { disabled: -1, enabled: 0 }
  enum weight: { nomal: 0, top: 1 }
  enum medial_type: { info: 0, video: 1 }
  enum approve_status: { unapproved: -1, wapprove: 0, approved: 1 }

  default_scope -> {where(is_delete: 0)}

  after_create :image_save
  after_save :tag_list, if: -> { self.saved_change_to_tags_str? }
  after_update :top_update, if: -> { self.saved_change_to_weight? }

  # 标签下有哪些咨讯
  def tag_list
    info_id = self.id
    tags_strs = tags_str.present? ? tags_str : (medial_spider.present? && medial_spider.tags_str.present? ? medial_spider.tags_str : "default")
    tags_strs.to_s.split(",").each do |tag_name|
      tag = Tag.find_or_create_by(name:tag_name)
      tag_id = tag.id
      InfosTag.find_or_create_by(tag_id: tag_id , info_id:info_id)
      $redis.sadd("tags_#{tag_id}_infos", info_id)
    end
  end

  # 每天推荐的咨询包
  def self.add_today_list
    Info.all.order(created_at: :desc).limit(100).each do |info|
      $redis.sadd("infos_#{Time.now.at_beginning_of_day.to_i}", info.id)
    end
  end
  def self.today_list
    $redis.smembers("infos_#{Time.now.at_beginning_of_day.to_i}").sample(10)
  end

  # 分类获取
  def self.category_list(category_id)
    $redis.smembers("category_#{category_id}_infos").sample(10)
  end

  # 缓存图片到本地
  def image_save
    image_url = self.image_url
    file_name = image_url.split("?").first.to_s.split("/").last
    file_name = "#{get_random}_#{file_name}"
    image_path = "#{Rails.root}/public/medial_images/infos/#{self.id}_#{file_name}"
    file = File.open(image_path, 'wb'){|f| f.write(open(image_url) {|f| f.read})}
    file = File.open(image_path) 
    result = FileAttachment.add_file_to_mongo(file,file_name)
    self.update(local_image_url:result.get_file_path)
    result.update(attachment_entity_type: "Info", attachment_entity_id: self.id)

    FileUtils.rm_rf image_path if image_path

    # Thread.new do
    #   sleep 2
    #   #  %x(rm "#{image_path}")
    #   FileUtils.rm_rf image_path if image_path
    # end

    # 加入分类缓存
    $redis.sadd("category_#{category_id}_infos", self.id)

  end


  def get_random(len=10,chars=[])
    chars = ("0".."9").to_a if chars.blank?
    result = []
    len.times { |i| result << chars[rand(chars.size-1)] }
    result.join('')
  end


  # 置顶缓存处理
  def top_update
    if weight == "top"
      top_list
    else
      cancer_top_list
    end
  end
  # 视频置顶列表
  def top_list
    $redis.sadd("infos_top", self.id)
  end
  # todo定时移除top
  def cancer_top_list
    $redis.srem("infos_top", self.id)
  end

 
  # 获取置顶列表
  def self.get_top(user_id)
    # 标签下视频记录
    infos = $redis.smembers("infos_top")
    # 用户访问视频记录
    user_infos = $redis.smembers("user_#{user_id}_infos")
    # 用户没有访问过的视频
    flow_infos = infos - user_infos
    flow_infos.sample(2)
  end


  # 导入数据
  def self.import_db
    SpiderOriginInfo.where("created_at >= ? ",Time.now.at_beginning_of_day).each do |data|
      medial_spider = MedialSpider.find_by(id:data.spider_medial_id)
      Info.find_or_create_by(medial_spider_id:data.spider_medial_id,category_id:medial_spider.category_id,"url": data.url, "title": data.title, "release_at": data.release_at, "mark": data.mark, "image_url": data.image_url)
    end
  end

end