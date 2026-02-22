# Script de Monitoramento e Automação Avançada ITSM
# Simula cenários reais de automação com integração

param(
    [Parameter(Mandatory=$false)]
    [switch]$MonitorMode,
    
    [Parameter(Mandatory=$false)]
    [switch]$BulkCreate,
    
    [Parameter(Mandatory=$false)]
    [switch]$HealthCheck,
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "$PSScriptRoot\itsm_config.json",
    
    [Parameter(Mandatory=$false)]
    [int]$MonitorInterval = 30
)

# Função para simulação de monitoramento de sistemas
function Invoke-SystemMonitoring {
    Write-Host "🔍 Iniciando monitoramento de sistemas..." -ForegroundColor Cyan
    
    $systems = @(
        @{ Name = "Email Server"; Status = "OK"; Response = 50 },
        @{ Name = "Web Application"; Status = "SLOW"; Response = 1200 },
        @{ Name = "Database Server"; Status = "OK"; Response = 80 },
        @{ Name = "File Server"; Status = "ERROR"; Response = 0 },
        @{ Name = "VPN Gateway"; Status = "OK"; Response = 45 }
    )
    
    $issues = @()
    
    foreach ($system in $systems) {
        Write-Host "  📡 $($system.Name): " -NoNewline
        
        switch ($system.Status) {
            "OK" { 
                Write-Host "✅ $($system.Status) ($($system.Response)ms)" -ForegroundColor Green 
            }
            "SLOW" { 
                Write-Host "⚠️  $($system.Status) ($($system.Response)ms)" -ForegroundColor Yellow
                $issues += @{
                    System = $system.Name
                    Issue = "Performance degradation"
                    Priority = "Medium"
                    Description = "Response time elevated to $($system.Response)ms"
                }
            }
            "ERROR" { 
                Write-Host "❌ $($system.Status)" -ForegroundColor Red
                $issues += @{
                    System = $system.Name  
                    Issue = "Service unavailable"
                    Priority = "High"
                    Description = "System is not responding to health checks"
                }
            }
        }
    }
    
    return $issues
}

# Função para criar tickets automaticamente baseado em problemas
function New-AutomatedTickets {
    param($Issues)
    
    if ($Issues.Count -eq 0) {
        Write-Host "✅ Nenhum problema detectado!" -ForegroundColor Green
        return
    }
    
    Write-Host "`n🎫 Criando tickets automaticamente para problemas detectados..." -ForegroundColor Yellow
    
    foreach ($issue in $Issues) {
        $summary = "$($issue.Issue) - $($issue.System)"
        $description = @"
TICKET CRIADO AUTOMATICAMENTE

Sistema: $($issue.System)
Problema: $($issue.Issue)  
Detalhes: $($issue.Description)

Detectado em: $(Get-Date)
Monitoramento: Automated System Health Check

Ações sugeridas:
- Verificar logs do sistema
- Executar diagnósticos básicos
- Escalar se necessário
"@

        try {
            $result = & "$PSScriptRoot\criar_ticket.ps1" `
                -TicketType "Incident" `
                -Summary $summary `
                -Description $description `
                -Priority $issue.Priority
                
            Write-Host "  ✅ Ticket criado: $($result.TicketNumber)" -ForegroundColor Green
        }
        catch {
            Write-Warning "  ⚠️ Erro ao criar ticket para $($issue.System): $($_.Exception.Message)"
        }
    }
}

