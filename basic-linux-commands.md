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
# Linux Servis ve Process Yönetimi

## Process Nedir?
Linux'ta çalışan her programa **process** denir.
Her process'in benzersiz bir **PID** (Process ID) vardır.

## Process Durumları (STAT)
| Harf | Anlamı |
|------|--------|
| `R` | Running — şu an çalışıyor |
| `S` | Sleeping — bir şey bekliyor |
| `I` | Idle — boşta |
| `Z` | Zombie — bitti ama bellekten silinmedi |

## Process Komutları
| Komut | Açılımı | Ne Yapar |
|-------|---------|----------|
| `ps aux` | Process Status | Tüm processleri listeler |
| `ps aux \| grep isim` | - | Belirli process'i filtreler |
| `top` | - | Canlı process izleme |
| `htop` | - | Renkli, gelişmiş canlı izleme |
| `kill PID` | - | SIGTERM — temiz kapat |
| `kill -9 PID` | - | SIGKILL — zorla öldür |

### kill Farkı
- `kill PID` → **Terminated** → process temiz kapanır, dosyaları kapatır
- `kill -9 PID` → **Killed** → zorla öldürür, veri kaybı olabilir
- Önce `kill` dene, olmadıysa `kill -9` kullan!

---

## systemd ve systemctl

**systemd** → Linux'un init sistemi, PID 1, tüm servislerin şefi
**systemctl** → System Control → systemd'yi kontrol eder

### Temel Komutlar
| Komut | Ne Yapar |
|-------|----------|
| `sudo systemctl start servis` | Şu an başlat |
| `sudo systemctl stop servis` | Şu an durdur |
| `sudo systemctl restart servis` | Yeniden başlat |
| `sudo systemctl status servis` | Durumu göster |
| `sudo systemctl enable servis` | Açılışta otomatik başlat |
| `sudo systemctl disable servis` | Açılışta başlatma |
| `sudo systemctl is-enabled servis` | Açılışta başlıyor mu? |
| `sudo systemctl enable --now servis` | Hem başlat hem enable et |

### enable vs start Farkı
- **start** → servisi şu an başlatır, sistem yeniden başlayınca çalışmaz
- **enable** → sistem her açılışta otomatik başlatır
- Gerçek dünyada ikisini birlikte kullan!

### Socket Activation
SSH örneği:
- `ssh.service` → disabled
- `ssh.socket` → enabled
- Bağlantı gelince socket, servisi uyandırır — daha verimli!

---

## journalctl — Log Yönetimi

**journalctl** → Journal Control → sistem loglarını okur

| Komut | Ne Yapar |
|-------|----------|
| `sudo journalctl -u servis` | Servis loglarını göster |
| `sudo journalctl -u servis -f` | Canlı izle |
| `sudo journalctl -u servis -n 20` | Son 20 satır |
| `sudo journalctl -u servis --since "1 hour ago"` | Son 1 saatin logları |
| `sudo journalctl -u servis --since "today"` | Bugünkü loglar |

### Gerçek Dünyada Kullanım
- Servis neden başlamadı? → `journalctl -u servis`
- Anlık ne oluyor? → `journalctl -u servis -f`
- Gece kaçta çöktü? → `journalctl -u servis --since "today"`
