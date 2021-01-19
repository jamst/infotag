class Admin::MedialSpidersController < Admin::BaseController

  before_action :set_medial_spider, only: [:destroy,:edit,:show,:update,:update_status]
  skip_before_action :verify_authenticity_token

  def index
    @q = SearchParams.new(params[:search_params] || {})
    @medial_spiders = MedialSpider.default_where(@q.attributes(self)).page(params[:page]).per(10)
  end

  def new
    @medial_spider =  MedialSpider.new
    render :layout => false
  end

  def edit
    render :layout => false
  end

  def show
    render :layout => false
  end


  # 导入爬取设置
  def import_medial_spider
    
  end

  def create_import_medial_spider
    results = MedialSpider.import_data(params[:file])
    @import,@message = results[0],results[1]
    render "import_medial_spider"
  end

  def export_medial_spider
    xls_report = MedialSpider.export_data
    send_data xls_report, :type => 'text/xls', :filename => "#{MedialSpider.table_name}_#{Time.now.to_s(:db)}.xls"
  end


  def update
    @medial_spider.update_attributes(permitted_resource_params)
  end

  def create
    @medial_spider = MedialSpider.new
    @medial_spider.attributes = permitted_resource_params
    if @medial_spider.save
      respond_with(@medial_spider) do |format|
        format.html { redirect_to location_after_save }
        format.js   { render :layout => false }
      end
    else
      respond_with(@medial_spider) do |format|
        format.html do
          flash.now[:error] = @medial_spider.errors.full_messages.join(", ")
          render action: 'new'
        end
        format.js { render layout: false }
      end
    end
  end

  def destroy
    @medial_spider.is_delete = Time.now.to_i
    if @medial_spider.save
      respond_to do |format|
        format.js
      end
    else
      respond_with(@medial_spider) do |format|
        format.html { redirect_to location_after_destroy }
      end
    end
  end

  # 更新状态
  def update_status
     @medial_spider.update(status:params[:status])
  end


  private

  def set_medial_spider
    @medial_spider = MedialSpider.find(params[:id])
  end

  def permitted_resource_params
    params.require(:medial_spider).permit!
  end



end
