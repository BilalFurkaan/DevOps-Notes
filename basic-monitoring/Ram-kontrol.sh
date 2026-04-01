#!/bin/bash

#Ram Kullanimini kontrol et

ram_kontrol() {
    kullanim=$(free | awk 'NR==2 {print $3}')
    echo "RAM kullanımı: $kullanim KB"

    if [ $kullanim -gt 2000000 ]; then
        echo "UYARI: RAM kullanımı kritik düzeyde!"
    else
        echo "RAM durumu normal."
    fi
}

ram_kontrol

