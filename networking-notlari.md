# Networking Temelleri

## Temel Kavramlar

### IP Adresi Nedir?
İnternetteki her cihazın benzersiz adresi — ev adresi gibi.
- **İç IP** → ağ içinde geçerli (192.168.x.x) — dışarıdan erişilemez
- **Dış IP** → internette görünen adres — modem/router üzerinden

### DNS Nedir?
**D**omain **N**ame **S**ystem → İsim-IP çevirme sistemi — telefon rehberi gibi
- `/etc/hosts` → DNS'den önce bakılan yerel rehber
- `/etc/resolv.conf` → hangi DNS sunucusu kullanılıyor

### NAT Nedir?
**N**etwork **A**ddress **T**ranslation → İç IP'leri dış IP'ye çevirir
- Evdeki modem NAT yapar
- İç ağdaki cihazlar dışarıdan görünmez → dolaylı yoldan  güvenlik saglar 

### Port Nedir?
IP adresi apartman, port daire numarası gibi:
192.168.64.2:22  → SSH
192.168.64.2:80  → HTTP
192.168.64.2:443 → HTTPS

### Yaygın Portlar
| Port | Protokol |
|------|----------|
| 22 | SSH |
| 80 | HTTP |
| 443 | HTTPS |
| 3306 | MySQL |
| 5432 | PostgreSQL |
| 6379 | Redis |
| 27017 | MongoDB |

### TTL Nedir?
**T**ime **T**o **L**ive → Paketin kaç router'dan geçebileceği
- Her router'dan geçince 1 azalır
- 0'a ulaşınca paket düşürülür — sonsuz döngü önlenir

### HTTP Status Kodları
| Kod | Anlamı |
|-----|--------|
| 200 | OK — başarılı |
| 301 | Moved Permanently — kalıcı yönlendirme |
| 302 | Found — geçici yönlendirme |
| 400 | Bad Request — hatalı istek |
| 401 | Unauthorized — giriş gerekli |
| 403 | Forbidden — yasak |
| 404 | Not Found — bulunamadı |
| 500 | Internal Server Error — sunucu hatası |

---

## Networking Komutları

| Komut | Açılımı | Ne Yapar |
|-------|---------|----------|
| `ip addr` | IP Address | IP adreslerini gösterir |
| `ping -c 4 hedef` | - | Hedefe paket gönder, erişilebilir mi? |
| `traceroute hedef` | - | Paket hangi router'lardan geçiyor? |
| `nslookup domain` | Name Server Lookup | DNS sorgusu yapar |
| `curl URL` | Client URL | HTTP isteği gönderir |
| `curl -I URL` | - | Sadece HTTP header'ları gösterir |
| `ss -tulnp` | Socket Statistics | Açık portları gösterir |

### ss Flagleri
| Flag | Açılımı | Ne Yapar |
|------|---------|----------|
| `-t` | TCP | TCP bağlantıları |
| `-u` | UDP | UDP bağlantıları |
| `-l` | Listen | Dinleyen portlar |
| `-n` | Numeric | Sayısal göster |
| `-p` | Process | Hangi process kullanıyor |

---

## UFW Firewall

**Temel Prensip:** Varsayılan olarak her şeyi engelle, sadece izin verdiklerini geçir

### Komutlar
| Komut | Ne Yapar |
|-------|----------|
| `sudo ufw enable` | Firewall'u aç |
| `sudo ufw disable` | Firewall'u kapat |
| `sudo ufw status verbose` | Kuralları göster |
| `sudo ufw allow 22/tcp` | Port 22'ye izin ver |
| `sudo ufw deny 80/tcp` | Port 80'i engelle |
| `sudo ufw delete allow 80/tcp` | Kuralı sil |
| `sudo ufw allow from IP to any port 22` | Sadece belirli IP'ye izin ver |

### Varsayılan Kurallar
Default: deny (incoming)   → dışarıdan gelen her şey engelli
Default: allow (outgoing)  → dışarıya giden her şey serbest


### Gerçek Dünya Kullanımı
- Production sunucusuna sadece ofis IP'sinden SSH erişimi
- Veritabanına sadece uygulama sunucusundan erişim
- Web sunucusunda sadece 80 ve 443 açık
