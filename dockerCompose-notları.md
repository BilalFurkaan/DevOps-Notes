# Docker Compose, Volume ve Network Notları

## Docker Compose Nedir?

Birden fazla container'ı tek bir YAML dosyasıyla tanımlayıp yönetmeye yarar.
Örnek: bir web sunucusu (nginx) + veritabanı (postgres) tek bir docker-compose.yml
dosyasında tanımlanır, tek komutla ayağa kalkar, tek komutla silinir.

docker run ile her container'ı ayrı ayrı çalıştırmak yerine, compose ile
hepsini bir arada tanımlar, network ve volume'larını otomatik yönetirsin.

## Compose Temel Komutlar

docker-compose up -d
  → Container'ları oluştur ve arka planda başlat
  → -d (detached): terminal'e yapışmaz, arka planda çalışır
  → -d yazmazsan loglar terminale akar, Ctrl+C ile container'lar durur

docker-compose down
  → Container'ları durdurur VE siler
  → Network'ü de siler
  → Volume'a dokunmaz — veri kalır

docker-compose down -v
  → Container + network + volume hepsini siler
  → Veritabanı dahil her şey sıfırlanır
  → Production'da backup olmadan bunu çalıştıran kişi CV'sini günceller

docker-compose stop
  → Container'ları sadece dondurur, silmez
  → Yazılabilir katman diskte kalır
  → start ile aynı container geri gelir

docker-compose ps
  → Sadece bu compose projesinin container'larını gösterir
  → docker ps ise sistemdeki TÜM container'ları gösterir — farkı bil

docker-compose exec <servis> <komut>
  → Çalışan bir servisin içinde komut çalıştırır
  → Örnek: docker-compose exec db psql -U postgres
  → bash'e girip oradan psql açmaya gerek yok, tek satırda direkt psql'e düşersin

## depends_on

depends_on: - db yazınca compose db container'ını web'den önce başlatır.
Ama bu "db hazır" demek DEĞİL. Container başlamış olabilir ama PostgreSQL
henüz bağlantı kabul etmiyor olabilir. Web bağlanmaya çalışır,
"connection refused" alır. Sadece başlatma SIRASI, hazırlık GARANTİSİ değil.

## Volume — Nedir ve Neden Gerekli?

Her container'ın kendine ait bir yazılabilir katmanı var (image'ın üstüne
binen, sadece o container'a özel katman). Volume tanımlamazsan veritabanı
verisini bu katmana yazar. Container silinince (rm, down) bu katman da
silinir — veri gider.

Volume bu sorunu çözer: veriyi container'ın içinden çıkarıp host makineye
taşır. Container doğar, ölür — volume umursamaz, veri yerinde durur.

Özet formül:
  Volume olmasaydı → veri container'a yazılır → container silinince yok olur
  Volume varsa → veri host'a taşınır → container silinince veri kalır

## Volume — Fiziksel Konum

Volume host makinede şurada durur:
  /var/lib/docker/volumes/<volume_adı>/_data

Container bu klasörü mount eder (bağlar). Veri aslında container'ın
içinde değil, host'un diskinde.

## Volume — Named vs Anonim

Named volume:
  → Compose dosyasında isim verirsin: db-data
  → docker volume ls'te adıyla görürsün
  → Yönetmesi, takip etmesi, silmesi kolay
  → Production'da HER ZAMAN named volume kullan

Anonim volume:
  → İsim vermezsin, Docker rastgele hash atar
  → dc500734d0d6b60da7d1eb5d2b9a7ea736c9755a... gibi isimler
  → Container silinince öksüz kalır, kimse sahiplenmez
  → Düzinelerce birikince disk dolar
  → İş yerindeki "disk doldu" sorununun muhtemel sebebi

## Volume — Çalıştığını şu şekilde test edebiliriz

1. PostgreSQL'e bağlan:
   docker-compose exec db psql -U postgres

2. Tablo oluştur ve veri ekle:
   volume_test tablosunda "Volume calisiyor Furkan" verisi

