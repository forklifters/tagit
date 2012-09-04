module ApplicationHelper
  # Returns the full title on a per-page basis.
  def full_title(page_title)
    if page_title.empty?
      t(:base_title)
    else
      "#{t(:base_title)} | #{page_title}"
    end
  end
end
