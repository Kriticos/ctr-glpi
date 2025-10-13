# Projeto GLPI com Docker Compose

Este projeto tem como objetivo facilitar a implementação do GLPI (Gestionnaire Libre de Parc Informatique) utilizando o Docker e o Docker Compose.

## Pré-requisitos

Antes de começar, verifique se você tem os seguintes itens instalados:

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/)
- [Git](https://git-scm.com/)
- Rede Docker `network-share` já criada:
- Container [ctr-mysql]() rodando

## Criar a rede externa se ainda não existir

```bash
docker network create --driver bridge network-share --subnet=172.18.0.0/16
```

### OBSERVAÇÃO

> Ajuste a subnet conforme a necessidade do seu cenário.

## Estrutura do Projeto

A estrutura do projeto é a seguinte:

```bash
ctr-glpi/
├── .env
├── .env.example
├── docker-compose.yml
└── cron/
    └── crontab
```

## Configuração

### 1. Clononando o repositório

Crie a pasta **bskp** e acesse-a:

Depois execute:

```bash
git clone https://github.com/Kriticos/ctr-glpi.git ctr-glpi
cd ctr-glpi
```

## 2. Criando a bBase de dados para o GLPI

Acesse o container do ctr-mysql e crie a base de dados para o glpi:

```bash
docker exec -it ctr-mysql mysql -u root -p
```

```sql
-- 1) Banco com charset/collation modernos
CREATE DATABASE IF NOT EXISTS glpi
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 2) Usuário (opção A: acessa de qualquer host)
CREATE USER IF NOT EXISTS 'glpi'@'%' IDENTIFIED BY 'PASSWORD';

--   (opção B: se o GLPI estiver no MESMO host do MySQL)
-- CREATE USER IF NOT EXISTS 'glpi'@'localhost' IDENTIFIED BY 'PASSWORD';

-- 3) Permissões mínimas necessárias no banco glpi
GRANT ALL PRIVILEGES ON glpi.* TO 'glpi'@'%';
-- GRANT ALL PRIVILEGES ON glpi.* TO 'glpi'@'localhost';

-- 4) Em MySQL/MariaDB atuais, FLUSH PRIVILEGES é opcional (o GRANT já recarrega)
FLUSH PRIVILEGES;

-- 5) (Comando do cliente, não é SQL do servidor)
-- exit
```

### 3. Arquivo **.env**

Na pasta /bskp/ctr-glpi, crie uma cópia do arquivo `.env.example` e renomeie-a para `.env`:

```bash
cp .env.example .env
```

>**OBS:** Edite o arquivo `.env` para configurar as variáveis de ambiente conforme necessário.**

## 3. Iniciando o container

Para iniciar todos os containers em segundo plano:

```bash
docker compose up -d
```

Verifique o status:

```bash
docker ps | grep glpi
```

Acompanhe os logs do Server:

```bash
docker logs -f ctr-glpi
```

Isso iniciará os contêineres em segundo plano.

## Acessando o glpi WEB [Troca a porta caso tenha alterado no .env]

```html
http://<IP_SERVIDOR>:7080 
```

## Voltando Backup

- Acesse a pasta do container /bskp/ctr-glpi

- Pare o container

```bash
docker compose stop
```

- Baixar o seu backup da base de dados para dentro da pasta /bskp/ctr-glpi

- Copie o arquivo **.sql** para a pasta temp dentro do container ctr-mysql

>Exemplo:

```bash
docker cp /bskp/ctr-glpi/glpi_backup_2025-10-10_22-00-01.sql ctr-mysql:/tmp/
```

### Restaurando o backup do glpi

Acesse o conteiner ctr-mysql

```bash
docker exec -it ctr-mysql bash
```

Restaure a base de dados

```bash
mysql -u glpi -p glpi < /tmp/glpi_backup_2025-10-06_22-00-01.sql
```

- Digite a senha do usuario glpi do banco de dados e aguarde o processo terminar

- Após terminar saia do container

```bash
exit
```

- Inicie o container novamente

```bash
docker compose up -d
```
