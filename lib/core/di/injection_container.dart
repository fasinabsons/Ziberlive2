import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/bill_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/bill_repository.dart';
import '../../domain/usecases/user/register_user_usecase.dart';
import '../../domain/usecases/user/manage_subscription_usecase.dart';
import '../../domain/usecases/bill/create_bill_usecase.dart';
import '../services/p2p_sync_service.dart';
import '../services/bluetooth_messaging_service.dart';
import '../services/data_sync_service.dart';
import '../services/ad_service.dart';
import 'injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Initialize DatabaseHelper
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper());
  
  // Register repositories
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<DatabaseHelper>(), getIt<SharedPreferences>()),
  );
  
  getIt.registerLazySingleton<BillRepository>(
    () => BillRepositoryImpl(getIt<DatabaseHelper>()),
  );
  
  // Register services
  getIt.registerLazySingleton<P2PSyncService>(() => P2PSyncService());
  getIt.registerLazySingleton<BluetoothMessagingService>(() => BluetoothMessagingService());
  getIt.registerLazySingleton<AdService>(() => AdService());
  getIt.registerLazySingleton<DataSyncService>(
    () => DataSyncService(
      getIt<DatabaseHelper>(),
      getIt<P2PSyncService>(),
      getIt<BluetoothMessagingService>(),
      getIt<AdService>(),
    ),
  );
  
  // Register use cases
  getIt.registerLazySingleton<RegisterUserUseCase>(
    () => RegisterUserUseCase(getIt<UserRepository>()),
  );
  
  getIt.registerLazySingleton<ManageSubscriptionUseCase>(
    () => ManageSubscriptionUseCase(getIt<UserRepository>()),
  );
  
  // Initialize generated dependencies
  getIt.init();
}

// Manual registration for core services that need special initialization
Future<void> initializeServices() async {
  // Database initialization
  final databaseHelper = getIt<DatabaseHelper>();
  await databaseHelper.database; // This will create the database if it doesn't exist
  
  // P2P service initialization will be added here
  // Ad service initialization will be added here
}