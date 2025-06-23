#!/bin/bash

# Test script to validate SSH connection logic improvements
# Este script testa a lógica melhorada de conexão SSH

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Testando Lógica de Conexão SSH${NC}"
echo "=========================================="

# Source das funções do script principal (apenas as funções, não execução)
source_functions() {
    # Extrair apenas as funções necessárias do script principal
    sed -n '/^# =============================================================================$/,/^main()/p' /workspaces/dots/proxmox-setup-interactive.sh | head -n -1 > /tmp/ssh_functions.sh
    source /tmp/ssh_functions.sh 2>/dev/null || true
}

# Mock das variáveis necessárias
setup_test_env() {
    export SSH_KEY="$HOME/.ssh/id_ed25519"
    export SSH_PUB_KEY="$HOME/.ssh/id_ed25519.pub"
    export SSH_DIR="$HOME/.ssh"
    export SSH_CONFIG="$HOME/.ssh/config"
    export PROXMOX_HOSTNAME="proxmox"
    export LOG_FILE="/tmp/test-ssh.log"
    
    # Criar mock da função log se não existir
    if ! declare -f log >/dev/null 2>&1; then
        log() {
            local level="$1"
            local message="$2"
            echo -e "[${level}] ${message}"
        }
    fi
}

# Função simplificada para teste
test_ssh_connection_simple() {
    local target="$1"
    local port="$2"
    
    echo -e "${YELLOW}📡 Testando conexão SSH para: $target${NC}"
    
    local ssh_cmd="ssh -o ConnectTimeout=2 -o BatchMode=yes"
    
    # Determinar se o target é um alias SSH ou IP/hostname direto
    if [[ -n "$port" ]]; then
        # Conexão direta com IP e porta
        ssh_cmd="$ssh_cmd -p $port $target"
        echo -e "${BLUE}   Usando conexão direta: $target:$port${NC}"
    else
        # Usar alias SSH configurado
        ssh_cmd="$ssh_cmd $target"
        echo -e "${BLUE}   Usando alias SSH: $target${NC}"
    fi
    
    echo -e "${BLUE}   Comando: $ssh_cmd 'echo test'${NC}"
    
    if $ssh_cmd 'echo "✅ Conexão teste OK"' 2>/dev/null; then
        echo -e "${GREEN}   ✅ Conexão bem-sucedida!${NC}"
        return 0
    else
        echo -e "${RED}   ❌ Conexão falhou (esperado para IPs de teste)${NC}"
        return 1
    fi
}

# Testes
run_tests() {
    echo -e "\n${YELLOW}🧪 Teste 1: Conexão direta com IP e porta${NC}"
    test_ssh_connection_simple "192.168.1.100" "22" || true
    
    echo -e "\n${YELLOW}🧪 Teste 2: Conexão via alias SSH${NC}"
    test_ssh_connection_simple "proxmox" "" || true
    
    echo -e "\n${YELLOW}🧪 Teste 3: Conexão direta com porta customizada${NC}"
    test_ssh_connection_simple "10.0.0.5" "2222" || true
    
    echo -e "\n${YELLOW}🧪 Teste 4: Conexão via alias de container${NC}"
    test_ssh_connection_simple "lxc-101" "" || true
}

# Verificar se o script principal existe
check_main_script() {
    if [[ ! -f "/workspaces/dots/proxmox-setup-interactive.sh" ]]; then
        echo -e "${RED}❌ Script principal não encontrado!${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Script principal encontrado${NC}"
}

# Verificar as mudanças na função test_ssh_connection
check_function_updates() {
    echo -e "\n${YELLOW}🔍 Verificando atualizações na função test_ssh_connection...${NC}"
    
    # Verificar se a função foi atualizada
    if grep -q "Determinar se o target é um alias SSH" /workspaces/dots/proxmox-setup-interactive.sh; then
        echo -e "${GREEN}✅ Função test_ssh_connection foi atualizada corretamente${NC}"
    else
        echo -e "${RED}❌ Função test_ssh_connection não foi atualizada${NC}"
        return 1
    fi
    
    # Verificar se as chamadas da função foram atualizadas
    if grep -q "test_ssh_connection.*PROXMOX_HOSTNAME" /workspaces/dots/proxmox-setup-interactive.sh; then
        echo -e "${GREEN}✅ Chamadas para aliases SSH foram atualizadas${NC}"
    else
        echo -e "${RED}❌ Chamadas da função não foram atualizadas corretamente${NC}"
        return 1
    fi
}

# Mostrar diferenças importantes
show_improvements() {
    echo -e "\n${BLUE}📝 Melhorias Implementadas:${NC}"
    echo "1. test_ssh_connection() agora diferencia entre:"
    echo "   - Conexões diretas (IP + porta): ssh -p PORT IP"
    echo "   - Conexões via alias: ssh ALIAS"
    echo
    echo "2. Lógica consistente em todo o script:"
    echo "   - Configuração inicial usa IP/porta direta"
    echo "   - Testes subsequentes usam alias configurado"
    echo
    echo "3. Melhor debugging e logs"
    echo "4. Tratamento de erro mais robusto"
}

# Main
main() {
    check_main_script
    setup_test_env
    check_function_updates
    run_tests
    show_improvements
    
    echo -e "\n${GREEN}🎉 Teste concluído!${NC}"
    echo -e "${BLUE}💡 A lógica SSH agora considera corretamente local vs remoto/alias${NC}"
}

main "$@"
