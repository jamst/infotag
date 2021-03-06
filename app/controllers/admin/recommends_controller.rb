class Admin::RecommendsController < Admin::BaseController

  before_action :set_recommend, only: [:destroy,:edit,:show,:update,:update_status]
  skip_before_action :verify_authenticity_token

  def index
    @q = SearchParams.new(params[:search_params] || {})
    @recommends = Recommend.default_where(@q.attributes(self)).page(params[:page]).per(10)
  end

  def new
    @recommend =  Recommend.new
    render :layout => false
  end

  def edit
    render :layout => false
  end

  def show
    render :layout => false
  end


  def update
    Rails.logger.tagged("推荐更新update") { Rails.logger.info("#{current_employee.name}:更改了Recommend：#{@recommend.id}") }
    @recommend.update_attributes(permitted_resource_params)
  end

  def create
    @recommend = Recommend.new
    @recommend.attributes = permitted_resource_params
    @recommend.employee_id = current_employee.id
    if @recommend.save
      Rails.logger.tagged("推荐创建create") { Rails.logger.info("#{current_employee.name}:创建了Recommend：#{@recommend.id}") }
      respond_with(@recommend) do |format|
        format.html { redirect_to location_after_save }
        format.js   { render :layout => false }
      end
    else
      respond_with(@recommend) do |format|
        format.html do
          flash.now[:error] = @recommend.errors.full_messages.join(", ")
          render action: 'new'
        end
        format.js { render layout: false }
      end
    end
  end

  def destroy
    Rails.logger.tagged("推荐删除destroy") { Rails.logger.info("#{current_employee.name}:更改了Recommend：#{@recommend.id}") }
    @recommend.srem_recommend_list
    @recommend.is_delete = Time.now.to_i
    if @recommend.save
      respond_to do |format|
        format.js
      end
    else
      respond_with(@recommend) do |format|
        format.html { redirect_to location_after_destroy }
      end
    end
  end


  # 更新状态
  def update_status
    Rails.logger.tagged("推荐更新状态update_status") { Rails.logger.info("#{current_employee.name}:更改了Recommend：#{@recommend.id}") }
    @recommend.update(status:params[:status])
  end


  private

  def set_recommend
    @recommend = Recommend.find(params[:id])
  end

  def permitted_resource_params
    params.require(:recommend).permit!
  end


end
