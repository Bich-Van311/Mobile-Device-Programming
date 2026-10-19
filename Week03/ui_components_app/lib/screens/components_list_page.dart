import 'package:flutter/material.dart';

import 'text_detail_page.dart';
import 'image_detail_page.dart';
import 'textfield_detail_page.dart';
import 'password_detail_page.dart';
import 'row_detail_page.dart';
import 'column_detail_page.dart';
import 'more_components_page.dart';

class ComponentsListPage extends StatelessWidget {
  const ComponentsListPage({super.key});

  Widget componentTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget page,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color ?? Colors.lightBlue.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        },
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 12,
        bottom: 7,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UI Components List',
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionTitle('Display'),

                componentTile(
                  context: context,
                  title: 'Text',
                  subtitle: 'Displays text',
                  page: const TextDetailPage(),
                ),

                componentTile(
                  context: context,
                  title: 'Image',
                  subtitle: 'Displays an image',
                  page: const ImageDetailPage(),
                ),

                sectionTitle('Input'),

                componentTile(
                  context: context,
                  title: 'TextField',
                  subtitle: 'Input field for text',
                  page: const TextFieldDetailPage(),
                ),

                componentTile(
                  context: context,
                  title: 'PasswordField',
                  subtitle: 'Input field for passwords',
                  page: const PasswordDetailPage(),
                ),

                sectionTitle('Layout'),

                componentTile(
                  context: context,
                  title: 'Column',
                  subtitle: 'Arranges elements vertically',
                  page: const ColumnDetailPage(),
                ),

                componentTile(
                  context: context,
                  title: 'Row',
                  subtitle: 'Arranges elements horizontally',
                  page: const RowDetailPage(),
                ),

                sectionTitle('Explore'),

                componentTile(
                  context: context,
                  title: 'Tự tìm hiểu',
                  subtitle: 'Tìm ra các thành phần UI cơ bản khác',
                  page: const MoreComponentsPage(),
                  color: Colors.red.shade100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}