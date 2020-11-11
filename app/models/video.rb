class Video < ApplicationRecord
  has_and_belongs_to_many :tags, through: :tags_videos
  belongs_to :category
  belongs_to :medial_spider
  belongs_to :spider_target
  # 用户标签来源明细记录
  has_many :user_tag_details, as: :from_entity

  has_one :file_attachment, as: :attachment_entity

  enum status: { disabled: -1, enabled: 0 }
  enum weight: { nomal: 0, top: 1, force: 2 }
  enum medial_type: { info: 0, video: 1 }
  enum approve_status: { unapproved: -1, wapprove: 0, approved: 1 }

  enum is_location_source: { un_location_source: 0, location_source: 1 }
  enum ads: { un_ads: 0, is_ads: 1 }

  default_scope -> {where(is_delete: 0)}

  after_create :image_save
  after_save :tag_list, if: -> { self.saved_change_to_tags_str? }
  after_update :top_update, if: -> { self.saved_change_to_weight? }
  after_update :location_update, if: -> { self.saved_change_to_location_source_url? }

  # 标签下有哪些视频
  # 视频资讯上的字段作为文本存储
  def tag_list
    video_id = self.id
    tags_strs = tags_str.present? ? tags_str : (medial_spider.present? && medial_spider.tags_str.present? ? medial_spider.tags_str : "default")
    tags_strs.to_s.split(",").each do |tag_name|
      tag = Tag.find_or_create_by(name:tag_name)
      tag_id = tag.id
      # 数据库持久化
      TagsVideo.find_or_create_by(tag_id: tag_id , video_id:video_id)
      # 缓存
      $redis.sadd("tags_#{tag_id}_videos", video_id)
    end
    # 加入分类缓存
    $redis.sadd("category_#{category_id}_videos", self.id)
    force_list if weight == "force"
    cancer_top_list if weight == "top"
  end

  # 移除info的标签下有哪些咨讯
  def srem_tag_list
    video_id = self.id
    tags_strs = tags_str.present? ? tags_str : (medial_spider.present? && medial_spider.tags_str.present? ? medial_spider.tags_str : "default")
    tags_strs.to_s.split(",").each do |tag_name|
      tag = Tag.find_by(name:tag_name)
      if tag.present?
        tag_id = tag&.id
        # 数据库持久化
        TagsVideo.where(tag_id: tag_id , video_id:video_id).delete_all
        # 缓存
        $redis.srem("tags_#{tag_id}_videos", video_id)
      end
    end
    # 加入分类缓存
    $redis.srem("category_#{category_id}_videos", self.id)
    cancer_top_list
    cancer_force_list
  end

  # 每天/每3个小时推荐的咨询包
  def self.add_today_list
    videos_today = $redis.smembers("videos_today")
    $redis.srem("videos_today", videos_today) if videos_today.present?

    videos_current = $redis.smembers("videos_current")
    $redis.srem("videos_current", videos_current) if videos_current.present?

    Video.nomal.approved.order(:play_count,created_at: :desc).limit(200).each_with_index do |video,index|
      if index < 50
        $redis.sadd("videos_current", video.id)
        $redis.sadd("videos_today", video.id)
      else
        $redis.sadd("videos_today", video.id)
      end
    end
  end
  def self.today_list
    $redis.srandmember("videos_today",15)
  end
  def self.current_list
    $redis.srandmember("videos_current",10)
  end

  
  # 分类获取
  def self.category_list(category_id)
    $redis.srandmember("category_#{category_id}_videos",20)
  end

  # 访问次数
  def incr_size
    $redis.get("video_incr_#{self.id}").to_i
  end

  # 缓存图片到本地
  def image_save
    image_url = self.image_url
    file_name = image_url.split("?").first.to_s.split("/").last
    file_name = "#{get_random}_#{file_name}"
    image_path = "#{Rails.root}/public/medial_images/videos/#{self.id}_#{file_name}"
    # 下载图片
    file = File.open(image_path, 'wb'){|f| f.write(open(image_url) {|f| f.read})}
    # 压缩图片
    compress_path =  ImageService.compress(image_path)
    # 上传到文件服务器
    file = File.open(compress_path)
    result = FileAttachment.add_file_to_mongo(file,file_name)
    self.update(local_image_url:result.get_file_path)
    result.update(attachment_entity_type: "Video", attachment_entity_id: self.id)
    FileUtils.rm_rf image_path if image_path
    FileUtils.rm_rf compress_path if compress_path
  end


  def get_random(len=10,chars=[])
    chars = ("0".."9").to_a if chars.blank?
    result = []
    len.times { |i| result << chars[rand(chars.size-1)] }
    result.join('')
  end

  #本地资源缓存
  def location_update
    if location_source_url.present?
      $redis.sadd("videos_location", self.id)
    else
      $redis.srem("videos_location", self.id)
    end
  end


  # 获取置顶列表
  def self.get_location(user_id)
    # $redis.srandmember("videos_location",3)

    # 标签下视频记录
    videos = $redis.smembers("videos_location")
    # 用户访问视频记录
    user_videos = $redis.smembers("user_#{user_id}_videos")
    # 用户没有访问过的视频
    flow_videos = videos - user_videos
    flow_videos.sample(5)
  end


  # 置顶缓存处理
  def top_update
    if weight == "top"
      top_list
      cancer_force_list
    elsif weight == "force"
      force_list
      cancer_top_list
    else
      cancer_top_list
      cancer_force_list
    end
  end
  # 视频置顶列表
  def top_list
    $redis.sadd("videos_top", self.id)
  end
  # 视频强推列表
  def force_list
    $redis.sadd("videos_force", self.id)
  end
  # todo定时移除top
  def cancer_top_list
    $redis.srem("videos_top", self.id)
  end
  # todo定时移除force
  def cancer_force_list
    $redis.srem("videos_force", self.id)
  end

 
  # 获取置顶列表
  def self.get_top(user_id)
    # 标签下视频记录
    videos = $redis.smembers("videos_top")
    # 用户访问视频记录
    user_videos = $redis.smembers("user_#{user_id}_videos")
    # 用户没有访问过的视频
    flow_videos = videos - user_videos
    flow_videos.sample(2)
  end


  # 文本导入数据
  def self.import_file
    File.open("#{Rails.root}/public/doc/youtube_item.txt", "r") do |file|
        file.each_line do |line|
            data = eval(line) 
            Video.find_or_create_by(medial_spider_id:data[:id],"url": "https://www.youtube.com/watch?v=#{data[:url_id]}", "title": data[:title], "play_count": data[:play_count], "release_at": data[:release_at], "overlay_time": data[:overlay_time], "author": data[:author], "image_url": data[:image_url])
        end
    end
  end

  # 导入数据
  def self.import_db
    SpiderOriginVideo.where("created_at >= ? ",Time.now.at_beginning_of_day).each do |data|
      medial_spider = MedialSpider.find_by(id:data.spider_medial_id)
      video = Video.find_or_create_by(medial_spider_id:data.spider_medial_id,spider_target_id:medial_spider.spider_target_id ,category_id:medial_spider.category_id,"url": "https://www.youtube.com/watch?v=#{data.url}", "title": data.title, "release_at": data.release_at, "overlay_time": data.overlay_time, "author": data.author, "image_url": data.image_url, "category_list": data.category_list )
      video.play_count = data.play_count
      if medial_spider.unneed? && !video.tags_str.present?
        if data.tags_str.present?
          video.approve_status = "approved"
          video.tags_str = data.tags_str
        else
          video.approve_status = "approved"
          video.tags_str = medial_spider.tags_str
        end
      end
      video.save
    end
    # 情况爬虫数据
    conn = ActiveRecord::Base.connection
    conn.execute("truncate table spider_origin_videos")
    conn.close
    # 推荐最新资讯
    Video.add_today_list
    # 删除3个月前的数据推荐
    # Video.where("created_at < ?",(Time.now-3.month).at_beginning_of_day).each do |video|
    #   video.srem_tag_list
    #   video.update(is_delete: Time.now.to_i)
    # end
  end

end