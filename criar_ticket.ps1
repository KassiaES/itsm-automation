# Script de Automação para Criação de Tickets ITSM
# Suporte para diferentes plataformas ITSM

param(
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "$PSScriptRoot\itsm_config.json",
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("Incident", "Request", "Problem", "Change")]
    [string]$TicketType,
    
    [Parameter(Mandatory=$true)]
    [string]$Summary,
    
    [Parameter(Mandatory=$true)]
    [string]$Description,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Low", "Medium", "High", "Critical")]
    [string]$Priority = "Medium",
    
    [Parameter(Mandatory=$false)]
    [string]$Category = "General",
    
    [Parameter(Mandatory=$false)]
    [string]$AssignedTo = ""
)

# Importar configuração
if (Test-Path $ConfigFile) {
    $config = Get-Content $ConfigFile | ConvertFrom-Json
    Write-Host "✅ Configuração carregada: $($config.Platform)" -ForegroundColor Green
} else {
    Write-Error "❌ Arquivo de configuração não encontrado. Execute itsm_login.ps1 primeiro."
    exit 1
}

# Recriar headers de autenticação (simplificado para este exemplo)
$headers = @{
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

# Função para criar ticket no ServiceNow
function New-ServiceNowTicket {
    param($Config, $Headers, $TicketType, $Summary, $Description, $Priority, $Category)
    
    $table = switch ($TicketType) {
        "Incident" { "incident" }
        "Request" { "sc_request" }
        "Problem" { "problem" }
        "Change" { "change_request" }
    }
    
    $priorityMap = @{
        "Low" = "4"
        "Medium" = "3"
        "High" = "2"
        "Critical" = "1"
    }
    
    $body = @{
        short_description = $Summary
        description = $Description
        priority = $priorityMap[$Priority]
        category = $Category
    } | ConvertTo-Json
    
    $uri = "$($Config.BaseURL)/api/now/table/$table"
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $Headers -Method POST -Body $body
        return @{
            Success = $true
            TicketNumber = $response.result.number
            TicketId = $response.result.sys_id
            Platform = "ServiceNow"
        }
    }
    catch {
        return @{ 
            Success = $false 
            Error = $_.Exception.Message 
        }
    }
}

# Função para criar ticket no Jira
function New-JiraTicket {
    param($Config, $Headers, $TicketType, $Summary, $Description, $Priority)
    
    $issueType = switch ($TicketType) {
        "Incident" { "Bug" }
        "Request" { "Task" }
        "Problem" { "Bug" }
        "Change" { "Task" }
    }
    
    $body = @{
        fields = @{
            project = @{ key = "IT" }  # Ajuste conforme seu projeto
            summary = $Summary
            description = $Description
            issuetype = @{ name = $issueType }
            priority = @{ name = $Priority }
        }
    } | ConvertTo-Json -Depth 3
    
    $uri = "$($Config.BaseURL)/rest/api/2/issue"
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $Headers -Method POST -Body $body
        return @{
            Success = $true
            TicketNumber = $response.key
            TicketId = $response.id
            Platform = "Jira"
        }
    }
    catch {
        return @{ 
            Success = $false 
            Error = $_.Exception.Message 
        }
    }
}

# Função para criar ticket no FreshService
function New-FreshServiceTicket {
    param($Config, $Headers, $TicketType, $Summary, $Description, $Priority)
    
    $priorityMap = @{
        "Low" = 1
        "Medium" = 2
        "High" = 3
        "Critical" = 4
    }
    
    $body = @{
        subject = $Summary
        description = $Description
        priority = $priorityMap[$Priority]
        status = 2  # Open
        type = $TicketType
    } | ConvertTo-Json
    
    $uri = "$($Config.BaseURL)/api/v2/tickets"
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $Headers -Method POST -Body $body
        return @{
            Success = $true
            TicketNumber = $response.ticket.id
            TicketId = $response.ticket.id
            Platform = "FreshService"
        }
    }
    catch {
        return @{ 
            Success = $false 
            Error = $_.Exception.Message 
        }
    }
}

# Função para API de teste
function New-TestAPITicket {
    param($Summary, $Description, $Priority)
    
    $body = @{
        title = $Summary
        body = $Description
        userId = 1
        priority = $Priority
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "https://jsonplaceholder.typicode.com/posts" -Headers $headers -Method POST -Body $body
        return @{
            Success = $true
            TicketNumber = "TEST-$($response.id)"
            TicketId = $response.id
            Platform = "TestAPI"
        }
    }
    catch {
        return @{ 
            Success = $false 
            Error = $_.Exception.Message 
        }
    }
}

# Main execution
Write-Host "=== Criação de Ticket ITSM ===" -ForegroundColor Cyan
Write-Host "Tipo: $TicketType | Prioridade: $Priority" -ForegroundColor Yellow
Write-Host "Resumo: $Summary" -ForegroundColor White

$result = switch ($config.Platform) {
    "ServiceNow" { New-ServiceNowTicket $config $headers $TicketType $Summary $Description $Priority $Category }
    "Jira" { New-JiraTicket $config $headers $TicketType $Summary $Description $Priority }
    "FreshService" { New-FreshServiceTicket $config $headers $TicketType $Summary $Description $Priority }
    "TestAPI" { New-TestAPITicket $Summary $Description $Priority }
    default { 
        Write-Error "Plataforma não suportada: $($config.Platform)"
        exit 1
    }
}

if ($result.Success) {
    Write-Host "`n✅ Ticket criado com sucesso!" -ForegroundColor Green
    Write-Host "🎫 Número do Ticket: $($result.TicketNumber)" -ForegroundColor Cyan
    Write-Host "🆔 ID do Sistema: $($result.TicketId)" -ForegroundColor Blue
    Write-Host "🏢 Plataforma: $($result.Platform)" -ForegroundColor Magenta
    
    # Salvar informações do ticket
    $ticketInfo = @{
        TicketNumber = $result.TicketNumber
        TicketId = $result.TicketId
        Platform = $result.Platform
        Type = $TicketType
        Summary = $Summary
        Priority = $Priority
        CreatedAt = Get-Date
    }
    
    $ticketPath = "$PSScriptRoot\last_ticket.json"
    $ticketInfo | ConvertTo-Json | Out-File -FilePath $ticketPath -Encoding UTF8
    
    return $result
}
else {
    Write-Host "`n❌ Erro ao criar ticket:" -ForegroundColor Red
    Write-Host $result.Error -ForegroundColor Red
    exit 1
}