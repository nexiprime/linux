#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

### =========================================================
### Verificação de root
### =========================================================
if [[ $EUID -ne 0 ]]; then
    echo "Este script deve ser executado como root."
    exit 1
fi

### =========================================================
### Variáveis
### =========================================================
SYSCTL_FILE="/etc/sysctl.d/99-optimized.conf"
LOG_FILE="/var/log/optimized.log"
TIMESTAMP="$(date +%F-%H%M)"

exec > >(tee -a "$LOG_FILE") 2>&1

### =========================================================
### Funções utilitárias
### =========================================================
print_info() {
    echo -e "[INFO] $1"
}

print_warn() {
    echo -e "[WARN] $1"
}

print_error() {
    echo -e "[ERROR] $1"
}

### =========================================================
### Detectar Desktop vs Server
### =========================================================
detect_environment() {
    if systemctl get-default | grep -q graphical; then
        ENV_TYPE="desktop"
    else
        ENV_TYPE="server"
    fi
    print_info "Ambiente detectado: Ubuntu $ENV_TYPE"
}

### =========================================================
### Limpeza segura do sistema
### =========================================================
cleanup_system() {
    print_info "Executando limpeza básica do sistema"
    apt update -y
    apt autoremove -y
    apt autoclean -y
}

### =========================================================
### Backup de sysctl
### =========================================================
backup_sysctl() {
    if [[ -f "$SYSCTL_FILE" ]]; then
        cp "$SYSCTL_FILE" "$SYSCTL_FILE.bak.$TIMESTAMP"
        print_info "Backup do sysctl criado"
    fi
}

### =========================================================
### Otimizações comuns (desktop + server)
### =========================================================
apply_common_sysctl() {
cat > "$SYSCTL_FILE" <<EOF
# ===== Common optimizations =====
vm.swappiness=10
vm.vfs_cache_pressure=50
fs.inotify.max_user_watches=524288
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
}

### =========================================================
### Otimizações para SERVER
### =========================================================
apply_server_sysctl() {
cat >> "$SYSCTL_FILE" <<EOF

# ===== Server optimizations =====
net.core.somaxconn=1024
net.ipv4.tcp_max_syn_backlog=4096
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_tw_reuse=1
net.ipv4.ip_local_port_range=10240 65535
EOF
}

### =========================================================
### Otimizações para DESKTOP
### =========================================================
apply_desktop_sysctl() {
cat >> "$SYSCTL_FILE" <<EOF

# ===== Desktop optimizations =====
kernel.sched_autogroup_enabled=1
vm.dirty_ratio=15
vm.dirty_background_ratio=5
EOF
}

### =========================================================
### Aplicar sysctl
### =========================================================
apply_sysctl() {
    print_info "Aplicando parâmetros de kernel"
    sysctl --system
}

### =========================================================
### Script principal
### =========================================================
main() {
    print_info "Iniciando otimização do sistema"

    detect_environment
    cleanup_system
    backup_sysctl
    apply_common_sysctl

    if [[ "$ENV_TYPE" == "server" ]]; then
        apply_server_sysctl
    else
        apply_desktop_sysctl
    fi

    apply_sysctl

    print_info "Otimização concluída com sucesso"
    print_info "Log salvo em $LOG_FILE"
}

main "$@"
