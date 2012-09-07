module PostsHelper
  require 'open-uri'
  require 'json'

  NEWLINE_REGEX = /\n/
  WHITESPACE_REGEX = /\s+/
  URL_REGEX = /(http|ftp|https):\/\/(\S*)/i
  IMAGE_URL_REGEX = />((http|ftp|https):\/\/(\S*)\.(jpg|jpeg|gif|png|svg|bmp)(\?[^\\\/\s]+)?)<\/a>/i
  YOUTUBE_REGEX = /<a class="_blank" href="(https?:\/\/(www\.)?(youtube\.com\/watch\?(?:\S+)?(?:v=([\w-]+))(?:\S+)?))">\1<\/a>/i
  VIMEO_REGEX = /<a class="_blank" href="(https?:\/\/(www\.)?(vimeo\.com)\/(\d+))">\1<\/a>/i
  
  def format_post(content, collapsed = false)
    content.gsub!(NEWLINE_REGEX, "<br>") # insert newlines
    content.gsub!(WHITESPACE_REGEX, " ") # insert whitespaces
    content.gsub!(AT_USERNAME_REGEX, link_to("@\\1", users_path + "/\\1") + "\\2") # insert user paths
    content.gsub!(URL_REGEX, '<a class="_blank" href="\\0">\\0</a>') # inser URLs
    
    if !collapsed
      content.gsub!(IMAGE_URL_REGEX, '><img src="\\1" /></a>') # insert images
      content.gsub!(YOUTUBE_REGEX, '<div class="youtube video" src="\\4"><img src="https://img.youtube.com/vi/\\4/0.jpg" /><div class="play_video"></div></div>') # embed youtube
      content.scan(VIMEO_REGEX).each do |match, www, domain, video_id|
        content.sub!(VIMEO_REGEX, '<div class="vimeo video" src="\\4"><img src="' + JSON.parse(open('http://vimeo.com/api/v2/video/' + video_id + '.json').read).first['thumbnail_large'] + '" /><div class="play_video"></div></div>') rescue nil # embed vimeo
      end
    end
    
    simple_format(content)
  end
end
