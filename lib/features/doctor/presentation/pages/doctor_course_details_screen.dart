import 'package:flutter/material.dart';
import '../../../courses/data/models/course_model.dart';
import 'tabs/course_lectures_tab.dart';
import 'tabs/course_grades_tab.dart';
import 'tabs/course_attendance_tab.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../injection_container.dart';
import '../../../lectures/presentation/cubit/lecture_cubit.dart';
import '../../../courses/presentation/cubit/grades_cubit.dart';
import '../../../courses/presentation/cubit/attendance_cubit.dart';

class DoctorCourseDetailsScreen extends StatelessWidget {
  final CourseModel course;

  const DoctorCourseDetailsScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LectureCubit>()),
        BlocProvider(create: (_) => sl<GradesCubit>()),
        BlocProvider(create: (_) => sl<AttendanceCubit>()),
      ],
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // In Dart, course.nameAr might be non-nullable if CourseEntity defines it as such.
                // Assuming nameAr is nullable but the IDE says it's not. 
                // Let's check: actually the IDE says left operand can't be null. So I just remove `?? course.name`.
                // Same for course.code ?? '' -> just course.code if they are non-nullable.
                course.nameAr,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                course.code,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          backgroundColor: isDark ? colorScheme.surface : Colors.white,
          elevation: 0,
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.video_library), text: 'المحاضرات'),
              Tab(icon: Icon(Icons.grading), text: 'الطلاب والدرجات'),
              Tab(icon: Icon(Icons.fact_check), text: 'الغياب والحضور'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CourseLecturesTab(course: course),
            CourseGradesTab(course: course),
            CourseAttendanceTab(course: course),
          ],
        ),
      ),
    ));
  }
}
