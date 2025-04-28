
# Descontos do INSS - Teste Técnico

Este é um teste técnico para desenvolver uma aplicação de descontos do INSS. Utilizei Ruby on Rails como backend. O projeto visa demonstrar o conhecimento técnico com Rails, e ferramentas complementares. A aplicação utiliza Bootstrap para estilização e Chart.js para renderizar gráficos interativos.

---

## Tecnologias Utilizadas

- **Ruby**: 3.2.2
- **Rails**: 7.0.8
- **Frontend**: Vite com Vue.js
- **Estilização**: Bootstrap
- **Gráficos**: Chart.js
- **Banco de Dados**: PostgreSQL
- **Mensageria**: Redis + Sidekiq
- **Containerização**: Docker & Docker Compose

---

## Passos para Configurar e Rodar a Aplicação

### Pré-requisitos

1. Certifique-se de que o Docker e o Docker Compose estão instalados:
   - [Instalar Docker](https://www.docker.com/get-started)
   - [Instalar Docker Compose](https://docs.docker.com/compose/install/)

2. Clone o repositório e entre no diretório do projeto:
   ```bash
   git clone <URL-DO-REPOSITORIO>
   cd <NOME-DO-DIRETORIO>
   ```

3. Configure o arquivo `.env`:
   - Na raiz do projeto, crie um arquivo `.env` com as seguintes variáveis de ambiente (exemplo abaixo).

4. Suba os containers utilizando o Docker Compose:
   ```bash
   docker-compose up --build
   ```

5. Acesse o serviço:
   - A aplicação estará disponível em [http://localhost:3000](http://localhost:3000).

6. Acesso ao Sidekiq:
   - Navegue até [http://localhost:3000/sidekiq](http://localhost:3000/sidekiq) para monitorar as filas de tarefas.

7. Acesso ao Vite (Frontend):
   - Acesse [http://localhost:5173](http://localhost:5173) para visualizar o frontend da aplicação.

---

## Exemplo do Arquivo `.env`

```env
POSTGRES_USERNAME=admin
POSTGRES_PASSWORD=admin123
POSTGRES_DATABASE=desconto_inss
POSTGRES_PORT=5432
POSTGRES_HOST=desconto_inss_db

REDIS_PASSWORD=redispass123
REDIS_URL=redis://:redispass123@redis:6379/0

RAILS_ENV=development
NODE_ENV=development
```

---

## Notas Adicionais

- **Volumes Persistentes**:
  - O Docker Compose está configurado para persistir os dados do PostgreSQL e Redis utilizando volumes nomeados (`postgres_data` e `redis_data`), garantindo que os dados não sejam perdidos ao reiniciar os containers.

- **Seed Inicial**:
  - A aplicação já possui um usuário de seed:
    ```
    Email: john@acme.inc
    Senha: Password1!
    ```

- **Variáveis de Ambiente**:
  - As variáveis de ambiente são gerenciadas através do arquivo `.env`, que deve conter todas as configurações sensíveis e específicas do ambiente.

Se tiver qualquer dúvida ou precisar de ajuda adicional, sinta-se à vontade para abrir uma issue ou entrar em contato!