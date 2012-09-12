desc "This task is called by the Heroku scheduler add-on"
task :delete_unused_tags => :environment do
  puts "Deleting unused tags..."
  Tag.all.each do |tag| tag.destroy if tag.count == 0 end
  puts "...done."
end
