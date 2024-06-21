#!/bin/bash

# Função para calcular hashes
calculate_hashes() {
    local output_file=$1
    > "$output_file"
    for file in "${FILES_TO_CHECK[@]}"; do
        echo "Processing $file..."
        date=$(date +"%Y-%m-%d %H:%M:%S")
        if [ -f "$file" ]; then
            hash=$(sha256sum "$file" | cut -d' ' -f1)
        elif [ -d "$file" ]; then
            hash=$(find "$file" -type f -exec sha256sum {} \; | sort | sha256sum | cut -d' ' -f1)
        fi
        echo "$date $file: $hash" >> "$output_file"
        echo "Done processing $file."
    done
}

# Arquivos e diretórios a serem verificados
FILES_TO_CHECK=(
    "/etc/passwd"
    "/etc/shadow"
    "/etc/group"
    "/etc/sudoers"
    "/etc/hosts"
    "/etc/network/interfaces"
    "/etc/resolv.conf"
    "/etc/hosts.allow"
    "/etc/hosts.deny"
    "/etc/ssh/sshd_config"
    "/etc/ssh/ssh_config"
    "/etc/pam.d/*"
    "/etc/apparmor/*"
    "/etc/crontab"
    "/var/spool/cron/*"
    "/var/log/auth.log"
    "/var/log/syslog"
    "/var/log/messages"
    "/etc/init.d/"
)

# Arquivo de saída
OUTPUT_FILE="hashes.txt"
TEMP_FILE="temp_hashes.txt"

# Pergunta ao usuário se ele quer verificar integridade de uma saída anterior
echo "Do you want to verify the integrity of a previous output? (y/n)"
read -r response

if [ "$response" = "y" ]; then
    # Solicita o checksum do usuário
    echo "Enter the checksum of the previous output:"
    read -r previous_checksum

    # Calcula os novos hashes
    calculate_hashes "$TEMP_FILE"

    # Calcula o checksum do arquivo temporário
    current_checksum=$(sha256sum "$TEMP_FILE" | cut -d' ' -f1)

    # Compara os checksums
    if [ "$previous_checksum" = "$current_checksum" ]; then
        echo "No changes detected."
    else
        echo "Changes detected. Saving new hashes to $OUTPUT_FILE"
        echo ""
        mv "$TEMP_FILE" "$OUTPUT_FILE"
        echo "New checksum: $current_checksum"
        
        # Identifica quais arquivos foram modificados
        if [ -f "$OUTPUT_FILE" ]; then
            diff <(sort "$OUTPUT_FILE") <(sort "$TEMP_FILE") > modified_files.txt
            echo "Modified files:"
            cat modified_files.txt
        fi
    fi
else
    # Calcula os hashes e salva no arquivo de saída
    calculate_hashes "$OUTPUT_FILE"

    # Calcula o checksum do arquivo hashes.txt
    checksum=$(sha256sum "$OUTPUT_FILE" | cut -d' ' -f1)
    echo "Checksum of $OUTPUT_FILE: $checksum"
fi

# Limpa arquivos temporários
rm -f "$TEMP_FILE" modified_files.txt
