class HomeController < ActionController::Base

  around_action :benchmark_filter
 
  # 方法执行时间测速
  def benchmark_filter
   start_time1 = Time.now.to_datetime.strftime('%Q').to_i
   yield # 这里让出来执行Action动作
   start_time_bt = (Time.now.to_datetime.strftime('%Q').to_i - start_time1)
   Rails.logger.tagged("资讯流接口请求取值耗时") { Rails.logger.info("#{controller_name}-#{action_name}:#{start_time_bt}ms") }
   Rails.logger.tagged("资讯流接口请求取值耗时超时") { Rails.logger.info("#{controller_name}-#{action_name}:#{start_time_bt}ms") } if start_time_bt > 1000
  end

  def index
    page = params[:page].to_i
    @info_forces = []
    if params[:category_id] #&& params[:category_id].to_i != 1
      # 分类资讯
      category_id = params[:category_id]

      merge_videos = Video.category_list(category_id)
      @videos = Video.where(id:merge_videos)

      @info_tops = []
      merge_infos = Info.category_list(category_id)
      @infos = Info.where(id:merge_infos)

      @video_tops = []

      if page == 1 && params[:category_id].to_i == 1
        info_force_ids = Info.get_force(1)
        @info_forces = Info.where(id:info_force_ids)

        video_top_ids = Video.get_location(params[:user_id])
        @video_tops = Video.where(id:video_top_ids)
      end

    elsif params[:user_id].present? 
      # 用户喜好资讯
      data = UserTag.flow_medias(params[:user_id])

      video_top_ids = Video.get_top(params[:user_id])
      @video_tops = Video.where(id:video_top_ids)

      info_top_ids = Info.get_top(params[:user_id])
      @info_tops = Info.where(id:info_top_ids)
      
      if page > 1
        # 下拉加载页码（用户偏好:实效性=5:15）
        today_infos = Info.today_list
        merge_infos = (data[:infos].sample(5) + today_infos.sample(15) - info_top_ids).uniq.sample(10)

        today_videos = Video.today_list
        merge_videos = (data[:videos].sample(5) + today_videos.sample(15) - video_top_ids).uniq.sample(10)
      else
        # 首页只推荐最新+强推1条（首页下滑刷新，确保最新50条中随机选5条；一方面确保时间新，一方面减少刷新重复数）
        info_force_ids = Info.get_force(params[:user_id])
        @info_forces = Info.where(id:info_force_ids)
        merge_infos = Info.current_list
        merge_videos = Video.current_list
      end
      
      @videos = Video.where(id:merge_videos)
      @infos = Info.where(id:merge_infos)
    else
      # 用户不登陆当天最新资讯
      video_top_ids = Video.get_top(1)
      @video_tops = Video.where(id:video_top_ids)

      info_top_ids = Info.get_top(1)
      @info_tops = Info.where(id:info_top_ids)
      
      if page > 1
        # 下拉加载页码，在前200条中随机10条
        merge_infos = Info.today_list.sample(10)
        merge_videos = Video.today_list.sample(10)
      else
        # 首页只推荐最新+强推1条（首页下滑刷新，确保最新50条中随机选5条；一方面确保时间新，一方面减少刷新重复数）
        info_force_ids = Info.get_force(1)
        @info_forces = Info.where(id:info_force_ids)
        merge_infos = Info.current_list
        merge_videos = Video.current_list
      end
      
      @videos = Video.where(id:merge_videos)
      @infos = Info.where(id:merge_infos)
    end

    flow_medias = {}
    flow_medias[:tops] = []
    flow_medias[:videos] = []
    flow_medias[:infos] = []
    # 推荐置顶
    @video_tops.each do |_|
      flow_medias[:tops] << {is_location_source: _.is_location_source, location_source_url: _.location_source_url ,author:_.author,medial_type: "video", medial_id:_.id, title:_.title,url:_.url,local_image_url:_.local_image_url,tag_ids:_.tag_ids.join(","), web_target:_.spider_target&.name, web_target_logo: _.spider_target&.logo_url,overlay_time: _.overlay_time, play_count:_.play_count }
    end
    @info_tops.each do |_|
      flow_medias[:tops] << {medial_type: "info", medial_id:_.id, title:_.title,url:_.url,local_image_url:_.local_image_url,tag_ids:_.tag_ids.join(","), web_target:_.spider_target&.name, web_target_logo: _.spider_target&.logo_url }
    end
    # 强推信息
    @info_forces.each do |_|
      flow_medias[:infos] << {medial_type: "info", medial_id:_.id, title:_.title,url:_.url,local_image_url:_.local_image_url,tag_ids:_.tag_ids.join(","), web_target:_.spider_target&.name, web_target_logo: _.spider_target&.logo_url }
    end
    # 视频
    @videos.each do |_|
      flow_medias[:videos] << {author:_.author,medial_type: "video", medial_id:_.id, title:_.title,url:_.url,local_image_url:_.local_image_url,tag_ids:_.tag_ids.join(","), web_target:_.spider_target&.name, web_target_logo: _.spider_target&.logo_url,overlay_time: _.overlay_time, play_count:_.play_count }
    end
    # 资讯
    @infos.each do |_|
      flow_medias[:infos] << {medial_type: "info", medial_id:_.id, title:_.title,url:_.url,local_image_url:_.local_image_url,tag_ids:_.tag_ids.join(","), web_target:_.spider_target&.name, web_target_logo: _.spider_target&.logo_url }
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
    Video.is_ads.order(:ads_index).each do |_|
      flow_medias[:videos] << {is_location_source: _.is_location_source, location_source_url: _.location_source_url , author:_.author,medial_type: "video", medial_id:_.id, title:_.title,url:_.url,local_image_url:_.local_image_url,tag_ids:_.tag_ids.join(","), web_target:_.spider_target&.name, web_target_logo: _.spider_target&.logo_url,overlay_time: _.overlay_time, play_count:_.play_count }
    end
    render json: flow_medias  and return
  end

  # 点击日志处理
  # 放到后台去定时分析Monggodb:click_logs
  def visit_log
    user_id = params[:session_id]
    user_id = params[:user_id]
    user_id = params[:device_uuid]
    medial_type = params[:medial_type]
    medial_id = params[:medial_id]
    tag_ids = params[:tag_ids]
    UserTag.user_view_info(user_id,medial_type,medial_id,tag_ids)
    render json: flow_medias  and return
  end

  # 分类数据
  def category_list
    categories = []
    Category.all.order(:sort_live).each do |ca|
      categories << {name:ca.name,value:ca.id}
    end
    render json:{categories:categories}
  end

  # YouTube分享缓存读取
  def youtube_share
    key = "share_#{params[:uuid]}"
    data = $redis.get(key)
    data = {} if !data.present? || data["status"] != 1
    render json: data  and return
  end

  # 分享缓存
  def youtube_catch
    key = "share_#{params[:uuid]}"
    data = $redis.get(key)
    unless data.present?
      title = params[:title]
      image_base64 = params[:image_base64]
      link = params[:link]
      uuid = params[:uuid]
      # 是否有本地缓存
      local_id = params[:local_id]||0
      data = {"uuid": uuid ,"title": title,"link": link,"image_base64": image_base64, "local_model": "Video", "medial_source": "youtube", "local_id": local_id, "status":0 }.to_json 
      $redis.set(key,data)
      # 添加审核列表
      MedialCache.create("uuid": uuid ,"title": title,"link": link,"image_base64": image_base64, "local_model": "Video", "medial_source": "youtube", "local_id": local_id, "status":0)
    end
    render json: data  and return
  end

end
