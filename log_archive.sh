#!/bin/bash
#Directory of logs
log_dir=/var/log

#Logs older than 7 days
days_to_keep_logs=7

#How long to keep backup archive of logs
days_to_keep_backups=30

#Archive directory path
archive_dir="$log_dir/archive"

#Searching loop
if [ ! -d "$archive_dir" ]; then
    mkdir -p "$archive_dir"
fi

#File naming
timestamp=$(date +"%d%m%Y_%H%M%S")
archive_file="$archive_dir/logs_archive_$timestamp.tar.gz"


find "$log_dir" -type f -mtime +$days_to_keep_logs -print0 | tar -czvf "$archive_file" --null -T -


echo "Logs archived in $archive_file on $(date)" >> "$archive_dir/archive_log.txt"


find "$log_dir" -type f -mtime +$days_to_keep_logs -exec rm -f {} \;


find "$archive_dir" -type f -name "*.tar.gz" -mtime +$days_to_keep_backups -exec rm -f {} \;


find "$archive_dir" -type f -name "*.tar.gz" -mtime +$days_to_keep_backups -exec rm -f {} \;


# Setup cron job function
setup_cron() {
    read -r -p "Do you want to add this script to cron for daily execution? (y/n) " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        cron_line="0 0 * * * find /var/logs"
        (crontab -l 2>/dev/null; echo "$cron_line") | crontab -
        echo "Cron job added: $cron_line"
    else
        echo "Cron job not added."
    fi
}

