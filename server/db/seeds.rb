# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Clear existing data
puts "Clearing existing data..."
Sympathy.destroy_all
Reply.destroy_all
Post.destroy_all
User.destroy_all

# Create demo users
puts "Creating demo users..."
users = []

# Main demo user
main_user = User.create!(
  email: "demo@example.com",
  password: "password123",
  password_confirmation: "password123",
  total_points: 150
)
users << main_user
puts "Created main demo user: #{main_user.email}"

# Additional users
5.times do |i|
  user = User.create!(
    email: "user#{i + 1}@example.com",
    password: "password123",
    password_confirmation: "password123",
    total_points: rand(10..200)
  )
  users << user
  puts "Created user: #{user.email}"
end

# Create demo posts
puts "\nCreating demo posts..."
post_contents = [
  {
    content: "大学の学園祭で、バンドのボーカルとして初めてステージに立ちました。緊張で歌詞を全部忘れてしまい、30秒間「あー」と言い続けた後、泣きながらステージを降りました。観客は200人以上いました。",
    category: "school",
    user: users[1]
  },
  {
    content: "初デートで相手の名前を間違えて呼び続けました。「さやか」さんなのに「あやか」と呼んでいて、3時間後にやっと指摘されました。しかも別れ際に「今日は楽しかったよ、あやか」と言ってしまいました。",
    category: "love",
    user: users[2]
  },
  {
    content: "新入社員歓迎会で上司にお酌をしようとして、勢い余ってビールを頭からかけてしまいました。しかもその上司は社長でした。翌日から「ビールシャワー」というあだ名がつきました。",
    category: "work",
    user: users[3]
  },
  {
    content: "友達の結婚式でスピーチを頼まれ、新郎の名前を最初から最後まで間違えて話し続けました。「たかし」さんなのに「ひろし」と。会場がざわついていたのに気づかず、最後まで熱弁をふるいました。",
    category: "friend",
    user: users[4]
  },
  {
    content: "プレゼンで自信満々に発表していたら、ズボンのチャックが全開でした。しかも下着が派手なキャラクターものだったので、プレゼン内容より印象に残ったと後で言われました。",
    category: "work",
    user: users[5]
  },
  {
    content: "告白しようとLINEで長文を送ったつもりが、間違えて母親に送信してしまいました。母は「頑張って！」と応援してくれましたが、本命の相手にはその勇気が出ませんでした。",
    category: "love",
    user: main_user
  },
  {
    content: "家族旅行で父が道に迷い、同じ場所を3時間ぐるぐる回っていました。母に「地図見たら？」と言われても意地を張って「大丈夫」と言い続け、結局目的地には着きませんでした。",
    category: "family",
    user: users[1]
  },
  {
    content: "卒業式で答辞を読んでいる最中、感極まって号泣。原稿が涙で濡れて読めなくなり、最後は記憶を頼りに適当なことを言いました。録画を見返すと支離滅裂でした。",
    category: "school",
    user: users[2]
  }
]

posts = []
post_contents.each do |post_data|
  post = Post.create!(
    user: post_data[:user],
    nickname: Utils::NicknameGenerator.call,
    content: post_data[:content],
    category: post_data[:category],
    status: ["active", "resolved"].sample
  )
  posts << post
  puts "Created post: #{post.nickname} - #{post.content[0..30]}..."
end

# Create replies for some posts
puts "\nCreating replies..."
reply_contents = [
  "緊張は誰にでもあります！むしろ「あー」を30秒続けられたのは、ある意味才能かも。次はきっと上手くいきますよ！",
  "名前を間違えるのは緊張の証。相手もきっと理解してくれているはず。次は名前をメモしていくのもアリですね！",
  "その瞬間は辛かったでしょうが、きっと良い思い出話になりますよ。社長も案外気にしていないかもしれません。",
  "式場の雰囲気を和ませたと思えば、ある意味大成功！新郎も笑い話として一生覚えていてくれるでしょう。",
  "プレゼンの内容より印象に残ったなら、ある意味プレゼン大成功！次からはチェックリストを作りましょう。"
]

posts.first(5).each_with_index do |post, index|
  # Create 2-3 replies per post
  rand(2..3).times do
    reply_user = users.sample
    next if reply_user == post.user  # Don't reply to own post
    
    reply = Reply.create!(
      post: post,
      user: reply_user,
      content: reply_contents.sample
    )
    puts "Created reply for post #{post.id} by #{reply_user.email}"
    
    # Randomly mark some as best answer
    if post.replies.count >= 2 && rand(1..3) == 1 && !post.replies.where(is_best: true).exists?
      reply.update!(is_best: true)
      post.update!(status: "resolved")
      puts "  -> Marked as best answer!"
    end
  end
end

# Create sympathies
puts "\nCreating sympathies..."
posts.each do |post|
  # Random number of sympathies per post
  rand(0..5).times do
    user = users.sample
    next if user == post.user  # Don't sympathize with own post
    
    begin
      Sympathy.create!(
        post: post,
        user: user
      )
      puts "User #{user.email} sympathized with post #{post.id}"
    rescue ActiveRecord::RecordInvalid
      # Skip if already sympathized
    end
  end
end

# Point totals are automatically calculated through callbacks

puts "\n=== Seed data created successfully! ==="
puts "Users: #{User.count}"
puts "Posts: #{Post.count}"
puts "Replies: #{Reply.count}"
puts "Sympathies: #{Sympathy.count}"
puts "\nDemo account:"
puts "Email: demo@example.com"
puts "Password: password123"
