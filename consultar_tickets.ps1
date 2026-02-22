# Script de Consulta e Atualização de Tickets ITSM
# Suporte para diferentes plataformas ITSM

param(
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "$PSScriptRoot\itsm_config.json",
    
    [Parameter(Mandatory=$false)]
    [string]$TicketNumber = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Status = "",
    
    [Parameter(Mandatory=$false)]
    [string]$AssignedTo = "",
    
    [Parameter(Mandatory=$false)]
    [int]$Limit = 10,
    
    [Parameter(Mandatory=$false)]
    [switch]$ShowDetails
)

# Importar configuração
if (Test-Path $ConfigFile) {
    $config = Get-Content $ConfigFile | ConvertFrom-Json
} else {
    Write-Error "❌ Arquivo de configuração não encontrado. Execute itsm_login.ps1 primeiro."
    exit 1
}

# Headers básicos
$headers = @{
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

# Função para consultar tickets no ServiceNow
function Get-ServiceNowTickets {
    param($Config, $Headers, $TicketNumber, $Status, $Limit)
    
    $query = @()
    if ($TicketNumber) { $query += "number=$TicketNumber" }
    if ($Status) { $query += "state=$Status" }
    
    $queryString = if ($query.Count -gt 0) { "?" + ($query -join "&") + "&sysparm_limit=$Limit" } else { "?sysparm_limit=$Limit" }
    
    $uri = "$($Config.BaseURL)/api/now/table/incident$queryString"
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $Headers -Method GET
        return @{
            Success = $true
            Tickets = $response.result
            Platform = "ServiceNow"
        }
    }
    catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

# Função para consultar tickets no Jira  
function Get-JiraTickets {
    param($Config, $Headers, $TicketNumber, $Status, $Limit)
    
    $jql = @()
    if ($TicketNumber) { $jql += "key=$TicketNumber" }
    if ($Status) { $jql += "status='$Status'" }
    
    $jqlString = if ($jql.Count -gt 0) { $jql -join " AND " } else { "project IS NOT EMPTY" }
    
    $uri = "$($Config.BaseURL)/rest/api/2/search?jql=$jqlString&maxResults=$Limit"
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $Headers -Method GET
        return @{
            Success = $true
            Tickets = $response.issues
            Platform = "Jira"
        }
    }
    catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

# Função para consultar tickets no FreshService
function Get-FreshServiceTickets {
    param($Config, $Headers, $TicketNumber, $Status, $Limit)
    
    $query = @()
    if ($TicketNumber) { $query += "id:$TicketNumber" }
    if ($Status) { $query += "status:$Status" }
    
    $queryString = if ($query.Count -gt 0) { "?query=" + [System.Web.HttpUtility]::UrlEncode($query -join " AND ") } else { "" }
    
    $uri = "$($Config.BaseURL)/api/v2/tickets$queryString"
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $Headers -Method GET
        return @{
            Success = $true
            Tickets = $response.tickets
            Platform = "FreshService"
        }
    }
    catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

# Função para API de teste
function Get-TestAPITickets {
    param($Limit)
    
    try {
        $response = Invoke-RestMethod -Uri "https://jsonplaceholder.typicode.com/posts" -Headers $headers -Method GET
        $tickets = $response | Select-Object -First $Limit
        return @{
            Success = $true
            Tickets = $tickets
            Platform = "TestAPI"
        }
    }
    catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

# Função para formatar saída dos tickets
function Format-TicketOutput {
    param($Tickets, $Platform, $ShowDetails)
    
    Write-Host "`n📋 Tickets encontrados ($Platform):" -ForegroundColor Cyan
    Write-Host ("="*60) -ForegroundColor DarkGray
    
    foreach ($ticket in $Tickets) {
        switch ($Platform) {
            "ServiceNow" {
                Write-Host "🎫 $($ticket.number)" -ForegroundColor Yellow -NoNewline
                Write-Host " | Status: $($ticket.state)" -ForegroundColor White -NoNewline
                Write-Host " | Prioridade: $($ticket.priority)" -ForegroundColor Magenta
                Write-Host "   📝 $($ticket.short_description)" -ForegroundColor Gray
                
                if ($ShowDetails) {
                    Write-Host "   👤 Atribuído a: $($ticket.assigned_to.display_value)" -ForegroundColor Blue
                    Write-Host "   📅 Criado em: $($ticket.sys_created_on)" -ForegroundColor DarkBlue
                    if ($ticket.description) {
                        Write-Host "   📄 Descrição: $($ticket.description)" -ForegroundColor DarkGray
                    }
                }
            }
            "Jira" {
                Write-Host "🎫 $($ticket.key)" -ForegroundColor Yellow -NoNewline
                Write-Host " | Status: $($ticket.fields.status.name)" -ForegroundColor White -NoNewline
                Write-Host " | Prioridade: $($ticket.fields.priority.name)" -ForegroundColor Magenta
                Write-Host "   📝 $($ticket.fields.summary)" -ForegroundColor Gray
                
                if ($ShowDetails) {
                    Write-Host "   👤 Atribuído a: $($ticket.fields.assignee.displayName)" -ForegroundColor Blue
                    Write-Host "   📅 Criado em: $($ticket.fields.created)" -ForegroundColor DarkBlue
                }
            }
            "FreshService" {
                Write-Host "🎫 $($ticket.id)" -ForegroundColor Yellow -NoNewline
                Write-Host " | Status: $($ticket.status)" -ForegroundColor White -NoNewline
                Write-Host " | Prioridade: $($ticket.priority)" -ForegroundColor Magenta
                Write-Host "   📝 $($ticket.subject)" -ForegroundColor Gray
                
                if ($ShowDetails) {
                    Write-Host "   👤 Solicitante: $($ticket.requester_id)" -ForegroundColor Blue
                    Write-Host "   📅 Criado em: $($ticket.created_at)" -ForegroundColor DarkBlue
                }
            }
            "TestAPI" {
                Write-Host "🎫 TEST-$($ticket.id)" -ForegroundColor Yellow -NoNewline
                Write-Host " | User: $($ticket.userId)" -ForegroundColor White
                Write-Host "   📝 $($ticket.title)" -ForegroundColor Gray
                
                if ($ShowDetails) {
                    Write-Host "   📄 Conteúdo: $($ticket.body.Substring(0, [Math]::Min(100, $ticket.body.Length)))..." -ForegroundColor DarkGray
                }
            }
        }
        Write-Host ""
    }
}

# Main execution
Write-Host "=== Consulta de Tickets ITSM ===" -ForegroundColor Cyan
if ($TicketNumber) { Write-Host "🔍 Buscando ticket: $TicketNumber" -ForegroundColor Yellow }

$result = switch ($config.Platform) {
    "ServiceNow" { Get-ServiceNowTickets $config $headers $TicketNumber $Status $Limit }
    "Jira" { Get-JiraTickets $config $headers $TicketNumber $Status $Limit }
    "FreshService" { Get-FreshServiceTickets $config $headers $TicketNumber $Status $Limit }
    "TestAPI" { Get-TestAPITickets $Limit }
    default { 
        Write-Error "Plataforma não suportada: $($config.Platform)"
        exit 1
    }
}

if ($result.Success) {
    if ($result.Tickets.Count -eq 0) {
        Write-Host "`n🔍 Nenhum ticket encontrado com os critérios especificados." -ForegroundColor Yellow
    } else {
        Format-TicketOutput $result.Tickets $result.Platform $ShowDetails
        Write-Host "📊 Total de tickets: $($result.Tickets.Count)" -ForegroundColor Green
    }
} else {
    Write-Host "`n❌ Erro na consulta:" -ForegroundColor Red
    Write-Host $result.Error -ForegroundColor Red
    exit 1
}