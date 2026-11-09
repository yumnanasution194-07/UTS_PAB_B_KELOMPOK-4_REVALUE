import 'package:flutter/material.dart';

// ====================================================================
// REVALUE: main.dart LENGKAP (UTS PAB)
// ALUR: SplashScreen -> LoginScreen -> MainShell (navbar 4 tab: Home/Notifikasi/Educycle/Akun)
//   Home (PilihSampahScreen) -> AlamatScreen -> RingkasanScreen
//   Educycle -> DetailEdukasiScreen (halaman ke-9)
// ====================================================================

void main() {
  runApp(const RevalueApp());
}

// ====================================================================
// BAGIAN 1: APP & DATA DUMMY
// ====================================================================
class RevalueApp extends StatelessWidget {
  const RevalueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revalue',
      debugShowCheckedModeBanner: false,
      theme: buatTema(),
      // Bingkai ukuran HP: di laptop/Chrome tampilan tetap berbentuk HP
      // (lebar maks 400, tinggi maks 850) dan berada di tengah layar.
      // Di HP asli ukurannya otomatis penuh. Ubah angkanya sesuai selera.
      builder: (context, child) {
        return Container(
          color: const Color(0xFFDDE8DD), // warna latar di luar "layar HP"
          alignment: Alignment.center,
          child: ClipRect(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 850),
              child: child,
            ),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}

// Data dummy harga per satuan (kg, atau liter untuk Minyak Jelantah).
// Sumber: tabel "Daftar kategori sampah, harga, dan batas maksimal".
const Map<String, int> hargaPerKg = {
  'Plastik': 3000,
  'Besi': 5000,
  'Kertas/Karton': 2000,
  'Kaca/Botol Kaca': 500,
  'Organik - Daun': 500,
  'Organik - Sisa Sayuran': 500,
  'Minyak Jelantah': 6000, // per liter
  'Tekstil': 1000,
};

// Batas maksimal per kategori (per transaksi), satuan sesuai satuanKategori.
const Map<String, double> maksimalPerKategori = {
  'Plastik': 10,
  'Besi': 10,
  'Kertas/Karton': 10,
  'Kaca/Botol Kaca': 5,
  'Organik - Daun': 5,
  'Organik - Sisa Sayuran': 5,
  'Minyak Jelantah': 5, // liter
  'Tekstil': 5,
};

// Contoh sampah tiap kategori (ditampilkan kecil di bawah harga).
const Map<String, String> contohKategori = {
  'Plastik': 'Botol, gelas, kemasan plastik',
  'Besi': 'Besi bekas, kaleng, potongan besi',
  'Kertas/Karton': 'Kertas bekas, kardus, karton',
  'Kaca/Botol Kaca': 'Botol kaca, pecahan kaca (dikemas aman)',
  'Organik - Daun': 'Daun kering, daun gugur',
  'Organik - Sisa Sayuran': 'Sisa sayuran, kulit sayuran',
  'Minyak Jelantah': 'Minyak goreng bekas yang sudah disaring',
  'Tekstil': 'Pakaian bekas, kain perca',
};

// Satuan tiap kategori: semua kg, kecuali Minyak Jelantah (liter).
const String kategoriCair = 'Minyak Jelantah';
String satuanKategori(String kategori) =>
    kategori == kategoriCair ? 'liter' : 'kg';

// Batas pengumpulan HARIAN per pengguna.
// Sampah padat (semua kategori kecuali jelantah) maks 25 kg/hari.
// Minyak jelantah dihitung terpisah, maks 5 liter/hari.
const double batasHarianPadatKg = 25;
const double batasHarianJelantahLiter = 5;

// Akumulasi hari ini (dummy, disimpan di memori selama aplikasi berjalan).
double _terjualPadatHariIni = 0;
double _terjualJelantahHariIni = 0;
DateTime _tanggalAkumulasi = DateTime.now();

void _resetKuotaJikaGantiHari() {
  final sekarang = DateTime.now();
  if (sekarang.year != _tanggalAkumulasi.year ||
      sekarang.month != _tanggalAkumulasi.month ||
      sekarang.day != _tanggalAkumulasi.day) {
    _terjualPadatHariIni = 0;
    _terjualJelantahHariIni = 0;
    _tanggalAkumulasi = sekarang;
  }
}

double sisaKuotaPadat() {
  _resetKuotaJikaGantiHari();
  return batasHarianPadatKg - _terjualPadatHariIni;
}

double sisaKuotaJelantah() {
  _resetKuotaJikaGantiHari();
  return batasHarianJelantahLiter - _terjualJelantahHariIni;
}

// Total sampah padat (tanpa jelantah) dari satu keranjang.
double totalPadat(Map<String, double> berat) {
  double total = 0;
  berat.forEach((k, v) {
    if (k != kategoriCair) total += v;
  });
  return total;
}

String formatAngka(double n) =>
    n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toStringAsFixed(1);

// Ikon cadangan tiap kategori (dipakai jika gambar aset belum ada).
const Map<String, IconData> ikonKategori = {
  'Plastik': Icons.local_drink,
  'Besi': Icons.hardware,
  'Kertas/Karton': Icons.inventory_2,
  'Kaca/Botol Kaca': Icons.wine_bar,
  'Organik - Daun': Icons.eco,
  'Organik - Sisa Sayuran': Icons.restaurant,
  'Minyak Jelantah': Icons.opacity,
  'Tekstil': Icons.checkroom,
};

// ---------------- TEMPAT MENYISIPKAN GAMBAR KATEGORI ----------------
// Simpan gambar di assets/images/ lalu samakan nama file-nya di sini.
// Jika file belum ada, otomatis tampil ikon cadangan di atas.
const Map<String, String> asetKategori = {
  'Plastik': 'assets/images/kategori_plastik.png',
  'Besi': 'assets/images/kategori_besi.png',
  'Kertas/Karton': 'assets/images/kategori_kertas.png',
  'Kaca/Botol Kaca': 'assets/images/kategori_kaca.png',
  'Organik - Daun': 'assets/images/kategori_daun.png',
  'Organik - Sisa Sayuran': 'assets/images/kategori_sayuran.png',
  'Minyak Jelantah': 'assets/images/kategori_jelantah.png',
  'Tekstil': 'assets/images/kategori_tekstil.png',
};

// ====================================================================
// BAGIAN 2: SCREEN 1 - PILIH SAMPAH & INPUT BERAT
// ====================================================================
class PilihSampahScreen extends StatefulWidget {
  const PilihSampahScreen({super.key});

