class ApiEndpoints {
  // Private constructor agar tidak bisa di-instantiate (Best Practice)
  ApiEndpoints._();

  // ==========================================
  // AUTHENTICATION
  // ==========================================
  static const String login = '/api/auth/login';
  static const String refreshToken = '/api/auth/refresh';
  static const String logout = '/auth/logout'; // Pindahan dari ApiConstants
  static const String validasiKontak = '/api/wajibpajak/validasi-kontak';
  static const String register = '/api/wajibpajak/buat-permohonan';

  // ==========================================
  // USER PROFILE
  // ==========================================
  static const String profile = '/api/wajibpajak/profile';
  static const String editProfile = '/api/wajibpajak/editprofile';
  static const String changePasswordProfile = '/api/wajibpajak/change-password';
  static const String getProfilePicture = '/api/wajibpajak/profile-picture';
  static const String changeProfilePicture =
      '/api/wajibpajak/change-profile-picture';

  // ==========================================
  // MASTER DATA (PATCHING)
  // ==========================================
  static const String version = '/api/Master/version';
  static const String jenisReklame = '/api/master/reklame/jenis-reklame';
  static const String jenisReklameById = '/api/Master/jenis-reklame-by-id';
  static const String namaJalanReklame = '/api/Master/reklame/jalan';
  static const String kecamatan = '/api/Master/reklame/kecamatan';
  static const String kelurahan = '/api/Master/reklame/kelurahan';
  static const String lokasiTertentu = '/api/Master/reklame/lokasi-tertentu';
  static const String provinsi = '/api/master/provinsi';
  static const String provinsiKota = '/api/master/provinsi-kota';
  static const String provinsiKotaKecamatan =
      '/api/master/provinsi-kota-kecamatan';
  static const String provinsiKotaKecamatanKelurahan =
      '/api/master/provinsi-kota-kecamatan-kelurahan';
  static const String dokumenWf = '/api/master/dokumen-wf';
  static const String kecamatanSurabaya = '/api/master/kecamatan-surabaya-only';
  static const String kelurahanSurabaya = '/api/master/kelurahan-surabaya-only';
  static const String listBank = '/api/master/bank';

  static const String tagihanSummary = '/api/tagihan/header';
  static const String detailTagihan = '/api/tagihan/header-detail';
  static const String nominalMetodePembayaran =
      '/api/pembayaran/check-nominal-pembayaran';
  static const String syaratKetentuan = '/api/master/syarat-ketentuan';

  // ==========================================
  // PERMOHONAN REKLAME
  // ==========================================
  static const String dokumenPermohonan =
      '/api/master/reklame/dokumen-permohonan';
  static const String submitPermohonanReklame =
      '/api/reklame/permohonan/buat-permohonan-baru';
  static const String detectKategoriPenyelenggaraan =
      '/api/master/reklame/detect-kategori-penyelenggaraan';

  // ==========================================
  // SIMULASI PAJAK REKLAME
  // ==========================================
  static const String simulasiReklameAset =
      '/api/reklame/kalkulator/permanen/aset';
  static const String simulasiReklameNonAsetInsidentil =
      '/api/reklame/kalkulator/insidentil';
  static const String simualsiReklameNonAsetPermanen =
      '/api/reklame/kalkulator/permanen/non-aset';
  static const String simulasiReklameNonAsetKontrak =
      '/api/reklame/kalkulator/nilai-kontrak';

  // ==========================================
  // TERUTANG REKLAME
  // ==========================================
  static const String terutangList = '/api/reklame/terutang/header';
  static const String terutangHeaderDetail =
      '/api/reklame/terutang/header-detail';
  static const String cekStatusBayar =
      '/api/pembayaran/check-status-pembayaran';

  // ==========================================
  // PEMBAYARAN
  // ==========================================
  static const String pembayaranCreate = '/api/pembayaran/create';
  // RIWAYAT REKLAME
  // ==========================================
  static const String riwayatReklame = '/api/reklame/riwayat/header';
  static const String detailRiwayatReklame =
      '/api/reklame/riwayat/header-detail';
  static const String hitungNilaiSewa =
      '/api/reklame/riwayat/hitung-nilai-sewa';

  // ==========================================
  // PERPANJANGAN REKLAME
  // ==========================================
  static const String perpanjanganReklame = '/api/reklame/perpanjangan/header';
  static const String detailPerpanjanganReklame =
      '/api/reklame/perpanjangan/header-detail';
  static const String permohonanPerpanjangan =
      '/api/reklame/perpanjangan/perpanjang-permohonan';

  /// OLD
  static const String hitungNilaiSewaNonAsetPermanen =
      '/api/Kalkulator/permanen-non-aset';
  static const String hitungNilaiSewaNonAsetKontrak =
      '/api/Kalkulator/nilai-kontrak';
  static const String hitungNilaiSewaNonAsetInsidentil =
      '/api/Kalkulator/insidentil';
  static const String hitungNilaiAset = '/api/Kalkulator/permanen-aset';
  static const String hitungNilaiAsetByNoForm =
      '/api/Kalkulator/aset-existing-by-noform';

  // ==========================================
  // PROSES REKLAME
  // ==========================================
  static const String prosesReklameList = '/api/reklame/proses/header';
  static const String prosesReklameHeaderDetail =
      '/api/reklame/proses/header-detail';
  static const String revisiPermohonan =
      '/api/reklame/permohonan/revisi-permohonan';
  static const String getPermohonanRevisi =
      '/api/reklame/proses/get-permohonan-revisi';
  static const String prosesPenilaianReklame = '/api/reklame/proses/penilaian';
  static const String approvePermohonan =
      '/api/reklame/permohonan/approve-permohonan';

  // ==========================================
  // RINGKASAN REKLAME
  // ==========================================
  static const String reklameRingkasan = '/api/reklame/ringkasan/header';
  static const String recentActivity = '/api/reklame/ringkasan/recent-activity';

  // ==========================================
  // JAMBONG REKLAME
  // ==========================================
  static const String jambongReklame = '/api/reklame/jambong/header';
  static const String detailJambongReklame =
      '/api/reklame/jambong/header-detail';
  static const String bongkarJambong = '/api/reklame/jambong/bongkar';

  // ==========================================
  // PAJAK ABT
  // ==========================================
  static const String summaryObjekPajak = '/api/airtanah/summary';
  static const String objekPajak = '/api/airtanah/header';
  static const String tahun = '/api/airtanah/headerdetailtahun';
  static const String namaObjekPajak = '/api/airtanah/headerdetail';
}
