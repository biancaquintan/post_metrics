require 'faker'
require 'open3'
require 'json'
require 'ruby-progressbar'

puts "\n=== INICIANDO SCRIPT 🚀\n\n"

Rating.delete_all
Post.delete_all
User.delete_all

def send_curl(url, payload)
  command = %(curl -s -X POST #{url} -H "Content-Type: application/json" -d '#{payload}')
  retries = 0

  begin
    stdout, stderr, status = Open3.capture3(command)

    raise "Erro ao fazer requisição: #{stderr}" unless status.success?

    stdout
  rescue => e
    if retries < 3
      retries += 1
      puts "Erro ao fazer requisição, tentando novamente (#{retries})... (#{e.message})"
      sleep(1)
      retry
    else
      puts "Erro ao fazer requisição: #{e.message}"
      raise
    end
  end
end

def create_user(login)
  payload = { login: login }.to_json
  send_curl('http://localhost:3000/api/v1/users', payload)
end

def create_posts_batch(posts)
  payload = { posts: posts }.to_json
  send_curl('http://localhost:3000/api/v1/posts/batch', payload)
end

def create_rating(user_id, post_id, value)
  payload = { user_id: user_id, post_id: post_id, value: value }.to_json
  send_curl('http://localhost:3000/api/v1/ratings', payload)
end

def create_ratings_batch(ratings)
  payload = { ratings: ratings }.to_json
  send_curl('http://localhost:3000/api/v1/ratings/batch', payload)
end

############## CRIANDO USERS ##############
puts ">>> Criando usuários..."

user_logins = []
100.times do
  login = Faker::Internet.unique.username(specifier: 5..10)
  create_user(login)
  user_logins << login
end

############## CRIANDO IPS ##############
puts ">>> Criando IPs..."

ips = Array.new(50) { Faker::Internet.unique.public_ip_v4_address }

############## CRIANDO POSTS ##############
puts ">>> Criando posts em lote..."

posts_to_create = []
total_posts = 200_000
batch_size = 500
posts_created = 0

posts_progressbar = ProgressBar.create(
  title: 'Posts',
  total: total_posts,
  format: '%t [%B] %p%% %e',
  projector: { type: 'smoothing', strength: 0.8 }
)

total_posts.times do
  posts_to_create << {
    login: user_logins.sample,
    title: Faker::Movie.title,
    body: Faker::Lorem.paragraph(sentence_count: 5),
    ip: ips.sample
  }

  if posts_to_create.size == batch_size
    create_posts_batch(posts_to_create)
    posts_created += posts_to_create.size
    posts_to_create.clear
    posts_created.times { posts_progressbar.increment }
    posts_created = 0
  end
end

unless posts_to_create.empty?
  create_posts_batch(posts_to_create)
  posts_to_create.size.times { posts_progressbar.increment }
end

posts_progressbar.finish

############## CRIANDO RATINGS ##############
puts ">>> Criando ratings em lote..."

user_map = User.pluck(:login, :id).to_h
post_ids = Post.pluck(:id)

ratings_to_create = []
ratings_created = 0
estimated_total_ratings = (post_ids.size * 0.75).to_i

ratings_progressbar = ProgressBar.create(
  title: 'Ratings',
  total: estimated_total_ratings,
  format: '%t [%B] %p%% %e',
  projector: { type: 'smoothing', strength: 0.8 }
)

post_ids.each do |post_id|
  next if rand > 0.75

  login = user_logins.sample
  user_id = user_map[login]
  rating_value = rand(1..5)

  ratings_to_create << {
    user_id: user_id,
    post_id: post_id,
    value: rating_value
  }

  ratings_created += 1

  if ratings_progressbar.progress < ratings_progressbar.total
    ratings_progressbar.increment
  end

  if ratings_to_create.size == batch_size
    create_ratings_batch(ratings_to_create)
    ratings_to_create.clear
  end
end

create_ratings_batch(ratings_to_create) unless ratings_to_create.empty?
ratings_progressbar.finish

puts "\n=== SCRIPT FINALIZADO 🏁\n\n"
