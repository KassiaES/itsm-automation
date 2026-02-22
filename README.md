# 🎫 Automação ITSM com PowerShell

Este módulo fornece scripts PowerShell para automação de sistemas ITSM (IT Service Management), com suporte para múltiplas plataformas.

## 🏢 Plataformas Suportadas

### ✅ Produção
- **ServiceNow** - Plataforma ITSM líder de mercado
- **Jira Service Management** - Solução da Atlassian
- **FreshService** - Plataforma cloud da FreshWorks

### 🧪 Teste e Desenvolvimento
- **API de Teste** - Usando JSONPlaceholder para testes sem configuração

## 🌐 Sites Públicos para Teste

| Plataforma | URL | Trial | Recursos |
|------------|-----|-------|----------|
| **ServiceNow Developer** | developer.servicenow.com | 10 dias (renovável) | Instância completa |
| **Jira Service Management** | atlassian.com/software/jira/service-management | 7 dias | Gestão completa de tickets |
| **FreshService** | freshservice.com | 21 dias | API REST completa |
| **JSONPlaceholder** | jsonplaceholder.typicode.com | Gratuito | API fake para testes |

## 📁 Estrutura dos Scripts

```powershell
itsm/
├── itsm_login.ps1          # 🔐 Login e configuração inicial
├── criar_ticket.ps1        # 🎫 Criação de tickets
├── consultar_tickets.ps1   # 📋 Consulta e listagem
├── exemplo_automacao.ps1   # 🚀 Exemplo completo
└── README.md              # 📖 Esta documentação
```

## 🚀 Guia de Uso Rápido

### 1. Primeiro Login (Teste)
```powershell
# Teste com API pública (sem configuração)
.\itsm_login.ps1 -Platform "TestAPI" -BaseURL "https://jsonplaceholder.typicode.com" -Username "test" -Password "test"
```

### 2. Login com Plataforma Real
```powershell
# ServiceNow Developer Instance
.\itsm_login.ps1 -Platform "ServiceNow" -BaseURL "https://devXXXXX.service-now.com" -Username "admin" -Password "sua_senha"

# Jira Cloud (use API Token como password)
.\itsm_login.ps1 -Platform "Jira" -BaseURL "https://empresa.atlassian.net" -Username "email@empresa.com" -Password "api_token"

# FreshService
.\itsm_login.ps1 -Platform "FreshService" -BaseURL "https://empresa.freshservice.com" -Username "email@empresa.com" -Password "senha_ou_api_key"
```

### 3. Criar Tickets
```powershell
# Incident crítico
.\criar_ticket.ps1 -TicketType "Incident" -Summary "Sistema indisponível" -Description "Falha completa do sistema principal" -Priority "Critical"

# Request de acesso
.\criar_ticket.ps1 -TicketType "Request" -Summary "Acesso ao sistema CRM" -Description "Novo funcionário precisa de acesso" -Priority "Medium"

# Problem para investigação
.\criar_ticket.ps1 -TicketType "Problem" -Summary "Lentidão recorrente" -Description "Investigar causa de performance" -Priority "High"
```

### 4. Consultar Tickets
```powershell
# Listar todos os tickets (últimos 10)
.\consultar_tickets.ps1

# Buscar ticket específico
.\consultar_tickets.ps1 -TicketNumber "INC0000123"

# Listar com detalhes completos
.\consultar_tickets.ps1 -ShowDetails -Limit 5

# Filtrar por status
.\consultar_tickets.ps1 -Status "Open" -Limit 20
```

### 5. Automação Completa
```powershell
# Executar exemplo de automação completa
.\exemplo_automacao.ps1
```

## 🔧 Configuração Detalhada

### ServiceNow Developer Instance

