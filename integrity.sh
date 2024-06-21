#!/bin/bash

# Pergunta ao usuário se ele quer verificar integridade de uma saída anterior
echo "Do you want to verify the integrity of a previous output? (y/n)"
read -r response

if [ "$response" = "y" ]; then
  # Solicita o checksum do usuário
  echo "Enter the checksum of the previous output:"
  read -r previous_checksum

  # Calcula o checksum do arquivo hashes.txt
  current_checksum=$(sha256sum hashes.txt | cut -d' ' -f1)

  # Compara os checksums
  if [ "$previous_checksum" = "$current_checksum" ]; then
    echo "No changes dettected."
  else
    echo "The integrity of the previous output is compromised."
    # Identifica quais arquivos foram modificados
    diff <(sort hashes.txt) <(sort previous_hashes.txt) > modified_files.txt
    echo "Modified files:"
    cat modified_files.txt
  fi
fi

# Arquivos e diretórios a serem verificados
FILES_TO_CHECK=(
  "/etc/passwd"  # User account information
  "/etc/shadow"  # Encrypted user passwords
  "/etc/group"  # Group information
  "/etc/sudoers"  # Sudo permissions
  "/etc/hosts"  # Hostname resolution
  "/etc/network/interfaces"  # Network interface configuration
  "/etc/resolv.conf"  # DNS resolver configuration
  "/etc/hosts.allow"  # Host-based access control
  "/etc/hosts.deny"  # Host-based access control
  "/etc/ssh/sshd_config"  # SSH server configuration
  "/etc/ssh/ssh_config"  # SSH client configuration
  "/etc/pam.d/*"  # Pluggable Authentication Modules
  "/etc/apparmor/*"  # Application Armor security profiles
  "/etc/crontab"  # System cron jobs
  "/var/spool/cron/*"  # User cron jobs
  "/var/log/auth.log"  # Authentication logs
  "/var/log/syslog"  # System logs
  "/var/log/messages"  # System messages
  "/etc/init.d/"  # System initialization scripts  
#  "/bin/"  # Essential system binaries
#  "/sbin/"  # Essential system binaries (superuser only)
#  "/usr/bin/"  # User binaries
#  "/usr/sbin/"  # User binaries (superuser only)

)

# Arquivo de saída
OUTPUT_FILE="hashes.txt"

# Calcula o hash SHA-256 de cada arquivo e diretório
for file in "${FILES_TO_CHECK[@]}"; do
  echo "Processing $file..."
  date=$(date +"%Y-%m-%d %H:%M:%S")
  if [ -f "$file" ]; then
    hash=$(sha256sum "$file" | cut -d' ' -f1)
  elif [ -d "$file" ]; then
    hash=$(find "$file" -type f -exec sha256sum {} \; | cut -d' ' -f1 | sha256sum | cut -d' ' -f1)
  fi
  echo "$date $file: $hash" >> "$OUTPUT_FILE"
  echo "Done processing $file."
done

# Calcula o checksum do arquivo hashes.txt
checksum=$(sha256sum hashes.txt | cut -d' ' -f1)
echo "Checksum of hashes.txt: $checksum"
