# Exemplo Seguro de Login ITSM
# Demonstra como usar credenciais de forma segura

# OPÇÃO 1: Solicitação interativa de credenciais
function Get-ITSMCredentialInteractive {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Platform,
        [Parameter(Mandatory=$true)]  
        [string]$BaseURL
    )
    
    Write-Host "🔐 Login Seguro - $Platform" -ForegroundColor Cyan
    
    # Solicitar credenciais de forma segura
    $credential = Get-Credential -Message "Digite suas credenciais para $Platform"
    
    if (-not $credential) {
        Write-Error "❌ Credenciais não fornecidas"
        return $null
    }
    
    # Fazer login usando SecureString
    try {
        $headers = & "$PSScriptRoot\itsm_login.ps1" `
            -Platform $Platform `
            -BaseURL $BaseURL `
            -Username $credential.UserName `
            -Password $credential.Password
            
        return $headers
    }
    catch {
        Write-Error "❌ Erro no login: $($_.Exception.Message)"
        return $null
    }
}

# OPÇÃO 2: Usar variáveis de ambiente (mais seguro para automação)
function Get-ITSMCredentialFromEnvironment {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Platform,
        [Parameter(Mandatory=$true)]
        [string]$BaseURL
    )
    
    # Verificar se as variáveis de ambiente existem
    $envUsername = $env:ITSM_USERNAME
    $envPassword = $env:ITSM_PASSWORD
    
    if (-not $envUsername -or -not $envPassword) {
        Write-Error "❌ Variáveis de ambiente ITSM_USERNAME e ITSM_PASSWORD não definidas"
        Write-Host "💡 Configure usando:" -ForegroundColor Yellow
        Write-Host "   `$env:ITSM_USERNAME = 'seu_usuario'" -ForegroundColor Gray
        Write-Host "   `$env:ITSM_PASSWORD = 'sua_senha'" -ForegroundColor Gray
        return $null
    }
    
    # Converter para SecureString
    $securePassword = ConvertTo-SecureString $envPassword -AsPlainText -Force
    
    try {
        $headers = & "$PSScriptRoot\itsm_login.ps1" `
            -Platform $Platform `
            -BaseURL $BaseURL `
            -Username $envUsername `
            -Password $securePassword
            
        return $headers
    }
    catch {
        Write-Error "❌ Erro no login: $($_.Exception.Message)"
        return $null
    }
}

# OPÇÃO 3: Usar arquivo de credenciais criptografadas
function Get-ITSMCredentialFromFile {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Platform,
        [Parameter(Mandatory=$true)]
        [string]$BaseURL,
        [Parameter(Mandatory=$false)]
        [string]$CredentialPath = "$PSScriptRoot\itsm_credentials.xml"
    )
    
    if (-not (Test-Path $CredentialPath)) {
        Write-Error "❌ Arquivo de credenciais não encontrado: $CredentialPath"
        Write-Host "💡 Crie o arquivo usando:" -ForegroundColor Yellow
        Write-Host "   Get-Credential | Export-Clixml -Path '$CredentialPath'" -ForegroundColor Gray
        return $null
    }
    
    try {
        # Importar credenciais criptografadas
        $credential = Import-Clixml -Path $CredentialPath
        
        $headers = & "$PSScriptRoot\itsm_login.ps1" `
            -Platform $Platform `
            -BaseURL $BaseURL `
            -Username $credential.UserName `
            -Password $credential.Password
            
        return $headers
    }
    catch {
        Write-Error "❌ Erro ao carregar credenciais: $($_.Exception.Message)"
        return $null
    }
}

# DEMONSTRAÇÃO DOS MÉTODOS SEGUROS
Write-Host "🛡️ ITSM - Métodos Seguros de Autenticação" -ForegroundColor Magenta
Write-Host ("="*60) -ForegroundColor DarkGray

# Configuração de teste
$testConfig = @{
    Platform = "TestAPI"
    BaseURL = "https://jsonplaceholder.typicode.com"
}

Write-Host "`n1️⃣ Método Interativo (Recomendado para uso manual)" -ForegroundColor Cyan
Write-Host "   Solicita credenciais de forma segura via interface" -ForegroundColor Gray

Write-Host "`n2️⃣ Variáveis de Ambiente (Recomendado para automação)" -ForegroundColor Cyan
Write-Host "   $ `$env:ITSM_USERNAME = 'usuario'" -ForegroundColor Gray
Write-Host "   $ `$env:ITSM_PASSWORD = 'senha'" -ForegroundColor Gray

Write-Host "`n3️⃣ Arquivo Criptografado (Recomendado para desenvolvimento)" -ForegroundColor Cyan
Write-Host "   $ Get-Credential | Export-Clixml -Path 'credentials.xml'" -ForegroundColor Gray

Write-Host "`n🔒 NUNCA faça:" -ForegroundColor Red
Write-Host "   ❌ Senhas em texto plano no código" -ForegroundColor Red
Write-Host "   ❌ Credenciais em arquivos versionados" -ForegroundColor Red
Write-Host "   ❌ Senhas em logs ou saídas de console" -ForegroundColor Red

Write-Host "`n✅ Sempre faça:" -ForegroundColor Green
Write-Host "   ✅ Use SecureString para senhas" -ForegroundColor Green
Write-Host "   ✅ Use variáveis de ambiente para automação" -ForegroundColor Green
Write-Host "   ✅ Adicione arquivos de credenciais ao .gitignore" -ForegroundColor Green
Write-Host "   ✅ Use Get-Credential para entrada interativa" -ForegroundColor Green

Write-Host "`n💡 Para testar agora:" -ForegroundColor Yellow
Write-Host "   Para usar método interativo:" -ForegroundColor White
Write-Host "   PS> Get-ITSMCredentialInteractive -Platform 'TestAPI' -BaseURL 'https://jsonplaceholder.typicode.com'" -ForegroundColor Gray
Write-Host "`n   Para usar variáveis de ambiente:" -ForegroundColor White  
Write-Host "   PS> `$env:ITSM_USERNAME = 'test'; `$env:ITSM_PASSWORD = 'test'" -ForegroundColor Gray
Write-Host "   PS> Get-ITSMCredentialFromEnvironment -Platform 'TestAPI' -BaseURL 'https://jsonplaceholder.typicode.com'" -ForegroundColor Gray