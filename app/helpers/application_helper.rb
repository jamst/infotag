module ApplicationHelper

def day_time(t)
  t&.strftime("%Y-%m-%d")
end

def str_chip(url,chip=100)
  url.size > chip ? "#{url[0..chip]}.." : url if url.present?
end 

def select_options_from_enum(model,attribute,opts=nil)
  options = model.send(attribute.to_s.pluralize) if options.blank? && model.respond_to?(attribute.to_s.pluralize)
  return [] if options.blank?
  mappings = options.keys
  mappings.keep_if{|k| opts[:values].map(&:to_s).include?(k.to_s)} if opts && opts[:values].present? && opts[:values].is_a?(Array)
  mappings.map{|key| [display_model_status(model,attribute,key),key]}
end

def display_model_status(model,attribute,value)
  return if value.nil?
  if ::I18n.exists?("activerecord.status.#{model.name.underscore}.#{attribute}.#{value}")
    key = "activerecord.status.#{model.name.underscore}.#{attribute}.#{value}"
  else
    key = "activerecord.status.#{attribute}.#{value}"
  end
  I18n.t(key,:default => value)
end


def link_to_with_permissions(name = nil, options = nil, html_options = nil, &block)
  html_options, options, name = options, name, block if block_given?
  options ||= {}
  entity = html_options.delete(:entity)
  entity.current_employee = current_employee if entity.respond_to?(:current_employee)
  entity.current_ability = current_ability if entity.respond_to?(:current_ability)

  active_class = html_options.delete(:active_class)
  html_options = convert_options_to_data_attributes(options, html_options)

  url = url_for(options)
  html_options['href'] ||= url
  method = html_options['data-method'].present?? html_options['data-method'] : 'get'
  r = Rails.application.routes.recognize_path(url, method: method, subdomain: 'www')
  if active_class.present? && controller_path  == r[:controller] && action_name  == r[:action]
    html_options['class'] = "#{html_options['class']} #{active_class}".strip
  end
  content_tag(:a, name || url, html_options, &block)
end


def action_on_list(options = [])
  isin = false
  options.each do |option|
    url = url_for(option)
    method = 'get'
    r = Rails.application.routes.recognize_path(url, method: method, subdomain: 'www')
    if controller_path  == r[:controller] && action_name  == r[:action]
      isin = true
      break
    end
  end
  isin
end


end
