#!/bin/bash

echo "=== Sistem Kontrolü Başlıyor ==="
echo ""

bash /home/furkan/devops/basic-monitoring/disk-kontrol.sh
echo ""
bash /home/furkan/devops/basic-monitoring/Ram-kontrol.sh

echo ""
echo "=== Kontrol Tamamlandı ==="
