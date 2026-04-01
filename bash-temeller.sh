#!/bin/bash

# Degisken tanimlama

isim="Furkan"
echo "Merhaba $isim!"

#Tarih bilgisi
tarih=$(date)
echo "Bugunun tarihi: $tarih"

# Koşul tanımlama
sayi=10

if [ $sayi -gt 5 ]; then 
    echo "$sayi sayısı 5 den büyük"
else
    echo "$sayi sayısı 5 den küçük"
fi 

# Döngüler
for i in 1 2 3 4 5 ; do 
    echo "Sayi: $i"
done

# Klasördeki dosyaları döngüyle listele

for dosya in /home/furkan/devops/*; do
    echo "Dosya bulundu: $dosya"
done

#Fonksiyon Tanımlama

selamlama() {
 echo "Merhaba" $1!
 echo "DevOps Öğrenme sürecim " 
 }

#Fonksiyonu Çagirma
selamlama "Furkan"
selamlama "Bilal Furkan"
