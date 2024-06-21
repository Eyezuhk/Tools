#!/bin/bash

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
  "/bin/"  # Essential system binaries
  "/sbin/"  # Essential system binaries (superuser only)
  "/usr/bin/"  # User binaries
  "/usr/sbin/"  # User binaries (superuser only)
  "/etc/init.d/"  # System initialization scripts
)

# Arquivo de saída
OUTPUT_FILE="hashes.txt"

# Calcula o hash SHA-256 de cada arquivo e diretório
for file in "${FILES_TO_CHECK[@]}"; do
  if [ -f "$file" ]; then
    echo "$file: $(sha256sum "$file" | cut -d' ' -f1)" >> "$OUTPUT_FILE"
  elif [ -d "$file" ]; then
    echo "$file: $(find "$file" -type f -exec sha256sum {} \; | cut -d' ' -f1 | sha256sum | cut -d' ' -f1)" >> "$OUTPUT_FILE"
  fi
done
