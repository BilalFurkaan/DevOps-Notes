# Docker Mini Proje Notları — Visit Counter

## Proje Mimarisi

Üç katmanlı (three-tier) bir web uygulaması:

```
Tarayıcı → nginx (reverse proxy) → Flask app → PostgreSQL
```

- **nginx**: Reverse proxy. Dış dünyaya açık tek servis. Host port `8080`'den gelen istekleri alır, `app:5000`'e yönlendirir. Kendisi içerik üretmez, sadece trafik yönlendirir. Stateless.
- **app (Flask)**: Uygulamanın kendisi. Her istek geldiğinde db'deki ziyaret sayacını 1 artırır, toplam sayıyı döndürür. Dışarıya kapalı — sadece nginx üzerinden erişilir. Stateless.
- **db (PostgreSQL)**: Veritabanı. Ziyaret sayacını tutar. Named volume ile veri kalıcılığı sağlanır. Dışarıya kapalı. **Stateful** — çünkü state (veri) burada yaşıyor.

## Neden Sadece nginx Dışarıya Açık?

Reverse proxy pattern: dış dünya sadece tek bir kapıdan girer. Bu üç avantaj sağlar:

- **Güvenlik**: app ve db dış network'e kapalı. Saldırı yüzeyi sadece nginx ile sınırlı.
- **Esneklik**: Yarın app 3 kopya olsa nginx load balance yapar. Dış dünya fark etmez.
- **Kontrol**: Rate limiting, SSL, caching, loglama tek noktada (nginx'te) yapılır. App bunlarla uğraşmaz.

Production'da hemen hemen hiçbir uygulama doğrudan internete açılmaz. Önünde mutlaka bir reverse proxy veya load balancer bulunur.

## State, Stateful ve Stateless

- **State**: Bir sistemin o anki durumu, hafızası, verisi. DB'deki tablolar, satırlar, sayaç değeri — bunlar state.
- **Stateful servis**: Kendi verisi var, saklar, kaybederse sorun olur. Örnek: PostgreSQL. Volume gerektirir.
- **Stateless servis**: Veri saklamaz. Silinip sıfırdan kurulsa hiçbir şey kaybolmaz. Örnek: nginx, Flask app.

Kural: "Bu servis silinip sıfırdan kurulsa bir şey kaybeder miyim?" Evet → stateful (volume ver). Hayır → stateless.

## Volume — Ne İşe Yaradı?

`db-data` adında named volume tanımlandı. PostgreSQL'in veri dizini (`/var/lib/postgresql/data`) bu volume'a bağlı.

### Test Sonuçları

| Senaryo | Komut | Sonuç |
|---------|-------|-------|
| Sayaç artışı | `curl localhost:8080` (8 kez) | Sayaç 1'den 8'e çıktı |
| Container silme (volume korumalı) | `docker-compose down` → `up -d` → `curl` | Sayaç **9**'dan devam etti |
| Volume ile silme | `docker-compose down -v` → `up -d` → `curl` | Sayaç **1**'den başladı |

## down vs down -v vs stop

| Komut | Container | Network | Named Volume | Veri |
|-------|-----------|---------|-------------|------|
| `docker-compose stop` | Durur (silinmez) | Kalır | Kalır | Kalır |
| `docker-compose down` | Silinir | Silinir | **Kalır** | **Kalır** |
| `docker-compose down -v` | Silinir | Silinir | **Silinir** | **Silinir** |

## Docker DNS

Container'lar aynı Compose network'ünde birbirlerini **servis adıyla** bulur. IP adresi yazmaya gerek yok.

- `docker-compose.yml`'de servis adı `db` → Docker DNS bu ismi otomatik olarak container'ın IP'sine çözümler.
- Kanıt: `docker-compose exec app getent hosts db` → `172.19.0.2 db`
- IP yazmama sebebi: `down`/`up` sonrası container yeni IP alabilir. Servis adı her zaman doğru container'a çözümlenir.

## --build Flag'i

`docker-compose up -d --build` → Compose dosyasında `build:` tanımı olan servislerin image'larını yeniden build eder.

- Bu projede sadece `app` servisinde `build: ./app` var, sadece onun image'ı build edilir.
- `--build` olmazsa: Daha önce build edilmiş image varsa onu kullanır. Kodda değişiklik yapılmış olsa bile eski image ile çalışır.
- Kural: Kod değişikliği yaptıysan `--build` kullan.

## RUN vs CMD (Dockerfile)

- **RUN**: Image **build edilirken** çalışır. Sonucu image'a katman olarak yazılır. Örnek: `RUN pip install -r requirements.txt` → paketler image'a kurulur.
- **CMD**: Container **başlatılırken** çalışır. Image'a bir şey yazmaz, sadece "container ayağa kalkınca bu komutu çalıştır" der. Örnek: `CMD ["python", "app.py"]`

`RUN python app.py` yazsaydık: build sırasında app çalışmaya başlar, db henüz yok, bağlantı hatası, build başarısız.

## Katman Cache Sıralaması

Docker her Dockerfile satırını bir katman (layer) olarak saklar. Bir katman değişmezse cache'ten gelir.

Kural: **Bir katman değişince ondan sonraki tüm katmanlar yeniden çalışır.**

```dockerfile
COPY requirements.txt .        # Nadiren değişir → üstte
RUN pip install -r requirements.txt  # Cache'ten gelir (requirements aynıysa)
COPY app.py .                  # Sık değişir → altta
```

Ters sırada olsaydı: `app.py`'de tek harf değişse `pip install` baştan çalışırdı — gereksiz zaman kaybı.

Kural: **Az değişeni yukarı, çok değişeni aşağı koy.**

## PostgreSQL Environment Variables

`postgres:17` image'ı ilk başlatmada şu environment variable'ları okur:

- `POSTGRES_USER` → kullanıcı oluşturur
- `POSTGRES_PASSWORD` → şifre verir
- `POSTGRES_DB` → veritabanı oluşturur

**Önemli**: Bu değişkenler sadece volume boşken (ilk kurulum) okunur. Volume'da zaten veri varsa tamamen yok sayılır.

## Forward Proxy vs Reverse Proxy

- **Forward proxy**: İstemcinin önünde durur. Sunucu istemciyi görmez, proxy'yi görür. Amaç: filtreleme, loglama, gizlilik.
- **Reverse proxy**: Sunucunun önünde durur. İstemci arkadaki uygulamayı görmez, proxy'yi görür. Amaç: güvenlik, load balancing, SSL, caching. (Bu projedeki nginx bu.)

Fark: forward proxy **istemciyi** gizler, reverse proxy **sunucuyu** gizler
