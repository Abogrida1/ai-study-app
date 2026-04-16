import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Features - Auth
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/upload_avatar_usecase.dart';
import 'core/cubit/auth_cubit.dart';

// Features - Courses
import 'features/courses/data/datasources/course_remote_data_source.dart';
import 'features/courses/data/repositories/course_repository_impl.dart';
import 'features/courses/domain/repositories/course_repository.dart';
import 'features/courses/domain/usecases/get_enrolled_courses_usecase.dart';
import 'features/courses/domain/usecases/get_assigned_courses_usecase.dart';
import 'features/courses/presentation/cubit/course_cubit.dart';
import 'features/courses/presentation/cubit/grades_cubit.dart';
import 'features/courses/data/datasources/grades_remote_data_source.dart';
import 'features/courses/presentation/cubit/attendance_cubit.dart';
import 'features/courses/data/datasources/attendance_remote_data_source.dart';
import 'features/chat/presentation/cubit/chat_cubit.dart';
import 'features/lectures/presentation/cubit/lecture_cubit.dart';

// Features - Chat
import 'features/chat/data/datasources/chat_remote_data_source.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';

// Features - Lectures
import 'features/lectures/data/datasources/lecture_remote_data_source.dart';
import 'features/lectures/data/repositories/lecture_repository_impl.dart';
import 'features/lectures/domain/repositories/lecture_repository.dart';

// Features - Exams
import 'features/exams/data/datasources/exam_remote_data_source.dart';
import 'features/exams/data/repositories/exam_repository_impl.dart';
import 'features/exams/domain/repositories/exam_repository.dart';

final sl = GetIt.instance; // sl is Service Locator

Future<void> init() async {
  //! External
  sl.registerLazySingleton(() => Supabase.instance.client);

  //! Features
  
  // Auth
  sl.registerFactory(() => AuthCubit(
    signInUseCase: sl(),
    getCurrentUserUseCase: sl(),
    uploadAvatarUseCase: sl(),
    supabaseClient: sl(),
  ));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(supabaseClient: sl()));

  // Courses
  sl.registerFactory(() => CourseCubit(
    getEnrolledCoursesUseCase: sl(),
    getAssignedCoursesUseCase: sl(),
  ));
  sl.registerLazySingleton(() => GetEnrolledCoursesUseCase(sl()));
  sl.registerLazySingleton(() => GetAssignedCoursesUseCase(sl()));
  sl.registerLazySingleton<CourseRepository>(() => CourseRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<CourseRemoteDataSource>(() => CourseRemoteDataSourceImpl(supabaseClient: sl()));

  // Grades & Attendance
  sl.registerFactory(() => GradesCubit(dataSource: sl()));
  sl.registerLazySingleton<GradesRemoteDataSource>(() => GradesRemoteDataSourceImpl(supabaseClient: sl()));
  sl.registerFactory(() => AttendanceCubit(dataSource: sl()));
  sl.registerLazySingleton<AttendanceRemoteDataSource>(() => AttendanceRemoteDataSourceImpl(supabaseClient: sl()));
  
  // Lectures Cubit
  sl.registerFactory(() => LectureCubit(repository: sl()));

  // Chat
  sl.registerFactory(() => ChatCubit());

  // Chat
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl(supabaseClient: sl()));

  // Lectures
  sl.registerLazySingleton<LectureRepository>(() => LectureRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<LectureRemoteDataSource>(() => LectureRemoteDataSourceImpl(supabaseClient: sl()));

  // Exams
  sl.registerLazySingleton<ExamRepository>(() => ExamRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ExamRemoteDataSource>(() => ExamRemoteDataSourceImpl(supabaseClient: sl()));
}
