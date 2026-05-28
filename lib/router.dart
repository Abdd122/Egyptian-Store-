
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/store_screen.dart';
import 'package:myapp/screens/about_us_screen.dart';
import 'package:myapp/screens/contact_us_screen.dart';
import 'package:myapp/screens/product_detail_screen.dart';
import 'package:myapp/screens/cart_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/admin/admin_screen.dart';
import 'package:myapp/screens/admin/add_product_screen.dart';
import 'package:myapp/screens/admin/product_list_screen.dart';
import 'package:myapp/screens/admin/edit_product_screen.dart';
import 'package:myapp/screens/admin/order_list_screen.dart';
import 'package:myapp/screens/admin/order_detail_screen.dart'; // Import the new screen

class AppRouter {
  static GoRouter getRouter(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return GoRouter(
      routes: <RouteBase>[
        GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) {
              return const HomeScreen();
            },
            routes: [
              GoRoute(
                path: 'product/:id',
                builder: (BuildContext context, GoRouterState state) {
                  final String productId = state.pathParameters['id']!;
                  return ProductDetailScreen(productId: productId);
                },
              ),
              GoRoute(
                path: 'cart',
                builder: (BuildContext context, GoRouterState state) {
                  return const CartScreen();
                },
              ),
            ]),
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) {
            return const LoginScreen();
          },
        ),
        GoRoute(
          path: '/store',
          builder: (BuildContext context, GoRouterState state) {
            return const StoreScreen();
          },
        ),
        GoRoute(
          path: '/about-us',
          builder: (BuildContext context, GoRouterState state) {
            return const AboutUsScreen();
          },
        ),
        GoRoute(
          path: '/contact-us',
          builder: (BuildContext context, GoRouterState state) {
            return const ContactUsScreen();
          },
        ),
        GoRoute(
            path: '/admin',
            builder: (BuildContext context, GoRouterState state) {
              return const AdminScreen();
            },
            routes: [
              GoRoute(
                path: 'add-product',
                builder: (BuildContext context, GoRouterState state) {
                  return const AddProductScreen();
                },
              ),
              GoRoute(
                path: 'product-list',
                builder: (BuildContext context, GoRouterState state) {
                  return const ProductListScreen();
                },
              ),
              GoRoute(
                path: 'edit-product/:productId',
                builder: (BuildContext context, GoRouterState state) {
                  final String productId = state.pathParameters['productId']!;
                  return EditProductScreen(productId: productId);
                },
              ),
               GoRoute(
                path: 'order-list',
                builder: (BuildContext context, GoRouterState state) {
                  return const OrderListScreen();
                },
              ),
              GoRoute( // Add the route for the order details
                path: 'order-details/:orderId',
                builder: (BuildContext context, GoRouterState state) {
                  final String orderId = state.pathParameters['orderId']!;
                  return OrderDetailScreen(orderId: orderId);
                },
              ),
            ]),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final user = Provider.of<User?>(context, listen: false);
        final isAdmin = userProvider.isAdmin;

        final loggingIn = state.matchedLocation == '/login';
        final goingToAdmin = state.matchedLocation.startsWith('/admin');

        // --- REDIRECT LOGIC ---

        // 1. If user is not logged in
        if (user == null) {
          // Allow access to public routes, otherwise redirect to login
          const publicRoutes = ['/', '/store', '/about-us', '/contact-us', '/login'];
          final isPublicProductRoute = state.matchedLocation.startsWith('/product/');
          if (publicRoutes.contains(state.matchedLocation) || isPublicProductRoute) {
            return null; // Allow navigation
          }
          return '/login'; // Redirect to login
        }

        // 2. If user is logged in
        // a. If they try to go to the login page, redirect them home.
        if (loggingIn) {
          return '/';
        }

        // b. If they try to go to an admin page but are NOT an admin, redirect them home.
        if (goingToAdmin && !isAdmin) {
          return '/';
        }

        // 3. If none of the above conditions are met, allow navigation.
        return null;
      },
      refreshListenable: userProvider,
    );
  }

  static late final GoRouter router;

  static void initialize(BuildContext context) {
    router = getRouter(context);
  }
}
