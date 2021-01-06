class CreateEmployees < ActiveRecord::Migration[5.2]
  def change
    create_table "employees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", comment: "员工表" do |t|
        t.string   "email",                            default: "",  null: false, comment: "email"
        t.string   "encrypted_password",               default: "",  null: false, comment: "密码"
        t.string "reset_password_token", comment: "重置密码的token"
        t.datetime "reset_password_sent_at", comment: "重置密码的时间"
        t.integer "sign_in_count", default: 0, null: false, comment: "登录次数"
        t.datetime "current_sign_in_at", comment: "当前登录时间"
        t.datetime "last_sign_in_at", comment: "上路登录时间"
        t.string "current_sign_in_ip", comment: "当前登录的IP"
        t.string "last_sign_in_ip", comment: "上次登录的IP"
        t.integer "failed_attempts", default: 0, null: false, comment: "登录失败次数"
        t.string "unlock_token", comment: "解锁token"
        t.datetime "locked_at", comment: "锁住时间"
        t.integer  "parent_id",                        default: 0,                comment: "上级ID"
        t.datetime "created_at",                                     null: false, comment: "创建日期"
        t.datetime "updated_at",                                     null: false, comment: "修改日期"
        t.string   "name",                 limit: 20,                             comment: "名字"
        t.integer  "department_id",                    default: 0,   null: false, comment: "部门ID"
        t.integer  "position_id",                      default: 0,   null: false, comment: "职位： 0:其它 6:财务 7:产品经理...."
        t.integer  "position_level",                   default: 0,   null: false, comment: "行政级别 0:员工 1:主管 2:经理 3:总监"
        t.integer  "job_status",                       default: 1,   null: false, comment: "在职状态, 1:在职, -1:离职"
        t.float    "weight",               limit: 24,  default: 1.0, null: false, comment: "权重"
        t.date     "joined_on",                                                   comment: "入职日期"
        t.integer  "gender",                                                      comment: "性别 0:男 1:女"
        t.string   "mobile",               limit: 30,                             comment: "手机"
        t.string   "qq",                   limit: 30,                             comment: "QQ"
        t.string   "office_tel",           limit: 30,                             comment: "公司电话"
        t.date     "dob",                                                         comment: "生日"
        t.datetime "remember_created_at",                                         comment: "记住创建日期"
        t.integer  "deputy_department_id",             default: 0,                comment: "副部门"
        t.string   "avatar",               limit: 100,                            comment: "员工头像"
        t.integer  "assign_count",                     default: 0,                comment: "分配点数"
        t.integer  "handover_id",                      default: 0,                comment: "交接人"
        t.index ["email"], name: "index_employees_on_email", unique: true, using: :btree
    end
  end
end
