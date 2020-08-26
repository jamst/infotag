class UserTag < ApplicationRecord
  belongs_to :user
  belongs_to :tag

  # 每个人应该有一个默认咨讯分类？

  # 用户标签存储(用户访问记录回调)
  def self.user_tag_cache(user_id,tag_ids)
    if tag_ids.present?
      # 用户列表
      $redis.sadd("users_lists", user_id)
      # tags 可以是单个标签，也可以是数组
      users_cache_key = "users_#{user_id}"
      # 用户包含的标签
      $redis.sadd(users_cache_key, tag_ids)
      if tag_ids.is_a? Array
        tag_ids.each do |tag_id|
          # 用户某个标签权重排序
          $redis.sadd("user_#{user_id}_tag_list","user_#{user_id}_tag_#{tag_id}_count")
          # 用户标签命中次数
          incr_count = $redis.incr("user_#{user_id}_tag_#{tag_id}")
          $redis.hset("user_#{user_id}_tag_#{tag_id}_count", "incr_count" , incr_count)
          # 标签命中次数
          $redis.incr("tag_incr_#{tag_id}")
        end
      else
        tag_ids.split(",").each do |tag_id|
          # 用户某个标签权重排序
          $redis.sadd("user_#{user_id}_tag_list","user_#{user_id}_tag_#{tag_id}_count")
          # 用户标签命中次数
          incr_count = $redis.incr("user_#{user_id}_tag_#{tag_id}")
          $redis.hset("user_#{user_id}_tag_#{tag_id}_count", "incr_count" , incr_count)
          # 标签命中次数
          $redis.incr("tag_incr_#{tag_id}")
        end
      end

      # tag命中取前五存储到top_user_tag_list中
      sort_user_tag_list = $redis.sort("user_#{user_id}_tag_list", :by => "desc incr_count", :limit => [0, 6])
      $redis.sadd("top_user_#{user_id}_tag_list",sort_user_tag_list) if sort_user_tag_list.present?

    end
  end


  # 用户访问过的咨询记录（访问过的内容，就不需要再推荐了）
  def self.user_view_info(user_id,medial_type,medial_id,tag_ids)
    # medial_type = info/video
    # todo 优化，用户可能会访问很多资讯，加上过期切分时间，避免内存占用。
    $redis.sadd("user_#{user_id}_#{medial_type}",medial_id)
    user_tag_cache(user_id,tag_ids)
  end


  # 用户访问过的咨询记录（访问过的内容，就不需要再推荐了）
  def self.today_user_view_info(init_time=Time.now.yesterday.at_beginning_of_day)
    # medial_type = info/video
    # todo 优化，用户可能会访问很多资讯，加上过期切分时间持久化，避免内存占用。
    ::ClickLog.where(created_at: {"$gte": init_time}).each do |log|
      user_id = log.user_id
      medial_type = log.medial_type
      medial_id = log.medial_id
      tag_ids = log.tag_ids.split(",")

      # 资讯访问统计
      $redis.incr("#{medial_type}_incr_#{medial_id}")
      if user_id.present?
        # 用户资讯访问统计
        $redis.sadd("user_#{user_id}_#{medial_type}",medial_id)
        # 用户标签触发计数
        user_tag_cache(user_id,tag_ids)
      end
    end

  end


  # 流媒体
  def self.flow_medias(user_id)

    users_cache_key = "users_#{user_id}"
    
    top_tag_ids = $redis.smembers("top_user_#{user_id}_tag_list")

    # 获取当前用户标签的权重，选用排序前6个标签做为推荐参考
    if top_tag_ids.present? 
      tag_ids = top_tag_ids.collect{|tag| tag.split("_")[-2]}
    else
      # 获取用户当前标签取随机的5个标签做推荐参考
      tag_ids = $redis.smembers(users_cache_key)
      tag_ids = tag_ids.present? ? tag_ids.sample(6) : Tag.ids.sample(6)
    end

    result = {}
    infos = []
    videos = []

    tag_ids.each do |tag_id|
      # 标签下资讯记录(获取key集合的num个随机元素)
      info_lists = $redis.srandmember("tags_#{tag_id}_infos",10)
      infos += info_lists
      # 标签下视频记录
      video_lists = $redis.srandmember("tags_#{tag_id}_videos",10)
      videos += video_lists
    end

    # 用户访问资讯记录
    user_infos = $redis.smembers("user_#{user_id}_infos")
    # 用户没有访问过的咨询
    flow_infos = infos.uniq - user_infos
    
    # 用户访问视频记录
    user_videos = $redis.smembers("user_#{user_id}_videos")
    # 用户没有访问过的视频
    flow_videos = videos.uniq - user_videos
    # 权重,用户标签的权重，文章的权重，已浏览记录
    result[:infos] = flow_infos.sample(10)
    result[:videos] = flow_videos.sample(10)
    return result
  end

end
