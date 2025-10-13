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
```bash
git clone https://github.com/Kriticos/ctr-glpi.git ctr-glpi
cd ctr-glpi
```

### 2. Arquivo **.env**

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

## Acesso ao GLPI

Após a inicialização, você pode acessar a interface do GLPI em `http://IP_DO_DOCKER:7080`.

## Cron Jobs

Os jobs do cron estão definidos no arquivo `cron/crontab`. Você pode editá-los conforme necessário.

## Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.
