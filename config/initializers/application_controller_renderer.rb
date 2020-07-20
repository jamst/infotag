# Be sure to restart your server when you modify this file.

# ApplicationController.renderer.defaults.merge!(
#   http_host: 'example.org',
#   https: false
# )
require "service/i18n"
ActiveRecord::Base.class_eval {include ::Service::I18n}