import 'package:flutter/material.dart';

import 'library_models.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final LibraryRepository _repository = LibraryRepository();
  final Set<String> _selectedIds = {};

  String _studentId = 'S01';
  int _tab = 0;

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _changeStudent() async {
    final student = await showModalBottomSheet<Student>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(
                title: Text(
                  'Chọn sinh viên',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              for (final student in _repository.students)
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(student.name),
                  trailing: student.id == _studentId
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext, student);
                  },
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || student == null) return;

    setState(() {
      _studentId = student.id;
      _selectedIds.clear();
    });
  }

  Future<void> _addItem({required bool isBook}) async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (_) => AddLibraryDialog(isBook: isBook),
    );

    if (!mounted || result == null) return;

    setState(() {
      if (isBook) {
        _repository.addBook(result[0], result[1]);
      } else {
        _repository.addStudent(result[0]);
      }
    });

    _message(isBook ? 'Đã thêm sách.' : 'Đã thêm sinh viên.');
  }

  void _borrow() {
    try {
      _repository.borrowBooks(_studentId, _selectedIds);
      setState(() => _selectedIds.clear());
      _message('Mượn sách thành công.');
    } on StateError catch (error) {
      _message(error.message);
    }
  }

  void _returnBook(LibraryItem item) {
    try {
      _repository.returnBook(item.id, _studentId);
      setState(() {});
      _message('Đã trả ${item.title}.');
    } on StateError catch (error) {
      _message(error.message);
    }
  }

  void _showDetails(LibraryItem item) {
    final loan = _repository.loanFor(item.id);

    final status = loan == null
        ? 'Trạng thái: Có thể mượn'
        : 'Người mượn: '
              '${_repository.studentById(loan.studentId).name}\n'
              'Ngày mượn: '
              '${loan.borrowedAt.day}/${loan.borrowedAt.month}/'
              '${loan.borrowedAt.year}';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(item.title),
          // Đa hình: describe() chạy theo loại đối tượng thực tế.
          content: Text('${item.describe()}\n\n$status'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  Widget _managementTab() {
    final student = _repository.studentById(_studentId);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Sinh viên',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    student.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _changeStudent,
              child: const Text('Thay đổi'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Danh sách sách',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        for (final item in _repository.items) _borrowCard(item),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _borrow,
          icon: const Icon(Icons.library_add_check),
          label: const Text('Mượn sách đã chọn'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _addItem(isBook: true),
          icon: const Icon(Icons.add),
          label: const Text('Thêm sách mới'),
        ),
      ],
    );
  }

  Widget _borrowCard(LibraryItem item) {
    final loan = _repository.loanFor(item.id);
    final isMine = loan?.studentId == _studentId;

    final status = loan == null
        ? 'Có thể mượn'
        : 'Đang mượn: '
              '${_repository.studentById(loan.studentId).name}';

    return Card(
      child: Column(
        children: [
          CheckboxListTile(
            value: _selectedIds.contains(item.id) || isMine,
            title: Text(item.title),
            subtitle: Text(status),
            secondary: IconButton(
              onPressed: () => _showDetails(item),
              icon: const Icon(Icons.info_outline),
            ),
            onChanged: loan != null
                ? null
                : (value) {
                    setState(() {
                      if (value == true) {
                        _selectedIds.add(item.id);
                      } else {
                        _selectedIds.remove(item.id);
                      }
                    });
                  },
          ),
          if (isMine)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _returnBook(item),
                child: const Text('Trả sách'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _booksTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton.icon(
          onPressed: () => _addItem(isBook: true),
          icon: const Icon(Icons.add),
          label: const Text('Thêm sách'),
        ),
        const SizedBox(height: 12),
        for (final item in _repository.items)
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book),
              title: Text(item.title),
              subtitle: Text(item.describe()),
              onTap: () => _showDetails(item),
            ),
          ),
      ],
    );
  }

  Widget _studentsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton.icon(
          onPressed: () => _addItem(isBook: false),
          icon: const Icon(Icons.person_add_alt),
          label: const Text('Thêm sinh viên'),
        ),
        const SizedBox(height: 12),
        for (final student in _repository.students)
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(student.name),
              subtitle: Text('Mã demo: ${student.id}'),
              trailing: student.id == _studentId
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                setState(() {
                  _studentId = student.id;
                  _selectedIds.clear();
                  _tab = 0;
                });
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 85,
        centerTitle: true,
        title: const Text(
          'Hệ thống\nQuản lý Thư viện',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: switch (_tab) {
        0 => _managementTab(),
        1 => _booksTab(),
        _ => _studentsTab(),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) {
          setState(() => _tab = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Quản lý',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'DS Sách',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Sinh viên',
          ),
        ],
      ),
    );
  }
}

// Dialog có State riêng để quản lý và dispose controller.
class AddLibraryDialog extends StatefulWidget {
  final bool isBook;

  const AddLibraryDialog({super.key, required this.isBook});

  @override
  State<AddLibraryDialog> createState() => _AddLibraryDialogState();
}

class _AddLibraryDialogState extends State<AddLibraryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _authorController = TextEditingController();

  String? _required(String? value) {
    return value == null || value.trim().isEmpty
        ? 'Không được để trống.'
        : null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(<String>[
      _nameController.text.trim(),
      if (widget.isBook) _authorController.text.trim(),
    ]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isBook ? 'Thêm sách' : 'Thêm sinh viên'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: widget.isBook ? 'Tên sách' : 'Tên sinh viên',
                ),
                validator: _required,
              ),
              if (widget.isBook) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(labelText: 'Tác giả'),
                  validator: _required,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(onPressed: _save, child: const Text('Lưu')),
      ],
    );
  }
}
