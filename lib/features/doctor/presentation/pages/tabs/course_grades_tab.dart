import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/presentation/widgets/modern_card.dart';
import '../../../../courses/data/models/course_model.dart';
import '../../../../courses/data/models/grade_model.dart';
import '../../../../courses/presentation/cubit/grades_cubit.dart';

class CourseGradesTab extends StatefulWidget {
  final CourseModel course;

  const CourseGradesTab({super.key, required this.course});

  @override
  State<CourseGradesTab> createState() => _CourseGradesTabState();
}

class _CourseGradesTabState extends State<CourseGradesTab> {
  @override
  void initState() {
    super.initState();
    context.read<GradesCubit>().getEnrolledStudentsWithGrades(widget.course.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GradesCubit, GradesState>(
      builder: (context, state) {
        if (state is GradesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is GradesError) {
          return Center(child: Text(state.message));
        }
        if (state is GradesLoaded) {
          if (state.studentsGrades.isEmpty) {
            return const Center(child: Text('لا يوجد طلاب مسجلون في هذه المادة.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.studentsGrades.length,
            itemBuilder: (context, index) {
              final studentData = state.studentsGrades[index];
              final grade = studentData['grade'] as GradeModel;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ModernCard(
                  onTap: () => _showGradeBottomSheet(context, studentData),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Text(studentData['full_name'][0]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentData['full_name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('ID: ${studentData['university_id']}'),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'المجموع',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            '${grade.total} / 100',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showGradeBottomSheet(BuildContext rootContext, Map<String, dynamic> studentData) {
    final grade = studentData['grade'] as GradeModel;
    
    // Using a separate StatefulBuilder inside the bottom sheet
    showModalBottomSheet(
      context: rootContext,
      isScrollControlled: true,
      builder: (context) {
        // Temporary state for the bottom sheet
        double midterm = grade.midterm;
        double practical = grade.practical;
        double oral = grade.oral;
        double tasks = grade.tasksAttendance;
        double finalExam = grade.finalExam;
        double bonus = grade.bonus;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24, left: 24, right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'تعديل الدرجات - ${studentData['full_name']}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildGradeField('الميدتيرم (من 15)', midterm.toString(), (val) => setModalState(() => midterm = double.tryParse(val) ?? 0)),
                    _buildGradeField('العملي (من 10)', practical.toString(), (val) => setModalState(() => practical = double.tryParse(val) ?? 0)),
                    _buildGradeField('الشفوي (من 10)', oral.toString(), (val) => setModalState(() => oral = double.tryParse(val) ?? 0)),
                    _buildGradeField('أعمال السنة / الغياب (من 5)', tasks.toString(), (val) => setModalState(() => tasks = double.tryParse(val) ?? 0)),
                    _buildGradeField('الفاينال (من 60)', finalExam.toString(), (val) => setModalState(() => finalExam = double.tryParse(val) ?? 0)),
                    _buildGradeField('بونص', bonus.toString(), (val) => setModalState(() => bonus = double.tryParse(val) ?? 0)),
                    
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final updatedGrade = GradeModel(
                            id: grade.id,
                            courseId: grade.courseId,
                            studentId: grade.studentId,
                            midterm: midterm,
                            practical: practical,
                            oral: oral,
                            tasksAttendance: tasks,
                            finalExam: finalExam,
                            bonus: bonus,
                          );
                          rootContext.read<GradesCubit>().updateGrade(grade.courseId, updatedGrade);
                          Navigator.pop(context);
                        },
                        child: const Text('حفظ التعديلات'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGradeField(String label, String initialVal, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        initialValue: initialVal,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
