#!/bin/bash

# Disk kullanımını kontrol et
disk_kontrol() {
    kullanim=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
    
    echo "Disk kullanımı: %$kullanim"
    
    if [ $kullanim -gt 80 ]; then
        echo "UYARI: Disk dolmak üzere!"
    else
        echo "Disk durumu normal."
    fi
}

disk_kontrol