3. docker-compose down ile container'ları SİL (stop değil)
   → Yazılabilir katman gitti

4. docker volume ls ile volume'un HALA durduğunu gözlemlendi
   → Container öldü ama volume yaşıyor

5. docker-compose up -d ile container'ları sıfırdan oluştur

6. Tekrar bağlanıp SELECT yaptık — veri duruyordu
   → Volume kanıtlandı

7. docker-compose down -v ile volume DAHİL sil

8. Tekrar up edip SELECT yapıldığında — tablo bile yoktu
   → "relation volume_test does not exist"
   → Volume silinince PostgreSQL sıfırdan başladı, boş veritabanı

Kritik fark: stop sadece dondurur (veri hep kalır çünkü container
hala var). down container'ı siler — veri SADECE volume varsa kalır.
Bu ikisini karıştırma, stop ile test yapmak volume'u kanıtlamaz.

## Volume — Temizlik Komutları

docker volume ls
  → Tüm volume'ları listele

docker volume prune
  → Hiçbir container'a bağlı olmayan tüm volume'ları sil
  → Tehlikeli ama etkili — anonim volume birikimini temizler

## Volume — Version Upgrade Senaryosu

PostgreSQL 17.0'dan 17.2'ye geçerken:
  1. Compose dosyasında image versiyonunu değiştir
  2. docker-compose down (volume kalır)
  3. docker-compose up -d (yeni image, eski veri)

down -v YAPMA — veriyi sıfırlamak anlamsız.
Minor version (17.0→17.2) genelde sorunsuz çalışır.
Major version (16→17) geçişlerinde data formatı değişebilir,
o zaman pg_dump ile backup al, yeni versiyonda restore et.

## Network — Nedir ve Neden Gerekli?

Container'lar birbirleriyle konuşmak için aynı network'te olmalı.
Compose her proje için otomatik bir network oluşturur: proje_default
(bizde compose-temeller_default).

Temel sorun: her down/up'ta container yeniden oluşuyor, IP değişebilir.
Web uygulaması veritabanına hangi IP ile bağlanacak? Sabit IP yazamaz.

Çözüm: Docker DNS. Compose network'ünde her container'a servis adıyla
ulaşılır. Web uygulaması host olarak "db" yazar — Docker DNS bunu
o anki container'ın IP'sine çevirir. IP değişse bile isim aynı kalır.

Linux'taki DNS ile aynı mantık:
  İnternette: google.com → DNS → 142.250.x.x
  Docker'da:  db → Docker DNS → 172.18.0.x

Gerçek dünyada config dosyasında şöyle görünür:
  DATABASE_HOST=db
  DATABASE_PORT=5432
  IP yok, sadece servis adı.

## Network — Test Ettiğimiz Şeyler

Aynı network'te DNS çözümleme:
  docker-compose exec web getent hosts db
  → IP döndü — web, db'yi isimle bulabiliyor

Farklı network'te izolasyon:
  docker-compose exec web getent hosts furkan-cv
  → Boş döndü — furkan-cv farklı network'te, web onu göremez

docker network inspect compose-temeller_default
  → Container'ların IP'lerini ve isimlerini gösterir
  → Her down/up'ta IP değişebilir ama isim sabit kalır

## Network — Türleri

bridge:
  → Varsayılan. docker run ile oluşturulan container'lar buraya düşer
  → Compose network'ü de bridge tipinde AMA farkı: DNS çözümleme var
  → Varsayılan bridge'de DNS yok, sadece IP ile iletişim

host:
  → Container host'un network'ünü doğrudan paylaşır
  → Port mapping gerekmez ama izolasyon sıfır

none:
  → Network yok, container tamamen izole

## Network — İzolasyon Neden Önemli?

Her compose projesi kendi network'ünde çalışır.
Proje A'nın container'ları Proje B'nin container'larını göremez.
Bir proje hacklense diğerine sıçramaz.

furkan-cv container'ı docker run ile oluşturuldu → varsayılan bridge'e düştü
compose servisleri → compose-temeller_default network'ünde
İkisi birbirini göremez — kanıtladık.

