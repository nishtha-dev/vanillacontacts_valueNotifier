import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        '/new-contact': (context) => const NewContactsView(),
      },
    );
  }
}

// ignore: empty_constructor_bodies
class Contact {
  final String id;
  final String name;
  Contact({required this.name}) : id = const Uuid().v4();
}

class ContactBook extends ValueNotifier<List<Contact>> {
  ContactBook._sharedInstance()
      : super([]); // Calling valueNotifier constructor
  static final ContactBook _shared = ContactBook._sharedInstance();
  factory ContactBook() => _shared;

  //final List<Contact> _contacts = [];
  int get length => value.length;

  void add({required Contact contact}) {
    final contacts = value;
    contacts.add(contact);
    value = contacts;
    notifyListeners();
  }

  void remove({required Contact contact}) {
    final contacts = value;

    contacts.remove(contact);
    notifyListeners();
  }

  Contact? contacts({required int atIndex}) =>
      value.length > atIndex ? value[atIndex] : null;
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final ContactBook contactBook = ContactBook();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: ValueListenableBuilder(
        valueListenable: ContactBook(),
        builder: (context, value, child) {
          final contacts = value as List<Contact>;
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              //final contacts = contactBook.contacts(atIndex: index)!;
              final contact = value[index];
              return Dismissible(
                onDismissed: (direction) {
                  //contacts.remove(value[index]);
                  contactBook.remove(contact: contact);
                },
                key: ValueKey(contact.id),
                child: Material(
                  color: Colors.white,
                  elevation: 6.0,
                  child: ListTile(
                    title: Text(contact.name),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/new-contact');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NewContactsView extends StatefulWidget {
  const NewContactsView({Key? key}) : super(key: key);

  @override
  State<NewContactsView> createState() => _NewContactsViewState();
}

class _NewContactsViewState extends State<NewContactsView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new contact'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Add new contact name',
            ),
          ),
          TextButton(
              onPressed: () {
                final contact = Contact(name: _controller.text);
                ContactBook().add(contact: contact);
                Navigator.of(context).pop();
              },
              child: const Text('Add contact'))
        ],
      ),
    );
  }
}