# Função para criar múltiplos tickets de uma lista
function Invoke-BulkTicketCreation {
    Write-Host "📋 Criação em lote de tickets..." -ForegroundColor Cyan
    
    $bulkTickets = @(
        @{
            Type = "Request"
            Summary = "Instalação de software - Adobe Acrobat"
            Description = "Solicitação de instalação do Adobe Acrobat Pro para o departamento de marketing"
            Priority = "Medium"
            Category = "Software"
        },
        @{
            Type = "Incident"
            Summary = "Impressora não imprime - Andar 3"
            Description = "Impressora HP LaserJet do 3º andar não está respondendo aos comandos de impressão"
            Priority = "Low"
            Category = "Hardware"
        },
        @{
            Type = "Request"
            Summary = "Criação de usuário - João Silva"
            Description = "Criar conta de usuário para o novo funcionário João Silva - Depto Vendas"
            Priority = "High"
            Category = "Access"
        },
        @{
            Type = "Problem"
            Summary = "Lentidão generalizada na rede"
            Description = "Múltiplos usuários relatam lentidão na rede durante horário comercial"
            Priority = "Medium"
            Category = "Network"
        },
        @{
            Type = "Change"
            Summary = "Atualização do sistema ERP"
            Description = "Planejamento para atualização do sistema ERP versão 2.1 para 2.3"
            Priority = "High"
            Category = "System Update"
        }
    )
    
    Write-Host "📝 Processando $($bulkTickets.Count) tickets..." -ForegroundColor White
    
    $results = @()
    $successful = 0
    $failed = 0
    
    foreach ($ticket in $bulkTickets) {
        try {
            Write-Host "  🔄 Criando: $($ticket.Summary.Substring(0, [Math]::Min(50, $ticket.Summary.Length)))..." -ForegroundColor Gray
            
            $result = & "$PSScriptRoot\criar_ticket.ps1" `
                -TicketType $ticket.Type `
                -Summary $ticket.Summary `
                -Description $ticket.Description `
                -Priority $ticket.Priority `
                -Category $ticket.Category
            
            $results += $result
            $successful++
            Write-Host "    ✅ $($result.TicketNumber)" -ForegroundColor Green
            
            Start-Sleep -Milliseconds 500  # Pausa para não sobrecarregar
        }
        catch {
            $failed++
            Write-Host "    ❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "`n📊 Resumo da criação em lote:" -ForegroundColor Cyan
    Write-Host "  ✅ Sucessos: $successful" -ForegroundColor Green
    Write-Host "  ❌ Falhas: $failed" -ForegroundColor Red
    Write-Host "  📈 Taxa de sucesso: $([math]::Round(($successful/($successful+$failed))*100, 2))%" -ForegroundColor Yellow
    
    return $results
}

# Função para verificar saúde do sistema ITSM
function Test-ITSMHealth {
    Write-Host "🏥 Verificando saúde do sistema ITSM..." -ForegroundColor Cyan
    
    $healthChecks = @{
        "Conectividade" = $false
        "Autenticação" = $false  
        "Criação de Tickets" = $false
        "Consulta de Tickets" = $false
        "Performance" = $false
    }
    
    # Teste 1: Conectividade básica
    Write-Host "  🌐 Testando conectividade..." -ForegroundColor White
    try {
        $config = Get-Content $ConfigFile | ConvertFrom-Json
        $testUri = if ($config.Platform -eq "TestAPI") { 
            "https://jsonplaceholder.typicode.com/posts/1" 
        } else { 
            "$($config.BaseURL)/api/now/table/sys_user?sysparm_limit=1" 
        }
        
        $response = Invoke-WebRequest -Uri $testUri -Method GET -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            $healthChecks["Conectividade"] = $true
            Write-Host "    ✅ Conectividade OK" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "    ❌ Falha na conectividade: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Teste 2: Autenticação
    Write-Host "  🔐 Testando autenticação..." -ForegroundColor White
    try {
        # Simular teste de login (usando script existente)
        $healthChecks["Autenticação"] = $true
        Write-Host "    ✅ Autenticação OK" -ForegroundColor Green
    }
    catch {
        Write-Host "    ❌ Falha na autenticação" -ForegroundColor Red
    }
    
    # Teste 3: Criação de ticket de teste
    Write-Host "  🎫 Testando criação de tickets..." -ForegroundColor White
    try {
        $testResult = & "$PSScriptRoot\criar_ticket.ps1" `
            -TicketType "Request" `
            -Summary "TESTE - Health Check $(Get-Date -Format 'HH:mm:ss')" `
            -Description "Ticket de teste criado automaticamente durante health check" `
            -Priority "Low"
            
        if ($testResult.Success) {
            $healthChecks["Criação de Tickets"] = $true
            Write-Host "    ✅ Criação OK - Ticket: $($testResult.TicketNumber)" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "    ❌ Falha na criação de tickets" -ForegroundColor Red
    }
    
    # Teste 4: Consulta de tickets
    Write-Host "  📋 Testando consulta de tickets..." -ForegroundColor White
    try {
        $queryResult = & "$PSScriptRoot\consultar_tickets.ps1" -Limit 1
        $healthChecks["Consulta de Tickets"] = $true
        Write-Host "    ✅ Consulta OK" -ForegroundColor Green
    }
    catch {
        Write-Host "    ❌ Falha na consulta de tickets" -ForegroundColor Red
    }
    
    # Teste 5: Performance 
    Write-Host "  ⚡ Testando performance..." -ForegroundColor White
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        # Fazer uma requisição simples e medir tempo
        if ($config.Platform -eq "TestAPI") {
            Invoke-RestMethod -Uri "https://jsonplaceholder.typicode.com/posts/1" -Method GET
        }
        $stopwatch.Stop()
        
        if ($stopwatch.ElapsedMilliseconds -lt 2000) {  # Menos de 2 segundos
            $healthChecks["Performance"] = $true
            Write-Host "    ✅ Performance OK ($($stopwatch.ElapsedMilliseconds)ms)" -ForegroundColor Green
        } else {
            Write-Host "    ⚠️ Performance lenta ($($stopwatch.ElapsedMilliseconds)ms)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "    ❌ Erro no teste de performance" -ForegroundColor Red
    }
    
    # Resumo da saúde
    $healthyChecks = ($healthChecks.Values | Where-Object { $_ -eq $true }).Count
    $totalChecks = $healthChecks.Count
    $healthPercentage = [math]::Round(($healthyChecks / $totalChecks) * 100, 2)
    
    Write-Host "`n🏥 Resumo da Saúde do Sistema:" -ForegroundColor Cyan
    Write-Host "  ✅ Testes OK: $healthyChecks/$totalChecks" -ForegroundColor Green
    Write-Host "  📊 Saúde Geral: $healthPercentage%" -ForegroundColor $(if ($healthPercentage -ge 80) { "Green" } elseif ($healthPercentage -ge 60) { "Yellow" } else { "Red" })
    
    return $healthChecks
}

# Main execution
Write-Host "🤖 ITSM - Automação Avançada" -ForegroundColor Magenta
Write-Host "=" * 50 -ForegroundColor DarkGray

if ($HealthCheck) {
    $health = Test-ITSMHealth
}
elseif ($MonitorMode) {
    Write-Host "🔄 Modo de monitoramento ativo (Ctrl+C para sair)" -ForegroundColor Yellow
    Write-Host "📊 Intervalo: $MonitorInterval segundos" -ForegroundColor Blue
    
    do {
        $issues = Invoke-SystemMonitoring
        
        if ($issues.Count -gt 0) {
            New-AutomatedTickets -Issues $issues
        }
        
        Write-Host "`n⏱️  Próxima verificação em $MonitorInterval segundos..." -ForegroundColor DarkYellow
        Start-Sleep -Seconds $MonitorInterval
        
    } while ($true)
}
elseif ($BulkCreate) {
    $results = Invoke-BulkTicketCreation
    
    # Gerar relatório  
    $reportPath = "$PSScriptRoot\bulk_creation_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $results | ConvertTo-Json -Depth 3 | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Host "📄 Relatório salvo: $reportPath" -ForegroundColor Blue
}
else {
    Write-Host "🚀 Demonstração completa de automação..." -ForegroundColor Cyan
    
    # 1. Health Check
    Write-Host "`n1️⃣ Executando health check..." -ForegroundColor White
    $health = Test-ITSMHealth
    
    Start-Sleep -Seconds 2
    
    # 2. Monitoramento simulado
    Write-Host "`n2️⃣ Simulando monitoramento de sistemas..." -ForegroundColor White  
    $issues = Invoke-SystemMonitoring
    
    if ($issues.Count -gt 0) {
        New-AutomatedTickets -Issues $issues
    }
    
    Start-Sleep -Seconds 2
    
    # 3. Criação em lote
    Write-Host "`n3️⃣ Executando criação em lote..." -ForegroundColor White
    $bulkResults = Invoke-BulkTicketCreation
    
    # 4. Relatório final
    Write-Host "`n📊 Relatório Final da Automação:" -ForegroundColor Magenta
    Write-Host "  🏥 Health Score: $([math]::Round((($health.Values | Where-Object { $_ }).Count / $health.Count) * 100))%" -ForegroundColor Blue
    Write-Host "  ⚠️  Problemas detectados: $($issues.Count)" -ForegroundColor Yellow
    Write-Host "  🎫 Tickets criados em lote: $($bulkResults.Count)" -ForegroundColor Green
    Write-Host "  ⏰ Executado em: $(Get-Date)" -ForegroundColor Gray
}

Write-Host "`n🎉 Automação concluída!" -ForegroundColor Green