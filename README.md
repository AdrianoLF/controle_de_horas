# Controle de Horas - CODELAB TEEN UNIFESP

Sistema inteligente para controle e monitoramento de horas trabalhadas por diferentes times de desenvolvimento.

## 🔗 Endpoint Público de Relatórios

O sistema oferece um endpoint público para consulta de relatórios de horas **sem necessidade de autenticação**:

- **Interface Web**: `GET /public/reports/{RA}` - Visualização completa do relatório
- **API JSON**: `GET /api/v1/public_reports/hours?ra={RA}` - Dados em formato JSON

Consulte relatórios usando apenas o RA (número de registro acadêmico) do membro

## 📖 Sobre o Projeto

O **Controle de Horas** é uma aplicação web moderna desenvolvida para auxiliar empresas e organizações no gerenciamento eficiente do tempo de trabalho de suas equipes. O sistema permite:

- 📊 **Registro de Eventos**: Controle detalhado de atividades realizadas por cada time
- 👥 **Gestão de Times**: Organização de membros em diferentes equipes com papéis específicos
- 📈 **Relatórios**: Visualização de métricas e estatísticas de produtividade
- 🔐 **Autenticação Segura**: Sistema de login com JWT para garantir segurança dos dados
- 🎯 **Multi-Team**: Suporte a eventos que envolvem múltiplos times simultaneamente

## 🚀 Tecnologias

- **Backend**: Ruby 3.2.2 + Rails 7.0.8
- **Frontend**: Vue.js 3 com Vite
- **Styling**: Bootstrap + CSS personalizado
- **Database**: PostgreSQL
- **Containerização**: Docker & Docker Compose
- **Autenticação**: Devise + JWT
- **Testes**: RSpec + FactoryBot

## 📋 Pré-requisitos

- Docker e Docker Compose instalados
- Ruby 3.2.2 (recomendado usar RVM para gerenciar versões)
- Node.js 20.x ou superior

## 🔧 Instalação

### 1. Clone o repositório

```bash
git clone <URL-DO-REPOSITORIO>
cd controle_de_horas
```

### 2. Configure o ambiente

Crie um arquivo `.env` na raiz do projeto (use o `.env.example` como base):

```env
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DATABASE=controle_de_horas
POSTGRES_USERNAME=myuser
POSTGRES_PASSWORD=my_password

DEVISE_JWT_SECRET_KEY=seu_token_secreto_aqui
```

### 3. Setup da aplicação

```bash
# Inicie os serviços do Docker (PostgreSQL)
docker-compose up -d

# Instale as dependências
bundle install
npm install

# Configure o banco de dados
rails db:create
rails db:migrate

# Caso queira popular seu banco com seeds
rails db:seed
```

### 4. Execute a aplicação

```bash
# Em um terminal, inicie o backend Rails
rails server
```

### 5. Acesse a aplicação

[http://localhost:3000](http://localhost:3000)

## 👤 Usuários de Exemplo

O sistema vem configurado com usuários de demonstração:

### Super Administrador

- **Email**: john@acme.inc
- **Senha**: Password1!
- **Permissões**: Acesso total ao sistema

### Usuário Líder

- **Email**: leader@acme.inc
- **Senha**: Password1!
- **Permissões**: Gestão de eventos

## 📝 Comandos Úteis

```bash
# Executar testes
bundle exec rspec

# Limpar e recriar banco com seeds
rails db:reset

# Console do Rails
rails console
```

## 📄 Licença

Este projeto foi desenvolvido para fins educacionais no **CODELAB TEEN UNIFESP**.

## 🤝 Suporte

Em caso de dúvidas ou problemas:

- Abra uma issue no repositório
- Consulte a documentação do Rails e Vue.js
