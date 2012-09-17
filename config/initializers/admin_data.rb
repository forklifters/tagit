AdminData.config do |config|
  config.is_allowed_to_view = lambda {|controller| controller.send('current_user.admin?') }
  config.is_allowed_to_update = lambda {|controller| controller.send('current_user.admin?') }
end
