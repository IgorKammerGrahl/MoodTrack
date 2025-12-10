#!/bin/bash
# setup-sonarqube-fedora.sh
# Script de configuração completa do SonarQube Community com Podman no Fedora

echo "================================================"
echo "   Setup SonarQube Community + Podman"
echo "   Fedora Linux - Projeto Flutter"
echo "================================================"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

error() {
    echo -e "${RED}✗ $1${NC}"
}

echo "[1/5] Verificando pré-requisitos..."
echo ""

if ! command -v podman-compose &> /dev/null; then
    warning "podman-compose não está instalado"
    echo "Instalando podman-compose..."
    sudo dnf install -y podman-compose
    if [ $? -eq 0 ]; then
        success "podman-compose instalado com sucesso"
    else
        error "Falha ao instalar podman-compose"
        exit 1
    fi
else
    success "podman-compose já está instalado"
fi

if ! podman --version &> /dev/null; then
    error "Podman não está funcionando"
    exit 1
fi
success "Podman está funcional"

echo ""
echo "[2/5] Configurando memória virtual (vm.max_map_count)..."
echo ""

current_vm_max=$(sysctl vm.max_map_count 2>/dev/null | cut -d' ' -f3)
required_vm_max=262144

if [ "$current_vm_max" -lt "$required_vm_max" ]; then
    warning "vm.max_map_count está muito baixo: $current_vm_max"
    echo "Ajustando para $required_vm_max (requer sudo)..."
    sudo sysctl -w vm.max_map_count=$required_vm_max
    
    echo "Tornando a mudança permanente..."
    echo "vm.max_map_count=$required_vm_max" | sudo tee /etc/sysctl.d/99-sonarqube.conf > /dev/null
    
    success "vm.max_map_count configurado corretamente"
else
    success "vm.max_map_count já está configurado ($current_vm_max)"
fi

echo ""
echo "[3/5] Limpando containers/volumes antigos (se existirem)..."
echo ""

podman-compose down 2>/dev/null
if [ $? -eq 0 ]; then
    success "Containers antigos removidos"
else
    warning "Nenhum container anterior encontrado (isso é normal)"
fi

echo ""
echo "[4/5] Iniciando SonarQube + PostgreSQL..."
echo ""

podman-compose up -d
if [ $? -eq 0 ]; then
    success "Containers iniciados com sucesso"
else
    error "Falha ao iniciar os containers"
    exit 1
fi

echo ""
echo "[5/5] Aguardando inicialização do SonarQube..."
echo ""

echo "Aguardando... (isso pode demorar até 2 minutos)"
sleep 5

max_attempts=24
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -s http://localhost:9000 > /dev/null 2>&1; then
        success "SonarQube está rodando!"
        break
    fi
    attempt=$((attempt + 1))
    echo "Tentativa $attempt/$max_attempts... aguardando 5 segundos"
    sleep 5
done

if [ $attempt -eq $max_attempts ]; then
    error "SonarQube demorou muito para iniciar"
    echo "Verifique os logs com: podman-compose logs -f sonarqube"
    exit 1
fi

echo ""
echo "================================================"
echo "   🎉 Setup Concluído com Sucesso!"
echo "================================================"
echo ""
echo "Informações úteis:"
echo ""
success "SonarQube Community Edition está rodando em:"
echo "   URL: http://localhost:9000"
echo "   Usuário: admin"
echo "   Senha padrão: admin (será solicitado trocar na primeira vez)"
echo ""
success "Banco de dados PostgreSQL:"
echo "   Host: localhost (dentro dos containers: db)"
echo "   Usuário: sonar"
echo "   Senha: sonar_secure_password"
echo "   Database: sonar"
echo ""
echo "Próximos passos:"
echo "   1. Abra http://localhost:9000 no navegador"
echo "   2. Faça login com admin/admin"
echo "   3. Crie um novo projeto Flutter"
echo "   4. Gere um token de autenticação"
echo "   5. Rode o SonarScanner no seu projeto Flutter"
echo ""
echo "Comandos úteis:"
echo "   Ver logs:           podman-compose logs -f sonarqube"
echo "   Parar containers:   podman-compose down"
echo "   Reiniciar:          podman-compose restart"
echo "   Remover tudo:       podman-compose down -v"
echo ""
