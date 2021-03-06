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

ActiveRecord::Schema.define(version: 2021_03_09_070152) do

  create_table "approve_events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "event_type", default: "black_user", comment: "审核类型"
    t.integer "event_id", default: 1, comment: "事件id"
    t.integer "emp_id", default: 1, comment: "分配审核员"
    t.integer "approve_emp_id", default: 1, comment: "实际审核员"
    t.integer "status", default: 0, comment: "用户状态：0待审核，1已审核"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approve_emp_id"], name: "index_approve_events_on_approve_emp_id"
    t.index ["emp_id"], name: "index_approve_events_on_emp_id"
    t.index ["event_id"], name: "index_approve_events_on_event_id"
    t.index ["event_type"], name: "index_approve_events_on_event_type"
    t.index ["status"], name: "index_approve_events_on_status"
  end

  create_table "black_words", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "title", comment: "内容标题"
    t.string "link", comment: "内容链接"
    t.string "source_tags", comment: "不合规描述"
    t.string "source_keyword", comment: "违规关键字"
    t.string "source_view", comment: "播放热度"
    t.datetime "release_at", comment: "收录时间"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["release_at"], name: "index_black_words_on_release_at"
    t.index ["title"], name: "index_black_words_on_title"
  end

  create_table "categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", comment: "名称"
    t.integer "parent_id", comment: "父节点"
    t.integer "status", default: 1, comment: "状态"
    t.integer "sort_live", comment: "排序"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "is_delete", default: 0, comment: "是否删除"
    t.integer "en_cod", default: 0, comment: "外语"
    t.integer "cnjt_cod", default: 0, comment: "简体"
    t.integer "cnft_cod", default: 0, comment: "繁体"
  end

  create_table "category_conditions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "category_id", comment: "栏目"
    t.bigint "classification_id", comment: "分类"
    t.integer "weight", default: 0, comment: "权重：10%,20%,30%,40%,50%,60%,70%,80%,90%,100%"
    t.string "tags_str", comment: "关键词"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_category_conditions_on_category_id"
    t.index ["classification_id"], name: "index_category_conditions_on_classification_id"
  end

  create_table "classifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name", comment: "名称"
    t.integer "parent_id", comment: "父节点"
    t.integer "status", default: 1, comment: "状态"
    t.integer "sort_live", comment: "排序"
    t.integer "is_delete", default: 0, comment: "是否删除"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", comment: "员工表", force: :cascade do |t|
    t.string "email", default: "", null: false, comment: "email"
    t.string "encrypted_password", default: "", null: false, comment: "密码"
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

  create_table "employees_roles", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "employee_id"
    t.bigint "role_id"
    t.index ["employee_id", "role_id"], name: "index_employees_roles_on_employee_id_and_role_id"
    t.index ["employee_id"], name: "index_employees_roles_on_employee_id"
    t.index ["role_id"], name: "index_employees_roles_on_role_id"
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
    t.integer "spider_target_id", comment: "信息来源"
    t.string "category_list", comment: "资讯分类"
    t.integer "encoding_type", default: 1, comment: "编码类型：0外语，1简体，2繁体"
    t.integer "classification_id", comment: "分类"
    t.index ["category_id"], name: "index_infos_on_category_id"
    t.index ["classification_id"], name: "index_infos_on_classification_id"
    t.index ["encoding_type"], name: "index_infos_on_encoding_type"
    t.index ["medial_spider_id"], name: "index_infos_on_medial_spider_id"
    t.index ["release_at"], name: "index_infos_on_release_at"
    t.index ["spider_target_id"], name: "index_infos_on_spider_target_id"
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

  create_table "marks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "title", comment: "名称"
    t.string "url", comment: "图片地址"
    t.integer "is_delete", default: 0, comment: "是否删除"
    t.integer "status", default: 0, comment: "状态：-1禁用,0启用"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "medial_caches", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "uuid", comment: "uuid"
    t.string "title", comment: "名称"
    t.string "link", comment: "链接"
    t.text "image_base64", comment: "图片内容"
    t.string "medial_source", default: "youtube", comment: "媒体资源"
    t.string "local_model", default: "Video", comment: "资源类型"
    t.string "local_id", default: "0", comment: "本地缓存ID"
    t.integer "status", default: 0, comment: "是否已审核"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.integer "need_approve", default: 1, comment: "是否需要审核0自动审核unneed，1手动审核need"
    t.integer "classification_id", comment: "分类"
    t.integer "spider_type", default: 0, comment: "0频道爬取，1视频爬取"
    t.index ["category_id"], name: "index_medial_spiders_on_category_id"
    t.index ["classification_id"], name: "index_medial_spiders_on_classification_id"
    t.index ["spider_target_id"], name: "index_medial_spiders_on_spider_target_id"
  end

  create_table "permissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "controller", comment: "控制器名称"
    t.string "action", comment: "方法名称"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recommends", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "title", comment: "标题"
    t.string "url", comment: "目标url"
    t.bigint "employee_id", default: 1, comment: "上传对象"
    t.integer "recommend_type", default: 0, comment: "分类：0外网头条，1综合推荐"
    t.bigint "mark_id", comment: "标注"
    t.integer "is_delete", default: 0, comment: "是否删除"
    t.integer "status", default: 0, comment: "状态：-1禁用,0启用"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_live", comment: "排序"
    t.index ["employee_id"], name: "index_recommends_on_employee_id"
    t.index ["mark_id"], name: "index_recommends_on_mark_id"
  end

  create_table "roles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name"
    t.string "name_cn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "roles_permissions", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "permission_id"
    t.index ["permission_id"], name: "index_roles_permissions_on_permission_id"
    t.index ["role_id", "permission_id"], name: "index_roles_permissions_on_role_id_and_permission_id"
    t.index ["role_id"], name: "index_roles_permissions_on_role_id"
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
    t.string "category_list", comment: "资讯分类"
    t.string "tags_str", comment: "资讯标签"
    t.integer "encoding_type", default: 1, comment: "编码类型：0外语，1简体，2繁体"
    t.integer "classification_id", comment: "分类"
    t.index ["encoding_type"], name: "index_spider_origin_infos_on_encoding_type"
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
    t.string "category_list", comment: "视频分类"
    t.string "tags_str", comment: "视频标签"
    t.integer "encoding_type", default: 1, comment: "编码类型：0外语，1简体，2繁体"
    t.integer "classification_id", comment: "分类"
    t.text "strategy_word", comment: "匹配策略黑词"
    t.index ["encoding_type"], name: "index_spider_origin_videos_on_encoding_type"
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

  create_table "strategy_source_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "strategy_source_id", comment: "资源用户"
    t.string "title", comment: "内容标题"
    t.string "link", comment: "内容链接"
    t.string "source_tags", comment: "不合规描述"
    t.string "source_keyword", comment: "违规关键字"
    t.string "source_view", comment: "播放热度"
    t.datetime "release_at", comment: "收录时间"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["release_at"], name: "index_strategy_source_details_on_release_at"
    t.index ["strategy_source_id"], name: "index_strategy_source_details_on_strategy_source_id"
    t.index ["title"], name: "index_strategy_source_details_on_title"
  end

  create_table "strategy_sources", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "medial_source", default: "youtube", comment: "网站名称"
    t.string "web_user", comment: "用户名称"
    t.string "trouble_size", comment: "不合规内容数"
    t.datetime "release_at", comment: "收录时间"
    t.integer "user_status", default: 1, comment: "用户状态：0白名单，1黑名单"
    t.string "user_tags", comment: "用户标签"
    t.string "user_follow", comment: "用户关注数"
    t.string "user_view", comment: "用户播放热度"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medial_source"], name: "index_strategy_sources_on_medial_source"
    t.index ["release_at"], name: "index_strategy_sources_on_release_at"
    t.index ["web_user"], name: "index_strategy_sources_on_web_user"
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
    t.integer "spider_target_id", comment: "信息来源"
    t.integer "is_location_source", default: 0, comment: "0:非本地资源，1:有本地资源"
    t.string "location_source_url", comment: "本地资源url"
    t.integer "ads", default: 0, comment: "0:非广告流，1:广告流"
    t.integer "ads_index", default: 0, comment: "广告排序"
    t.string "category_list", comment: "视频分类"
    t.integer "encoding_type", default: 1, comment: "编码类型：0外语，1简体，2繁体"
    t.integer "classification_id", comment: "分类"
    t.text "strategy_word", comment: "匹配策略黑词"
    t.index ["category_id"], name: "index_videos_on_category_id"
    t.index ["classification_id"], name: "index_videos_on_classification_id"
    t.index ["encoding_type"], name: "index_videos_on_encoding_type"
    t.index ["medial_spider_id"], name: "index_videos_on_medial_spider_id"
    t.index ["release_at"], name: "index_videos_on_release_at"
    t.index ["spider_target_id"], name: "index_videos_on_spider_target_id"
  end

end
