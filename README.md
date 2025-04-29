# post_metrics

API desenvolvida em **Ruby on Rails 8** com **PostgreSQL**, focada na criação, avaliação e geração de métricas de posts.

---

## ✨ Funcionalidades

- Criar posts
- Avaliar posts
- Obter melhores posts por média de avaliação
- Obter lista de IPs utilizados por diferentes autores

---

## 🚀 Tecnologias utilizadas

- Ruby 3.4.3
- Rails 8
- PostgreSQL
- RSpec (testes)

---

## 🔐 Configuração de variáveis de ambiente

Este projeto utiliza um arquivo `.env` para armazenar configurações sensíveis.  
Crie um arquivo `.env` na raiz do projeto com as seguintes variáveis:

```env
POSTGRES_USER=seu_usuario
POSTGRES_PASSWORD=sua_senha
POSTGRES_HOST=seu_host
POSTGRES_PORT=sua_porta_postgres

```
---

## ⚙️ Como rodar o projeto

```bash
# Clone o repositório
git clone https://github.com/biancaquintan/post_metrics.git
cd post_metrics

# Instale as dependências
bundle install

# Configure o banco de dados
rails db:create
rails db:migrate

# Rode o servidor
rails server
```

Acesse `http://localhost:3000` para usar a API.

---

## 📚 Endpoints principais

### Criar Post

- **Método:** `POST`
- **Rota:** `/api/v1/posts`
- **Descrição:** Cria um novo post associado a um usuário (criado ou recuperado pelo login).

### Listar Posts com Melhor Avaliação

- **Método:** `GET`
- **Rota:** `/api/v1/posts/top_rated`
- **Descrição:** Retorna posts ordenados pela média de avaliação. Pode receber um parâmetro `limit`.

### Listar IPs e Autores

- **Método:** `GET`
- **Rota:** `/api/v1/posts/authors_ips_list`
- **Descrição:** Retorna uma lista de IPs com os respectivos logins dos autores que postaram a partir deles.

### Avaliar Post

- **Método:** `POST`
- **Rota:** `/api/v1/ratings`
- **Descrição:** Cria uma avaliação (nota) para um post associando a um usuário e retorna a média atualizada.

---

## 🧪 Testes

Este projeto utiliza **RSpec** para testes automatizados.

### Rodar Testes

```bash
bundle exec rspec
```

