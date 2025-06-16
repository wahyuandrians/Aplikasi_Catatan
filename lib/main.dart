import 'package:flutter/material.dart';

void main() {
  runApp(CatatanApp());
}

class CatatanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Catatan',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: CatatanHome(),
    );
  }
}

class CatatanHome extends StatefulWidget {
  @override
  _CatatanHomeState createState() => _CatatanHomeState();
}

class _CatatanHomeState extends State<CatatanHome> {
  List<Map<String, String>> _catatanList = [];
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();

  void _tambahCatatan() {
    _judulController.clear();
    _isiController.clear();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Tambah Catatan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _judulController,
                  decoration: InputDecoration(labelText: 'Judul'),
                ),
                TextField(
                  controller: _isiController,
                  decoration: InputDecoration(labelText: 'Isi'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _catatanList.add({
                      'judul': _judulController.text,
                      'isi': _isiController.text,
                    });
                  });
                  Navigator.pop(context);
                },
                child: Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _editCatatan(int index) {
    _judulController.text = _catatanList[index]['judul']!;
    _isiController.text = _catatanList[index]['isi']!;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Edit Catatan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _judulController,
                  decoration: InputDecoration(labelText: 'Judul'),
                ),
                TextField(
                  controller: _isiController,
                  decoration: InputDecoration(labelText: 'Isi'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _catatanList[index] = {
                      'judul': _judulController.text,
                      'isi': _isiController.text,
                    };
                  });
                  Navigator.pop(context);
                },
                child: Text('Update'),
              ),
            ],
          ),
    );
  }

  void _hapusCatatan(int index) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Hapus Catatan'),
            content: Text('Yakin ingin menghapus catatan ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _catatanList.removeAt(index);
                  });
                  Navigator.pop(context);
                },
                child: Text('Hapus'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Catatan')),
      body:
          _catatanList.isEmpty
              ? Center(child: Text('Belum ada catatan.'))
              : ListView.builder(
                itemCount: _catatanList.length,
                itemBuilder: (context, index) {
                  final catatan = _catatanList[index];
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(catatan['judul'] ?? ''),
                      subtitle: Text(catatan['isi'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => _editCatatan(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _hapusCatatan(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahCatatan,
        child: Icon(Icons.add),
      ),
    );
  }
}
