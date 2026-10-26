// 1. TRỪU TƯỢNG
abstract class LibraryItem {
  final String id;
  String _title;

  LibraryItem({required this.id, required String title})
    : _title = _validateTitle(title);

  static String _validateTitle(String value) {
    final title = value.trim();

    if (title.isEmpty) {
      throw ArgumentError('Tên tài liệu không được để trống.');
    }

    return title;
  }

  // 2. ĐÓNG GÓI
  String get title => _title;

  set title(String value) {
    _title = _validateTitle(value);
  }

  String get type;
  String describe();
}

// 3. KẾ THỪA
class Book extends LibraryItem {
  final String author;

  Book({required super.id, required super.title, required this.author});

  @override
  String get type => 'Sách';

  @override
  String describe() => '$type: $title\nTác giả: $author';
}

class Textbook extends Book {
  final String subject;

  Textbook({
    required super.id,
    required super.title,
    required super.author,
    required this.subject,
  });

  @override
  String get type => 'Giáo trình';

  @override
  String describe() => '${super.describe()}\nMôn học: $subject';
}

class Student {
  final String id;
  final String name;

  Student({required this.id, required this.name});
}

class Loan {
  final String itemId;
  final String studentId;
  final DateTime borrowedAt;

  Loan({
    required this.itemId,
    required this.studentId,
    required this.borrowedAt,
  });
}

class LibraryRepository {
  // 4. ĐA HÌNH:
  // Danh sách LibraryItem chứa cả Book và Textbook.
  final List<LibraryItem> _items = [
    Book(id: 'B01', title: 'Dế Mèn phiêu lưu ký', author: 'Tô Hoài'),
    Book(
      id: 'B02',
      title: 'Tôi thấy hoa vàng trên cỏ xanh',
      author: 'Nguyễn Nhật Ánh',
    ),
    Textbook(
      id: 'B03',
      title: 'Lập trình hướng đối tượng',
      author: 'Nhóm tác giả',
      subject: 'OOP',
    ),
  ];

  final List<Student> _students = [
    Student(id: 'S01', name: 'Nguyễn Văn An'),
    Student(id: 'S02', name: 'Trần Minh Anh'),
  ];

  final List<Loan> _loans = [];

  int _nextBookId = 4;
  int _nextStudentId = 3;

  List<LibraryItem> get items => List.unmodifiable(_items);

  List<Student> get students => List.unmodifiable(_students);

  Student studentById(String id) {
    return _students.firstWhere((student) => student.id == id);
  }

  Loan? loanFor(String itemId) {
    for (final loan in _loans) {
      if (loan.itemId == itemId) {
        return loan;
      }
    }

    return null;
  }

  void addBook(String title, String author) {
    if (title.trim().isEmpty || author.trim().isEmpty) {
      throw ArgumentError('Nhập đủ tên sách và tác giả.');
    }

    _items.add(
      Book(id: 'B${_nextBookId++}', title: title.trim(), author: author.trim()),
    );
  }

  void addStudent(String name) {
    if (name.trim().isEmpty) {
      throw ArgumentError('Tên sinh viên không được để trống.');
    }

    _students.add(Student(id: 'S${_nextStudentId++}', name: name.trim()));
  }

  void borrowBooks(String studentId, Set<String> itemIds) {
    if (!_students.any((student) => student.id == studentId)) {
      throw StateError('Sinh viên không tồn tại.');
    }

    if (itemIds.isEmpty) {
      throw StateError('Hãy chọn ít nhất một sách.');
    }

    // Kiểm tra toàn bộ trước khi ghi nhận lượt mượn.
    for (final id in itemIds) {
      if (!_items.any((item) => item.id == id)) {
        throw StateError('Sách không tồn tại.');
      }

      if (loanFor(id) != null) {
        throw StateError('Có sách đã được mượn.');
      }
    }

    for (final id in itemIds) {
      _loans.add(
        Loan(itemId: id, studentId: studentId, borrowedAt: DateTime.now()),
      );
    }
  }

  void returnBook(String itemId, String studentId) {
    final loan = loanFor(itemId);

    if (loan == null || loan.studentId != studentId) {
      throw StateError('Sinh viên này không mượn sách đó.');
    }

    _loans.remove(loan);
  }
}
