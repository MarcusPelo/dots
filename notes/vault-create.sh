#!/bin/bash

# --- Script para criar a estrutura completa para um Vault do Obsidian ---
# Este script irá gerar todas as pastas e arquivos de template
# que discutimos, para uma organização pessoal completa.

# Define o nome do diretório raiz para o Vault (opcional). 
# Deixe em branco para criar no diretório atual.
VAULT_NAME="BrainFog"

# --- Início da Criação ---

echo "Iniciando a criação da estrutura completa do Vault em: $VAULT_NAME"

# Cria o diretório raiz do Vault, se um nome foi definido
if [ ! -z "$VAULT_NAME" ]; then
    mkdir -p "$VAULT_NAME"
    cd "$VAULT_NAME" || exit
fi

# Cria a estrutura principal de pastas usando mkdir -p
# O comando '-p' garante que os diretórios pais sejam criados se não existirem.
echo "Criando diretórios principais..."
mkdir -p "01-Daily Notes"
mkdir -p "02-Quick Notes"
mkdir -p "03-Knowledge"
mkdir -p "05-Work"
mkdir -p "98-Archive"

# Cria todas as subpastas dentro de "04-Sources"
echo "Criando diretórios de Fontes (Sources)..."
mkdir -p "04-Sources/Books"
mkdir -p "04-Sources/Games"
mkdir -p "04-Sources/Lectures"
mkdir -p "04-Sources/People"
mkdir -p "04-Sources/Pets"
mkdir -p "04-Sources/Podcasts"
mkdir -p "04-Sources/Recipes"
mkdir -p "04-Sources/Trips"
mkdir -p "04-Sources/Videos"
mkdir -p "04-Sources/Web"

# Cria as subpastas dentro de "99-Setup"
echo "Criando diretórios de Configuração (Setup)..."
mkdir -p "99-Setup/Al Chat History"
mkdir -p "99-Setup/Files"
mkdir -p "99-Setup/Help"
mkdir -p "99-Setup/Templates"

# Cria todos os arquivos de template vazios (.md) dentro da pasta de Templates
# O comando 'touch' cria um arquivo vazio se ele não existir.
echo "Criando todos os arquivos de template..."
touch "99-Setup/Templates/Daily Note.md"
touch "99-Setup/Templates/Meeting Note.md"
touch "99-Setup/Templates/New Book Note.md"
touch "99-Setup/Templates/New Game Note.md"
touch "99-Setup/Templates/New Person Note.md"
touch "99-Setup/Templates/New Recipe Note.md"
touch "99-Setup/Templates/New Source Note.md"
touch "99-Setup/Templates/New Trip Note.md"
touch "99-Setup/Templates/Permanent Note.md"
touch "99-Setup/Templates/Quick Note.md"


echo "---"
echo "Estrutura do Vault criada com sucesso!"
echo "Você pode agora abrir o diretório '$VAULT_NAME' como um novo Vault no Obsidian."

# Lista a estrutura criada para verificação (opcional)
ls -R
