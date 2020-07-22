# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_22_035451) do

  create_table "categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", comment: "名称"
    t.integer "parent_id", comment: "父节点"
    t.integer "status", default: 1, comment: "状态"
    t.integer "sort_live", comment: "排序"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "is_delete", default: 0, comment: "是否删除"
  end

  create_table "employees", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", comment: "员工表", force: :cascade do |t|
    t.string "email", default: "", null: false, comment: "email"
    t.string "encrypted_password", default: "", null: false, comment: "密码"
    t.integer "parent_id", default: 0, comment: "上级ID"
    t.datetime "created_at", null: false, comment: "创建日期"
    t.datetime "updated_at", null: false, comment: "修改日期"
    t.string "name", limit: 20, comment: "名字"
    t.integer "department_id", default: 0, null: false, comment: "部门ID"
    t.integer "position_id", default: 0, null: false, comment: "职位： 0:其它 6:财务 7:产品经理...."
    t.integer "position_level", default: 0, null: false, comment: "行政级别 0:员工 1:主管 2:经理 3:总监"
    t.integer "job_status", default: 1, null: false, comment: "在职状态, 1:在职, -1:离职"
    t.float "weight", default: 1.0, null: false, comment: "权重"
    t.date "joined_on", comment: "入职日期"
    t.integer "gender", comment: "性别 0:男 1:女"
    t.string "mobile", limit: 30, comment: "手机"
    t.string "qq", limit: 30, comment: "QQ"
    t.string "office_tel", limit: 30, comment: "公司电话"
    t.date "dob", comment: "生日"
    t.datetime "remember_created_at", comment: "记住创建日期"
    t.integer "deputy_department_id", default: 0, comment: "副部门"
    t.string "avatar", limit: 100, comment: "员工头像"
    t.integer "assign_count", default: 0, comment: "分配点数"
    t.integer "handover_id", default: 0, comment: "交接人"
    t.index ["email"], name: "index_employees_on_email", unique: true
  end

  create_table "employees_roles", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", comment: "员工权限表", force: :cascade do |t|
    t.integer "employee_id", comment: "员工ID"
    t.integer "role_id", comment: "员工权限"
    t.index ["employee_id", "role_id"], name: "index_employees_roles_on_employee_id_and_role_id"
  end

  create_table "file_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "attachment_entity_type", limit: 64
    t.integer "attachment_entity_id"
    t.string "path", comment: "文件路径"
    t.string "name", comment: "文件名"
    t.string "content_type", comment: "文件类型"
    t.integer "file_size", comment: "文件大小"
    t.integer "created_by", comment: "上传人"
    t.integer "is_delete", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "info_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "info_id", comment: "咨讯"
    t.bigint "category_id", comment: "分类"
    t.index ["category_id"], name: "index_info_categories_on_category_id"
    t.index ["info_id"], name: "index_info_categories_on_info_id"
  end

  create_table "infos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title", comment: "标题"
    t.string "url", comment: "目标url"
    t.string "image_url", comment: "图片url"
    t.string "local_image_url", comment: "本地视频封面图片url"
    t.bigint "category_id", comment: "类型"
    t.bigint "medial_spider_id", comment: "爬虫设置"
    t.string "tags_str", comment: "标签"
    t.integer "weight", default: 0, comment: "权重：0随机，1置顶"
    t.integer "click_count", comment: "点击数量"
    t.integer "status", default: 0, comment: "状态：-1禁用,0启用"
    t.integer "is_delete", default: 0, comment: "是否删除"
    t.datetime "release_at", comment: "发布时间"
    t.string "author", comment: "发布者名称"
    t.text "mark", comment: "描述"
    t.integer "medial_type", default: 0, comment: "内容类型:0资讯,1视频"
    t.integer "approve_status", default: 0, comment: "状态：-1已拒绝,0待审核,1已通过"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_infos_on_category_id"
    t.index ["medial_spider_id"], name: "index_infos_on_medial_spider_id"
    t.index ["release_at"], name: "index_infos_on_release_at"
  end

  create_table "infos_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "info_id", comment: "咨讯"
    t.bigint "tag_id", comment: "标签"
    t.index ["info_id"], name: "index_infos_tags_on_info_id"
    t.index ["tag_id"], name: "index_infos_tags_on_tag_id"
  end

  create_table "keywords", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", comment: "名称"
    t.bigint "tag_id", comment: "标签"
    t.integer "click_count", comment: "点击数量"
    t.integer "status", default: 0, comment: "状态：-1禁用,0启用"
    t.integer "is_delete", default: 0, comment: "是否删除"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_keywords_on_tag_id"
  end

  create_table "medial_spiders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "spider_target_id", comment: "网站名称"
    t.string "url", comment: "网址url"
    t.string "web_site", comment: "网站模块"
    t.integer "medial_type", comment: "内容类型:0资讯,1视频"
    t.bigint "category_id", comment: "分类栏目"
    t.string "tags_str", comment: "标签"
    t.integer "status", default: 0, comment: "状态：-1禁用,0启用"
    t.integer "is_delete", default: 0, comment: "是否删除"
    t.text "mark", comment: "描述"
    t.datetime "release_at", comment: "指定过滤时间"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_medial_spiders_on_category_id"
    t.index ["spider_target_id"], name: "index_medial_spiders_on_spider_target_id"
  end

  create_table "roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", comment: "角色表", force: :cascade do |t|
    t.string "name", comment: "角色名称"
    t.string "name_cn", comment: "中文名"
    t.datetime "created_at", comment: "创建日期"
    t.datetime "updated_at", comment: "修改日期"
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "spider_origin_infos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "spider_medial_id", comment: "爬虫配置id"
    t.string "url", comment: "目标url"
    t.string "title", comment: "标题"
    t.datetime "release_at", comment: "发布时间"
    t.string "image_url", comment: "视频封面图片url"
    t.text "mark", comment: "描述"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spider_origin_videos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "spider_medial_id", comment: "爬虫配置id"
    t.string "url", comment: "目标url"
    t.string "title", comment: "标题"
    t.string "overlay_time", comment: "时长"
    t.string "play_count", comment: "播放量"
    t.datetime "release_at", comment: "发布时间"
    t.string "author", comment: "发布者名称"
    t.string "image_url", comment: "视频封面图片url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spider_targets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", comment: "名称"
    t.string "url", comment: "网站url"
    t.string "logo_url", comment: "网站logo"
    t.integer "status", default: 1, comment: "状态"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "is_delete", default: 0, comment: "是否删除"
  end

  create_table "tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", comment: "名称"
    t.integer "status", default: 1, comment: "状态"
    t.text "connection_tags", comment: "关联"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "is_delete", default: 0, comment: "是否删除"
    t.index ["name"], name: "index_tags_on_name"
    t.index ["status"], name: "index_tags_on_status"
  end

  create_table "tags_videos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "video_id", comment: "视频"
    t.bigint "tag_id", comment: "标签"
    t.index ["tag_id"], name: "index_tags_videos_on_tag_id"
    t.index ["video_id"], name: "index_tags_videos_on_video_id"
  end

  create_table "user_tag_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id", comment: "用户"
    t.bigint "tag_id", comment: "标签"
    t.string "from_entity_type", comment: "来源模型"
    t.integer "form_entity_id", comment: "来源id"
    t.text "from_url", comment: "来源url"
    t.index ["tag_id"], name: "index_user_tag_details_on_tag_id"
    t.index ["user_id"], name: "index_user_tag_details_on_user_id"
  end

  create_table "user_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id", comment: "用户"
    t.bigint "tag_id", comment: "标签"
    t.integer "hit_count", comment: "点击数量"
    t.index ["tag_id"], name: "index_user_tags_on_tag_id"
    t.index ["user_id"], name: "index_user_tags_on_user_id"
  end

  create_table "videos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title", comment: "标题"
    t.string "url", comment: "目标url"
    t.string "image_url", comment: "视频封面图片url"
    t.string "local_image_url", comment: "本地视频封面图片url"
    t.bigint "category_id", comment: "类型"
    t.bigint "medial_spider_id", comment: "爬虫设置"
    t.string "tags_str", comment: "标签"
    t.integer "weight", default: 0, comment: "权重：0随机，1置顶"
    t.integer "click_count", comment: "点击数量"
    t.integer "status", default: 0, comment: "状态：-1禁用,0启用"
    t.integer "is_delete", default: 0, comment: "是否删除"
    t.datetime "release_at", comment: "发布时间"
    t.string "author", comment: "发布者名称"
    t.string "overlay_time", comment: "时长"
    t.string "play_count", comment: "播放量"
    t.text "mark", comment: "描述"
    t.integer "medial_type", default: 1, comment: "内容类型:0资讯,1视频"
    t.integer "approve_status", default: 0, comment: "状态：-1已拒绝,0待审核,1已通过"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_videos_on_category_id"
    t.index ["medial_spider_id"], name: "index_videos_on_medial_spider_id"
    t.index ["release_at"], name: "index_videos_on_release_at"
  end

end
