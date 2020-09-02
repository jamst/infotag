class HomeController < ActionController::Base

  def index
    page = params[:page].to_i
    @info_forces = []
    if params[:category_id] #&& params[:category_id].to_i != 1
      # 分类资讯
      category_id = params[:category_id]
      @video_tops = [] 
      merge_videos = Video.category_list(category_id)
      @videos = Video.where(id:merge_videos)

      @info_tops = []
      merge_infos = Info.category_list(category_id)
      @infos = Info.where(id:merge_infos)

      if page == 1 && params[:category_id].to_i == 1
        info_force_ids = Info.get_force(1)
        @info_forces = Info.where(id:info_force_ids)
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
      flow_medias[:tops] << {author:_.author,medial_type: "video", medial_id:_.id, title:_.title,url:_.url,local_image_url:_.local_image_url,tag_ids:_.tag_ids.join(","), web_target:_.spider_target&.name, web_target_logo: _.spider_target&.logo_url,overlay_time: _.overlay_time, play_count:_.play_count }
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

end
