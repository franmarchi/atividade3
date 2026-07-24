# Deploy de Infraestrutura como Código utilizando Terraform e GitHub Actions

## Sobre o projeto

Este projeto tem como objetivo automatizar o provisionamento de infraestrutura na Amazon Web Services (AWS) utilizando **Terraform** e **GitHub Actions**.

Toda a infraestrutura é definida como código (Infrastructure as Code - IaC), permitindo que qualquer pessoa possa criar o ambiente completo apenas executando o pipeline ou os comandos do Terraform.

Além disso, foi implementado um processo de **Integração Contínua e Deploy Contínuo (CI/CD)**, onde qualquer alteração enviada para a branch principal do repositório dispara automaticamente o pipeline responsável pela criação ou atualização da infraestrutura.

---

# Objetivos

Este projeto foi desenvolvido para demonstrar a utilização de:

- Infrastructure as Code (IaC)
- Terraform
- GitHub Actions
- Amazon Web Services (AWS)
- CI/CD
- GitHub Secrets

---

# Arquitetura da solução

A infraestrutura criada é composta pelos seguintes recursos:

- Virtual Private Cloud (VPC)
- Internet Gateway
- Route Table
- Duas Subnets Públicas
- Security Group
- Instância EC2
- Application Load Balancer (ALB)
- Target Group
- Listener HTTP
- Banco de Dados Amazon RDS MySQL

Fluxo da infraestrutura:

```
Internet

↓

Application Load Balancer

↓

EC2

↓

Banco de Dados RDS
```

---

# Tecnologias utilizadas

- Terraform
- GitHub Actions
- Amazon Web Services (AWS)
- EC2
- VPC
- Application Load Balancer
- RDS MySQL
- Git
- GitHub

---

# Estrutura do projeto

```
ATIVIDADE3
│
├── .github
│   └── workflows
│       └── deploy.yaml
│
├── .terraform
│
├── .gitignore
├── .terraform.lock.hcl
├── main.tf
├── outputs.tf
├── README.md
├── terraform.tfstate
└── terraform.tfstate.backup
```

Descrição dos principais arquivos:

| Arquivo | Descrição |
|----------|-----------|
| main.tf | Define toda a infraestrutura AWS |
| outputs.tf | Exibe informações importantes após o deploy |
| deploy.yaml | Workflow responsável pelo pipeline CI/CD |
| README.md | Documentação do projeto |

---

# Pré-requisitos

Antes de executar este projeto é necessário possuir:

- Conta na AWS
- Terraform instalado
- Git instalado
- Conta no GitHub
- Visual Studio Code (opcional)

---

# Clonando o projeto

Clone o repositório:

```bash
git clone https://github.com/franmarchi/atividade3.git
```

Entre na pasta:

```bash
cd atividade3
```

---

# Configuração da AWS

É necessário configurar as credenciais da AWS.

Existem duas formas:

## Opção 1 - AWS CLI

Execute:

```bash
aws configure
```

Informe:

```
AWS Access Key ID
AWS Secret Access Key
Region
Output Format
```

---

## Opção 2 - GitHub Secrets

Criar os seguintes Secrets no repositório:

```
AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

AWS_REGION
```

Essas credenciais serão utilizadas automaticamente pelo GitHub Actions durante o pipeline.

---

# Executando localmente

Inicializar o Terraform:

```bash
terraform init
```

Validar a configuração:

```bash
terraform validate
```

Visualizar as alterações:

```bash
terraform plan
```

Aplicar a infraestrutura:

```bash
terraform apply
```

Caso seja solicitado, digite:

```
yes
```

---

# Pipeline CI/CD

O pipeline foi implementado utilizando GitHub Actions.


Arquivo responsável:

```
.github/workflows/deploy.yaml
```

O workflow é executado automaticamente quando ocorre:

- Push na branch main
- Pull Request para a branch main

Durante sua execução são realizadas as seguintes etapas.

## 1. Checkout

Obtém o código do repositório.

---

## 2. Configuração das credenciais AWS

As credenciais armazenadas no GitHub Secrets são carregadas para autenticação na AWS.

---

## 3. Instalação do Terraform

Instala automaticamente a versão necessária do Terraform.

---

## 4. Terraform Init

Inicializa o ambiente.

Realiza o download dos providers necessários.

---

## 5. Terraform Validate

Verifica se a sintaxe dos arquivos Terraform está correta.

---

## 6. Terraform Plan

Analisa a infraestrutura atual.

Compara com os arquivos do projeto.

Exibe quais recursos serão criados, modificados ou removidos.

---

## 7. Upload do Artifact

O plano gerado pelo Terraform é armazenado como Artifact do GitHub Actions.

---

## 8. Terraform Apply

Aplica automaticamente todas as alterações na infraestrutura AWS.

---

# GitHub Actions

O pipeline pode ser acompanhado na aba:

```
Actions
```

Cada execução apresenta logs detalhados de todas as etapas realizadas.

Também é possível visualizar:

- tempo de execução;
- logs;
- artifacts;
- histórico das execuções.

---

# Recursos criados

Após a execução do Terraform são criados automaticamente:

- VPC
- Internet Gateway
- Route Table
- Subnet Pública 1
- Subnet Pública 2
- Security Group
- EC2
- Target Group
- Application Load Balancer
- Listener HTTP
- Banco de Dados RDS

---

# Boas práticas adotadas

Durante o desenvolvimento foram utilizadas algumas boas práticas:

- Versionamento utilizando Git.
- Pipeline automatizado utilizando GitHub Actions.
- Credenciais protegidas através de GitHub Secrets.
- Organização do código em Terraform.
- Utilização de arquivos ignorados pelo Git através do .gitignore.
- Utilização de Infrastructure as Code para facilitar manutenção e reprodutibilidade.

---

# Como reproduzir este projeto

1. Clonar o repositório.

2. Configurar as credenciais da AWS.

3. Executar:

```bash
terraform init
```

4.

```bash
terraform validate
```

5.

```bash
terraform plan
```

6.

```bash
terraform apply
```

ou simplesmente realizar um:

```bash
git push origin main
```

O GitHub Actions executará automaticamente todas as etapas do deploy.

---

# Resultado esperado

Ao término da execução será possível visualizar na AWS:

- VPC criada;
- Subnets públicas;
- Internet Gateway;
- Security Group;
- Instância EC2 em execução;
- Application Load Balancer ativo;
- Banco de Dados RDS disponível.

Além disso, no GitHub será possível acompanhar toda a execução do pipeline através da aba **Actions**.

---

# Considerações finais

A utilização do Terraform em conjunto com o GitHub Actions possibilita automatizar completamente o processo de provisionamento da infraestrutura.

Essa abordagem reduz erros manuais, aumenta a padronização do ambiente e facilita futuras alterações, uma vez que toda a infraestrutura permanece documentada e versionada como código.