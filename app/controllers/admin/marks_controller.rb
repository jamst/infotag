class Admin::MarksController < Admin::BaseController

  before_action :set_mark, only: [:destroy,:edit,:show,:update,:update_status]
  skip_before_action :verify_authenticity_token

  def index
    @q = SearchParams.new(params[:search_params] || {})
    @marks = Mark.default_where(@q.attributes(self)).page(params[:page]).per(10)
  end

  def new
    @mark =  Mark.new
    render :layout => false
  end

  def edit
    render :layout => false
  end

  def show
    render :layout => false
  end


  def update
    @mark.update_attributes(permitted_resource_params)
    if params[:file].present?
      result = FileAttachment.web_file_to_mongo(params[:file])
      @mark.update(url:result.get_file_path)
    end
  end

  def create
    @mark = Mark.new
    @mark.attributes = permitted_resource_params
    if @mark.save
      if params[:file].present?
        result = FileAttachment.web_file_to_mongo(params[:file])
        @mark.update(url:result.get_file_path)
      end
      respond_with(@mark) do |format|
        format.html { redirect_to location_after_save }
        format.js   { render :layout => false }
      end
    else
      respond_with(@mark) do |format|
        format.html do
          flash.now[:error] = @mark.errors.full_messages.join(", ")
          render action: 'new'
        end
        format.js { render layout: false }
      end
    end
  end

  def destroy
    @mark.srem_mark_list
    @mark.is_delete = Time.now.to_i
    if @mark.save
      respond_to do |format|
        format.js
      end
    else
      respond_with(@mark) do |format|
        format.html { redirect_to location_after_destroy }
      end
    end
  end

  # 更新状态
  def update_status
     @mark.update(status:params[:status])
  end

  private

  def set_mark
    @mark = Mark.find(params[:id])
  end

  def permitted_resource_params
    params.require(:mark).permit!
  end


end
