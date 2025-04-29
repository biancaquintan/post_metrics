require 'faker'
require 'open3'
require 'json'

puts "=== INICIANDO SCRIPT ==="

User.delete_all
Post.delete_all
Rating.delete_all

def send_curl(url, payload)
  command = %(curl -s -X POST #{url} -H "Content-Type: application/json" -d '#{payload}')
  retries = 0

  begin
    stdout, stderr, status = Open3.capture3(command)

    unless status.success?
      raise "Erro ao fazer requisição: #{stderr}"
    end

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
batch_size = 1000

total_posts.times do |i|
  posts_to_create << {
    login: user_logins.sample,
    title: Faker::Movie.title,
    body: Faker::Lorem.paragraph(sentence_count: 5),
    ip: ips.sample
  }

  if posts_to_create.size == batch_size
    create_posts_batch(posts_to_create)
    posts_to_create.clear
    puts "#{i + 1} posts criados" if (i + 1) % batch_size == 0
  end
end

create_posts_batch(posts_to_create) unless posts_to_create.empty?

############## CRIANDO RATINGS ##############
puts ">>> Criando ratings em lote..."

user_map = User.pluck(:login, :id).to_h
post_ids = Post.pluck(:id)

ratings_to_create = []
batch_size = 500

post_ids.each_with_index do |post_id, index|
  next if rand > 0.75

  login = user_logins.sample
  user_id = user_map[login]
  rating_value = rand(1..5)

  ratings_to_create << {
    user_id: user_id,
    post_id: post_id,
    value: rating_value
  }

  if ratings_to_create.size == batch_size
    create_ratings_batch(ratings_to_create)
    ratings_to_create.clear
    puts "#{index} ratings criados" if (index + 1) % batch_size == 0
  end
end

unless ratings_to_create.empty?
  create_ratings_batch(ratings_to_create)
  puts "#{ratings_to_create.size} ratings criados"
end

create_ratings_batch(ratings_to_create) unless ratings_to_create.empty?

puts "=== SCRIPT FINALIZADO ==="