1. **Criar conta**: Acesse [developer.servicenow.com](https://developer.servicenow.com)
2. **Request instance**: Solicite uma instância de desenvolvimento
3. **Configure**: Use as credenciais fornecidas

```powershell
# Exemplo de configuração ServiceNow
$config = @{
    Platform = "ServiceNow"
    BaseURL = "https://dev12345.service-now.com"
    Username = "admin" 
    Password = "sua_senha_segura"
}
```

### Jira Service Management

1. **Trial gratuito**: [atlassian.com/software/jira/service-management](https://www.atlassian.com/software/jira/service-management)
2. **Create API Token**: Account Settings → Security → API Tokens
3. **Configure projeto**: Certifique-se que existe um projeto "IT" ou ajuste o código

```powershell
# Exemplo de configuração Jira
$config = @{
    Platform = "Jira"
    BaseURL = "https://minhaempresa.atlassian.net"
    Username = "[seu.email@empresa.com]"
    Password = "[seu_api_token_aqui]"  # Use API Token, não senha
}
```

### FreshService

1. **Trial gratuito**: [freshservice.com](https://freshservice.com)
2. **API Key**: Profile Settings → API Key
3. **Configure**: Use email + API Key ou email + senha

```powershell
# Exemplo de configuração FreshService
$config = @{
    Platform = "FreshService"
    BaseURL = "https://minhaempresa.freshservice.com"
    Username = "meu.email@empresa.com"
    Password = "minha_api_key"
}
```

## 📊 Tipos de Tickets Suportados

| Tipo | ServiceNow | Jira | FreshService | Uso |
|------|------------|------|--------------|-----|
| **Incident** | incident | Bug | Incident | Problema que afeta o serviço |
| **Request** | sc_request | Task | Service Request | Solicitação de serviço |
| **Problem** | problem | Bug | Problem | Investigação de causa raiz |
| **Change** | change_request | Task | Change | Mudança planejada |

## ⚡ Exemplos Práticos

### Cenário 1: Monitoramento Automatizado
```powershell
# Script para verificar tickets críticos
.\consultar_tickets.ps1 -Status "Open" | Where-Object { $_.Priority -eq "Critical" }
```

### Cenário 2: Criação em Lote
```powershell
# Criar múltiplos tickets de uma lista
$tickets = Import-Csv "tickets.csv"
foreach ($ticket in $tickets) {
    .\criar_ticket.ps1 -TicketType $ticket.Type -Summary $ticket.Summary -Description $ticket.Description -Priority $ticket.Priority
}
```

### Cenário 3: Relatório Diário
```powershell
# Gerar relatório de tickets do dia
$hoje = Get-Date -Format "yyyy-MM-dd"
.\consultar_tickets.ps1 | Where-Object { $_.CreatedDate -eq $hoje } | Export-Csv "relatorio_$hoje.csv"
```

## 🛠️ Personalização

### Adicionar Nova Plataforma

1. **Login Script**: Adicione função `Get-AuthHeaders` para nova plataforma
2. **Ticket Creation**: Implemente função `New-[Platform]Ticket`
3. **Query Script**: Adicione função `Get-[Platform]Tickets`

### Campos Personalizados

Edite os scripts para incluir campos específicos da sua organização:

```powershell
# Exemplo: adicionar campo "Department"
$body = @{
    short_description = $Summary
    description = $Description
    priority = $priorityMap[$Priority]
    category = $Category
    u_department = $Department  # Campo personalizado
} | ConvertTo-Json
```

## 🔒 Segurança

### Melhores Práticas

1. **Não hardcode credenciais** nos scripts
2. **Use variáveis de ambiente** para dados sensíveis
3. **Implemente rotação** de API tokens
4. **Log atividades** para auditoria
5. **Valide entradas** do usuário

### Exemplo Seguro
```powershell
# Usar credenciais do ambiente
$Username = $env:ITSM_USERNAME
$Password = $env:ITSM_PASSWORD
$BaseURL = $env:ITSM_URL

# Ou usar Get-Credential para entrada interativa
$credential = Get-Credential -Message "Digite suas credenciais ITSM"
```

## 📈 Monitoramento e Logs

### Habilitação de Logs
```powershell
# Adicionar ao início dos scripts
Start-Transcript -Path "$PSScriptRoot\logs\itsm_$(Get-Date -Format 'yyyyMMdd').log" -Append
```

### Métricas Básicas
- Tickets criados por hora/dia
- Tempo de resposta da API
- Taxa de sucesso/erro
- Distribuição por prioridade

## 🤝 Contribuição

### Reportar Issues
- Descreva o ambiente (plataforma, versão)
- Inclua logs de erro (sem credenciais)
- Forneça passos para reproduzir

### Sugerir Melhorias
- Novas plataformas ITSM
- Funcionalidades adicionais
- Otimizações de performance

## 📚 Recursos Adicionais

### Documentação das APIs
- [ServiceNow REST API](https://docs.servicenow.com/bundle/paris-application-development/page/integrate/inbound-rest/concept/c_RESTAPI.html)
- [Jira REST API](https://developer.atlassian.com/cloud/jira/platform/rest/v2/)
- [FreshService API](https://api.freshservice.com/)

### Ferramentas de Teste
- [Postman Collections](https://www.postman.com/) para testar APIs
- [Insomnia](https://insomnia.rest/) para desenvolvimento
- [HTTPie](https://httpie.io/) para linha de comando

## ⚠️ Troubleshooting

### Problemas Comuns

1. **Erro 401 (Unauthorized)**
   - Verifique credenciais
   - Confirme URL base
   - Teste API token (Jira)

2. **Erro 403 (Forbidden)**
   - Verifique permissões do usuário
   - Confirme licenças da plataforma

3. **Erro 404 (Not Found)**
   - Verifique URL base
   - Confirme tabelas/projetos existem

4. **Timeout de Conexão**
   - Verifique conectividade de rede
   - Confirme firewall/proxy

### Debug Mode
```powershell
# Habilitar debug verbose
$VerbosePreference = "Continue"
$DebugPreference = "Continue"
```

---

## 🎉 Começar Agora

1. **Teste rápido**: Execute `exemplo_automacao.ps1`
2. **Conecte real**: Configure sua plataforma ITSM preferida  
3. **Personalize**: Adapte os scripts às suas necessidades
4. **Automatize**: Integre com seus processos existentes

**🚀 Automação ITSM nunca foi tão fácil!**