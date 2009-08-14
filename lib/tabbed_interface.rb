# TabbedInterface
module TabbedInterface
  
  def tabbed_content(id = nil)
    content_box = ContentBox.new(id)
    
    yield content_box
    
    tabs = []
    content_box.tabs.each do |tab|
      stuff = link_to_remote(tab.title, tab.link_opts(content_box), tab.html_options)
      stuff << image_tag("/images/ajax-loader.gif", :style => "display:none;", :id => tab.loader_id)
      tabs << content_tag(content_box.tab_tag, stuff, :class => tab.cls_str((tab == content_box.tabs.first)), :id => "tab-#{tab.id}")
    end
      
    tab_content = content_tag(content_box.tabs_tag, tabs)
    tab_content << content_tag(:div, "&nbsp;", :class => "clear")
    concat content_tag(:div, tab_content, :class => content_box.navigation_wrapper)
    concat content_tag(:div, content_box.main_content, :id => content_box.content_div, :class => content_box.content_wrapper)
  end

end
  
  
def generate_id
  Digest::SHA1.hexdigest([Time.now, rand].join).gsub(/\D/,'').first(10)
end


class ContentBox < Struct.new(:tabs, :main_content, :content_div, :options)
  
  def initialize(id = nil)
    self[:tabs] = []
    self[:content_div] = id || "main_content_#{generate_id}"
    self[:main_content] = nil
    self[:options] = {
      :content_wrapper => "tabbed_content", 
      :navigation_wrapper => "tabbed_navigation",
      :tab_tag => :li,
      :tabs_tag => :ul
    }
  end  
  
  def tab(title, url, options={}, html={})
    tabs << ContentTab.new(title,url,options,html)
  end
  
  def content=(str="")
    self[:main_content] = str
  end
  
  # make setting and getting options dynamic!
  # currently used options
  # :content_wrapper
  # :navigation_wrapper  
  # :tab_tag
  # :tabs_tag
  def method_missing(method, *args, &block)
    name = method.to_s.gsub("=","")
    if method.to_s.include?("=")
      self[:options][name.to_sym] = *args
    else
      self[:options][name.to_sym].to_s
    end
  rescue
    super
  end
  
end

class ContentTab < Struct.new(:id, :css_classes, :title, :ajax_options, :html_options)
  def initialize(title, url, options = {},html={})
    options.reverse_merge! :url => url, :method => :get, :class => "tab-title"
    self[:id] = generate_id
    self[:css_classes] = ["tab"]
    self[:title] = title
    self[:ajax_options] = options
    self[:html_options] = html
  end
  
  def loader_id
    "tab-#{id}-loading"
  end
  
  def link_opts(cb)
    this = "tab-#{self.id}"
    hsh = {
      :update => cb.content_div,
      :before => "Element.show('#{loader_id}');", 
      :complete => "Element.hide('#{loader_id}'); $('#{this}').className='tab tab-active'; $('#{this}').siblings().each(function(e){e.className='tab tab-inactive'});"
    }
    ajax_options.merge(hsh)
  end
  
  def cls_str(active = false)
    self.css_classes += ["tab-active"] if active
    self.css_classes += ["tab-inactive"] if !active
    self.css_classes.join(" ")
  end
  
end
