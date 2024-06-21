#!/bin/bash

calculate_hashes() {
    local output_file=$1
    > "$output_file"
    for file in "${FILES_TO_CHECK[@]}"; do
        if [ -e "$file" ]; then
            if [ -f "$file" ]; then
                sha256sum "$file" >> "$output_file"
            elif [ -d "$file" ]; then
                find "$file" -type f -exec sha256sum {} + | sort >> "$output_file"
            fi
        fi
    done
}

FILES_TO_CHECK=(
    "/etc/passwd" "/etc/shadow" "/etc/group" "/etc/sudoers" "/etc/hosts"
    "/etc/network/interfaces" "/etc/resolv.conf" "/etc/hosts.allow" "/etc/hosts.deny"
    "/etc/ssh/sshd_config" "/etc/ssh/ssh_config" "/etc/pam.d/*" "/etc/apparmor/*"
    "/etc/crontab" "/var/spool/cron/*" "/var/log/auth.log" "/var/log/syslog"
    "/var/log/messages" "/etc/init.d/"
)

OUTPUT_FILE="hashes.txt"
TEMP_FILE="temp_hashes.txt"

echo "Do you want to verify the integrity of a previous output? (y/n)"
read -r response

if [ "$response" = "y" ]; then
    echo "Enter the checksum of the previous output:"
    read -r previous_checksum

    calculate_hashes "$TEMP_FILE"
    current_checksum=$(sha256sum "$TEMP_FILE" | cut -d' ' -f1)

    if [ "$previous_checksum" = "$current_checksum" ]; then
        echo "No changes detected."
    else
        echo "Changes detected. Saving new hashes to $OUTPUT_FILE"
        echo "New checksum: $current_checksum"
        echo "Modified files:"
        diff -u <(sort "$OUTPUT_FILE") <(sort "$TEMP_FILE") | grep '^[-+]' | grep -v '^[-+]$' | sed 's/^-/Removed: /;s/^+/Added or Modified: /'
        mv "$TEMP_FILE" "$OUTPUT_FILE"
    fi
else
    calculate_hashes "$OUTPUT_FILE"
    checksum=$(sha256sum "$OUTPUT_FILE" | cut -d' ' -f1)
    echo "Checksum of $OUTPUT_FILE: $checksum"
fi

rm -f "$TEMP_FILE"
