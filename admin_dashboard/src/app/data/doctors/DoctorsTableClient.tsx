'use client';

import React, { useState } from 'react';
import { deleteUser, updateDoctor } from '@/app/actions/users';

export default function DoctorsTableClient({ doctors, courses }: any) {
  const [editingDoctor, setEditingDoctor] = useState<any>(null);
  const [isDeleting, setIsDeleting] = useState<string | null>(null);
  
  const [formData, setFormData] = useState({
    university_id: '',
    full_name: '',
    plain_password: '',
  });
  const [selectedCourses, setSelectedCourses] = useState<string[]>([]);
  const [isSaving, setIsSaving] = useState(false);

  const openEditModal = (doctor: any) => {
    setEditingDoctor(doctor);
    setFormData({
      university_id: doctor.university_id || '',
      full_name: doctor.full_name || '',
      plain_password: doctor.plain_password || '',
    });
    const currentCourseIds = doctor.assignments?.map((a: any) => a.courses?.id).filter(Boolean) || [];
    setSelectedCourses(currentCourseIds);
  };

  const handleSave = async () => {
    setIsSaving(true);
    const res = await updateDoctor(editingDoctor.id, formData, selectedCourses);
    setIsSaving(false);
    if (res.success) {
      setEditingDoctor(null);
    } else {
      alert("حدث خطأ أثناء الحفظ: " + res.error);
    }
  };

  const handleDelete = async (id: string) => {
    if (confirm("هل أنت متأكد من حذف هذا الدكتور نهائياً؟")) {
      setIsDeleting(id);
      const res = await deleteUser(id);
      setIsDeleting(null);
      if (!res.success) alert("حدث خطأ أثناء الحذف: " + res.error);
    }
  };

  const toggleCourse = (courseId: string) => {
    setSelectedCourses(prev => 
      prev.includes(courseId) ? prev.filter(id => id !== courseId) : [...prev, courseId]
    );
  };

  return (
    <>
      <div className="bg-surface-container-low border border-outline-variant/10 rounded-2xl overflow-hidden mt-6">
        <div className="overflow-x-auto">
          <table className="w-full text-right" dir="rtl">
            <thead>
              <tr className="border-b border-outline-variant/10 bg-surface-container-highest">
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-right w-16">الكود</th>
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-right">الباسوورد</th>
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-right">الاسم</th>
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-right">المواد المُدرّسة</th>
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-center w-24">إجراءات</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-outline-variant/5">
              {doctors?.map((d: any) => (
                <tr key={d.id} className="hover:bg-primary/[0.02] transition-colors">
                  <td className="py-4 px-6 font-bold text-sm text-primary" dir="ltr">{d.university_id}</td>
                  <td className="py-4 px-6 text-sm font-mono text-on-surface-variant">{d.plain_password || 'مخفي'}</td>
                  <td className="py-4 px-6 text-sm font-bold">{d.full_name}</td>
                  <td className="py-4 px-6 text-sm">
                    <div className="flex flex-wrap gap-2">
                      {d.assignments && d.assignments.length > 0 ? (
                        d.assignments.map((a: any, i: number) => (
                          a.courses && (
                            <span key={i} className="px-2 py-1 bg-surface-container-highest rounded text-xs">
                              {a.courses.name_ar || a.courses.name} ({a.courses.code})
                            </span>
                          )
                        ))
                      ) : (
                        <span className="text-on-surface-variant text-xs">بدون تكليفات</span>
                      )}
                    </div>
                  </td>
                  <td className="py-4 px-6 text-sm">
                    <div className="flex items-center justify-center gap-2">
                      <button onClick={() => openEditModal(d)} className="w-8 h-8 rounded-full bg-primary/10 text-primary flex items-center justify-center hover:bg-primary/20 transition-colors">
                        <span className="material-symbols-outlined text-[18px]">edit</span>
                      </button>
                      <button onClick={() => handleDelete(d.id)} disabled={isDeleting === d.id} className="w-8 h-8 rounded-full bg-error/10 text-error flex items-center justify-center hover:bg-error/20 transition-colors disabled:opacity-50">
                        <span className="material-symbols-outlined text-[18px]">delete</span>
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
              {!doctors || doctors.length === 0 && (
                 <tr>
                   <td colSpan={5} className="py-8 text-center text-on-surface-variant">لا يوجد دكاترة مسجلين</td>
                 </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {editingDoctor && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4" dir="rtl">
          <div className="bg-surface-container-lowest border border-outline-variant/20 rounded-3xl w-full max-w-2xl max-h-[90vh] flex flex-col shadow-2xl overflow-hidden animate-in fade-in zoom-in-95 duration-200">
            <div className="px-6 py-4 border-b border-outline-variant/10 flex justify-between items-center bg-surface-container-low/50">
              <h2 className="text-xl font-bold font-headline text-primary">تعديل بيانات الدكتور</h2>
              <button onClick={() => setEditingDoctor(null)} className="text-on-surface-variant hover:bg-surface-container rounded-full p-2 mt-[-5px]">
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
                <label className="block text-xs font-bold text-on-surface mb-1" dir="rtl">كلمة المرور الباسوورد (Plain Password)</label>
                <input type="text" value={formData.plain_password} onChange={e => setFormData({...formData, plain_password: e.target.value})} className="w-full bg-surface-container-low border-none rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-primary outline-none font-mono text-primary tracking-widest" dir="ltr" />
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface mb-1">المواد المُدرّسة</label>
                <div className="bg-surface-container-highest/30 p-3 rounded-xl border border-outline-variant/10 grid grid-cols-2 md:grid-cols-3 gap-2 overflow-y-auto max-h-[150px]">
                  {courses?.map((c: any) => (
                    <label key={c.id} className="flex items-center gap-2 text-sm p-1 cursor-pointer hover:bg-surface-container rounded transition-colors group">
                      <input type="checkbox" checked={selectedCourses.includes(c.id)} onChange={() => toggleCourse(c.id)} className="w-4 h-4 rounded text-primary focus:ring-primary border-outline-variant/30 bg-surface-container cursor-pointer" />
                      <span className="group-hover:text-primary font-medium transition-colors truncate">{c.name_ar || c.name}</span>
                    </label>
                  ))}
                </div>
              </div>
            </div>
            
            <div className="px-6 py-4 border-t border-outline-variant/10 bg-surface-container-low mt-auto flex gap-3">
              <button onClick={handleSave} disabled={isSaving} className="flex-1 bg-primary text-on-primary py-3 rounded-xl font-bold hover:bg-primary/90 transition-colors shadow-sm disabled:opacity-50">
                {isSaving ? 'يتم الحفظ...' : 'حفظ التعديلات'}
              </button>
              <button onClick={() => setEditingDoctor(null)} className="px-6 bg-surface-container-highest text-on-surface py-3 rounded-xl font-bold hover:bg-surface-container-highest/80 transition-colors">
                إلغاء
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
