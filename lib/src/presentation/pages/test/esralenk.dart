import 'package:flutter/material.dart';

void main() {
  runApp(const RandevuPlanlamaApp());
}

class RandevuPlanlamaApp extends StatelessWidget {
  const RandevuPlanlamaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Randevu Planlama',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
        fontFamily: 'Poppins',
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const RandevuPlanlamaEkrani(),
    );
  }
}

class RandevuPlanlamaEkrani extends StatefulWidget {
  const RandevuPlanlamaEkrani({Key? key}) : super(key: key);

  @override
  State<RandevuPlanlamaEkrani> createState() => _RandevuPlanlamaEkraniState();
}

class _RandevuPlanlamaEkraniState extends State<RandevuPlanlamaEkrani>
    with SingleTickerProviderStateMixin {
  final List<Danisan> _danisanlar = [];
  final List<List<int>> _arkaArkayaGelmeyecekler = [];
  late TabController _tabController;
  final TextEditingController _danisanAdiController = TextEditingController();
  final TimeOfDay _baslangicSaati = const TimeOfDay(hour: 9, minute: 0);
  final int _seansSuresi = 45; // dakika
  Map<String, Danisan> _randevuPlani = {};
  List<Danisan> _atanamayanDanisanlar = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Örnek veri ekle
    _ornekVeriEkle();
  }

  void _ornekVeriEkle() {
    _danisanlar.addAll([
      Danisan(
        id: 1,
        isim: "Ahmet Yılmaz",
        uygunSaatler: ["09:00", "09:45", "10:30", "13:00"],
      ),
      Danisan(
        id: 2,
        isim: "Ayşe Demir",
        uygunSaatler: ["09:00", "09:45", "14:30", "15:15"],
      ),
      Danisan(
        id: 3,
        isim: "Mehmet Kaya",
        uygunSaatler: ["09:45", "10:30", "13:00", "13:45"],
      ),
    ]);

    _arkaArkayaGelmeyecekler.addAll([
      [1, 3], // Ahmet ve Mehmet arka arkaya gelmemeli
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _danisanAdiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevu Planlama Uygulaması'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Danışanlar'),
            Tab(icon: Icon(Icons.block), text: 'Kısıtlamalar'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Plan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_danisanlarTab(), _kisitlamalarTab(), _planTab()],
      ),
      floatingActionButton:
          _tabController.index == 2
              ? FloatingActionButton(
                onPressed: _randevuPlaniOlustur,
                child: const Icon(Icons.play_arrow),
                tooltip: 'Planı Oluştur',
              )
              : null,
    );
  }

  Widget _danisanlarTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Yeni Danışan Ekle',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _danisanAdiController,
                    decoration: const InputDecoration(
                      labelText: 'Danışan Adı',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Uygun Saatler:'),
                  const SizedBox(height: 8),
                  _saatSeciciOlustur(),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _danisanEkle,
                      icon: const Icon(Icons.add),
                      label: const Text('Danışan Ekle'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Danışan Listesi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                _danisanlar.isEmpty
                    ? const Center(child: Text('Henüz danışan eklenmedi.'))
                    : ListView.builder(
                      itemCount: _danisanlar.length,
                      itemBuilder: (context, index) {
                        final danisan = _danisanlar[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(danisan.isim.substring(0, 1)),
                            ),
                            title: Text(danisan.isim),
                            subtitle: Text(
                              'Uygun Saatler: ${danisan.uygunSaatler.join(", ")}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _danisanSil(danisan),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _saatSeciciOlustur() {
    final saatler = [
      "09:00",
      "09:45",
      "10:30",
      "11:15",
      "12:00",
      "12:45",
      "13:00",
      "13:45",
      "14:30",
      "15:15",
      "16:00",
      "16:45",
    ];

    List<Widget> saatChipler = [];
    final seciliSaatler = <String>{};

    for (var saat in saatler) {
      saatChipler.add(
        FilterChip(
          label: Text(saat),
          selected: seciliSaatler.contains(saat),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                seciliSaatler.add(saat);
              } else {
                seciliSaatler.remove(saat);
              }
            });
          },
        ),
      );
    }

    return Wrap(spacing: 8.0, runSpacing: 4.0, children: saatChipler);
  }

  void _danisanEkle() {
    // Seçili saatleri al
    final seciliSaatler = _getSeciliSaatler();

    if (_danisanAdiController.text.trim().isEmpty) {
      _hataGoster('Danışan adı boş olamaz');
      return;
    }

    if (seciliSaatler.isEmpty) {
      _hataGoster('En az bir uygun saat seçilmelidir');
      return;
    }

    final yeniDanisan = Danisan(
      id: _danisanlar.isEmpty ? 1 : _danisanlar.last.id + 1,
      isim: _danisanAdiController.text.trim(),
      uygunSaatler: seciliSaatler,
    );

    setState(() {
      _danisanlar.add(yeniDanisan);
      _danisanAdiController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${yeniDanisan.isim} başarıyla eklendi')),
    );
  }

  List<String> _getSeciliSaatler() {
    // Bu metod UI'dan seçili saatleri alır (şu an basitleştirilmiş bir liste dönüyor)
    // Gerçek uygulamada bu değerler FilterChip'lerden alınmalı
    return ["09:00", "09:45", "10:30"];
  }

  void _danisanSil(Danisan danisan) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Danışanı Sil'),
            content: Text(
              '${danisan.isim} adlı danışanı silmek istiyor musunuz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _danisanlar.remove(danisan);

                    // Danışan silindiğinde ilgili kısıtlamaları da kaldır
                    _arkaArkayaGelmeyecekler.removeWhere(
                      (kisit) => kisit.contains(danisan.id),
                    );
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${danisan.isim} silindi')),
                  );
                },
                child: const Text('Sil', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Widget _kisitlamalarTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Yeni Kısıtlama Ekle',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Arka arkaya gelmemesi gereken danışanları seçin:',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _danisanSeciciDropdown(1)),
                      const SizedBox(width: 16),
                      const Icon(Icons.block),
                      const SizedBox(width: 16),
                      Expanded(child: _danisanSeciciDropdown(2)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _kisitlamaEkle,
                      icon: const Icon(Icons.add),
                      label: const Text('Kısıtlama Ekle'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Kısıtlama Listesi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                _arkaArkayaGelmeyecekler.isEmpty
                    ? const Center(child: Text('Henüz kısıtlama eklenmedi.'))
                    : ListView.builder(
                      itemCount: _arkaArkayaGelmeyecekler.length,
                      itemBuilder: (context, index) {
                        final kisit = _arkaArkayaGelmeyecekler[index];
                        final danisan1 = _danisanlar.firstWhere(
                          (d) => d.id == kisit[0],
                        );
                        final danisan2 = _danisanlar.firstWhere(
                          (d) => d.id == kisit[1],
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.block),
                            title: Text('${danisan1.isim} ve ${danisan2.isim}'),
                            subtitle: const Text('arka arkaya programlanamaz'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _kisitlamaSil(index),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _danisanSeciciDropdown(int dropdownNo) {
    int? seciliDanisanId;

    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: 'Danışan $dropdownNo',
        border: const OutlineInputBorder(),
      ),
      value: seciliDanisanId,
      onChanged: (value) {
        setState(() {
          if (dropdownNo == 1) {
            // İlk dropdown için seçili danışan
          } else {
            // İkinci dropdown için seçili danışan
          }
        });
      },
      items:
          _danisanlar.map((danisan) {
            return DropdownMenuItem<int>(
              value: danisan.id,
              child: Text(danisan.isim),
            );
          }).toList(),
    );
  }

  void _kisitlamaEkle() {
    // Bu değerler gerçek bir uygulamada dropdown'lardan alınmalı
    final danisan1Id = 1;
    final danisan2Id = 3;

    if (danisan1Id == danisan2Id) {
      _hataGoster('Aynı danışan seçilemez');
      return;
    }

    // Kısıtlama zaten var mı kontrol et
    final kisitlamaVarMi = _arkaArkayaGelmeyecekler.any(
      (kisit) =>
          (kisit[0] == danisan1Id && kisit[1] == danisan2Id) ||
          (kisit[0] == danisan2Id && kisit[1] == danisan1Id),
    );

    if (kisitlamaVarMi) {
      _hataGoster('Bu kısıtlama zaten eklenmiş');
      return;
    }

    setState(() {
      _arkaArkayaGelmeyecekler.add([danisan1Id, danisan2Id]);
    });

    final danisan1 = _danisanlar.firstWhere((d) => d.id == danisan1Id);
    final danisan2 = _danisanlar.firstWhere((d) => d.id == danisan2Id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${danisan1.isim} ve ${danisan2.isim} için kısıtlama eklendi',
        ),
      ),
    );
  }

  void _kisitlamaSil(int index) {
    final kisit = _arkaArkayaGelmeyecekler[index];
    final danisan1 = _danisanlar.firstWhere((d) => d.id == kisit[0]);
    final danisan2 = _danisanlar.firstWhere((d) => d.id == kisit[1]);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Kısıtlamayı Sil'),
            content: Text(
              '${danisan1.isim} ve ${danisan2.isim} arasındaki kısıtlamayı kaldırmak istiyor musunuz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _arkaArkayaGelmeyecekler.removeAt(index);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Kısıtlama kaldırıldı')),
                  );
                },
                child: const Text('Sil', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Widget _planTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Randevu Planı Ayarları',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Başlangıç Saati'),
                    subtitle: Text('${_baslangicSaati.format(context)}'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: const Text('Seans Süresi'),
                    subtitle: Text('$_seansSuresi dakika'),
                  ),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _randevuPlaniOlustur,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Planı Oluştur'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Oluşturulan Plan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _randevuPlani.isEmpty
              ? const Expanded(
                child: Center(child: Text('Henüz plan oluşturulmadı.')),
              )
              : Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _randevuPlani.length,
                          separatorBuilder:
                              (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final saat = _randevuPlani.keys.elementAt(index);
                            final danisan = _randevuPlani[saat]!;

                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.access_time),
                              ),
                              title: Text(danisan.isim),
                              subtitle: Text('Saat: $saat'),
                              trailing: Text('${index + 1}. Randevu'),
                            );
                          },
                        ),
                      ),

                      if (_atanamayanDanisanlar.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Randevu Atanamayan Danışanlar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          color: Colors.red.withOpacity(0.1),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _atanamayanDanisanlar.length,
                            itemBuilder: (context, index) {
                              final danisan = _atanamayanDanisanlar[index];

                              return ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(danisan.isim),
                                subtitle: Text(
                                  'Uygun Saatler: ${danisan.uygunSaatler.join(", ")}',
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  void _randevuPlaniOlustur() {
    if (_danisanlar.isEmpty) {
      _hataGoster('Lütfen önce danışan ekleyin');
      return;
    }

    final saatler = [
      "09:00",
      "09:45",
      "10:30",
      "11:15",
      "12:00",
      "12:45",
      "13:00",
      "13:45",
      "14:30",
      "15:15",
      "16:00",
      "16:45",
    ];

    Map<String, Danisan> plan = {};
    List<Danisan> atanmamisDanisanlar = List.from(_danisanlar);

    // Her saat için uygun danışanları bul ve en iyi seçimi yap
    for (var i = 0; i < saatler.length; i++) {
      final mevcutSaat = saatler[i];
      final oncekiSaat = i > 0 ? saatler[i - 1] : null;
      final oncekiDanisan = oncekiSaat != null ? plan[oncekiSaat] : null;

      // Bu saat için uygun danışanları filtrele
      final uygunDanisanlar =
          atanmamisDanisanlar.where((danisan) {
            // Danışanın bu saate uygunluğunu kontrol et
            final saatUygun = danisan.uygunSaatler.contains(mevcutSaat);

            // Önceki danışan ile olan kısıtlamaları kontrol et
            var kisitlamaUygun = true;
            if (oncekiDanisan != null) {
              for (var kisit in _arkaArkayaGelmeyecekler) {
                if ((kisit[0] == oncekiDanisan.id && kisit[1] == danisan.id) ||
                    (kisit[1] == oncekiDanisan.id && kisit[0] == danisan.id)) {
                  kisitlamaUygun = false;
                  break;
                }
              }
            }

            return saatUygun && kisitlamaUygun;
          }).toList();

      // Eğer uygun danışan varsa, bu saate ata
      if (uygunDanisanlar.isNotEmpty) {
        // En az uygun saati olan danışanı önceliklendirme
        uygunDanisanlar.sort(
          (a, b) => a.uygunSaatler.length.compareTo(b.uygunSaatler.length),
        );
        final secilenDanisan = uygunDanisanlar.first;

        // Planı güncelle
        plan[mevcutSaat] = secilenDanisan;

        // Atanmış danışanı listeden çıkar
        atanmamisDanisanlar.removeWhere((d) => d.id == secilenDanisan.id);
      }

      // Tüm danışanlar atanmışsa döngüyü sonlandır
      if (atanmamisDanisanlar.isEmpty) break;
    }

    setState(() {
      _randevuPlani = Map.fromEntries(
        plan.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
      _atanamayanDanisanlar = atanmamisDanisanlar;
      _tabController.animateTo(2); // Plan sekmesine geç
    });

    // Tüm danışanlar atandıysa başarı mesajı göster
    if (atanmamisDanisanlar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan başarıyla oluşturuldu!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Bazı danışanlar atanamadıysa uyarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${atanmamisDanisanlar.length} danışan için uygun zaman bulunamadı.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mesaj), backgroundColor: Colors.red));
  }
}

class Danisan {
  final int id;
  final String isim;
  final List<String> uygunSaatler;

  Danisan({required this.id, required this.isim, required this.uygunSaatler});
}
