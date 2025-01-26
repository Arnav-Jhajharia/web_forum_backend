# db/seeds.rb

require 'faker'

puts "Clearing existing data..."
Comment.delete_all
Reaction.delete_all
Follow.delete_all
ForumThread.delete_all
Tag.delete_all
Category.delete_all
User.delete_all

puts "Seeding Categories..."
categories = Category.create!([
  { name: "General Discussion", description: "Talk about anything and everything." },
  { name: "Music", description: "Discuss albums, artists, concerts, and more." },
  { name: "Movies", description: "Film discussions, reviews, and recommendations." },
  { name: "Technology", description: "Chat about the latest tech trends and tools." },
  { name: "Books", description: "Share your favorite reads and authors." },
  { name: "Gaming", description: "Video games, board games, and everything in-between." },
  { name: "Health & Fitness", description: "Tips, progress, and encouragement." },
  { name: "Food & Cooking", description: "Recipes, restaurants, and cooking tips." }
])

puts "Seeding Tags..."
tags = Tag.create!([
  { name: "ruby" },
  { name: "rails" },
  { name: "gaming" },
  { name: "music" },
  { name: "fitness" },
  { name: "cooking" },
  { name: "books" },
  { name: "movies" },
  { name: "tech" }
])

puts "Seeding Users..."
# Create 12 users with some random data
users = 12.times.map do
  username  = Faker::Internet.unique.username(specifier: 5..10)
  name      = Faker::Name.name
  email     = Faker::Internet.unique.email
  bio       = Faker::Quote.famous_last_words
  language  = %w[en es fr de].sample
  timezone  = ActiveSupport::TimeZone.all.sample.name # or "UTC"
  dark_mode = [true, false].sample

  User.create!(
    username:   username,
    name:       name,
    email:      email,
    bio:        bio,
    language:   language,
    timezone:   timezone,
    dark_mode:  dark_mode
  )
end

# Optional: You could create an "admin" or "test" user if desired:
# admin = User.create!(
#   username: "admin",
#   name: "Admin User",
#   email: "admin@example.com",
#   bio: "Site administrator",
#   language: "en",
#   timezone: "UTC",
#   dark_mode: true
# )

puts "Seeding Follows..."
# Randomly create some follows among the users
users.each do |follower|
  # Each user follows 2-5 other random users
  others = users.reject { |u| u == follower }.sample(rand(2..5))
  others.each do |followed_user|
    Follow.create!(follower: follower, followed_user: followed_user)
  end
end

moods = %w[Chill Excited Curious Supportive]

puts "Seeding Forum Threads..."
# Create ~30 forum threads
forum_threads = 30.times.map do
  user      = users.sample
  category  = categories.sample
  mood      = moods.sample
  title     = Faker::Lorem.sentence(word_count: rand(3..6))
  content   = Faker::Lorem.paragraph(sentence_count: rand(3..7))

  ForumThread.create!(
    title:       title,
    content:     content,
    mood:        mood,
    user:        user,
    category:    category
  )
end

puts "Assigning random Tags to Forum Threads..."
forum_threads.each do |thread|
  # Grab between 1 and 3 tags
  selected_tags = tags.sample(rand(1..3))
  # Attach them via the join table or a custom method if you have one
  thread.tags << selected_tags
end

puts "Seeding Comments..."
# For each thread, create 1-5 comments, some nested
forum_threads.each do |thread|
  rand(1..5).times do
    commenter = users.sample
    comment = Comment.create!(
      content: Faker::Lorem.sentence(word_count: 8),
      user: commenter,
      forum_thread: thread
    )

    # Randomly add a nested reply ~50% of the time
    if [true, false].sample
      Comment.create!(
        content: Faker::Lorem.sentence(word_count: 6),
        user: users.sample,
        forum_thread: thread,
        parent: comment
      )
    end
  end
end

puts "Seeding Reactions..."
# For each thread, have a random number of users react
reaction_types = %w[like chill]
forum_threads.each do |thread|
  # Random subset of users
  reacting_users = users.sample(rand(3..7))
  reacting_users.each do |u|
    Reaction.create!(
      user: u,
      forum_thread: thread,
      reaction_type: reaction_types.sample
    )
  end
end

puts "Done seeding!"
