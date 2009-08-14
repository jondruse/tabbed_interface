# TabbedInterface
module TabbedInterface
  
  def tabbed_content(id = nil)
    content_box = ContentBox.new(id)
    
    yield content_box
    
    tabs = []
    
    content_box.tabs.each do |tab|
      
      stuff = link_to_remote(tab.title, tab.link_opts(content_box))
      stuff << image_tag("/images/ajax-loader.gif", :style => "display:none;", :id => tab.loader_id)
      
      tabs << content_tag(:div, stuff, :class => tab.cls_str((tab == content_box.tabs.first)), :id => "tab-#{tab.id}")
      
    end #tab loop
      
    tab_content = content_tag(:div, tabs)
    tab_content << content_tag(:div, "&nbsp;", :class => "clear")
    
    concat content_tag(:div, tab_content, :class => "tab-navigation width-100-percent")
        
    concat content_tag(:div, content_box.main_content, :id => content_box.content_div, :class => "width-100-percent")
    
  end

end
  
  
def generate_id
  Digest::SHA1.hexdigest([Time.now, rand].join).gsub(/\D/,'').first(10)
end

class ContentBox < Struct.new(:tabs, :main_content, :content_div, :)
  
  def initialize(id = nil)
    self[:tabs] = []
    self[:content_div] = id || "main_content_#{generate_id}"
    self[:main_content] = nil
  end  
  
  def tab(title, url)
    tabs << ContentTab.new(title, url)
  end
  
  def content=(str="")
    self[:main_content] = str
  end
  
  def tab_ids
    tabs.map(&:id)
  end
  
  def helpers
    ActionController::Helpers
  end
  
end

class ContentTab < Struct.new(:id, :css_classes, :title, :ajax_options)
  def initialize(title, url)
    self[:id] = generate_id
    self[:css_classes] = ["tab"]
    self[:title] = title
    self[:ajax_options] = {:url => url, :method => :get, :class => "tab-title"}
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
