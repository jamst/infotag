# default job_type defined like so:
# job_type :command, ":task :output"
# job_type :rake,    "cd :path && :environment_variable=:environment bundle exec rake :task --silent :output"
# job_type :runner,  "cd :path && bin/rails runner -e :environment ':task' :output"
# job_type :script,  "cd :path && :environment_variable=:environment bundle exec script/:task :output"

# 修改了schedule.rb文件后重启whenever之前需要执行 $bundle exec whenever --update-crontab 命令更新crontab文件	
# bundle exec whenever -s 'environment=staging'
set :output, { error: 'log/whenever_error.log', standard: 'log/whenever.log' }

# 每天的2点00分同步
# 海外定时任务
every 1.day, :at => '02:00 am' do
  runner 'Info.import_db'
  runner 'Video.import_db' 
end

# 国内定时任务
every 1.day, :at => '03:30 am' do
  runner 'Info.add_today_list'
  runner 'Video.add_today_list' 
end