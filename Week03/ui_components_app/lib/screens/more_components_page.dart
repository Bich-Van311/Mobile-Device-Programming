import 'package:flutter/material.dart';

class MoreComponentsPage extends StatefulWidget {
  const MoreComponentsPage({super.key});

  @override
  State<MoreComponentsPage> createState() => _MoreComponentsPageState();
}

class _MoreComponentsPageState extends State<MoreComponentsPage> {
  bool checkboxValue = false;
  bool switchValue = false;

  int radioValue = 1;

  double sliderValue = 50;

  String selectedItem = 'Flutter';

  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'More UI Components',
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: 'about', child: Text('About')),
                PopupMenuItem(value: 'settings', child: Text('Settings')),
              ];
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selection',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Button clicked!')),
                  );
                },
                child: const Text('Button'),
              ),
            ),

            CheckboxListTile(
              title: const Text('Checkbox'),
              value: checkboxValue,
              onChanged: (value) {
                setState(() {
                  checkboxValue = value ?? false;
                });
              },
            ),

            RadioGroup<int>(
              groupValue: radioValue,
              onChanged: (value) {
                setState(() {
                  radioValue = value ?? 1;
                });
              },
              child: const Column(
                children: [
                  RadioListTile<int>(title: Text('Option 1'), value: 1),
                  RadioListTile<int>(title: Text('Option 2'), value: 2),
                ],
              ),
            ),

            SwitchListTile(
              title: const Text('Toggle / Switch'),
              value: switchValue,
              onChanged: (value) {
                setState(() {
                  switchValue = value;
                });
              },
            ),

            const Divider(),

            const Text(
              'Slider',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Slider(
              value: sliderValue,
              min: 0,
              max: 100,
              divisions: 10,
              label: sliderValue.round().toString(),
              onChanged: (value) {
                setState(() {
                  sliderValue = value;
                });
              },
            ),

            Text('Value: ${sliderValue.round()}'),

            const SizedBox(height: 20),

            const Text(
              'Picker / Dropdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            DropdownButton<String>(
              value: selectedItem,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Flutter', child: Text('Flutter')),
                DropdownMenuItem(value: 'Dart', child: Text('Dart')),
                DropdownMenuItem(value: 'Mobile', child: Text('Mobile')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedItem = value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'DatePicker',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () async {
                final DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (date != null) {
                  setState(() {
                    selectedDate = date;
                  });
                }
              },
              child: const Text('Select Date'),
            ),

            if (selectedDate != null)
              Text(
                'Selected: '
                '${selectedDate!.day}/'
                '${selectedDate!.month}/'
                '${selectedDate!.year}',
              ),

            const SizedBox(height: 25),

            const Divider(),

            const Text(
              'Content',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Card Component'),
                subtitle: Text('A Card contains styled content.'),
              ),
            ),

            const Divider(),

            const ListTile(
              leading: Icon(Icons.list),
              title: Text('List Item 1'),
            ),

            const ListTile(
              leading: Icon(Icons.list),
              title: Text('List Item 2'),
            ),
          ],
        ),
      ),
    );
  }
}