  @override
  State<PilihSampahScreen> createState() => _PilihSampahScreenState();
}

class _PilihSampahScreenState extends State<PilihSampahScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, bool> _dipilih = {};
  final Map<String, TextEditingController> _controllerBerat = {};

  // Untuk teks petunjuk "scroll ke bawah" bila isi belum terlihat semua.
  final ScrollController _scroll = ScrollController();
  bool _tampilHintScroll = false;

  @override
  void initState() {
    super.initState();
    for (final kategori in hargaPerKg.keys) {
      _dipilih[kategori] = false;
      _controllerBerat[kategori] = TextEditingController();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _cekHintScroll());
  }

  @override
  void dispose() {
    for (final c in _controllerBerat.values) {
      c.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  // Hint tampil jika masih ada isi di bawah yang belum terlihat.
  void _cekHintScroll() {
    if (!mounted || !_scroll.hasClients) return;
    final p = _scroll.position;
    final perlu = p.maxScrollExtent > 8 && p.pixels < p.maxScrollExtent - 8;
    if (perlu != _tampilHintScroll) {
      setState(() => _tampilHintScroll = perlu);
    }
  }

  Map<String, double> _kumpulkanBerat() {
    final hasil = <String, double>{};
    _dipilih.forEach((kategori, dicentang) {
      if (!dicentang) return;
      final teks = _controllerBerat[kategori]!.text.trim().replaceAll(',', '.');
      final berat = double.tryParse(teks);
      if (berat != null && berat > 0) {
        hasil[kategori] = berat;
      }
    });
    return hasil;
  }

  void _lanjut() {
    if (!_dipilih.values.any((v) => v)) {
      tampilkanSnackBar(context, 'Pilih minimal satu jenis sampah.',
          error: true);
      return;
    }
    if (!_formKey.currentState!.validate()) {
      tampilkanSnackBar(context, 'Periksa kembali berat sampah Anda.',
          error: true);
      return;
    }
    // Cek batas harian (sampah padat 25 kg/hari, jelantah 5 liter/hari).
    final berat = _kumpulkanBerat();
    final padat = totalPadat(berat);
    final jelantah = berat[kategoriCair] ?? 0;
    if (padat > sisaKuotaPadat() + 1e-9) {
      tampilkanSnackBar(
          context,
          'Melebihi batas ${formatAngka(batasHarianPadatKg)} kg/hari. '
          'Sisa kuota padat hari ini: ${formatAngka(sisaKuotaPadat())} kg.',
          error: true);
      return;
    }
    if (jelantah > sisaKuotaJelantah() + 1e-9) {
      tampilkanSnackBar(
          context,
          'Melebihi batas ${formatAngka(batasHarianJelantahLiter)} liter/hari. '
          'Sisa kuota jelantah hari ini: '
          '${formatAngka(sisaKuotaJelantah())} liter.',
          error: true);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AlamatScreen(beratPerKategori: berat),
      ),
    );
  }

  // Kotak info batas pengumpulan harian + sisa kuota.
  Widget _kotakBatasHarian() {
    final padatDipakai = totalPadat(_kumpulkanBerat());
    final melebihi = padatDipakai > sisaKuotaPadat() + 1e-9;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warnaBiru.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warnaBiru.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Batas pengumpulan harian',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Sampah padat: maks ${formatAngka(batasHarianPadatKg)} kg/hari '
            '(sisa ${formatAngka(sisaKuotaPadat())} kg)',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            'Minyak jelantah: maks ${formatAngka(batasHarianJelantahLiter)} liter/hari '
            '(sisa ${formatAngka(sisaKuotaJelantah())} liter), dihitung terpisah.',
            style: const TextStyle(fontSize: 12),
          ),
          if (padatDipakai > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Total sampah padat dipilih: ${formatAngka(padatDipakai)} kg'
                '${melebihi ? ' (melebihi sisa kuota!)' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: melebihi ? Colors.red.shade700 : warnaHijau,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Jual Sampah')),
      body: Stack(
        children: [
          NotificationListener<ScrollMetricsNotification>(
            onNotification: (_) {
              _cekHintScroll();
              return false;
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (_) {
                _cekHintScroll();
                return false;
              },
              child: SingleChildScrollView(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pilih jenis sampah',
                          style: tema.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Centang jenis sampah, lalu isi beratnya (kg).',
                          style: tema.textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      _kotakBatasHarian(),
                      const SizedBox(height: 12),
                      ...hargaPerKg.entries.map((e) {
                        final kategori = e.key;
                        final dicentang = _dipilih[kategori] ?? false;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            children: [
                              CheckboxListTile(
                                value: dicentang,
                                secondary: IkonAset(
                                  aset: asetKategori[kategori],
                                  cadangan:
                                      ikonKategori[kategori] ?? Icons.recycling,
                                  ukuran: 36,
                                  warna: warnaBiru,
                                ),
                                title: Text(kategori,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                isThreeLine: true,
                                subtitle: Text(
                                  '${formatRupiah(e.value)} / ${satuanKategori(kategori)}'
                                  ' \u2022 maks ${formatAngka(maksimalPerKategori[kategori] ?? 0)} ${satuanKategori(kategori)}\n'
                                  '${contohKategori[kategori] ?? ''}',
                                ),
                                onChanged: (v) {
                                  setState(() {
                                    _dipilih[kategori] = v ?? false;
                                    if (!(v ?? false)) {
                                      _controllerBerat[kategori]!.clear();
                                    }
                                  });
                                },
                              ),
                              if (dicentang)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: TextFormField(
                                    controller: _controllerBerat[kategori],
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: InputDecoration(
                                      labelText: 'Berat $kategori',
                                      suffixText: satuanKategori(kategori),
                                      hintText: 'contoh: 2.5',
                                    ),
                                    validator: (v) => validasiBerat(
                                      v,
                                      maks: maksimalPerKategori[kategori] ??
                                          beratMaksimalKg,
                                      satuan: satuanKategori(kategori),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                      EstimasiBox(total: hitungEstimasi(_kumpulkanBerat())),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _lanjut,
                          child: const Text('Lanjut'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Teks kecil petunjuk scroll (hilang otomatis saat sudah di bawah).
          if (_tampilHintScroll)
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.keyboard_arrow_down,
                            size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Scroll ke bawah untuk lihat selengkapnya',
                          style: TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ====================================================================
// BAGIAN 3: VALIDASI BERAT & HITUNG HARGA
// ====================================================================
const double beratMaksimalKg = 100;

String? validasiBerat(String? value,
    {double maks = beratMaksimalKg, String satuan = 'kg'}) {
  if (value == null || value.trim().isEmpty) {
    return 'Berat tidak boleh kosong';
  }
  final berat = double.tryParse(value.trim().replaceAll(',', '.'));
  if (berat == null) {
    return 'Masukkan angka yang valid';
  }
  if (berat <= 0) {
    return 'Berat harus lebih dari 0';
  }
  if (berat > maks) {
    return 'Maksimal ${formatAngka(maks)} $satuan per kategori';
  }
  return null;
}

double hitungSubtotal(String kategori, double beratKg) {
  final harga = hargaPerKg[kategori] ?? 0;
  return beratKg * harga;
}

double hitungEstimasi(Map<String, double> beratPerKategori) {
  double total = 0;
  beratPerKategori.forEach((kategori, berat) {
    total += hitungSubtotal(kategori, berat);
  });
  return total;
}

// 15000 -> "Rp15.000"
String formatRupiah(num nilai) {
  final bulat = nilai.round();
  final negatif = bulat < 0;
  final digit = bulat.abs().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < digit.length; i++) {
    if (i > 0 && (digit.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digit[i]);
  }
  return '${negatif ? '-' : ''}Rp$buffer';
}

class EstimasiBox extends StatelessWidget {
  final double total;

  const EstimasiBox({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: skema.secondary.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: skema.secondary, width: 1.5),
      ),
      child: Column(
        children: [
          const Text('Estimasi Harga'),
          const SizedBox(height: 4),
          Text(
            formatRupiah(total),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: skema.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// BAGIAN 4: SCREEN 2 - ALAMAT PENJEMPUTAN
// ====================================================================
class AlamatScreen extends StatefulWidget {
  final Map<String, double> beratPerKategori;

  const AlamatScreen({super.key, required this.beratPerKategori});

  @override
  State<AlamatScreen> createState() => _AlamatScreenState();
}

class _AlamatScreenState extends State<AlamatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _patokanController = TextEditingController(); // opsional

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    _patokanController.dispose();
    super.dispose();
  }

  void _kirim() {
    if (!_formKey.currentState!.validate()) {
      tampilkanSnackBar(context, 'Lengkapi data penjemputan dengan benar.',
          error: true);
      return;
    }
    // Catat akumulasi harian (batas 25 kg padat & 5 liter jelantah per hari).
    _resetKuotaJikaGantiHari();
    _terjualPadatHariIni += totalPadat(widget.beratPerKategori);
    _terjualJelantahHariIni += widget.beratPerKategori[kategoriCair] ?? 0;
    // Feedback setelah data dikirim (snackbar tetap tampil di halaman berikutnya).
    tampilkanSnackBar(context, 'Data sudah terkirim');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RingkasanScreen(
          beratPerKategori: widget.beratPerKategori,
          nama: _namaController.text.trim(),
          noHp: _noHpController.text.trim(),
          alamat: _alamatController.text.trim(),
          patokan: _patokanController.text.trim(),
          sudahTerkirim: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alamat Penjemputan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: validasiNama,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noHpController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'No. HP',
                  hintText: '08xxxxxxxxxx',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: validasiNoHp,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alamatController,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Alamat Lengkap',
                  hintText: 'Jalan, RT/RW, kelurahan, kota',
                  prefixIcon: Icon(Icons.home),
                ),
                validator: validasiAlamat,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _patokanController,
                decoration: const InputDecoration(
                  labelText: 'Patokan (opsional)',
                  hintText: 'contoh: depan warung biru',
                  prefixIcon: Icon(Icons.flag),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _kirim,
                  child: const Text('Kirim'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// BAGIAN 5: TEMA, VALIDASI ALAMAT, FEEDBACK
// ====================================================================
const Color warnaHijau = Color(0xFF2E9B3E);
const Color warnaKuning = Color(0xFFF7C41F);
const Color warnaBiru = Color(0xFF1E78C8);

ThemeData buatTema() {
  final skema = ColorScheme.fromSeed(
    seedColor: warnaHijau,
    brightness: Brightness.light,
  ).copyWith(
    primary: warnaHijau,
    onPrimary: Colors.white,
    secondary: warnaKuning,
    onSecondary: Colors.black87,
    tertiary: warnaBiru,
    onTertiary: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: skema,
    scaffoldBackgroundColor: const Color(0xFFF6FAF6),
    appBarTheme: const AppBarTheme(
      backgroundColor: warnaHijau,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: warnaHijau,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? warnaHijau : null,
      ),
    ),
    // Jika error "CardThemeData", ganti menjadi CardTheme (Flutter versi lama).
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: warnaBiru.withOpacity(0.15)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: warnaBiru.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: warnaHijau, width: 2),
      ),
      prefixIconColor: warnaBiru,
    ),
  );
}

String? validasiNama(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Nama tidak boleh kosong';
  }
  if (value.trim().length < 3) {
    return 'Nama minimal 3 karakter';
  }
  return null;
}

String? validasiNoHp(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'No. HP tidak boleh kosong';
  }
  final hp = value.trim();
  if (!RegExp(r'^[0-9]+$').hasMatch(hp)) {
    return 'No. HP hanya boleh berisi angka';
  }
  if (hp.length < 10 || hp.length > 13) {
    return 'No. HP harus 10-13 digit';
  }
  return null;
}

String? validasiAlamat(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Alamat tidak boleh kosong';
  }
  if (value.trim().length < 15) {
    return 'Alamat terlalu singkat, tulis alamat lengkap';
  }
  return null;
}

void tampilkanSnackBar(BuildContext context, String pesan,
    {bool error = false}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(error ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(pesan)),
        ],
      ),
      backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}

// ====================================================================
// BAGIAN 6: SCREEN 3 - RINGKASAN PENJUALAN
// ====================================================================
const int ongkir = 0; // fitur #9: gratis

class RingkasanScreen extends StatefulWidget {
  final Map<String, double> beratPerKategori;
  final String nama;
  final String noHp;
  final String alamat;
  final String patokan; // boleh kosong
  final bool sudahTerkirim; // true jika datang dari tombol Kirim

  const RingkasanScreen({
    super.key,
    required this.beratPerKategori,
    required this.nama,
    required this.noHp,
    required this.alamat,
    required this.patokan,
    this.sudahTerkirim = false,
  });

  @override
  State<RingkasanScreen> createState() => _RingkasanScreenState();
}

class _RingkasanScreenState extends State<RingkasanScreen> {
  late bool _sudahDikonfirmasi;

  @override
  void initState() {
    super.initState();
    _sudahDikonfirmasi = widget.sudahTerkirim;
  }

  double _hitungTotal() {
    return hitungEstimasi(widget.beratPerKategori) + ongkir;
  }

  void _konfirmasi() {
    setState(() {
      _sudahDikonfirmasi = true;
    });
    tampilkanSnackBar(context, 'Permintaan penjemputan berhasil dikirim!');
  }

  void _kembaliKeBeranda() {
    // Kembali ke Home (tab pertama) dengan form dikosongkan.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  String _formatBerat(double berat) {
    return berat == berat.roundToDouble()
        ? berat.toStringAsFixed(0)
        : berat.toString();
  }

  Widget _barisInfo(IconData ikon, String label, String isi) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, size: 20, color: warnaBiru),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(isi,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _barisHarga(String kiri, String kanan,
      {bool tebal = false, Color? warna}) {
    final gaya = TextStyle(
      fontWeight: tebal ? FontWeight.bold : FontWeight.normal,
      fontSize: tebal ? 18 : 14,
      color: warna,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(kiri, style: gaya)),
          Text(kanan, style: gaya),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan Penjualan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_sudahDikonfirmasi)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: warnaKuning.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: warnaKuning, width: 1.5),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.hourglass_top, color: Colors.black87),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Permintaan diproses',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data Penjemputan',
                        style: tema.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _barisInfo(Icons.person, 'Nama', widget.nama),
                    _barisInfo(Icons.phone, 'No. HP', widget.noHp),
                    _barisInfo(Icons.home, 'Alamat', widget.alamat),
                    if (widget.patokan.isNotEmpty)
                      _barisInfo(Icons.flag, 'Patokan', widget.patokan),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rincian Sampah',
                        style: tema.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...widget.beratPerKategori.entries.map((e) {
                      final subtotal = hitungSubtotal(e.key, e.value);
                      return _barisHarga(
                        '${e.key} (${_formatBerat(e.value)} ${satuanKategori(e.key)})',
                        formatRupiah(subtotal),
                      );
                    }),
                    const Divider(height: 24),
                    _barisHarga('Ongkir', '${formatRupiah(ongkir)} (Gratis)'),
                    const SizedBox(height: 4),
                    _barisHarga('Total', formatRupiah(_hitungTotal()),
                        tebal: true, warna: warnaHijau),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: _sudahDikonfirmasi
                  ? ElevatedButton(
                      onPressed: _kembaliKeBeranda,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: warnaBiru),
                      child: const Text('Kembali ke Beranda'),
                    )
                  : ElevatedButton(
                      onPressed: _konfirmasi,
                      child: const Text('Konfirmasi'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// BAGIAN 7: SPLASH SCREEN (LAYAR AWAL)
// Hanya logo di tengah. Diketuk -> ke LoginScreen.
//
// CARA MENAMBAH LOGO:
// 1. Buat folder  assets/images/  di root project (sejajar lib/).
// 2. Simpan gambar logo sebagai  assets/images/logo_ikon.png
// 3. Di pubspec.yaml (rata kiri dengan "uses-material-design"), tambahkan:
//
//    flutter:
//      uses-material-design: true
//      assets:
//        - assets/images/
//
// 4. Jalankan  flutter pub get , lalu restart (bukan hot reload).
// Jika logo belum ada, akan tampil ikon cadangan (errorBuilder).
// ====================================================================
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
        child: Center(
          child: Image.asset(
            'assets/images/logo_ikon.png',
            width: 220,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.recycling, size: 160, color: warnaHijau);
            },
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// BAGIAN 8: NAVBAR & HALAMAN UTAMA (MAIN SHELL)
// Navbar bawah menghubungkan 4 halaman: Home, Notifikasi, Educycle, Akun.
//
// CARA MENYISIPKAN ICON / GAMBAR:
// 1. Buat folder  assets/icons/  (untuk icon navbar) dan  assets/images/
//    (untuk gambar lain) di root project (sejajar lib/).
// 2. Simpan file gambar (PNG) dengan nama seperti pada daftarNavbar di bawah,
//    atau ubah path-nya sesuai nama file kalian.
// 3. Di pubspec.yaml tambahkan:
//
//    flutter:
//      uses-material-design: true
//      assets:
//        - assets/images/
//        - assets/icons/
//
// 4. Jalankan  flutter pub get , lalu restart (bukan hot reload).
// Jika file belum ada, otomatis tampil ikon bawaan Flutter (errorBuilder).
// ====================================================================

// Widget serbaguna: tampilkan gambar aset, jika gagal pakai ikon cadangan.
class IkonAset extends StatelessWidget {
  final String? aset;
  final IconData cadangan;
  final double ukuran;
  final Color? warna; // warna ikon cadangan saja

  const IkonAset({
    super.key,
    required this.aset,
    required this.cadangan,
    this.ukuran = 24,
    this.warna,
  });

  @override
  Widget build(BuildContext context) {
    if (aset == null) {
      return Icon(cadangan, size: ukuran, color: warna);
    }
    return Image.asset(
      aset!,
      width: ukuran,
      height: ukuran,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Icon(cadangan, size: ukuran, color: warna),
    );
  }
}

class ItemNavbar {
  final String label;
  final IconData ikon; // cadangan saat tidak aktif
  final IconData ikonAktif; // cadangan saat aktif
  final String? asetIkon; // gambar saat tidak aktif
  final String? asetIkonAktif; // gambar saat aktif (boleh sama dengan asetIkon)

  const ItemNavbar({
    required this.label,
    required this.ikon,
    required this.ikonAktif,
    this.asetIkon,
    this.asetIkonAktif,
  });
}

// ---------------- TEMPAT MENYISIPKAN ICON NAVBAR ----------------
// Ganti path di bawah sesuai nama file icon kalian.
// Urutan HARUS sama dengan urutan halaman di MainShell.
const List<ItemNavbar> daftarNavbar = [
  ItemNavbar(
    label: 'Home',
    ikon: Icons.home_outlined,
    ikonAktif: Icons.home,
    asetIkon: 'assets/icons/nav_home.png',
    asetIkonAktif: 'assets/icons/nav_home_aktif.png',
  ),
  ItemNavbar(
    label: 'Notifikasi',
    ikon: Icons.notifications_none,
    ikonAktif: Icons.notifications,
    asetIkon: 'assets/icons/nav_notifikasi.png',
    asetIkonAktif: 'assets/icons/nav_notifikasi_aktif.png',
  ),
  ItemNavbar(
    label: 'Educycle',
    ikon: Icons.menu_book_outlined,
    ikonAktif: Icons.menu_book,
    asetIkon: 'assets/icons/nav_educycle.png',
    asetIkonAktif: 'assets/icons/nav_educycle_aktif.png',
  ),
  ItemNavbar(
    label: 'Akun',
    ikon: Icons.person_outline,
    ikonAktif: Icons.person,
    asetIkon: 'assets/icons/nav_akun.png',
    asetIkonAktif: 'assets/icons/nav_akun_aktif.png',
  ),
];

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _indexAktif = 0;

  // Urutan sama dengan daftarNavbar.
  final List<Widget> _halaman = const [
    PilihSampahScreen(), // Home
    NotifikasiScreen(),
    EducycleScreen(),
    AkunScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indexAktif, children: _halaman),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexAktif,
        onTap: (i) => setState(() => _indexAktif = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: warnaHijau,
        unselectedItemColor: Colors.black54,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: [
          for (final item in daftarNavbar)
            BottomNavigationBarItem(
              label: item.label,
              icon: IkonAset(
                aset: item.asetIkon,
                cadangan: item.ikon,
                warna: Colors.black54,
              ),
              activeIcon: IkonAset(
                aset: item.asetIkonAktif,
                cadangan: item.ikonAktif,
                warna: warnaHijau,
              ),
            ),
        ],
      ),
    );
  }
}

// ====================================================================
// BAGIAN 9: HALAMAN NOTIFIKASI
// ====================================================================
class ItemNotifikasi {
  final IconData ikon;
  final Color warna;
  final String judul;
  final String isi;
  final String waktu;

  const ItemNotifikasi({
    required this.ikon,
    required this.warna,
    required this.judul,
    required this.isi,
    required this.waktu,
  });
}

const List<ItemNotifikasi> dataNotifikasi = [
  ItemNotifikasi(
    ikon: Icons.check,
    warna: warnaHijau,
    judul: 'Permintaan penjemputan berhasil!',
    isi: 'Tim kami akan segera datang.',
    waktu: 'Hari ini, 14.20',
  ),
  ItemNotifikasi(
    ikon: Icons.campaign_outlined,
    warna: warnaBiru,
    judul: 'Tips: Pisahkan sampah sesuai kategori',
    isi: 'Plastik, besi, dan kertas dipisah agar harga maksimal.',
    waktu: 'Kemarin, 16.30',
  ),
  ItemNotifikasi(
    ikon: Icons.card_giftcard,
    warna: warnaKuning,
    judul: 'Dapatkan poin tambahan setiap kali recycle!',
    isi: 'Kumpulkan poin dan tukar dengan hadiah.',
    waktu: '20 Okt 2026',
  ),
  ItemNotifikasi(
    ikon: Icons.info_outline,
    warna: warnaBiru,
    judul: 'Jadwal penjemputan tersedia setiap hari',
    isi: 'Pilih waktu yang sesuai untukmu.',
    waktu: '18 Okt 2026',
  ),
  ItemNotifikasi(
    ikon: Icons.star_border,
    warna: warnaKuning,
    judul: 'Selamat! Kamu naik level Eco Hero',
    isi: 'Terus kurangi sampah untuk bumi yang lebih sehat.',
    waktu: '10 Okt 2026',
  ),
];

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: dataNotifikasi.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final n = dataNotifikasi[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: n.warna.withOpacity(0.2),
                    child: Icon(n.ikon, color: n.warna),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.judul,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(n.isi,
                            style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 6),
                        Text(n.waktu,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black45)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ====================================================================
// BAGIAN 10: HALAMAN EDUCYCLE (halaman ke-7)
// Search bar tetap ada, tombol quick filter dihapus.
// Hanya artikel pertama yang tombol "Baca Selengkapnya"-nya berfungsi.
// ====================================================================
class ArtikelEdu {
  final String judul;
  final String? aset; // TEMPAT GAMBAR: assets/images/...
  final IconData ikon; // ikon cadangan
  final Color warna;
  final bool bisaDibuka;

  const ArtikelEdu({
    required this.judul,
    required this.aset,
    required this.ikon,
    required this.warna,
    this.bisaDibuka = false,
  });
}

const List<ArtikelEdu> dataArtikel = [
  ArtikelEdu(
    judul: 'Cara Memilah Sampah dengan Benar',
    aset: 'assets/images/edu_memilah.png',
    ikon: Icons.spa,
    warna: warnaHijau,
    bisaDibuka: true, // satu-satunya yang berfungsi
  ),
  ArtikelEdu(
    judul: 'Plastik, Besi, Kertas: Mana yang Paling Bernilai?',
    aset: 'assets/images/edu_bernilai.png',
    ikon: Icons.delete_outline,
    warna: warnaBiru,
  ),
  ArtikelEdu(
    judul: 'Tips Kecil untuk Bumi yang Lebih Sehat',
    aset: 'assets/images/edu_tips.png',
    ikon: Icons.public,
    warna: warnaBiru,
  ),
];

class EducycleScreen extends StatefulWidget {
  const EducycleScreen({super.key});

  @override
  State<EducycleScreen> createState() => _EducycleScreenState();
}

class _EducycleScreenState extends State<EducycleScreen> {
  String _kataKunci = '';

  @override
  Widget build(BuildContext context) {
    final daftar = dataArtikel
        .where((a) => a.judul.toLowerCase().contains(_kataKunci.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Educycle')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            onChanged: (v) => setState(() => _kataKunci = v),
            decoration: const InputDecoration(
              hintText: 'Cari topik edukasi...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          // Banner utama
          Container(
            height: 140,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [warnaHijau, Color(0xFF6CC47A)],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('#Lingkungan',
                            style:
                                TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Kenapa Kita Harus Daur Ulang Sampah?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // TEMPAT GAMBAR BANNER
                const IkonAset(
                  aset: 'assets/images/edu_banner.png',
                  cadangan: Icons.recycling,
                  ukuran: 80,
                  warna: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (daftar.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Topik tidak ditemukan.')),
            ),
          ...daftar.map((a) => _kartuArtikel(context, a)),
        ],
      ),
    );
  }

  Widget _kartuArtikel(BuildContext context, ArtikelEdu a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(
            width: 96,
            height: 96,
            color: a.warna.withOpacity(0.12),
            alignment: Alignment.center,
            child: IkonAset(
              aset: a.aset,
              cadangan: a.ikon,
              ukuran: 56,
              warna: a.warna,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.judul,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  InkWell(
                    // Hanya artikel pertama yang berfungsi.
                    onTap: a.bisaDibuka
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailEdukasiScreen(artikel: a),
                              ),
                            );
                          }
                        : null,
                    child: const Text(
                      'Baca Selengkapnya →',
                      style: TextStyle(
                        color: warnaHijau,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// BAGIAN 11: HALAMAN DETAIL EDUKASI (halaman ke-9, baru)
// Dibuka dari tombol "Baca Selengkapnya" di Educycle.
// ====================================================================
class BagianArtikel {
  final String judul;
  final String isi;

  const BagianArtikel(this.judul, this.isi);
}

const String isiPembuka =
    'Setiap hari kita menghasilkan sampah, tetapi tidak semuanya benar-benar '
    'menjadi "sampah". Banyak di antaranya masih punya nilai dan bisa diolah '
    'kembali, asalkan dipisahkan sejak awal. Memilah sampah adalah langkah '
    'kecil yang dampaknya besar untuk lingkungan sekaligus dompet kita.';

const List<BagianArtikel> isiArtikel = [
  BagianArtikel(
    'Mengapa sampah harus dipilah?',
    'Sampah yang tercampur sulit didaur ulang. Kertas yang basah terkena sisa '
        'makanan, misalnya, tidak lagi laku dijual. Dengan memilah, sampah '
        'bernilai bisa dijual, sampah organik bisa menjadi kompos, dan jumlah '
        'sampah yang berakhir di tempat pembuangan akhir (TPA) jauh berkurang.',
  ),
  BagianArtikel(
    'Kenali jenis-jenis sampah',
    '• Organik: sisa makanan, daun, dan ranting. Mudah membusuk dan bisa '
        'dijadikan kompos.\n'
        '• Plastik: botol, gelas, dan kemasan. Bilas dahulu agar bersih.\n'
        '• Kertas: kardus, koran, dan buku bekas. Simpan di tempat kering.\n'
        '• Besi dan logam: kaleng dan potongan besi. Bernilai jual tinggi.\n'
        '• Kaca: botol dan toples kaca. Hati-hati saat menyimpan agar tidak '
        'pecah.\n'
        '• Tekstil: pakaian dan kain bekas. Yang masih layak bisa disumbangkan.\n'
        '• Minyak jelantah: minyak goreng bekas. Tampung dalam botol tertutup, '
        'jangan dibuang ke saluran air.',
  ),
  BagianArtikel(
    'Langkah memilah di rumah',
    '1. Siapkan minimal tiga wadah: organik, anorganik, dan khusus (jelantah, '
        'kaca, atau tekstil).\n'
        '2. Beri label pada setiap wadah agar semua anggota keluarga paham.\n'
        '3. Bersihkan kemasan plastik dan kaca dari sisa makanan.\n'
        '4. Keringkan sampah kertas dan tekstil sebelum disimpan.\n'
        '5. Kumpulkan hingga cukup banyak, lalu jual melalui aplikasi Revalue.',
  ),
  BagianArtikel(
    'Tips agar konsisten',
    'Mulailah dari satu jenis sampah dahulu, misalnya plastik, lalu tambah '
        'kategori lain secara bertahap. Letakkan wadah di tempat yang mudah '
        'dijangkau, dan jadikan kebiasaan ini bersama keluarga atau teman '
        'serumah. Dalam beberapa minggu, memilah akan terasa otomatis.',
  ),
  BagianArtikel(
    'Dari sampah menjadi manfaat',
    'Sampah yang sudah dipilah dapat ditimbang dan dijual dengan harga yang '
        'jelas. Selain mendapat penghasilan tambahan dan poin reward, kamu ikut '
        'mengurangi pencemaran dan menjaga bumi tetap sehat. Jual Sampah, Jaga '
        'Bumi!',
  ),
];

class DetailEdukasiScreen extends StatelessWidget {
  final ArtikelEdu artikel;

  const DetailEdukasiScreen({super.key, required this.artikel});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Edukasi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TEMPAT GAMBAR HEADER ARTIKEL
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: artikel.warna.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: IkonAset(
                aset: artikel.aset,
                cadangan: artikel.ikon,
                ukuran: 100,
                warna: artikel.warna,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: warnaHijau.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('#Lingkungan',
                  style: TextStyle(
                      color: warnaHijau,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Text(artikel.judul,
                style: tema.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Tim Educycle • Revalue',
                style: TextStyle(color: Colors.black45, fontSize: 12)),
            const SizedBox(height: 14),
            const Text(isiPembuka, style: TextStyle(height: 1.5)),
            const SizedBox(height: 8),
            ...isiArtikel.map(
              (b) => Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.judul,
                        style: tema.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(b.isi, style: const TextStyle(height: 1.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali ke Educycle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// BAGIAN 12: HALAMAN AKUN / PROFIL (halaman ke-8)
// Hanya poin (tanpa total penjualan). Semua tombol menu BELUM berfungsi,
// kecuali Keluar yang kembali ke halaman Login.
// ====================================================================
class AkunScreen extends StatelessWidget {
  const AkunScreen({super.key});

  // Menu: tidak ada yang berfungsi (onTap kosong).
  static const List<_MenuAkun> _menu = [
    _MenuAkun(Icons.receipt_long_outlined, 'Riwayat Transaksi', warnaBiru),
    _MenuAkun(Icons.star_border, 'Poin & Reward', warnaKuning),
    _MenuAkun(Icons.help_outline, 'Bantuan', warnaBiru),
    _MenuAkun(Icons.info_outline, 'Tentang Aplikasi', warnaHijau),
    _MenuAkun(Icons.logout, 'Keluar', Colors.red, keluar: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header hijau + avatar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
              decoration: const BoxDecoration(
                color: warnaHijau,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  // TEMPAT FOTO PROFIL
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.center,
                    child: const IkonAset(
                      aset: 'assets/images/avatar.png',
                      cadangan: Icons.person,
                      ukuran: 64,
                      warna: warnaHijau,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Budi Santoso',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  const Text('@budi_revalue',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Kartu poin saja (tanpa total penjualan)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: warnaKuning, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Poin',
                        style: TextStyle(color: Colors.black54, fontSize: 15)),
                    Row(
                      children: [
                        const Text('120',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB8860B))),
                        const SizedBox(width: 6),
                        Icon(Icons.star, color: warnaKuning, size: 28),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Column(
                  children: [
                    for (int i = 0; i < _menu.length; i++) ...[
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _menu[i].warna.withOpacity(0.15),
                          child: Icon(_menu[i].ikon, color: _menu[i].warna),
                        ),
                        title: Text(_menu[i].label),
                        trailing: const Icon(Icons.chevron_right),
                        // Hanya Keluar yang berfungsi: kembali ke halaman Login.
                        onTap: _menu[i].keluar
                            ? () => Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()),
                                  (route) => false,
                                )
                            : () {}, // belum berfungsi
                      ),
                      if (i < _menu.length - 1) const Divider(height: 1),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MenuAkun {
  final IconData ikon;
  final String label;
  final Color warna;

  final bool keluar; // true = tombol Keluar (kembali ke Login)

  const _MenuAkun(this.ikon, this.label, this.warna, {this.keluar = false});
}

// ====================================================================
// BAGIAN 13: HALAMAN LOGIN (halaman ke-2)
// Splash -> Login -> MainShell. Login bersifat dummy (tanpa server):
// cukup email berformat benar dan kata sandi minimal 6 karakter.
// Tombol Lupa kata sandi, Google, dan Daftar belum berfungsi
// (hanya menampilkan pesan).
// TEMPAT LOGO: assets/images/logo_ikon.png (sama dengan Splash).
// ====================================================================
String? validasiEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email tidak boleh kosong';
  }
  if (!RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(value.trim())) {
    return 'Format email tidak valid';
  }
  return null;
}

String? validasiKataSandi(String? value) {
  if (value == null || value.isEmpty) {
    return 'Kata sandi tidak boleh kosong';
  }
  if (value.length < 6) {
    return 'Kata sandi minimal 6 karakter';
  }
  return null;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _sandiController = TextEditingController();
  bool _sembunyikanSandi = true;

  @override
  void dispose() {
    _emailController.dispose();
    _sandiController.dispose();
    super.dispose();
  }

  void _masuk() {
    if (!_formKey.currentState!.validate()) {
      tampilkanSnackBar(context, 'Periksa kembali email dan kata sandi.',
          error: true);
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  void _belumTersedia() {
    tampilkanSnackBar(context, 'Fitur ini belum tersedia.', error: true);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header hijau + logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 64, 16, 32),
              decoration: const BoxDecoration(
                color: warnaHijau,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const IkonAset(
                      aset: 'assets/images/logo_ikon.png',
                      cadangan: Icons.recycling,
                      ukuran: 78,
                      warna: warnaHijau,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Revalue',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selamat Datang \u{1F44B}',
                        style: tema.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Masuk untuk mulai menjual sampahmu',
                        style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'budi@email.com',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: validasiEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sandiController,
                      obscureText: _sembunyikanSandi,
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_sembunyikanSandi
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(
                              () => _sembunyikanSandi = !_sembunyikanSandi),
                        ),
                      ),
                      validator: validasiKataSandi,
                      onFieldSubmitted: (_) => _masuk(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _belumTersedia,
                        child: const Text('Lupa kata sandi?',
                            style: TextStyle(
                                color: warnaBiru,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _masuk,
                        child: const Text('Masuk'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('atau',
                              style: TextStyle(color: Colors.black54)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _belumTersedia,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Lanjutkan dengan Google',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Belum punya akun? '),
                          GestureDetector(
                            onTap: _belumTersedia,
                            child: const Text('Daftar',
                                style: TextStyle(
                                    color: warnaBiru,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
