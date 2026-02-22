# Exemplo de Automação ITSM Completa
# Este script demonstra um fluxo completo de automação

# 1. CONFIGURAR AMBIENTE DE TESTE
Write-Host "🔧 Configurando ambiente de teste ITSM..." -ForegroundColor Cyan

# Para teste com API pública (sem autenticação real)
$testConfig = @{
    Platform = "TestAPI"
    BaseURL = "https://jsonplaceholder.typicode.com"
    Username = "test"
    Password = "test"
}

# Para uso real, descomente uma das opções abaixo:

# ServiceNow Developer Instance
# $realConfig = @{
#     Platform = "ServiceNow" 
#     BaseURL = "https://devXXXXX.service-now.com"
#     Username = "admin"
#     Password = "sua_senha"
# }

# Jira Cloud
# $realConfig = @{
#     Platform = "Jira"
#     BaseURL = "https://suaempresa.atlassian.net"
#     Username = "seu_email@empresa.com"
#     Password = "seu_api_token"
# }

# FreshService
# $realConfig = @{
#     Platform = "FreshService"
#     BaseURL = "https://suaempresa.freshservice.com"
#     Username = "seu_email@empresa.com"
#     Password = "sua_senha"
# }

# 2. FAZER LOGIN
Write-Host "`n🔐 Realizando login..." -ForegroundColor Yellow

try {
    $loginResult = & "$PSScriptRoot\itsm_login.ps1" `
        -Platform $testConfig.Platform `
        -BaseURL $testConfig.BaseURL `
        -Username $testConfig.Username `
        -Password $testConfig.Password
    
    Write-Host "✅ Login realizado com sucesso!" -ForegroundColor Green
}
catch {
    Write-Error "❌ Erro no login: $($_.Exception.Message)"
    exit 1
}

# 3. CRIAR TICKETS DE EXEMPLO
Write-Host "`n🎫 Criando tickets de exemplo..." -ForegroundColor Cyan

$tickets = @(
    @{
        Type = "Incident"
        Summary = "Sistema de email indisponível"
        Description = "Usuários relatam que não conseguem enviar emails desde as 09:00"
        Priority = "High"
        Category = "Email"
    },
    @{
        Type = "Request"
        Summary = "Solicitação de acesso ao sistema CRM"
        Description = "Novo funcionário precisa de acesso ao sistema CRM para iniciar suas atividades"
        Priority = "Medium"
        Category = "Access"
    },
    @{
        Type = "Problem"
        Summary = "Lentidão recorrente no sistema de vendas"
        Description = "Investigar causa da lentidão no sistema de vendas que afeta múltiplos usuários"
        Priority = "Medium"
        Category = "Performance"
    }
)

$createdTickets = @()

foreach ($ticketData in $tickets) {
    try {
        Write-Host "  📝 Criando: $($ticketData.Summary)" -ForegroundColor White
        
        $result = & "$PSScriptRoot\criar_ticket.ps1" `
            -TicketType $ticketData.Type `
            -Summary $ticketData.Summary `
            -Description $ticketData.Description `
            -Priority $ticketData.Priority `
            -Category $ticketData.Category
        
        $createdTickets += $result
        Write-Host "    ✅ Ticket $($result.TicketNumber) criado!" -ForegroundColor Green
        
        Start-Sleep -Seconds 1  # Pausa para não sobrecarregar a API
    }
    catch {
        Write-Warning "⚠️ Erro ao criar ticket: $($_.Exception.Message)"
    }
}

# 4. CONSULTAR TICKETS CRIADOS  
Write-Host "`n📋 Consultando tickets criados..." -ForegroundColor Cyan

try {
    & "$PSScriptRoot\consultar_tickets.ps1" -ShowDetails -Limit 5
}
catch {
    Write-Warning "⚠️ Erro na consulta: $($_.Exception.Message)"
}

# 5. DEMONSTRAR RELATÓRIO
Write-Host "`n📊 Gerando relatório de atividades..." -ForegroundColor Magenta

$report = @{
    Timestamp = Get-Date
    TicketsCreated = $createdTickets.Count
    Platform = $testConfig.Platform
    Summary = @()
}

foreach ($ticket in $createdTickets) {
    if ($ticket.Success) {
        $report.Summary += @{
            Number = $ticket.TicketNumber
            ID = $ticket.TicketId
            Status = "Created"
        }
    }
}

$reportPath = "$PSScriptRoot\automation_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
$report | ConvertTo-Json -Depth 3 | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "📄 Relatório salvo em: $reportPath" -ForegroundColor Blue

# 6. SIMULAÇÃO DE MONITORAMENTO
Write-Host "`n🔍 Simulando monitoramento de tickets..." -ForegroundColor Yellow

for ($i = 1; $i -le 3; $i++) {
    Write-Host "  🔄 Verificação $i/3..." -ForegroundColor White
    
    # Simular verificação de status
    $randomTicket = Get-Random -InputObject $createdTickets
    if ($randomTicket -and $randomTicket.Success) {
        Write-Host "    📋 Ticket $($randomTicket.TicketNumber): Status OK" -ForegroundColor Green
    }
    
    Start-Sleep -Seconds 2
}

# 7. EXEMPLO DE INTEGRAÇÃO COM OUTRAS FERRAMENTAS
Write-Host "`n🔗 Exemplo de integração..." -ForegroundColor Cyan

# Simular envio de notificação (placeholder)
$notificationData = @{
    Message = "Automação ITSM concluída. $($createdTickets.Count) tickets criados."
    Timestamp = Get-Date
    Platform = $testConfig.Platform
}

Write-Host "📧 Notificação: $($notificationData.Message)" -ForegroundColor Magenta

# 8. LIMPEZA E FINALIZAÇÃO
Write-Host "`n🧹 Finalizando automação..." -ForegroundColor DarkYellow

$summary = @"

=== RESUMO DA AUTOMAÇÃO ITSM ===
✅ Plataforma testada: $($testConfig.Platform)
🎫 Tickets criados: $($createdTickets.Count)
📄 Relatório: $reportPath
⏰ Concluído em: $(Get-Date)

Para usar com plataforma real:
1. Edite as configurações no topo do arquivo
2. Descomente a configuração desejada
3. Execute novamente o script

"@

Write-Host $summary -ForegroundColor White

Write-Host "🎉 Automação ITSM concluída com sucesso!" -ForegroundColor Green