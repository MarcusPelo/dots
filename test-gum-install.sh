#!/bin/bash

# Script de teste para instalação manual do gum

set -euo pipefail

# Cores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Função para logging
log() {
    local level="$1"
    shift
    local message="$*"
    
    case "$level" in
        "INFO")  echo -e "${BLUE}ℹ️  $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "STEP") echo -e "${CYAN}🔸 $message${NC}" ;;
    esac
}

# Testar instalação manual do gum
test_gum_manual_install() {
    local arch="x86_64"
    
    log "STEP" "Testando instalação manual do gum..."
    
    # Detectar versão mais recente
    log "INFO" "Detectando versão mais recente do gum..."
    local latest_version
    latest_version=$(curl -s https://api.github.com/repos/charmbracelet/gum/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | head -1)
    
    if [[ -z "$latest_version" ]] || [[ "$latest_version" == "null" ]]; then
        log "ERROR" "Falha ao detectar versão"
        return 1
    fi
    
    log "INFO" "Versão detectada: $latest_version"
    
    # Construir URL correta
    local version_number="${latest_version#v}"
    local gum_url="https://github.com/charmbracelet/gum/releases/download/${latest_version}/gum_${version_number}_Linux_${arch}.tar.gz"
    
    log "INFO" "URL construída: $gum_url"
    
    # Verificar se URL existe
    log "INFO" "Verificando se URL existe..."
    if curl -fsSL --head "$gum_url" >/dev/null 2>&1; then
        log "SUCCESS" "URL verificada com sucesso!"
    else
        log "ERROR" "URL não encontrada"
        return 1
    fi
    
    # Criar diretório temporário
    local temp_dir=$(mktemp -d)
    local gum_archive="$temp_dir/gum.tar.gz"
    
    # Baixar arquivo
    log "INFO" "Baixando arquivo..."
    if curl -fsSL "$gum_url" -o "$gum_archive"; then
        log "SUCCESS" "Download concluído"
    else
        log "ERROR" "Falha no download"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Verificar arquivo baixado
    if [[ -f "$gum_archive" ]] && [[ -s "$gum_archive" ]]; then
        log "SUCCESS" "Arquivo baixado: $(ls -lh "$gum_archive" | awk '{print $5}')"
    else
        log "ERROR" "Arquivo inválido"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Extrair arquivo
    log "INFO" "Extraindo arquivo..."
    if tar -xzf "$gum_archive" -C "$temp_dir"; then
        log "SUCCESS" "Extração concluída"
        log "INFO" "Conteúdo extraído:"
        ls -la "$temp_dir"
    else
        log "ERROR" "Falha na extração"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Encontrar binário
    local gum_binary=$(find "$temp_dir" -name "gum" -type f -executable | head -1)
    if [[ -n "$gum_binary" ]]; then
        log "SUCCESS" "Binário encontrado: $gum_binary"
        log "INFO" "Testando binário..."
        if "$gum_binary" --version; then
            log "SUCCESS" "Binário funcional!"
        else
            log "ERROR" "Binário não funcional"
        fi
    else
        log "ERROR" "Binário não encontrado"
        log "INFO" "Arquivos encontrados:"
        find "$temp_dir" -type f
    fi
    
    # Limpeza
    rm -rf "$temp_dir"
    
    log "SUCCESS" "Teste da instalação manual concluído!"
}

# Executar teste
test_gum_manual_install
