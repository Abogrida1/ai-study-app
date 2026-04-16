'use client';

import React, { useState } from 'react';
import { deleteUser, updateTA } from '@/app/actions/users';

// coursesWithSections: [{id, code, name, name_ar, level_id, sections: [{id, name, level_id}]}]
// sectionsMap: {sectionId: {id, name, level_id}}
export default function TAsTableClient({ tas, sectionsMap, coursesWithSections }: any) {
  const [editingTA, setEditingTA] = useState<any>(null);
  const [isDeleting, setIsDeleting] = useState<string | null>(null);
  
  const [formData, setFormData] = useState({
    university_id: '',
    full_name: '',
    plain_password: '',
  });
  
  // Format: {course_id: string, section_id: string}
  const [selectedAssignments, setSelectedAssignments] = useState<{course_id: string, section_id: string}[]>([]);
  const [isSaving, setIsSaving] = useState(false);

  const openEditModal = (ta: any) => {
    setEditingTA(ta);
    setFormData({
      university_id: ta.university_id || '',
      full_name: ta.full_name || '',
      plain_password: ta.plain_password || '',
    });
    
    // Convert existing assignments (scope='section' only for TAs)
    const currentAssigns = (ta.assignments || [])
      .filter((a: any) => a.course_id && a.scope_id)
      .map((a: any) => ({
        course_id: a.course_id,
        section_id: a.scope_id
      }));
    
    setSelectedAssignments(currentAssigns);
  };

  const handleSave = async () => {
    setIsSaving(true);
    const res = await updateTA(editingTA.id, formData, selectedAssignments);
    setIsSaving(false);
    if (res.success) {
      setEditingTA(null);
      window.location.reload();
    } else {
      alert("حدث خطأ أثناء الحفظ: " + res.error);
    }
  };

  const handleDelete = async (id: string) => {
    if (confirm("هل أنت متأكد من حذف هذا المعيد نهائياً؟")) {
      setIsDeleting(id);
      const res = await deleteUser(id);
      setIsDeleting(null);
      if (!res.success) alert("حدث خطأ أثناء الحذف: " + res.error);
      else window.location.reload();
    }
  };

  const toggleAssignment = (courseId: string, sectionId: string) => {
    setSelectedAssignments(prev => {
      const exists = prev.some(a => a.course_id === courseId && a.section_id === sectionId);
      if (exists) {
        return prev.filter(a => !(a.course_id === courseId && a.section_id === sectionId));
      } else {
        return [...prev, { course_id: courseId, section_id: sectionId }];
      }
    });
  };

  const safeCoursesWithSections = coursesWithSections || [];

  return (
    <>
      {/* Table */}
      <div className="bg-surface-container-low border border-outline-variant/10 rounded-2xl overflow-hidden mt-6">
        <div className="overflow-x-auto">
          <table className="w-full text-right" dir="rtl">
            <thead>
              <tr className="border-b border-outline-variant/10 bg-surface-container-highest">
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-right w-16">الكود</th>
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-right">الباسوورد</th>
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-right">الاسم</th>
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-right">السكاشن والمواد</th>
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-center w-24">إجراءات</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-outline-variant/5">
              {tas?.map((t: any) => (
                <tr key={t.id} className="hover:bg-primary/[0.02] transition-colors">
                  <td className="py-4 px-6 font-bold text-sm text-primary" dir="ltr">{t.university_id}</td>
                  <td className="py-4 px-6 text-sm font-mono text-on-surface-variant">{t.plain_password || 'مخفي'}</td>
                  <td className="py-4 px-6 text-sm font-bold">{t.full_name}</td>
                  <td className="py-4 px-6 text-sm">
                    <div className="flex flex-col gap-1">
                      {t.assignments && t.assignments.length > 0 ? (
                        t.assignments.map((a: any, i: number) => {
                          const sectionData = a.scope_id ? sectionsMap[a.scope_id] : null;
                          return (
                            <div key={i} className="text-xs">
                              {a.courses && <span className="font-bold text-emerald-600 ml-1">{a.courses.name_ar || a.courses.name}</span>}
                              {sectionData && <span className="text-on-surface-variant">— {sectionData.name}</span>}
                            </div>
                          );
                        })
                      ) : (
                        <span className="text-on-surface-variant text-xs">بدون تكليفات</span>
                      )}
                    </div>
                  </td>
                  <td className="py-4 px-6 text-sm">
                    <div className="flex items-center justify-center gap-2">
                      <button onClick={() => openEditModal(t)} className="w-8 h-8 rounded-full bg-primary/10 text-primary flex items-center justify-center hover:bg-primary/20 transition-colors">
                        <span className="material-symbols-outlined text-[18px]">edit</span>
                      </button>
                      <button onClick={() => handleDelete(t.id)} disabled={isDeleting === t.id} className="w-8 h-8 rounded-full bg-error/10 text-error flex items-center justify-center hover:bg-error/20 transition-colors disabled:opacity-50">
                        <span className="material-symbols-outlined text-[18px]">delete</span>
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
              {(!tas || tas.length === 0) && (
                <tr>
                  <td colSpan={5} className="py-8 text-center text-on-surface-variant">لا يوجد معيدين مسجلين</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Edit Modal */}
      {editingTA && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4" dir="rtl">
          <div className="bg-surface-container-lowest border border-outline-variant/20 rounded-3xl w-full max-w-3xl max-h-[90vh] flex flex-col shadow-2xl overflow-hidden animate-in fade-in zoom-in-95 duration-200">
            <div className="px-6 py-4 border-b border-outline-variant/10 flex justify-between items-center bg-surface-container-low/50">
              <h2 className="text-xl font-bold font-headline text-primary">تعديل بيانات المعيد</h2>
              <button onClick={() => setEditingTA(null)} className="text-on-surface-variant hover:bg-surface-container rounded-full p-2">
                <span className="material-symbols-outlined text-[20px]">close</span>
              </button>
            </div>
            
            <div className="p-6 overflow-y-auto flex-1 space-y-5">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-on-surface mb-1">الاسم بالكامل</label>
                  <input type="text" value={formData.full_name} onChange={e => setFormData({...formData, full_name: e.target.value})} className="w-full bg-surface-container-low border-none rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-primary outline-none transition-all" />
                </div>
                <div>
                  <label className="block text-xs font-bold text-on-surface mb-1">الكود</label>
                  <input type="text" value={formData.university_id} onChange={e => setFormData({...formData, university_id: e.target.value})} className="w-full bg-surface-container-low border-none rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-primary outline-none" dir="ltr" />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface mb-1">كلمة المرور (Plain Password)</label>
                <input type="text" value={formData.plain_password} onChange={e => setFormData({...formData, plain_password: e.target.value})} className="w-full bg-surface-container-low border-none rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-primary outline-none font-mono text-primary tracking-widest" dir="ltr" />
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface mb-2">
                  تعيين السكاشن (Assign Sections)
                  <span className="text-primary/40 mr-2 text-[9px] font-normal">
                    {safeCoursesWithSections.length} مادة متاحة
                  </span>
                </label>
                
                {safeCoursesWithSections.length === 0 ? (
                  <div className="bg-surface-container-highest/30 p-6 rounded-xl border border-outline-variant/10 text-center text-on-surface-variant text-sm">
                    لا توجد مواد مسجلة في النظام
                  </div>
                ) : (
                  <div className="bg-surface-container-highest/30 rounded-xl border border-outline-variant/10 max-h-[320px] overflow-y-auto divide-y divide-outline-variant/10">
                    {safeCoursesWithSections.map((course: any) => (
                      <div key={course.id}>
                        {/* Course header */}
                        <div className="px-4 py-2 bg-surface-container/80 sticky top-0">
                          <span className="font-bold text-xs text-primary">{course.name_ar || course.name}</span>
                          <span className="text-on-surface-variant text-[10px] mr-2">({course.code})</span>
                        </div>
                        {/* Sections grid */}
                        <div className="p-3 grid grid-cols-2 sm:grid-cols-3 gap-2 bg-surface-container-lowest">
                          {course.sections.map((sec: any) => {
                            const isSelected = selectedAssignments.some(
                              a => a.course_id === course.id && a.section_id === sec.id
                            );
                            return (
                              <label
                                key={sec.id}
                                className={`flex items-center gap-2 px-3 py-2 rounded-lg cursor-pointer border transition-all text-xs select-none
                                  ${isSelected 
                                    ? 'bg-primary/10 border-primary/30 text-primary font-bold' 
                                    : 'bg-surface-container border-outline-variant/10 text-on-surface-variant hover:border-primary/20 hover:bg-primary/5'
                                  }`}
                              >
                                <input
                                  type="checkbox"
                                  checked={isSelected}
                                  onChange={() => toggleAssignment(course.id, sec.id)}
                                  className="sr-only"
                                />
                                <span className={`w-3.5 h-3.5 rounded-sm border-2 flex items-center justify-center flex-shrink-0 transition-colors
                                  ${isSelected ? 'bg-primary border-primary' : 'border-outline-variant/40'}`}
                                >
                                  {isSelected && (
                                    <svg className="w-2 h-2 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={3}>
                                      <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                                    </svg>
                                  )}
                                </span>
                                {sec.name}
                              </label>
                            );
                          })}
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
            
            <div className="px-6 py-4 border-t border-outline-variant/10 bg-surface-container-low mt-auto flex gap-3">
              <button onClick={handleSave} disabled={isSaving} className="flex-1 bg-primary text-on-primary py-3 rounded-xl font-bold hover:bg-primary/90 transition-colors shadow-sm disabled:opacity-50">
                {isSaving ? 'يتم الحفظ...' : 'حفظ التعديلات'}
              </button>
              <button onClick={() => setEditingTA(null)} className="px-6 bg-surface-container-highest text-on-surface py-3 rounded-xl font-bold hover:bg-surface-container-highest/80 transition-colors">
                إلغاء
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
