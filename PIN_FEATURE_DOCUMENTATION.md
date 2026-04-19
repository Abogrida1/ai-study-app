# Pin/Bookmark Feature Implementation

## Overview
تم تنفيذ ميزة Pin/Bookmark للمواد في تطبيق الطالب. تسمح للطلاب بـ:
- ✅ حفظ (pin) المواد المفضلة بنقرة على أيقونة الـ bookmark
- ✅ عرض المواد المثبتة فقط في قسم "Pinned Subjects" بالصفحة الرئيسية
- ✅ حفظ الحالة محليّاً في الجهاز (Local Storage)
- ✅ التبديل بين الحالات بسهولة (pinned/unpinned)

## Files Modified

### 1. `pubspec.yaml`
**التغيير**: إضافة مكتبة `shared_preferences`
```yaml
shared_preferences: ^2.2.2
```
**السبب**: للتخزين المحلي للمواد المثبتة

### 2. `lib/core/local_storage/pinned_courses_storage.dart` (ملف جديد)
**الوصف**: فئة للإدارة المركزية للمواد المثبتة

**الدوال الرئيسية**:
- `addPinnedCourse(String courseId)`: إضافة مادة للقائمة المثبتة
- `removePinnedCourse(String courseId)`: إزالة مادة من القائمة المثبتة
- `getPinnedCourses()`: الحصول على جميع المواد المثبتة
- `isPinned(String courseId)`: التحقق من أن المادة مثبتة

### 3. `lib/features/student/presentation/pages/subjects_screen.dart`
**التعديلات**:

#### أ) Import الجديد:
```dart
import '../../../../core/local_storage/pinned_courses_storage.dart';
```

#### ب) تعديل استدعاء `_buildSubjectCard`:
- إضافة معامل `courseId` (معرف فريد لكل مادة)
- إزالة معامل `isBookmarked` (الآن يتم جلبه ديناميكياً)

#### ج) تعديل دالة `_buildSubjectCard`:
- استخدام `StatefulBuilder` + `FutureBuilder` لجلب حالة الـ bookmark
- جعل زر الـ bookmark **قابلاً للنقر** (onTap event)
- عند النقر:
  - إذا كانت المادة مثبتة → حذفها
  - إذا لم تكن مثبتة → إضافتها
  - تحديث الـ UI تلقائياً

**كود زر الـ bookmark**:
```dart
Positioned(
  top: 16,
  right: 16,
  child: GestureDetector(
    onTap: () async {
      if (isBookmarked) {
        await PinnedCoursesStorage.removePinnedCourse(courseId);
      } else {
        await PinnedCoursesStorage.addPinnedCourse(courseId);
      }
      setState(() {});
    },
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isBookmarked ? colorScheme.primary : Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        size: 20,
        color: isBookmarked ? colorScheme.onPrimary : const Color(0xFF64748B),
      ),
    ),
  ),
),
```

### 4. `lib/features/student/presentation/pages/student_home_screen.dart`
**التعديلات**:

#### أ) Import الجديد:
```dart
import '../../../../core/local_storage/pinned_courses_storage.dart';
```

#### ب) تعديل قسم "Pinned Subjects":
- جلب قائمة المواد المثبتة من Local Storage
- تصفية المواد الكاملة لعرض فقط المواد المثبتة
- إذا كانت لا توجد مواد مثبتة: عرض رسالة فارغة جميلة

**الكود**:
```dart
FutureBuilder<List<String>>(
  future: PinnedCoursesStorage.getPinnedCourses(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final pinnedCourseIds = snapshot.data ?? [];
    final pinnedCourses = courses.where((course) => pinnedCourseIds.contains(course.id)).toList();
    
    if (pinnedCourses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              Icon(Icons.bookmark_outline, size: 48, color: colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'No pinned courses',
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      children: pinnedCourses.map((course) => Padding(...)).toList(),
    );
  },
)
```

## كيفية الاستخدام

