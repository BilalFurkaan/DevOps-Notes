# Temel Linux Komutları
### Navigasyon
| Komut | Açılımı | Ne Yapar |
|-------|---------|----------|
| `pwd` | Print Working Directory | Bulunduğun dizini gösterir |
| `ls` | List | Dizin içeriğini listeler |
| `ls -la` | List Long All | Gizli dosyalarla detaylı listeler |
| `cd` | Change Directory | Dizin değiştirir |
| `cd ..` | - | Bir üst dizine çıkar |

### Dosya İşlemleri
| Komut | Açılımı | Ne Yapar |
|-------|---------|----------|
| `touch` | Touch | Boş dosya oluşturur |
| `mkdir` | Make Directory | Klasör oluşturur |
| `rm` | Remove | Dosya siler |
| `rm -r` | Remove Recursive | Klasör ve içindekileri siler |
| `cp` | Copy | Dosya kopyalar |
| `mv` | Move | Dosya taşır veya yeniden adlandırır |
| `cat` | Concatenate | Dosya içeriğini gösterir |
| `nano` | Nano Editor | Dosya düzenler |

### Sistem Komutları
| Komut | Açılımı | Ne Yapar |
|-------|---------|----------|
| `sudo` | Superuser Do | Yönetici yetkisiyle çalıştırır |
| `chmod` | Change Mode | Dosya izinlerini değiştirir |
| `echo` | Echo | Terminale yazı yazdırır |
| `shutdown now` | - | Sistemi kapatır |
| `systemctl` | System Control | Servisleri yönetir |

---

## Dosya İzinleri
```
-rw-rw-r--
│├┤├┤├┤
││ │ │ └── Diğerleri: r-- (sadece okuma)
││ │ └──── Grup: rw- (okuma + yazma)
││ └────── Sahip: rw- (okuma + yazma)
│└──────── Tip: - dosya, d klasör
```

### İzin Sayıları
| Sayı | İzin | Açıklama |
|------|------|----------|
| 7 | rwx | Okuma + Yazma + Çalıştırma |
| 6 | rw- | Okuma + Yazma |
| 5 | r-x | Okuma + Çalıştırma |
| 4 | r-- | Sadece Okuma |

### Örnekler
```bash
chmod +x script.sh    # çalıştırma izni ekle
chmod 644 dosya.txt   # sahip rw, grup r, diğer r
chmod 755 script.sh   # sahip rwx, grup rx, diğer rx
```

---

## SSH
```bash
ssh kullanici@sunucu_ip   # sunucuya bağlan
```

- **Client:** Bağlanan taraf (Mac)
- **Server:** Bağlanılan taraf (Linux VM)
- **Port 22:** SSH'ın varsayılan portu
- Tüm trafik şifrelenir

---
