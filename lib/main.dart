import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

/* ==================== MODEL ==================== */
class Menu {
  final String id;
  final String nama;
  final int harga;
  final String imageUrl;
  const Menu(
      {required this.id,
      required this.nama,
      required this.harga,
      required this.imageUrl});
}

class PesananItem {
  final Menu menu;
  int qty;
  PesananItem({required this.menu, this.qty = 1});
  int get total => menu.harga * qty; // (e) total harga menu (c*d)
}

/* ==================== DATA ==================== */
const _menus = <Menu>[
  Menu(
    id: 'm1',
    nama: 'kue tradisional',
    harga: 18000,
    imageUrl:
        'https://images.unsplash.com/photo-1627308595229-7830a5c91f9f?w=800',
  ),
  Menu(
    id: 'm2',
    nama: 'Mie Ayam Bakso',
    harga: 15000,
    imageUrl: 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=800',
  ),
  Menu(
    id: 'm3',
    nama: 'Ayam Geprek',
    harga: 20000,
    imageUrl: 'https://images.unsplash.com/photo-1550513008-8cd1a9b590c8?w=800',
  ),
  Menu(
    id: 'm4',
    nama: 'Es Teh Manis',
    harga: 6000,
    imageUrl:
        'https://images.unsplash.com/photo-1601390395693-364c0e22031a?w=800',
  ),
  Menu(
    id: 'm5',
    nama: 'Soto Ayam',
    harga: 17000,
    imageUrl:
        'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=800',
  ),
  Menu(
    id: 'm6',
    nama: 'Jus Jeruk',
    harga: 10000,
    imageUrl:
        'https://images.unsplash.com/photo-1602835124432-0ca2d2e66183?w=800',
  ),
];

/* ==================== APP ==================== */
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu & Pesanan (Alt UI)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const MenuGridPage(),
    );
  }
}

/* ==================== VIEW 1: MENU (Grid) ==================== */
// Menampilkan: (a) gambar, (b) nama, (c) harga. Aksi tambah/kurang via tombol dan bottom bar.
class MenuGridPage extends StatefulWidget {
  const MenuGridPage({super.key});
  @override
  State<MenuGridPage> createState() => _MenuGridPageState();
}

class _MenuGridPageState extends State<MenuGridPage> {
  final List<PesananItem> _cart = [];

  int _indexOf(Menu m) => _cart.indexWhere((e) => e.menu.id == m.id);
  int qtyOf(Menu m) {
    final i = _indexOf(m);
    return i == -1 ? 0 : _cart[i].qty;
  }

  void add(Menu m) {
    final i = _indexOf(m);
    setState(() {
      if (i == -1) {
        _cart.add(PesananItem(menu: m, qty: 1));
      } else {
        _cart[i].qty++;
      }
    });
  }

  void removeOne(Menu m) {
    final i = _indexOf(m);
    if (i == -1) return;
    setState(() {
      _cart[i].qty--;
      if (_cart[i].qty <= 0) _cart.removeAt(i); // “hapus pesanan” di diagram
    });
  }

  String rp(num n) => 'Rp ${n.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final totalQty = _cart.fold<int>(0, (a, b) => a + b.qty);
    final totalHarga = _cart.fold<int>(0, (a, b) => a + b.total);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Menu'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // beda dari versi list
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: _menus.length,
        itemBuilder: (_, i) {
          final m = _menus[i];
          final q = qtyOf(m);
          return _MenuCardGrid(
            menu: m,
            qty: q,
            onAdd: () => add(m),
            onRemove: () => removeOne(m),
            priceText: rp(m.harga),
          );
        },
      ),

      // Bottom bar keranjang (beda tampilan)
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: totalQty == 0 ? 0 : 78,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border(
            top:
                BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ),
        child: totalQty == 0
            ? const SizedBox.shrink()
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: Text('$totalQty'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Total: ${rp(totalHarga)}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    FilledButton.icon(
                      icon: const Icon(Icons.shopping_cart_checkout),
                      label: const Text('Lihat Pesanan'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PesananPage(
                                items: _cart
                                    .map((e) =>
                                        PesananItem(menu: e.menu, qty: e.qty))
                                    .toList()),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _MenuCardGrid extends StatelessWidget {
  final Menu menu;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final String priceText;
  const _MenuCardGrid({
    required this.menu,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
    required this.priceText,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onAdd,
        child: Stack(
          children: [
            // Gambar (a)
            Positioned.fill(
              child: Image.network(menu.imageUrl, fit: BoxFit.cover),
            ),
            // lapisan gradient tipis
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.45),
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),
            // Nama + harga (b,c)
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(menu.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(priceText,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            // Tombol ADD / stepper kecil
            Positioned(
              right: 8,
              top: 8,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: qty == 0
                    ? FilledButton.tonal(
                        key: const ValueKey('add'),
                        onPressed: onAdd,
                        child: const Text('ADD'),
                      )
                    : Container(
                        key: const ValueKey('stepper'),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 6)
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: onRemove),
                            Text('$qty',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            IconButton(
                                icon: const Icon(Icons.add), onPressed: onAdd),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ==================== VIEW 2: PESANAN (Stepper + Swipe) ==================== */
// Menampilkan: a gambar, b nama, c harga, d jumlah, e total per menu, f Σ jumlah menu,
// g total jenis pesanan, h Σ total harga pesanan.
class PesananPage extends StatefulWidget {
  final List<PesananItem> items;
  const PesananPage({super.key, required this.items});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  String rp(num n) => 'Rp ${n.toStringAsFixed(0)}';

  void add(int i) => setState(() => widget.items[i].qty++);
  void removeOne(int i) {
    setState(() {
      widget.items[i].qty--;
      if (widget.items[i].qty <= 0) widget.items.removeAt(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalQty = widget.items.fold<int>(0, (a, b) => a + b.qty); // (f)
    final totalJenis = widget.items.length; // (g)
    final totalHarga = widget.items.fold<int>(0, (a, b) => a + b.total); // (h)

    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan')),
      body: widget.items.isEmpty
          ? const Center(child: Text('Belum ada pesanan'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: widget.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final it = widget.items[i];
                      return Dismissible(
                        key: ValueKey(it.menu.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red.withOpacity(0.85),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) =>
                            setState(() => widget.items.removeAt(i)),
                        child: Card(
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(it.menu.imageUrl,
                                  width: 60, height: 60, fit: BoxFit.cover),
                            ), // (a) gambar
                            title: Text(it.menu.nama), // (b) nama
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Harga: ${rp(it.menu.harga)}'), // (c) harga
                                Text('Total menu: ${rp(it.total)}'), // (e) c*d
                              ],
                            ),
                            // Stepper jumlah (d)
                            trailing: SizedBox(
                              width: 120,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                      onPressed: () => removeOne(i),
                                      icon: const Icon(
                                          Icons.remove_circle_outline)),
                                  Text('${it.qty}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  IconButton(
                                      onPressed: () => add(i),
                                      icon:
                                          const Icon(Icons.add_circle_outline)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: Border(
                      top: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _row('Total jumlah menu (Σ d)', '$totalQty'), // (f)
                      _row('Total jenis pesanan', '$totalJenis'), // (g)
                      const SizedBox(height: 8),
                      _row('Total harga pesanan (Σ e)', rp(totalHarga),
                          bold: true), // (h)
                      const SizedBox(height: 6),
                      FilledButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Pesanan diproses (dummy)')),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Buat Pesanan'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final st = TextStyle(
        fontSize: 16, fontWeight: bold ? FontWeight.w700 : FontWeight.w500);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: st), Text(value, style: st)],
      ),
    );
  }
}
