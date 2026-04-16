import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/presentation/widgets/modern_card.dart';
import '../../../../courses/data/models/course_model.dart';
import '../../../../lectures/data/models/lecture_model.dart';
import '../../../../lectures/presentation/cubit/lecture_cubit.dart';

class CourseLecturesTab extends StatefulWidget {
  final CourseModel course;

  const CourseLecturesTab({super.key, required this.course});

  @override
  State<CourseLecturesTab> createState() => _CourseLecturesTabState();
}

class _CourseLecturesTabState extends State<CourseLecturesTab> {
  @override
  void initState() {
    super.initState();
    context.read<LectureCubit>().getLectures(widget.course.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LectureCubit, LectureState>(
      builder: (context, state) {
        if (state is LectureLoading) return const Center(child: CircularProgressIndicator());
        if (state is LectureError) return Center(child: Text(state.message));
        if (state is LectureLoaded) {
          if (state.lectures.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 60, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    const Text('لا توجد محاضرات حالياً لهذه المادة.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('ابدأ بتوليد خطة الأسابيع الدراسية بضغطة زر.', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<LectureCubit>().generateInitialWeeks(widget.course.id),
                      icon: const Icon(Icons.rocket_launch),
                      label: const Text('البدء بإعداد خطة الأسابيع'),
                    ),
                  ],
                ),
              ),
            );
          }

          final generalMaterial = state.lectures.where((l) => l.order == 999).toList();
          final weeks = state.lectures.where((l) => l.order != 999).toList();

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...weeks.map((lecture) => _buildLectureCard(context, lecture)),
                if (generalMaterial.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('ماتيريال المادة بالكامل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                  ),
                  _buildLectureCard(context, generalMaterial.first, isGeneral: true),
                ],
                const SizedBox(height: 80),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                int nextWeek = 1;
                if (weeks.isNotEmpty) {
                  nextWeek = weeks.map((e) => e.order).reduce((a, b) => a > b ? a : b) + 1;
                }
                context.read<LectureCubit>().addSingleWeek(widget.course.id, nextWeek);
              },
              tooltip: 'إضافة أسبوع جديد',
              child: const Icon(Icons.add),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildLectureCard(BuildContext context, LectureModel lecture, {bool isGeneral = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ModernCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Header
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    image: (lecture.thumbnailUrl != null && lecture.thumbnailUrl!.isNotEmpty)
                        ? DecorationImage(image: NetworkImage(lecture.thumbnailUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: (lecture.thumbnailUrl == null || lecture.thumbnailUrl!.isEmpty)
                      ? Center(child: Icon(Icons.image, size: 40, color: colorScheme.onSurfaceVariant.withOpacity(0.5)))
                      : null,
                ),
                Positioned(
                  top: 8, right: 8,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                          onPressed: () => _showManageLectureBottomSheet(context, lecture),
                        ),
                      ),
                      if (!isGeneral) ...[
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          radius: 18,
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                            onPressed: () => _showDeleteConfirmation(context, lecture),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                      ),
                    ),
                    child: Text(
                      lecture.titleAr,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
            
            // Materials List
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  if (lecture.materials.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('لم يتم إضافة محتوى بعد', style: TextStyle(color: colorScheme.outline, fontSize: 13)),
                    )
                  else
                    ...lecture.materials.map((m) => _buildMaterialTile(context, m)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialTile(BuildContext context, Map<String, dynamic> material) {
    final colorScheme = Theme.of(context).colorScheme;
    final type = material['type'] as String? ?? 'link';
    final title = material['title'] as String? ?? 'بدون عنوان';

    IconData icon;
    Color color;
    switch (type) {
      case 'video':
        icon = Icons.play_circle_fill;
        color = Colors.red;
        break;
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.orange;
        break;
      case 'image':
        icon = Icons.image;
        color = Colors.blue;
        break;
      default:
        icon = Icons.link;
        color = colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () async {
          final url = Uri.parse(material['url'] ?? '');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              Icon(Icons.chevron_right, size: 16, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext rootContext, LectureModel lecture) {
    showDialog(
      context: rootContext,
      builder: (context) => AlertDialog(
        title: const Text('حذف الأسبوع'),
        content: Text('هل أنت متأكد من حذف "${lecture.titleAr}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              rootContext.read<LectureCubit>().deleteLecture(widget.course.id, lecture.id);
              Navigator.pop(context);
            }, 
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showManageLectureBottomSheet(BuildContext rootContext, LectureModel lecture) {
    showModalBottomSheet(
      context: rootContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => _ManageLectureSheet(
        lecture: lecture,
        onSave: (updated) {
          rootContext.read<LectureCubit>().updateWeekMaterial(widget.course.id, updated);
        },
        uploadFile: (bucket, path, file) => rootContext.read<LectureCubit>().uploadFile(bucket, path, file),
      ),
    );
  }
}

class _ManageLectureSheet extends StatefulWidget {
  final LectureModel lecture;
  final Function(LectureModel) onSave;
  final Future<String?> Function(String, String, dynamic) uploadFile;

  const _ManageLectureSheet({required this.lecture, required this.onSave, required this.uploadFile});

  @override
  State<_ManageLectureSheet> createState() => _ManageLectureSheetState();
}

class _ManageLectureSheetState extends State<_ManageLectureSheet> {
  late TextEditingController _titleController;
  late List<Map<String, dynamic>> _materials;
  String? _thumbnailUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.lecture.titleAr);
    _materials = List.from(widget.lecture.materials);
    _thumbnailUrl = widget.lecture.thumbnailUrl;
  }

  Future<void> _pickThumbnail() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isUploading = true);
      final path = 'thumbnails/${DateTime.now().millisecondsSinceEpoch}_thumbnail.jpg';
      final url = await widget.uploadFile('lectures', path, File(image.path));
      if (url != null) setState(() => _thumbnailUrl = url);
      setState(() => _isUploading = false);
    }
  }

  Future<void> _addMaterial() async {
    final type = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('اختر نوع الماتيريال'),
        children: [
          _dialogItem(context, 'فيديو (YouTube/Drive)', Icons.play_circle, 'video'),
          _dialogItem(context, 'ملف PDF', Icons.picture_as_pdf, 'pdf'),
          _dialogItem(context, 'صورة', Icons.image, 'image'),
          _dialogItem(context, 'رابط خارجي', Icons.link, 'link'),
        ],
      ),
    );

    if (type == null || !mounted) return;

    String name = '';
    String url = '';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('إضافة $type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'اسم الماتيريال'),
                onChanged: (v) => name = v,
              ),
              const SizedBox(height: 12),
              if (type == 'video' || type == 'link')
                TextField(
                  decoration: const InputDecoration(labelText: 'الرابط (URL)'),
                  onChanged: (v) => url = v,
                )
              else
                ElevatedButton.icon(
                  onPressed: () async {
                    if (type == 'pdf') {
                      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                      if (result != null) {
                        setDialogState(() => _isUploading = true);
                        final path = 'materials/pdf/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
                        final uploadedUrl = await widget.uploadFile('lectures', path, File(result.files.single.path!));
                        if (uploadedUrl != null) url = uploadedUrl;
                        setDialogState(() => _isUploading = false);
                      }
                    } else if (type == 'image') {
                      final picker = ImagePicker();
                      final img = await picker.pickImage(source: ImageSource.gallery);
                      if (img != null) {
                        setDialogState(() => _isUploading = true);
                        final path = 'materials/img/${DateTime.now().millisecondsSinceEpoch}_img.jpg';
                        final uploadedUrl = await widget.uploadFile('lectures', path, File(img.path));
                        if (uploadedUrl != null) url = uploadedUrl;
                        setDialogState(() => _isUploading = false);
                      }
                    }
                  },
                  icon: Icon(_isUploading ? Icons.sync : Icons.upload_file),
                  label: Text(_isUploading ? 'جاري الرفع...' : 'اختر ملف للرفع'),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && url.isNotEmpty) {
                  Navigator.pop(context);
                }
              }, 
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );

    if (name.isNotEmpty && url.isNotEmpty) {
      setState(() {
        _materials.add({'type': type, 'title': name, 'url': url});
      });
    }
  }

  Widget _dialogItem(BuildContext context, String text, IconData icon, String value) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, value),
      child: Row(children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(text)]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تعديل محتوى الأسبوع', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'اسم الأسبوع / المحاضرة')),
            const SizedBox(height: 20),
            const Text('صورة غلاف الأسبوع', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickThumbnail,
              child: Container(
                height: 120, width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100], borderRadius: BorderRadius.circular(12),
                  image: _thumbnailUrl != null ? DecorationImage(image: NetworkImage(_thumbnailUrl!), fit: BoxFit.cover) : null,
                ),
                child: _isUploading ? const Center(child: CircularProgressIndicator()) : (_thumbnailUrl == null ? const Icon(Icons.add_a_photo) : null),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الملفات والمحتوى', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(onPressed: _addMaterial, icon: const Icon(Icons.add), label: const Text('إضافة')),
              ],
            ),
            ..._materials.asMap().entries.map((e) => Card(
              child: ListTile(
                leading: Icon(_getIconFor(e.value['type'])),
                title: Text(e.value['title'] ?? ''),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _materials.removeAt(e.key))),
              ),
            )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final updated = LectureModel(
                    id: widget.lecture.id, 
                    title: widget.lecture.title, 
                    titleAr: _titleController.text,
                    thumbnailUrl: _thumbnailUrl, 
                    materials: _materials, 
                    order: widget.lecture.order, 
                    isPublished: widget.lecture.isPublished, 
                    createdAt: widget.lecture.createdAt, 
                    creatorName: widget.lecture.creatorName,
                  );
                  widget.onSave(updated);
                  Navigator.pop(context);
                },
                child: const Text('حفظ التغييرات'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconFor(dynamic type) {
    if (type == 'video') return Icons.play_circle;
    if (type == 'pdf') return Icons.picture_as_pdf;
    if (type == 'image') return Icons.image;
    return Icons.link;
  }
}
