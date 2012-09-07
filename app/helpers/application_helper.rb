module ApplicationHelper
  def full_title(page_title)
    if page_title.empty?
      t(:base_title)
    else
      "#{t(:base_title)} | #{page_title}"
    end
  end
  
  def active(page)
    "active" if current_page?(page)
  end
  
  def pageless(total_pages, url = nil, target = nil, container = nil)
    opts = { totalPages: total_pages, url: url, loader: "#" + target, loaderImage: "/assets/load.gif" }
    container && opts[:container] ||= container
    javascript_tag("$('##{target}').pageless(#{opts.to_json});")
  end
end
