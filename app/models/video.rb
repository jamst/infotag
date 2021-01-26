class Video < ApplicationRecord
  has_and_belongs_to_many :tags, through: :tags_videos
  belongs_to :category
  belongs_to :medial_spider
  belongs_to :spider_target
  # 用户标签来源明细记录
  has_many :user_tag_details, as: :from_entity

  has_one :file_attachment, as: :attachment_entity
  belongs_to :classification

  enum status: { disabled: -1, enabled: 0 }
  enum weight: { nomal: 0, top: 1, force: 2 }
  enum medial_type: { info: 0, video: 1 }
  enum approve_status: { unapproved: -1, wapprove: 0, approved: 1 }
  enum encoding_type: { en_cod: 0, cnjt_cod: 1, cnft_cod: 2 }

  enum is_location_source: { un_location_source: 0, location_source: 1 }
  enum ads: { un_ads: 0, is_ads: 1 }

  default_scope -> {where(is_delete: 0)}

  after_save :image_save, if: -> { self.saved_change_to_image_url? }
  after_save :change_cache_list, if: -> { self.saved_change_to_approve_status? }
  after_update :top_update, if: -> { self.saved_change_to_weight? }
  after_update :location_update, if: -> { self.saved_change_to_location_source_url? }

  LOCATION_SOURCE_DOMAIN = "https://sz6.je2ci9.com" #"https://sz6.dayomall.com:51100"

  include FileHandle

  EXPORT_COLUMN = {
    'id': 0,
    'url': 1 
  }

  # 移动端地址
  def mobile_url
    gurl = self.url.gsub("//www","//m")
    gurl
  end

  # 审核状态下，更新缓存内容。
  def change_cache_list
    if approve_status == "approved"
      tag_list
    else
      srem_tag_list
    end
  end
  
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
    # 加入栏目缓存
    $redis.sadd("category_#{category_id}_videos", self.id)
    # 加入分类缓存
    $redis.sadd("classification_#{classification_id}_videos", self.id)
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
    # 移除栏目缓存
    $redis.srem("category_#{category_id}_videos", self.id)
    # 移除分类缓存
    $redis.srem("classification_#{classification_id}_videos", self.id)
    # 移除本地资源缓存
    $redis.srem("videos_location", self.id)
    # 移除top推荐
    $redis.srem("videos_top", self.id)
    # 移除强制推荐
    $redis.srem("videos_force", self.id)

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

  
  # 栏目获取
  def self.category_list(category_id)
    $redis.srandmember("category_#{category_id}_videos",20)
  end

  # 分类获取
  def self.classification_list(category_id)
    video_ids = []
    category = Category.find_by(id:category_id)

    cache_condition = category.get_cache_condition

    redis_cache_conditions = eval(cache_condition)

    if redis_cache_conditions[:cache].present?
      redis_cache_conditions[:cache].each do |category_condition|
        # 标签占比
        video_ids += $redis.srandmember("classification_#{category_condition[:classification_id]}_videos",(20.0*category_condition[:weight]/100).to_i)
        # 关键词占比
        if category_condition[:tags_str].present?
          tag_list = category_condition[:tags_str].split(",")
          tag_size = tag_list.size
          tag_list.each do |tag_id|
            video_ids += $redis.srandmember("tags_#{tag_id}_videos",(20.0*category_condition[:weight]/100/tag_size).to_i)
          end
        end
      end
    else
      video_ids = $redis.srandmember("category_#{category_id}_videos",20)
    end
    # 语言占比过滤
    video_ids.uniq.sample(20)
  end


  def self.classification_list_mysql(category_id)
    video_ids = []
    category = Category.find_by(id:category_id)
    category_conditions = category&.category_conditions
    if category_conditions.present?
      category_conditions.each do |category_condition|
        # 标签占比
        video_ids += $redis.srandmember("classification_#{category_condition.classification_id}_videos",(20.0*category_condition.weight/100).to_i)
        # 关键词占比
        if category_condition.tags_str.present?
          tag_list = category_condition.tags_str.split(",")
          tag_size = tag_list.size
          tag_list.each do |tag|
            tag = Tag.find_by(name:tag)
            if tag.present?
              tag_id = tag.id
              video_ids += $redis.srandmember("tags_#{tag_id}_videos",(20.0*category_condition.weight/100/tag_size).to_i)
            end
          end
        end
      end
    else
      video_ids = $redis.srandmember("category_#{category_id}_videos",20)
    end
    # 语言占比过滤
    video_ids.uniq.sample(20)
  end
  

  # 访问次数
  def incr_size
    $redis.get("video_incr_#{self.id}").to_i
  end

  # 缓存图片到本地
  def image_save
    image_url = self.image_url
    
    begin
      image_url_read = open(image_url) {|f| f.read}
    rescue Exception => e
      image_url = image_url.gsub("hq720.jpg","0.jpg")
      image_url_read = open(image_url) {|f| f.read}
    end

    file_name = image_url.split("?").first.to_s.split("/").last
    file_name = "#{get_random}_#{file_name}"
    image_path = "#{Rails.root}/public/medial_images/videos/#{self.id}_#{file_name}"
    # 下载图片

    file = File.open(image_path, 'wb'){|f| f.write(image_url_read)}

    # 压缩图片
    #compress_path =  ImageService.compress(image_path)
    # 上传到文件服务器
    #file = File.open(compress_path)
    file = File.open(image_path)
    result = FileAttachment.add_file_to_mongo(file,file_name)
    self.update(local_image_url:result.get_file_path,image_url:image_url)
    result.update(attachment_entity_type: "Video", attachment_entity_id: self.id)
    FileUtils.rm_rf image_path if image_path
    #FileUtils.rm_rf compress_path if compress_path
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

  # 设置学校置顶列表
  def self.set_school_location
    # 标签下视频记录
    videos = Video.where(category_id: 7).where("location_source_url is not null and location_source_url != '' ")
    videos.each do |video|
      $redis.sadd("school_videos_location",video.id)
    end
  end


  # 获取学校置顶列表
  def self.get_school_location(user_id)
    # 标签下视频记录
    videos = $redis.smembers("school_videos_location")
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


  # 获取置顶列表
  def self.get_force(user_id)
    # 标签下视频记录
    videos = $redis.smembers("videos_force")
    # 用户访问视频记录
    user_videos = $redis.smembers("user_#{user_id}_videos")
    # 用户没有访问过的视频
    flow_videos = videos - user_videos
    flow_videos.sample(2)
  end


  # 添加本地缓存地址
  def self.add_location_source_url(ids)
    Video.where(id:ids).each do |video|
      video.update(location_source_url:"#{Video::LOCATION_SOURCE_DOMAIN}/videos/#{video.id}.mp4")
    end
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
      video = Video.find_by("url": "https://www.youtube.com/watch?v=#{data.url}")
      unless video.present?
        # 第一次入库
        @exists = 1
        video = Video.find_or_create_by(medial_spider_id:data.spider_medial_id,spider_target_id:medial_spider.spider_target_id ,category_id:medial_spider.category_id,"url": "https://www.youtube.com/watch?v=#{data.url}", "title": data.title, "release_at": data.release_at, "overlay_time": data.overlay_time, "author": data.author)
      end
      # 这类数据可能会变更所以单独更新，避免重新创建
      video.play_count = data.play_count
      video.encoding_type = data.encoding_type
      video.category_list = data.category_list
      video.classification_id = medial_spider.classification_id
      video.image_url = data.image_url

      if !video.tags_str.present?
        if data.tags_str.present?
          video.tags_str = data.tags_str
          # 爬虫同步过来的标签叠加指定的标签
          video.tags_str += ",#{medial_spider.tags_str}" if medial_spider.tags_str.present?
        else
          # 频道设置的默认标签
          video.tags_str = medial_spider.tags_str
        end
      end

      if medial_spider.unneed? && @exists == 1
        # 第一次入库，且不需要审核:回调：change_cache_list加入到相关的缓存列表中
        video.approve_status = "approved"
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
    # Video.where("created_at < ?",(Time.now-90.day).at_beginning_of_day).where("location_source_url is null and is_location_source = 0 ").each do |video|
    #   video.srem_tag_list
    #   video.update(is_delete: Time.now.to_i)
    # end
  end

end