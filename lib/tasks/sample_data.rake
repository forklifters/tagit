namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!(
      name: "Vladimir Sabev",
      username: "vdsabev",
      email: "vdsabev@gmail.com",
      password: "tester",
      password_confirmation: "tester")
    admin.toggle!(:admin)
    
    99.times do |n|
      password = "tester"
      User.create!(
        name: Faker::Name.name,
        username: "example#{n+1}",
        email: "example-#{n+1}@railstutorial.org",
        password: password,
        password_confirmation: password
      )
    end
    
    users = [User.first] + User.all(limit: 2)
    33.times do
      content = Faker::Lorem.sentence(5)
      users.each { |user| user.posts.create!(content: content) }
    end
  end
end
