
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/providers/cart_provider.dart';
import 'package:myapp/widgets/badge_widget.dart';
import 'package:myapp/screens/store_screen.dart';
import 'package:myapp/screens/about_us_screen.dart';
import 'package:myapp/screens/contact_us_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    StoreScreen(),
    AboutUsScreen(),
    ContactUsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 40,
        ),
        centerTitle: true,
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, ch) => BadgeWidget(
              value: cart.itemCount.toString(),
              child: ch!,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                context.go('/cart');
              },
              tooltip: 'عربة التسوق',
            ),
          ),
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'تبديل المظهر',
          ),
          Consumer<User?>(
            builder: (context, user, _) {
              if (user == null) {
                return IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () {
                    context.go('/login');
                  },
                  tooltip: 'تسجيل الدخول',
                );
              } else {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.account_circle),
                  tooltip: 'الحساب',
                  onSelected: (value) {
                    if (value == 'logout') {
                      context.read<AuthService>().signOut();
                    } else if (value == 'admin') {
                      context.go('/admin');
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    final items = <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Text('تسجيل الخروج'),
                      ),
                    ];
                    if (userProvider.isAdmin) {
                      items.insert(
                        0,
                        const PopupMenuItem<String>(
                          value: 'admin',
                          child: Text('لوحة التحكم'),
                        ),
                      );
                    }
                    return items;
                  },
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'المتجر',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'من نحن',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'اتصل بنا',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              height: 150,
            ),
            const SizedBox(height: 30),
            Text(
              'مرحباً بك في تكنوسيرا',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              'حلول مواد البناء بين يديك',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                final state = context.findAncestorStateOfType<_HomeScreenState>();
                state?._onItemTapped(1);
              },
              child: const Text('اكتشف منتجاتنا'),
            ),
          ],
        ),
      ),
    );
  }
}
