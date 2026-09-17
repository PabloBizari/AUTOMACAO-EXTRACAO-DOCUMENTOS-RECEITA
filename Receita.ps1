# --- INÍCIO DA CONFIGURAÇÃO ---

# 1. Caminho da pasta onde estão as pastas "proposta_cpf"
$caminhoOrigem = "Z:\_CAPITAL"

# 2. Caminho da pasta para onde os arquivos de RECEITA serão copiados
$caminhoDestino = "Y:\CAPITAL\CONFERENCIA\- LASTRO - ROBO DOCUMENTOS\PASTAS\PASTAS - Pablo\RECEITA"


# --- FIM DA CONFIGURAÇÃO ---


#region --- CÓDIGO DA JANELA GRÁFICA (NÃO PRECISA MODIFICAR) ---
function Get-UserInput {
    Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing
    $form = New-Object System.Windows.Forms.Form; $form.Text = 'Entrada de Propostas'; $form.Size = New-Object System.Drawing.Size(300, 400); $form.StartPosition = 'CenterScreen'; $form.TopMost = $true
    $label = New-Object System.Windows.Forms.Label; $label.Location = New-Object System.Drawing.Point(10, 10); $label.Size = New-Object System.Drawing.Size(280, 20); $label.Text = 'Cole as propostas abaixo (uma por linha):'; $form.Controls.Add($label)
    $textBox = New-Object System.Windows.Forms.TextBox; $textBox.Location = New-Object System.Drawing.Point(10, 40); $textBox.Size = New-Object System.Drawing.Size(260, 250); $textBox.Multiline = $true; $textBox.ScrollBars = 'Vertical'; $textBox.AcceptsReturn = $true; $form.Controls.Add($textBox)
    $okButton = New-Object System.Windows.Forms.Button; $okButton.Location = New-Object System.Drawing.Point(110, 310); $okButton.Size = New-Object System.Drawing.Size(75, 23); $okButton.Text = 'OK'; $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK; $form.AcceptButton = $okButton; $form.Controls.Add($okButton)
    $cancelButton = New-Object System.Windows.Forms.Button; $cancelButton.Location = New-Object System.Drawing.Point(190, 310); $cancelButton.Size = New-Object System.Drawing.Size(75, 23); $cancelButton.Text = 'Cancelar'; $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel; $form.CancelButton = $cancelButton; $form.Controls.Add($cancelButton)
    $form.Add_Shown({$textBox.Select()}); $result = $form.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) { return $textBox.Lines } else { return $null }
}
#endregion

# --- LÓGICA PRINCIPAL DO SCRIPT ---

$propostasDesejadas = Get-UserInput

if ($null -eq $propostasDesejadas) { Write-Host "Processo cancelado pelo usuário." -ForegroundColor Yellow; Read-Host -Prompt "Pressione Enter para sair"; return }
$propostasDesejadas = $propostasDesejadas | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Trim() }
if ($propostasDesejadas.Count -eq 0) { Write-Host "Nenhuma proposta foi inserida. Encerrando o script." -ForegroundColor Yellow; Read-Host -Prompt "Pressione Enter para sair"; return }

Write-Host "Iniciando verificação para $($propostasDesejadas.Count) propostas..." -ForegroundColor Green
if (-not (Test-Path -Path $caminhoDestino -PathType Container)) { 
    Write-Host "A pasta de destino '$caminhoDestino' não existe. Criando..."
    New-Item -Path $caminhoDestino -ItemType Directory -Force | Out-Null 
}

foreach ($propostaDesejada in $propostasDesejadas) {
    
    # --- INÍCIO DA NOVA LÓGICA DE BUSCA "00" ---
    # Por padrão, o termo de busca é a própria proposta.
    $termoBusca = $propostaDesejada
    # Se a proposta tiver menos de 9 dígitos, adiciona "00" ao termo de busca.
    if ($propostaDesejada.Length -lt 9) {
        $termoBusca = "00" + $propostaDesejada
        Write-Host "INFO: Proposta '$propostaDesejada' tem < 9 dígitos. Buscando como '$termoBusca'..." -ForegroundColor Magenta
    }
    # --- FIM DA NOVA LÓGICA DE BUSCA "00" ---

    # A busca pela pasta agora usa o termo de busca formatado ($termoBusca)
    $pasta = Get-ChildItem -Path $caminhoOrigem -Directory -Filter "${termoBusca}*" | Select-Object -First 1

    if ($null -eq $pasta) {
        Write-Host "INFO: Proposta '$propostaDesejada' - Sem pasta." -ForegroundColor Gray
        continue
    }
    
    Write-Host "Processando pasta encontrada: $($pasta.Name)"
    $arquivoReceita = Get-ChildItem -Path $pasta.FullName -Recurse -File | Where-Object { $_.Name -like "*Receita*" } | Select-Object -First 1

    if ($null -eq $arquivoReceita) {
        Write-Host "   -> AVISO: Sem receita." -ForegroundColor Yellow
    } 
    else {
        # --- INÍCIO DA NOVA LÓGICA DE NOMEAÇÃO COM DIGITO ---
        # Divide o nome da pasta para extrair a proposta completa.
        $partesNomePasta = $pasta.Name -split '_'
        # A proposta completa (com dígito) é a primeira parte do nome da pasta.
        $propostaCompleta = $partesNomePasta[0]
        # Extrai o CPF, assumindo que ele é a segunda parte (se existir).
        $cpf = if ($partesNomePasta.Length -ge 2) { $partesNomePasta[1] } else { "CPF_NAO_IDENTIFICADO" }
        $extensao = $arquivoReceita.Extension
        # Monta o novo nome do arquivo usando a proposta completa do nome da pasta.
        $novoNome = "${cpf}_RECEITA_${propostaCompleta}${extensao}"
        # --- FIM DA NOVA LÓGICA DE NOMEAÇÃO COM DIGITO ---
        
        $caminhoCompletoDestino = Join-Path -Path $caminhoDestino -ChildPath $novoNome
        Copy-Item -Path $arquivoReceita.FullName -Destination $caminhoCompletoDestino -Force
        
        Write-Host "   -> SUCESSO: OK." -ForegroundColor Cyan
    }
}

Write-Host "----------------------------------------------------" -ForegroundColor Green
Write-Host "Processo concluído."
Read-Host -Prompt "Pressione Enter para finalizar"```