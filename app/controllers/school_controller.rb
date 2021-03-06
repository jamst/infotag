class SchoolController < ActionController::Base

  around_action :benchmark_filter
 
  # 方法执行时间测速
  def benchmark_filter
   start_time1 = Time.now.to_datetime.strftime('%Q').to_i
   yield # 这里让出来执行Action动作
   start_time_bt = (Time.now.to_datetime.strftime('%Q').to_i - start_time1)
   Rails.logger.tagged("高校资讯流接口请求取值耗时") { Rails.logger.info("#{controller_name}-#{action_name}:#{start_time_bt}ms") }
   Rails.logger.tagged("高校资讯流接口请求取值耗时超时") { Rails.logger.info("#{controller_name}-#{action_name}:#{start_time_bt}ms") } if start_time_bt > 1000
  end


  def index
    page = params[:page].to_i
    @info_forces = []
    @video_forces = []
    @video_tops = []
    @info_tops = []

    category_id = params[:category_id] || 7

    merge_videos = Video.classification_list(category_id)
    @videos = Video.where(id:merge_videos)

    merge_infos = Info.classification_list(category_id)
    @infos = Info.where(id:merge_infos)

    if page == 1 && params[:category_id].to_i == 7
      info_force_ids = Info.get_force(params[:user_id].to_i)
      @info_forces = Info.where(id:info_force_ids)

      video_force_ids = Video.get_force(params[:user_id].to_i)
      @video_forces = Video.where(id:video_force_ids)

      video_top_ids = Video.get_location(params[:user_id].to_i)
      @video_tops = Video.where(id:video_top_ids)
    end

    flow_medias = {}
    flow_medias[:tops] = []
    flow_medias[:videos] = []
    flow_medias[:infos] = []
    # 推荐置顶
    @video_tops.each do |_|
      flow_medias[:tops] << {is_location_source: _.is_location_source, location_source_url: _.location_source_url ,author:_.author,medial_type: "video", medial_id:_.id, title:_.title,url:_.url,mobile_url:_.mobile_url,local_image_url:_.local_image_url,tag_ids:_.tags_str, web_target:"Youtube", web_target_logo: "https://sz6.dayomall.com:54600/strategy/aclconf/0127741811_Youtube@2x.png",overlay_time: _.overlay_time, play_count:_.play_count }
    end
    @info_tops.each do |_|
      flow_medias[:tops] << {medial_type: "info", medial_id:_.id, title:_.title,url:_.url,mobile_url:_.mobile_url,local_image_url:_.local_image_url,tag_ids:_.tags_str, web_target:_.spider_target&.name, web_target_logo: _.spider_target&.logo_url,release_at: _.release_at }
    end
    # 强推信息
    @info_forces.each do |_|
      flow_medias[:infos] << {medial_type: "info", medial_id:_.id, title:_.title,url:_.url,mobile_url:_.mobile_url,local_image_url:_.local_image_url,tag_ids:_.tags_str, web_target:_.spider_target&.name, web_target_logo: _.spider_target&.logo_url,release_at: _.release_at }
    end
    @video_forces.each do |_|
      flow_medias[:videos] << {author:_.author,medial_type: "video", medial_id:_.id, title:_.title,url:_.url,mobile_url:_.mobile_url,local_image_url:_.local_image_url,tag_ids:_.tags_str, web_target:"Youtube", web_target_logo: "https://sz6.dayomall.com:54600/strategy/aclconf/0127741811_Youtube@2x.png",overlay_time: _.overlay_time, play_count:_.play_count }
    end
    # 视频
    @videos.each do |_|
      flow_medias[:videos] << {author:_.author,medial_type: "video", medial_id:_.id, title:_.title,url:_.url,mobile_url:_.mobile_url,local_image_url:_.local_image_url,tag_ids:_.tags_str, web_target:"Youtube", web_target_logo: "https://sz6.dayomall.com:54600/strategy/aclconf/0127741811_Youtube@2x.png",overlay_time: _.overlay_time, play_count:_.play_count }
    end
    # 资讯
    @infos.each do |_|
      flow_medias[:infos] << {medial_type: "info", medial_id:_.id, title:_.title,url:_.url,mobile_url:_.mobile_url,local_image_url:_.local_image_url,tag_ids:_.tags_str, web_target:_.spider_target&.name, web_target_logo: _.spider_target&.logo_url,release_at: _.release_at }
    end
    
    flow_medias[:infos] = flow_medias[:infos].sample(10)

    flow_medias[:medias] = (flow_medias[:videos] + flow_medias[:infos]).sample(100)

    render json: flow_medias  and return
  end
  
  def index_school
    page = params[:page].to_i
    @info_forces = []
    @video_tops = []
    @info_tops = []

    if params[:category_id] && params[:category_id].to_i == 7
      # 推荐分类资讯
      category_id = params[:category_id]

      merge_videos = Video.category_list(category_id)
      @videos = Video.where(id:merge_videos)

      merge_infos = Info.category_list(category_id)
      @infos = Info.where(id:merge_infos)

      if page == 1
        info_force_ids = Info.get_force(1)
        @info_forces = Info.where(id:info_force_ids)

        video_top_ids = Video.get_school_location(params[:user_id])
        @video_tops = Video.where(id:video_top_ids)
      end
    else
      # 用户不登陆当天最新资讯
      if page > 1
        # 下拉加载页码，在前200条中随机10条
        merge_infos = $redis.srandmember("infos_today",50)
        merge_videos = $redis.srandmember("videos_today",50)
      else
        merge_infos = $redis.smembers("videos_current")
        merge_videos = $redis.smembers("videos_current")
      end
      
      @videos = Video.where(id:merge_videos).where("category_id != 1 and category_id != 7").sample(10)
      @infos = Info.where(id:merge_infos).where("category_id != 1 and category_id != 7").sample(10)
    end

    flow_medias = {}
    flow_medias[:tops] = []
    flow_medias[:videos] = []
    flow_medias[:infos] = []
    # 推荐置顶
    @video_tops.each do |_|
      flow_medias[:tops] << {is_location_source: _.is_location_source, location_source_url: _.location_source_url ,author:_.author,medial_type: "video", medial_id:_.id, title:_.title,url:_.url,mobile_url:_.mobile_url,local_image_url:_.local_image_url,tag_ids:_.tags_str, web_target:_.spider_target&.name, web_target_logo: _.spider_target&.logo_url,overlay_time: _.overlay_time, play_count:_.play_count }
    end
    @info_tops.each do |_|
      flow_medias[:tops] << {medial_type: "info", medial_id:_.id, title:_.title,url:_.url,mobile_url:_.mobile_url,local_image_url:_.local_image_url,tag_ids:_.tags_str, web_target:_.spider_target&.name, web_target_logo: _.spider_target&.logo_url,release_at: _.release_at }
    end
    # 强推信息
    @info_forces.each do |_|
      flow_medias[:infos] << {medial_type: "info", medial_id:_.id, title:_.title,url:_.url,mobile_url:_.mobile_url,local_image_url:_.local_image_url,tag_ids:_.tags_str, web_target:_.spider_target&.name, web_target_logo: _.spider_target&.logo_url,release_at: _.release_at }
    end
    # 视频
    @videos.each do |_|
      flow_medias[:videos] << {author:_.author,medial_type: "video", medial_id:_.id, title:_.title,url:_.url,mobile_url:_.mobile_url,local_image_url:_.local_image_url,tag_ids:_.tags_str, web_target:_.spider_target&.name, web_target_logo: _.spider_target&.logo_url,overlay_time: _.overlay_time, play_count:_.play_count }
    end
    # 资讯
    @infos.each do |_|
      flow_medias[:infos] << {medial_type: "info", medial_id:_.id, title:_.title,url:_.url,mobile_url:_.mobile_url,local_image_url:_.local_image_url,tag_ids:_.tags_str, web_target:_.spider_target&.name, web_target_logo: _.spider_target&.logo_url,release_at: _.release_at }
    end
    
    flow_medias[:infos] = flow_medias[:infos].sample(10)

    flow_medias[:medias] = (flow_medias[:videos] + flow_medias[:infos]).sample(100)

    render json: flow_medias  and return
  end


  # 包含本地视频的资讯流
  def location_source
    
    # flow_medias[:videos] << {is_location_source: 是否有本地资源, location_source_url: 本地资源地址 , author:作者, medial_type: "video", medial_id:id, title:标题, url:线上播放地址, local_image_url: 首屏图片地址 ,tag_ids: 标签类型, web_target: 网址来源, web_target_logo: 来源网址logo图片地址 ,overlay_time: 播放时长, play_count: 播放量}
    flow_medias = {}
    flow_medias[:videos] = []
    Video.enabled.is_ads.order(:ads_index).each do |_|
      flow_medias[:videos] << {is_location_source: _.is_location_source, location_source_url: _.location_source_url , author:_.author,medial_type: "video", medial_id:_.id, title:_.title,url:_.url,mobile_url:_.mobile_url,local_image_url:_.local_image_url,tag_ids:_.tags_str, web_target:"Youtube", web_target_logo: "https://sz6.dayomall.com:54600/strategy/aclconf/0127741811_Youtube@2x.png",overlay_time: _.overlay_time, play_count:_.play_count }
    end
    render json: flow_medias  and return
  end


  # 分类数据
  def category_list
    categories = [{name:"推荐",value:7},{name:"热门",value:8}]
    render json:{categories:categories}
  end

end
