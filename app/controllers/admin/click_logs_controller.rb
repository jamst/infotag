class Admin::ClickLogsController < Admin::BaseController

  def index
    @q = SearchParams.new(params[:search_params] || {})

    params_arr = @q.attributes(self)

    if params_arr["start_at"].present?
      @click_logs = ::ClickLog.where(created_at: {"$gte": params_arr["start_at"]}) 
      @click_logs = @click_logs.where(created_at: {"$lt": params_arr["end_at"].to_date.at_end_of_day}) if params_arr["end_at"].present?
    else
      @click_logs = ::ClickLog.where(created_at: {"$gte": Time.now.at_beginning_of_day })
    end
    
    @click_logs = @click_logs.where(user_id: params_arr["user_id"]) if params_arr["user_id"].present?
    @click_logs = @click_logs.where(device_uuid: params_arr["device_uuid"]) if params_arr["device_uuid"].present?
    @click_logs = @click_logs.where(medial_type: params_arr["medial_type"]) if params_arr["medial_type"].present?
    @click_logs = @click_logs.where(medial_id: params_arr["medial_id"]) if params_arr["medial_id"].present?

    @click_logs = @click_logs.where(vpn_key: params_arr["vpn_key"]) if params_arr["vpn_key"].present?
    @click_logs = @click_logs.where(vpn_version: params_arr["vpn_version"]) if params_arr["vpn_version"].present?
    @click_logs = @click_logs.where(vpn_channel: params_arr["vpn_channel"]) if params_arr["vpn_channel"].present?

    @click_logs = @click_logs.where(tag_ids: /#{params_arr["tag_ids"]}/) if params_arr["tag_ids"].present?

    @click_logs = @click_logs.order_by(created_at: :desc)

    @click_logs = Kaminari.paginate_array(@click_logs.to_ary, total_count: @click_logs.size).page(params["page"]).per(30)
  end

  def uptoday
    UserTag.today_user_view_info(Time.now.at_beginning_of_day)
  end

end