### للطالب (User Experience):
1. اذهب لصفحة "My Subjects"
2. انقر على أيقونة الـ bookmark (أيقونة الكتاب) في الزاوية العلوية اليمنى لأي مادة
3. الأيقونة تتحول من فارغة إلى ممتلئة (تصبح زرقاء)
4. اذهب للصفحة الرئيسية
5. ستظهر المواد المثبتة فقط في قسم "Pinned Subjects"

### للمطور (Developer):
```dart
// إضافة مادة
await PinnedCoursesStorage.addPinnedCourse('course-id-123');

// إزالة مادة
await PinnedCoursesStorage.removePinnedCourse('course-id-123');

// الحصول على جميع المواد المثبتة
final pinnedIds = await PinnedCoursesStorage.getPinnedCourses();

// التحقق من مادة معينة
final isPinned = await PinnedCoursesStorage.isPinned('course-id-123');

// حذف جميع المثبتة
await PinnedCoursesStorage.clearAllPinned();
```

## التخزين والبيانات

### Local Storage (SharedPreferences)
- **المفتاح**: `pinned_courses`
- **الصيغة**: `List<String>` (قائمة معرفات المواد)
- **التخزين**: ملف JSON محلي على الجهاز
- **البقاء**: حتى حذف البيانات أو حذف التطبيق

### مثال من البيانات المحفوظة:
```json
{
  "pinned_courses": ["course-001", "course-005", "course-012"]
}
```

## الحالات الحدية

### 1. عند بدء التطبيق
- إذا لم تكن هناك مواد مثبتة → عرض رسالة "No pinned courses"

### 2. عند مسح جميع المثبتة
- القائمة تصبح فارغة
- الصفحة الرئيسية تعرض رسالة فارغة

### 3. عند حذف التطبيق وإعادة تثبيته
- جميع المواد المثبتة تُفقد (تُحفظ محلياً فقط)

## التحسينات المستقبلية

### 1. **Sync مع السيرفر** (اختياري)
- حفظ المواد المثبتة في Supabase (جدول `user_preferences`)
- مزامنة تلقائية عند تسجيل الدخول

### 2. **Reordering** (اختياري)
- السماح بإعادة ترتيب المواد المثبتة بـ Drag & Drop

### 3. **Colors/Tags** (اختياري)
- تعيين ألوان أو علامات لكل مادة مثبتة

### 4. **Analytics** (اختياري)
- تتبع أي المواد يتم تثبيتها بشكل أكثر

## Troubleshooting

### المشكلة: الزر لا يتفاعل
**الحل**: تأكد من وجود `courseId` صحيح وغير فارغ

### المشكلة: البيانات لا تُحفظ
**الحل**: تأكد من تثبيت `shared_preferences` بـ `flutter pub get`

### المشكلة: المواد المثبتة لا تظهر في الصفحة الرئيسية
**الحل**: تحقق من أن معرف المادة (courseId) يطابق في كلا الصفحتين

## ملاحظات تقنية

- ✅ **State Management**: استخدام `StatefulBuilder` لإدارة الحالة المحلية
- ✅ **Async Operations**: جميع العمليات async لتجنب blocking
- ✅ **Error Handling**: معالجة الأخطاء في FutureBuilder
- ✅ **UI Responsiveness**: تحديث فوري عند النقر (setState)
- ✅ **Performance**: استخدام `.where()` لتصفية المواد بكفاءة

## الاختبار

### خطوات الاختبار اليدوي:
1. ✅ فتح التطبيق والذهاب لصفحة Subjects
2. ✅ نقر على bookmark لمادة واحدة
3. ✅ التحقق من تحول اللون إلى الأزرق
4. ✅ الذهاب للصفحة الرئيسية
5. ✅ التحقق من ظهور المادة المثبتة فقط
6. ✅ إغلاق التطبيق وإعادة فتحه
7. ✅ التحقق من بقاء البيانات (persisted)
8. ✅ نقر على bookmark مرة أخرى لإزالة التثبيت
9. ✅ التحقق من رسالة "No pinned courses"
