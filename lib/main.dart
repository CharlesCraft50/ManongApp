import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logging/logging.dart';
import 'package:manong_application/models/manong.dart';
import 'package:manong_application/models/service_request.dart';
import 'package:manong_application/models/sub_service_item.dart';
import 'package:manong_application/providers/bottom_nav_provider.dart';
import 'package:manong_application/screens/auth/register_screen.dart';
import 'package:manong_application/screens/auth/verify_screen.dart';
import 'package:manong_application/screens/booking/booking_summary_screen.dart';
import 'package:manong_application/screens/booking/card_add_payment_method_screen.dart';
import 'package:manong_application/screens/booking/manong_details_screen.dart';
import 'package:manong_application/screens/booking/manong_list_screen.dart';
import 'package:manong_application/screens/booking/payment_methods_screen.dart';
import 'package:manong_application/screens/booking/problem_details_screen.dart';
import 'package:manong_application/screens/booking/sub_service_list_screen.dart';
import 'package:manong_application/screens/main_screen.dart';
import 'package:manong_application/screens/profile/edit_profile.dart';
import 'package:manong_application/screens/service_requests/route_tracking_screen.dart';
import 'package:manong_application/widgets/authenticated_screen.dart';
import 'package:manong_application/widgets/location_map.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL; // capture all logs
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}',
    );
  });

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await GetStorage.init();

  await Future.delayed(Duration(seconds: 1));

  FlutterNativeSplash.remove();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BottomNavProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manong Application',
      initialRoute: '/',
      navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => MainScreen(
                index: args?['index'] != null ? args!['index'] as int : null,
              ),
            );
          case '/register':
            return MaterialPageRoute(builder: (_) => RegisterScreen());
          case '/verify':
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (_) => VerifyScreen(
                authService: args['authService'],
                verificationId: args['verificationId'],
                phoneNumber: args['phoneNumber'],
              ),
            );
          case '/sub-service-list':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => SubServiceListScreen(
                serviceItem: args['serviceItem'],
                iconColor: args['iconColor'],
              ),
            );
          case '/problem-details':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AuthenticatedScreen(
                child: ProblemDetailsScreen(
                  serviceItem: args['serviceItem'],
                  subServiceItem: args['subServiceItem'],
                  iconColor: args['iconColor'],
                ),
              ),
            );
          case '/location-map':
            return MaterialPageRoute(builder: (_) => LocationMap());
          case '/route-tracking':
            final args = settings.arguments as Map<String, dynamic>?;

            return MaterialPageRoute(
              builder: (_) => RouteTrackingScreen(
                currentLatLng: args?['currentLatLng'] as LatLng?,
                manongLatLng: args?['manongLatLng'] as LatLng?,
                manongName: args?['manongName'] as String?,
              ),
            );
          case '/manong-list':
            final args = settings.arguments as Map<String, dynamic>?;

            ServiceRequest? serviceRequest;

            if (args?['serviceRequest'] is ServiceRequest) {
              serviceRequest = args?['serviceRequest'] as ServiceRequest;
            } else {
              serviceRequest = ServiceRequest.fromJson(args?['serviceRequest']);
            }

            return MaterialPageRoute(
              builder: (_) => ManongListScreen(
                serviceRequest: args?['serviceRequest'] != null
                    ? serviceRequest!
                    : throw Exception(
                        'ManongListScreen: serviceRequest is required',
                      ),
                subServiceItem: args?['subServiceItem'] != null
                    ? args!['subServiceItem']
                    : null,
              ),
            );

          case '/manong-details':
            final args = settings.arguments as Map<String, dynamic>?;

            return MaterialPageRoute(
              builder: (_) => ManongDetailsScreen(
                currentLatLng: args?['currentLatLng'] as LatLng?,
                manongLatLng: args?['manongLatLng'] as LatLng?,
                manongName: args?['manongName'] as String?,
                manong: args?['manong'] as Manong?,
                serviceRequest: args?['serviceRequest'] as ServiceRequest?,
                subServiceItem: args?['subServiceItem'] as SubServiceItem?,
              ),
            );

          case '/payment-methods':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => PaymentMethodsScreen(
                selectedIndex: args?['selectedIndex'] != null
                    ? int.tryParse(args!['selectedIndex'].toString())
                    : null,
              ),
            );

          case '/card-add-payment-method':
            return MaterialPageRoute(
              builder: (_) => CardAddPaymentMethodScreen(),
            );

          case '/booking-summary':
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (_) => BookingSummaryScreen(
                serviceRequest: args['serviceRequest'] as ServiceRequest,
                manong: args['manong'] as Manong,
              ),
            );
          case '/edit-profile':
            return MaterialPageRoute(builder: (_) => EditProfile());
        }
        return null;
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
