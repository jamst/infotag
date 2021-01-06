# coding: utf-8
# 雇员管理
class Admin::EmployeesController < Admin::BaseController
  # before_action :authenticate_employee!, :except => [:forget_password, :reset_mail]
  # before_action :left_tab, :only => [:index]
  # before_action :set_employee, only: [:destroy]
  skip_before_action :verify_authenticity_token
  
  def desboart

  end

  def index
    @q = SearchParams.new(params[:search_params] || {})
    @employees = Employee.default_where(@q.attributes(self)).page(params[:page]).per(10)
  end

  def new
    @employee =  Employee.new
  end

  def edit
    @employee =  Employee.find(params[:id])
  end

  def show
    @employee =  Employee.find(params[:id])
  end

  def add_roles
    @employee = Employee.find(params[:id])
  end

  def save_roles
    @employee = Employee.find(params[:id])
    @employee.role_ids = params[:employee][:role_ids]
    @employee.save
  end

  def update
    @employee = Employee.find(params[:id])
    @employee.update_attributes(permitted_resource_params)
  end

  def create
    @employee = Employee.new
    @employee.attributes = permitted_resource_params
    @employee.save
  end

  def destroy
    @employee.employee_status = params[:employee_status] if params[:employee_status]
    @employee.save
  end

  #找回密码
  def forget_password
    return unless request.post?
    userinfo =  params[:email].strip
    employee = Employee.where("name = ? or email = ?", userinfo, userinfo)
    if employee.present? && userinfo.present?
      employee.last.send_user_mail
      redirect_to :action => "reset_mail"
    else
      flash.now[:warning]  = "Please enter the correct user name / registered mail"
    end
  end

  # 邮件重置
  def reset_mail

  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def permitted_resource_params
    params.require(:employee).permit!
  end


end
