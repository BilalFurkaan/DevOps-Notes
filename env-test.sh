#!/bin/bash

echo "Ortam: $DEVOPS_ORTAM"
echo "Kullanıcı: $DEVOPS_USER"

if [ "$DEVOPS_ORTAM" = "production" ]; then
    echo "UYARI: Production ortamındasın!"
else
    echo "Geliştirme ortamındasın."
fi
