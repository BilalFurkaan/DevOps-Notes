#!/bin/bash

tarih=$(date '+%Y-%m-%d_%H-%M')
rapor_dosyasi=/home/furkan/devops/SystemHealthPanel/Reports/rapor_$tarih.txt

{
echo "========================================="
echo "Sistem Raporu: $(date '+%Y-%m-%d %H:%M')"
echo "========================================="

disk_kullanimi() {
    dkullanim=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
    echo "Disk Kullanimi: %$dkullanim"
}

ram_kullanimi() {
    rkullanim=$(free | awk 'NR==2 {print $3}')
    rkullanim_gb=$(echo "$rkullanim" | awk '{printf "%.2f", $1/1024/1024}')
    echo "RAM Kullanimi: $rkullanim_gb GB"
}

giris_yapanlar() {
    echo "=== Sisteme Giris Yapanlar ==="
    who
    echo "Toplam: $(who | wc -l) kullanici"
}

cpu_kullanim() {
    echo "=== CPU Kullanimi ==="
    echo "Anlik CPU Yuku: $(top -bn1 | grep 'Cpu(s)' | awk '{print $2}')%"
    echo ""
    echo "=== En Cok CPU Kullanan 3 Process ==="
    ps aux --sort=-%cpu | awk 'NR==1 || NR<=4 {print $1, $2, $3, $11}'
}

disk_kullanimi
ram_kullanimi
giris_yapanlar
echo "Uptime: $(uptime)"
cpu_kullanim

} | tee $rapor_dosyasi

echo "Rapor kaydedildi: $rapor_dosyasi"

