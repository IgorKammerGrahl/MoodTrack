#!/bin/bash
# migrate-sonarqube.sh
# Move volumes do SonarQube de /var/lib/containers para /mnt/dev

echo "================================================"
echo "   Migrando SonarQube para /mnt/dev"
echo "   (100GB de espaço disponível)"
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

# Verificar se estamos no diretório certo
if [ ! -f "docker-compose.yml" ]; then
    error "docker-compose.yml não encontrado!"
    echo "Execute este script na raiz do seu projeto MoodTrack"
    exit 1
fi

echo "[1/5] Parando containers..."
podman-compose down
success "Containers parados"

echo ""
echo "[2/5] Criando diretório em /mnt/dev..."
mkdir -p /mnt/dev/sonarqube-volumes
success "Diretório criado: /mnt/dev/sonarqube-volumes"

echo ""
echo "[3/5] Configurando permissões..."
sudo chown -R $(whoami):$(whoami) /mnt/dev/sonarqube-volumes
sudo chmod 777 /mnt/dev/sonarqube-volumes
success "Permissões configuradas"

echo ""
echo "[4/5] Atualizando docker-compose.yml..."

# Criar novo docker-compose.yml com paths em /mnt/dev e versão LTS
cat > docker-compose.yml << 'EOF'
version: "3.9"

services:
  sonarqube:
    image: sonarqube:10.6-community
    container_name: sonarqube_flutter
    depends_on:
      - db
    hostname: sonarqube
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://db:5432/sonar
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonar_secure_password
      SONAR_ES_BOOTSTRAP_CHECKS_DISABLE: "true"
      SONAR_JAVA_OPTS: "-Xmx2g -Xms1g"
      TZ: "America/Sao_Paulo"
    
    volumes:
      - /mnt/dev/sonarqube-volumes/sonarqube_data:/opt/sonarqube/data:Z
      - /mnt/dev/sonarqube-volumes/sonarqube_extensions:/opt/sonarqube/extensions:Z
      - /mnt/dev/sonarqube-volumes/sonarqube_logs:/opt/sonarqube/logs:Z
    
    ports:
      - "9000:9000"
    
    networks:
      - sonar_network
    
    restart: unless-stopped
    
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/api/system/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  db:
    image: postgres:15-alpine
    container_name: sonarqube_db_flutter
    hostname: db
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar_secure_password
      POSTGRES_DB: sonar
      POSTGRES_INITDB_ARGS: "--encoding=UTF8 --locale=pt_BR.UTF-8"
      TZ: "America/Sao_Paulo"
    
    volumes:
      - /mnt/dev/sonarqube-volumes/postgresql_data:/var/lib/postgresql/data:Z
    
    networks:
      - sonar_network
    
    restart: unless-stopped
    
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U sonar"]
      interval: 10s
      timeout: 5s
      retries: 5

networks:
  sonar_network:
    driver: bridge
EOF

success "docker-compose.yml atualizado com /mnt/dev"

echo ""
echo "[5/5] Iniciando containers com novo storage..."
podman-compose up -d
sleep 30

if podman-compose ps | grep -q "sonarqube_flutter"; then
    success "Containers iniciados com sucesso!"
else
    error "Falha ao iniciar containers"
    echo "Verifique os logs com: podman-compose logs -f sonarqube"
    exit 1
fi

echo ""
echo "================================================"
echo "   🎉 Migração Concluída!"
echo "================================================"
echo ""
echo "Informações:"
success "Volumes agora em: /mnt/dev/sonarqube-volumes/"
echo "   - sonarqube_data (Elasticsearch)"
echo "   - sonarqube_extensions (Plugins)"
echo "   - sonarqube_logs (Logs)"
echo "   - postgresql_data (Banco de dados)"
echo ""
echo "SonarQube 10.6 LTS agora rodando em http://localhost:9000"
echo ""
