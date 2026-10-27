#!/bin/bash
# samsung_boost.sh - Gerenciador do CPU Turbo Samsung (1.8GHz - 2.8GHz / PL1=12W PL2=18W)

set -euo pipefail

SCRIPT_TARGET="/usr/local/sbin/unlock-samsung-cpu.sh"
SERVICE_TARGET="/etc/systemd/system/unlock-samsung-cpu.service"
MODULES_CONF="/etc/modules-load.d/msr.conf"

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Erro: Este script precisa ser executado como root." >&2
        exit 1
    fi
}

show_status() {
    echo "=== Status do Serviço systemd ==="
    systemctl is-active unlock-samsung-cpu.service >/dev/null 2>&1 && echo "  Serviço: ATIVO (Daemon em execução)" || echo "  Serviço: INATIVO"
    systemctl is-enabled unlock-samsung-cpu.service >/dev/null 2>&1 && echo "  No Boot: HABILITADO (enabled)" || echo "  No Boot: DESABILITADO"

    echo
    echo "=== Status do Hardware (Bit 38 do MSR 0x1a0) ==="
    if command -v rdmsr >/dev/null 2>&1 && [ -e /dev/cpu/0/msr ]; then
        rdmsr -a -f 38:38 0x1a0 2>/dev/null | sort | uniq -c | sed 's/^/    /'
    fi

    echo
    echo "=== Frequência e Temperatura Atual ==="
    awk '/cpu MHz/ {s+=$4; n++} END { if (n) printf "  Média: %.0f MHz em %d núcleos\n", s/n, n }' /proc/cpuinfo
    sensors 2>/dev/null | grep 'Package id 0:' || true
}

install_boost() {
    check_root
    echo "[1/4] Verificando msr-tools..."
    if ! command -v rdmsr >/dev/null 2>&1 || ! command -v wrmsr >/dev/null 2>&1; then
        apt-get update -qq && apt-get install -y msr-tools
    fi

    modprobe msr 2>/dev/null || true
    [ ! -f "$MODULES_CONF" ] && echo "msr" > "$MODULES_CONF"

    echo "[2/4] Criando o script de desbloqueio ($SCRIPT_TARGET)..."
    cat > "$SCRIPT_TARGET" << 'EOF'
#!/bin/bash
modprobe msr 2>/dev/null

apply_boost() {
    # 1. Limpa Bit 38 (Turbo Unlock) em todos os núcleos
    wrmsr -a 0x1a0 0x00850089 2>/dev/null || true

    # 2. Mantém o Turbo do driver liberado
    if [ -w /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
        echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo
    fi

    # 3. Faixa de operacao: 1.8 GHz (mínimo em idle) ate 2.8 GHz (máximo seguro)
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq; do
        [ -w "$f" ] && echo 1800000 > "$f" 2>/dev/null || true
    done
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
        [ -w "$f" ] && echo 2800000 > "$f" 2>/dev/null || true
    done
    for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        [ -w "$f" ] && echo balance_performance > "$f" 2>/dev/null || true
    done

    # 4. Limites de potencia RAPL (PL1 = 12W, PL2 = 18W)
    RAPL_DIR="/sys/class/powercap/intel-rapl/intel-rapl:0"
    if [ -f "$RAPL_DIR/constraint_0_power_limit_uw" ]; then
        echo 12000000 > "$RAPL_DIR/constraint_0_power_limit_uw" 2>/dev/null || true
    fi
    if [ -f "$RAPL_DIR/constraint_1_power_limit_uw" ]; then
        echo 18000000 > "$RAPL_DIR/constraint_1_power_limit_uw" 2>/dev/null || true
    fi
}

apply_boost

while true; do
    sleep 5
    BIT38=$(rdmsr -f 38:38 0x1a0 2>/dev/null | head -n1 || echo "1")
    if [ "$BIT38" != "0" ]; then
        apply_boost
    fi
done
EOF

    chmod +x "$SCRIPT_TARGET"

    echo "[3/4] Criando serviço systemd..."
    cat > "$SERVICE_TARGET" << EOF
[Unit]
Description=Daemon de Desbloqueio e Controle Termico Samsung
After=multi-user.target

[Service]
Type=simple
ExecStart=$SCRIPT_TARGET
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    echo "[4/4] Habilitando e ativando o serviço no boot..."
    systemctl daemon-reload
    systemctl enable --now unlock-samsung-cpu.service

    echo "Serviço instalado e habilitado com sucesso!"
    sleep 2
    show_status
}

uninstall_boost() {
    check_root
    systemctl disable --now unlock-samsung-cpu.service 2>/dev/null || true
    rm -f "$SERVICE_TARGET" "$SCRIPT_TARGET"
    systemctl daemon-reload
    echo "Desinstalado com sucesso."
}

case "${1:-install}" in
    install) install_boost ;;
    uninstall) uninstall_boost ;;
    status) show_status ;;
    *) echo "Uso: $0 {install|uninstall|status}" ;;
esac
