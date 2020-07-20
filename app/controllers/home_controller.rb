class HomeController < ActionController::Base

  def index
    if params[:category_id] && params[:category_id].to_i != 1
      # 分类资讯
      # page
      category_id = params[:category_id]
      video_top_ids = Video.get_top(1)
      @video_tops = Video.where(id:video_top_ids)
      merge_videos = Video.category_list(category_id) - video_top_ids
      @videos = Video.where(id:merge_videos).sample(5)

      info_top_ids = Info.get_top(10)
      @info_tops = Info.where(id:info_top_ids)
      merge_infos = Info.category_list(category_id) - info_top_ids
      @infos = Info.where(id:merge_infos).sample(5)
    elsif params[:user_id].present? && $redis.smembers("users_#{params[:user_id]}").present? 
      # 用户喜好资讯
      data = UserTag.flow_medias(params[:user_id])
      # 视频数据
      video_top_ids = Video.get_top(params[:user_id])
      merge_videos = data[:videos] - video_top_ids
      @videos = Video.where(id:merge_videos).sample(5)
      @video_tops = Video.where(id:video_top_ids)
      # 资讯
      info_top_ids = Info.get_top(params[:user_id])
      merge_infos = data[:infos] - info_top_ids
      @infos = Info.where(id:merge_infos).sample(5)
      @info_tops = Info.where(id:info_top_ids)
    else
      # 当天最新资讯
      video_top_ids = Video.get_top(1)
      @video_tops = Video.where(id:video_top_ids)
      merge_videos = Video.today_list - video_top_ids
      @videos = Video.where(id:merge_videos).sample(5)

      info_top_ids = Info.get_top(10)
      @info_tops = Info.where(id:info_top_ids)
      merge_infos = Info.today_list - info_top_ids
      @infos = Info.where(id:merge_infos).sample(5)
    end

    flow_medias = {}
    flow_medias[:tops] = []
    flow_medias[:videos] = []
    flow_medias[:infos] = []
    # 推荐置顶
    @video_tops.each do |_|
      flow_medias[:tops] << {medial_typel: "video", medial_id:_.id, title:_.title,url:_.url,local_image_url:_.local_image_url,tags_str:_.tag_ids, web_target:_.medial_spider&.spider_target&.name, web_target_logo: _.medial_spider&.spider_target&.logo_url,overlay_time: _.overlay_time, play_count:_.play_count }
    end
    @info_tops.each do |_|
      flow_medias[:tops] << {medial_typel: "info", medial_id:_.id, title:_.title,url:_.url,local_image_url:_.local_image_url,tags_str:_.tag_ids, web_target:_.medial_spider&.spider_target&.name, web_target_logo: _.medial_spider&.spider_target&.logo_url }
    end
    # 视频
    @videos.each do |_|
      flow_medias[:videos] << {medial_typel: "video", medial_id:_.id, title:_.title,url:_.url,local_image_url:_.local_image_url,tags_str:_.tag_ids, web_target:_.medial_spider&.spider_target&.name, web_target_logo: _.medial_spider&.spider_target&.logo_url,overlay_time: _.overlay_time, play_count:_.play_count }
    end
    # 资讯
    @infos.each do |_|
      flow_medias[:infos] << {medial_typel: "info", medial_id:_.id, title:_.title,url:_.url,local_image_url:_.local_image_url,tags_str:_.tag_ids, web_target:_.medial_spider&.spider_target&.name, web_target_logo: _.medial_spider&.spider_target&.logo_url }
    end
    render json: flow_medias  and return
  end

  # 点击日志处理
  # 放到后台去定时分析Monggodb:click_logs
  def visit_log
    user_id = params[:session_id]
    user_id = params[:user_id]
    user_id = params[:device_uuid]
    medial_typel = params[:medial_typel]
    medial_id = params[:medial_id]
    tag_ids = params[:tag_ids]
    UserTag.user_view_info(user_id,medial_typel,medial_id,tag_ids)
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
