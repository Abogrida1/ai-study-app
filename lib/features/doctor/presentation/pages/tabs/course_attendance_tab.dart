import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/presentation/widgets/modern_card.dart';
import '../../../../courses/data/models/course_model.dart';
import '../../../../courses/data/models/attendance_model.dart';
import '../../../../courses/presentation/cubit/attendance_cubit.dart';
import '../../../../lectures/presentation/cubit/lecture_cubit.dart';
import '../../../../lectures/data/models/lecture_model.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';

class CourseAttendanceTab extends StatefulWidget {
  final CourseModel course;

  const CourseAttendanceTab({super.key, required this.course});

  @override
  State<CourseAttendanceTab> createState() => _CourseAttendanceTabState();
}

class _CourseAttendanceTabState extends State<CourseAttendanceTab> {
  LectureModel? selectedLecture;
  bool isScannerActive = false;

  @override
  void initState() {
    super.initState();
    context.read<LectureCubit>().getLectures(widget.course.id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Lecture Selector & Scanner Toggle
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<LectureCubit, LectureState>(
            builder: (context, state) {
              if (state is LectureLoading) return const CircularProgressIndicator();
              if (state is LectureLoaded) {
                final attendanceLectures = state.lectures.where((l) => l.order != 999).toList();
                
                if (attendanceLectures.isEmpty) {
                  return const Text('لا توجد محاضرات لاختيارها للحضور.');
                }
                
                if ((selectedLecture == null || selectedLecture!.order == 999) && attendanceLectures.isNotEmpty) {
                  selectedLecture = attendanceLectures.first;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<AttendanceCubit>().getEnrolledStudentsWithAttendance(widget.course.id, selectedLecture!.id);
                  });
                }

                return Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<LectureModel>(
                        value: selectedLecture,
                        decoration: const InputDecoration(
                          labelText: 'اختر المحاضرة',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: attendanceLectures.map((l) {
                          return DropdownMenuItem(
                            value: l,
                            child: Text(l.titleAr),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedLecture = val;
                          });
                          if (val != null) {
                            context.read<AttendanceCubit>().getEnrolledStudentsWithAttendance(widget.course.id, val.id);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: selectedLecture == null 
                        ? () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('يرجى اختيار المحاضرة أولاً!')),
                          )
                        : () {
                            setState(() {
                              isScannerActive = !isScannerActive;
                            });
                          },
                      icon: Icon(isScannerActive ? Icons.close : Icons.qr_code_scanner),
                      style: IconButton.styleFrom(
                        backgroundColor: isScannerActive ? Colors.red : (selectedLecture == null ? Colors.grey : null),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),

        if (isScannerActive && selectedLecture != null)
          _buildScannerView()
        else if (isScannerActive && selectedLecture == null)
          const Expanded(child: Center(child: Text('يرجى اختيار أسبوع للتحضير قبل فتح الكاميرا.')))
        else
          Expanded(
            child: _AttendanceListContent(
              courseId: widget.course.id, 
              lectureId: selectedLecture?.id,
              onStudentsLoaded: () {},
            ),
          ),
      ],
    );
  }

  Widget _buildScannerView() {
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            MobileScanner(
              controller: MobileScannerController(
                facing: CameraFacing.back,
                torchEnabled: false,
              ),
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _onQRCodeScanned(barcode.rawValue!);
                  }
                }
              },
            ),
            // Custom overlay
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // A simple scanning line animation placeholder or just a corner design
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 140,
                        height: 2,
                        color: Colors.red.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'جاري التحضير لـ: ${selectedLecture?.titleAr}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQRCodeScanned(String studentId) async {
    // Only process if scanning is active AND we have a selected lecture
    if (!isScannerActive || selectedLecture == null) return;
    // Basic verification: UUID length is 36
    if (studentId.length >= 30) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 100);
      }
      
      if (!mounted) return;
      context.read<AttendanceCubit>().toggleAttendance(
        widget.course.id,
        selectedLecture!.id,
        studentId,
        true,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم تحضير الطالب بنجاح!'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 20, right: 20,
          ),
        ),
      );
    }
  }
}

class _AttendanceListContent extends StatelessWidget {
  final String courseId;
  final String? lectureId;
  final VoidCallback onStudentsLoaded;

  const _AttendanceListContent({
    required this.courseId, 
    this.lectureId,
    required this.onStudentsLoaded,
  });

  @override
  Widget build(BuildContext context) {
    if (lectureId == null) {
      return const Center(child: Text('يرجى اختيار المحاضرة أولاً.'));
    }

    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, state) {
        if (state is AttendanceLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AttendanceError) {
          return Center(child: Text(state.message));
        }
        if (state is AttendanceLoaded) {
          if (state.studentsAttendance.isEmpty) {
            return const Center(child: Text('لا يوجد طلاب مسجلون في هذه المادة.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.studentsAttendance.length,
            itemBuilder: (context, index) {
              final studentData = state.studentsAttendance[index];
              final att = studentData['attendance'] as AttendanceModel;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ModernCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      Switch(
                        value: att.isPresent,
                        activeColor: Colors.green,
                        onChanged: (val) {
                          context.read<AttendanceCubit>().toggleAttendance(
                            courseId, 
                            lectureId!, 
                            studentData['student_id'], 
                            val
                          );
                        },
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
}
