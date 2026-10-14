-- ============================================================
-- 1. STRUKTUR TABEL (DDL)
-- ============================================================

CREATE TABLE IF NOT EXISTS kosts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nama_kost VARCHAR(255) NOT NULL,
    alamat TEXT,
    total_kamar INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS kamars (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    kost_id BIGINT NOT NULL,
    nomor_kamar VARCHAR(50) NOT NULL,
    harga DECIMAL(12, 2) NOT NULL,
    status ENUM('isi', 'kosong') DEFAULT 'kosong',
    FOREIGN KEY (kost_id) REFERENCES kosts(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS penghunis (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    kamar_id BIGINT NOT NULL,
    nama VARCHAR(255) NOT NULL,
    tanggal_masuk DATE NOT NULL,
    tanggal_keluar DATE,
    FOREIGN KEY (kamar_id) REFERENCES kamars(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS transaksis (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    penghuni_id BIGINT NOT NULL,
    jumlah_bayar DECIMAL(12, 2) NOT NULL,
    tanggal_bayar DATE NOT NULL,
    bulan INT NOT NULL CHECK (bulan BETWEEN 1 AND 12),
    tahun INT NOT NULL,
    FOREIGN KEY (penghuni_id) REFERENCES penghunis(id) ON DELETE CASCADE
);

-- ============================================================
-- 2. QUERY ANALYTICS
-- ============================================================

-- Query A: Hitung Persentase Okupansi Real-time Per Kos
SELECT 
    k.id AS kost_id,
    k.nama_kost,
    k.total_kamar,
    COUNT(CASE WHEN km.status = 'isi' THEN 1 END) AS kamar_terisi,
    COUNT(CASE WHEN km.status = 'kosong' THEN 1 END) AS kamar_kosong,
    ROUND(
        (COUNT(CASE WHEN km.status = 'isi' THEN 1 END) * 100.0) / NULLIF(k.total_kamar, 0), 
        2
    ) AS persentase_okupansi
FROM kosts k
LEFT JOIN kamars km ON k.id = km.kost_id
GROUP BY k.id, k.nama_kost, k.total_kamar;

-- Query B: List Kamar Kosong Lebih dari 2 Bulan (> 60 Hari)
SELECT 
    km.id AS kamar_id,
    k.nama_kost,
    km.nomor_kamar,
    km.harga,
    MAX(p.tanggal_keluar) AS tanggal_keluar_terakhir,
    DATEDIFF(CURRENT_DATE, MAX(p.tanggal_keluar)) AS hari_kosong
FROM kamars km
JOIN kosts k ON km.kost_id = k.id
LEFT JOIN penghunis p ON km.id = p.kamar_id
WHERE km.status = 'kosong'
GROUP BY km.id, k.nama_kost, km.nomor_kamar, km.harga
HAVING tanggal_keluar_terakhir IS NULL 
    OR DATEDIFF(CURRENT_DATE, tanggal_keluar_terakhir) > 60;