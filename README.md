# Controle de Horas - CODELAB TEEN UNIFESP

Sistema inteligente para controle de horas de diferentes times.

## 🚀 Tecnologias

- Ruby 3.2.2
- Rails 7.0.8
- Vue.js 3 com Vite
- Bootstrap
- PostgreSQL
- Docker & Docker Compose

## 📋 Pré-requisitos

- Docker e Docker Compose
- Ruby 3.2.2 (recomendado usar RVM)
- Node.js 20.x

## 🔧 Instalação

1. Clone o repositório

```bash
git clone <URL-DO-REPOSITORIO>
cd <NOME-DO-DIRETORIO>
```

2. Configure o ambiente

- Crie um arquivo `.env` (pode copiar o `.env.example`) na raiz do projeto com as seguintes variáveis:

```env
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DATABASE=controle_de_horas
POSTGRES_USERNAME=myuser
POSTGRES_PASSWORD=my_password

DEVISE_JWT_SECRET_KEY=seu_token_secreto

REDIS_PASSWORD=your_redis_password
REDIS_URL=redis://:your_redis_password@redis:6379/0
```

3. Faça a build

```bash
docker-compose up --build
bundle install
npm install
rails db:reset
rails db:seed
```

4. Acesse a aplicação

- Disponível em [http://localhost:3000](http://localhost:3000)

## 👤 Usuário Padrão

Para acessar o sistema, utilize as seguintes credenciais:

- Email: john@acme.inc
- Senha: Password1!

## 📝 Notas Importantes

- Os dados do PostgreSQL são persistidos através de volumes do Docker
- O sistema utiliza autenticação JWT para segurança

## 🤝 Suporte

Em caso de dúvidas ou problemas, abra uma issue no repositório ou entre em contato com a equipe de desenvolvimento.
