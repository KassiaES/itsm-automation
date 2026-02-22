# Script de Login e Automação ITSM
# Suporte para ServiceNow, Jira Service Management, FreshService

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("ServiceNow", "Jira", "FreshService", "TestAPI")]
    [string]$Platform,
    
    [Parameter(Mandatory=$true)]
    [string]$BaseURL,
    
    [Parameter(Mandatory=$true)]
    [string]$Username,
    
    [Parameter(Mandatory=$true)]
    [SecureString]$Password,
    
    [Parameter(Mandatory=$false)]
    [string]$Domain = ""
)

# Função para criar headers de autenticação
function Get-AuthHeaders {
    param($Platform, $Username, [SecureString]$Password)
    
    switch ($Platform) {
        "ServiceNow" {
            $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
            $base64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${Username}:${plainPassword}"))
            return @{
                "Authorization" = "Basic $base64"
                "Content-Type" = "application/json"
                "Accept" = "application/json"
            }
        }
        "Jira" {
            $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
            $base64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${Username}:${plainPassword}"))
            return @{
                "Authorization" = "Basic $base64"
                "Content-Type" = "application/json"
            }
        }
        "FreshService" {
            $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
            $base64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${Username}:${plainPassword}"))
            return @{
                "Authorization" = "Basic $base64"
                "Content-Type" = "application/json"
            }
        }
        "TestAPI" {
            return @{
                "Content-Type" = "application/json"
                "User-Agent" = "PowerShell-ITSM-Client"
            }
        }
    }
}

# Função para testar conexão
function Test-ITSMConnection {
    param($Platform, $BaseURL, $Headers)
    
    try {
        switch ($Platform) {
            "ServiceNow" {
                $uri = "$BaseURL/api/now/table/sys_user?sysparm_limit=1"
                $response = Invoke-RestMethod -Uri $uri -Headers $Headers -Method GET
                return $response.result.Count -ge 0
            }
            "Jira" {
                $uri = "$BaseURL/rest/api/2/myself"
                $response = Invoke-RestMethod -Uri $uri -Headers $Headers -Method GET
                return $null -ne $response.name
            }
            "FreshService" {
                $uri = "$BaseURL/api/v2/requesters"
                $response = Invoke-RestMethod -Uri $uri -Headers $Headers -Method GET
                return $response.requesters.Count -ge 0
            }
            "TestAPI" {
                $uri = "https://jsonplaceholder.typicode.com/users/1"
                $response = Invoke-RestMethod -Uri $uri -Headers $Headers -Method GET
                return $response.id -eq 1
            }
        }
    }
    catch {
        Write-Error "Erro na conexão: $($_.Exception.Message)"
        return $false
    }
}

# Main execution
Write-Host "=== ITSM Login e Teste de Conexão ===" -ForegroundColor Cyan
Write-Host "Plataforma: $Platform" -ForegroundColor Yellow
Write-Host "URL Base: $BaseURL" -ForegroundColor Yellow

# Criar headers de autenticação
$headers = Get-AuthHeaders -Platform $Platform -Username $Username -Password $Password

# Testar conexão
Write-Host "`nTestando conexão..." -ForegroundColor Yellow
$connected = Test-ITSMConnection -Platform $Platform -BaseURL $BaseURL -Headers $headers

if ($connected) {
    Write-Host "✅ Conexão bem-sucedida!" -ForegroundColor Green
    
    # Salvar configuração para uso futuro
    $config = @{
        Platform = $Platform
        BaseURL = $BaseURL
        Username = $Username
        Domain = $Domain
        ConnectedAt = Get-Date
    }
    
    $configPath = "$PSScriptRoot\itsm_config.json"
    $config | ConvertTo-Json | Out-File -FilePath $configPath -Encoding UTF8
    Write-Host "📝 Configuração salva em: $configPath" -ForegroundColor Blue
    
    # Retornar headers para outros scripts
    return $headers
}
else {
    Write-Host "❌ Falha na conexão!" -ForegroundColor Red
    exit 1
}
