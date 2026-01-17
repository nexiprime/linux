#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ==========================================================
# Verificações iniciais
# ==========================================================
if [[ $EUID -ne 0 ]]; then
    echo "Execute como root."
    exit 1
fi

if ! grep -qiE "linux mint|ubuntu" /etc/os-release; then
    echo "Este script é compatível apenas com Linux Mint ou Ubuntu."
    exit 1
fi

# ==========================================================
# Variáveis
# ==========================================================
SYSCTL_FILE="/etc/sysctl.d/99-low-spec.conf"
ZRAM_CONF="/etc/systemd/zram-generator.conf"
LOG_FILE="/var/log/optimized-low-spec.log"
TIMESTAMP="$(date +%F-%H%M)"

exec > >(tee -a "$LOG_FILE") 2>&1

log() {
    echo "[INFO] $1"
}

# ==========================================================
# Detectar RAM total (em MB)
# ==========================================================
TOTAL_RAM_MB=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)

# ==========================================================
# Limpeza leve
# ==========================================================
cleanup_system() {
    log "Limpeza leve do sistema"
    apt update -y
    apt autoremove -y
    apt autoclean -y
}

# ==========================================================
# Backup sysctl
# ==========================================================
backup_sysctl() {
    if [[ -f "$SYSCTL_FILE" ]]; then
        cp "$SYSCTL_FILE" "$SYSCTL_FILE.bak.$TIMESTAMP"
        log "Backup do sysctl criado"
    fi
}

# ==========================================================
# Otimizações para 4GB RAM + CPU fraca
# ==========================================================
apply_low_spec_sysctl() {
cat > "$SYSCTL_FILE" <<EOF
# =========================================================
# Low Spec Optimization
# Target: <=4GB RAM + CPU fraca
# =========================================================

# ---- Memória ----
vm.swappiness=25
vm.vfs_cache_pressure=100
vm.min_free_kbytes=65536

vm.dirty_ratio=10
vm.dirty_background_ratio=3
vm.dirty_expire_centisecs=1500
vm.dirty_writeback_centisecs=500

# ---- Scheduler ----
kernel.sched_autogroup_enabled=1
kernel.sched_migration_cost_ns=5000000

# ---- Filesystem ----
fs.inotify.max_user_watches=262144

# ---- Network (leve) ----
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_low_latency=1
EOF
}

# ==========================================================
# Configurar ZRAM (forma correta)
# ==========================================================
configure_zram() {
    log "Configurando ZRAM"

    apt install -y systemd-zram-generator

    # ZRAM ~75% da RAM
    ZRAM_SIZE_MB=$(( TOTAL_RAM_MB * 75 / 100 ))

cat > "$ZRAM_CONF" <<EOF
[zram0]
zram-size = ${ZRAM_SIZE_MB}M
compression-algorithm = lzo-rle
swap-priority = 100
EOF

    log "ZRAM configurado: ${ZRAM_SIZE_MB} MB (lzo-rle)"
}

# ==========================================================
# Ajustar prioridade do swap em disco
# ==========================================================
adjust_disk_swap_priority() {
    log "Ajustando prioridade do swap em disco"

    sed -i 's/pri=[0-9]\+/pri=10/g' /etc/fstab || true
}

# ==========================================================
# Aplicar sysctl
# ==========================================================
apply_sysctl() {
    log "Aplicando parâmetros sysctl"
    sysctl --system
}

# ==========================================================
# Reiniciar ZRAM
# ==========================================================
restart_zram() {
    log "Ativando ZRAM"
    systemctl daemon-reexec
    systemctl restart systemd-zram-setup@zram0.service || true
}

# ==========================================================
# Execução principal
# ==========================================================
main() {
    log "Iniciando otimização para hardware fraco com ZRAM"
    log "RAM detectada: ${TOTAL_RAM_MB} MB"

    cleanup_system
    backup_sysctl
    apply_low_spec_sysctl
    configure_zram
    adjust_disk_swap_priority
    apply_sysctl
    restart_zram

    log "Otimização concluída com sucesso"
    log "Log salvo em $LOG_FILE"
}

main "$@"
