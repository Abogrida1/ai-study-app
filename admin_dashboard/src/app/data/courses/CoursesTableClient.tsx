'use client';

import React, { useState, useRef } from 'react';
import { deleteCourse, updateCourse } from '@/app/actions/courses';
import { supabase } from '@/lib/supabase';
import { convertToWebP } from '@/lib/image-utils';

export default function CoursesTableClient({ courses, levels }: any) {
  const [editingCourse, setEditingCourse] = useState<any>(null);
  const [isDeleting, setIsDeleting] = useState<string | null>(null);
  
  const [formData, setFormData] = useState({
    code: '',
    name: '',
    name_ar: '',
    credit_hours: 3,
    level_id: '',
    semester: 1,
    has_sections: false,
    thumbnail_url: '',
  });
  const [isUploading, setIsUploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [isSaving, setIsSaving] = useState(false);

  const openEditModal = (course: any) => {
    setEditingCourse(course);
    setFormData({
      code: course.code || '',
      name: course.name || '',
      name_ar: course.name_ar || '',
      credit_hours: course.credit_hours || 3,
      level_id: course.level_id || '',
      semester: course.semester || 1,
      has_sections: !!course.has_sections,
      thumbnail_url: course.thumbnail_url || '',
    });
  };

  const handleSave = async () => {
    setIsSaving(true);
    const res = await updateCourse(editingCourse.id, formData);
    setIsSaving(false);
    if (res.success) {
      setEditingCourse(null);
    } else {
      alert("حدث خطأ أثناء الحفظ: " + res.error);
    }
  };

  const handleDelete = async (id: string) => {
    if (confirm("هل أنت متأكد من حذف هذه المادة نهائياً؟")) {
      setIsDeleting(id);
      const res = await deleteCourse(id);
      setIsDeleting(null);
      if (!res.success) alert("حدث خطأ أثناء الحذف: " + res.error);
    }
  };

  return (
    <>
      <div className="bg-surface-container-low border border-outline-variant/10 rounded-2xl overflow-hidden mt-6">
        <div className="overflow-x-auto">
          <table className="w-full text-right" dir="rtl">
            <thead>
              <tr className="border-b border-outline-variant/10 bg-surface-container-highest">
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-right w-16">كود المادة</th>
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-right">اسم المادة</th>
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-right">المستوى الدراسي</th>
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-right">الترم</th>
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-right">الساعات</th>
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-right">سكاشن عملي؟</th>
                <th className="py-4 px-6 font-bold text-xs text-on-surface-variant uppercase tracking-wider text-center w-24">إجراءات</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-outline-variant/5">
              {courses?.map((c: any) => (
                <tr key={c.id} className="hover:bg-primary/[0.02] transition-colors">
                  <td className="py-4 px-6 font-bold text-sm text-primary" dir="ltr">{c.code}</td>
                  <td className="py-4 px-6 text-sm flex flex-col">
                    <span className="font-bold">{c.name_ar || c.name}</span>
                    <span className="text-xs text-on-surface-variant" dir="ltr">{c.name}</span>
                  </td>
                  <td className="py-4 px-6 text-sm">{c.levels?.name || 'بدون مستوى'}</td>
                  <td className="py-4 px-6 text-sm">{c.semester == 1 ? 'الترم الأول' : 'الترم الثاني'}</td>
                  <td className="py-4 px-6 text-sm">{c.credit_hours} ساعات</td>
                  <td className="py-4 px-6 text-sm">
                    <span className={`px-2 py-1 rounded text-[10px] font-bold ${c.has_sections ? 'bg-emerald-500/10 text-emerald-600' : 'bg-amber-500/10 text-amber-600'}`}>
                      {c.has_sections ? 'يوجد' : 'لا يوجد'}
                    </span>
                  </td>
                  <td className="py-4 px-6 text-sm">
                    <div className="flex items-center justify-center gap-2">
                      <button onClick={() => openEditModal(c)} className="w-8 h-8 rounded-full bg-primary/10 text-primary flex items-center justify-center hover:bg-primary/20 transition-colors">
                        <span className="material-symbols-outlined text-[18px]">edit</span>
                      </button>
                      <button onClick={() => handleDelete(c.id)} disabled={isDeleting === c.id} className="w-8 h-8 rounded-full bg-error/10 text-error flex items-center justify-center hover:bg-error/20 transition-colors disabled:opacity-50">
                        <span className="material-symbols-outlined text-[18px]">delete</span>
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
              {!courses || courses.length === 0 && (
                 <tr>
                   <td colSpan={7} className="py-8 text-center text-on-surface-variant">لا توجد مواد مسجلة</td>
                 </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {editingCourse && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4" dir="rtl">
          <div className="bg-surface-container-lowest border border-outline-variant/20 rounded-3xl w-full max-w-2xl max-h-[90vh] flex flex-col shadow-2xl overflow-hidden animate-in fade-in zoom-in-95 duration-200">
            <div className="px-6 py-4 border-b border-outline-variant/10 flex justify-between items-center bg-surface-container-low/50">
              <h2 className="text-xl font-bold font-headline text-primary">تعديل بيانات المادة</h2>
              <button onClick={() => setEditingCourse(null)} className="text-on-surface-variant hover:bg-surface-container rounded-full p-2 mt-[-5px]">
                <span className="material-symbols-outlined text-[20px]">close</span>
              </button>
            </div>
            
            <div className="p-6 overflow-y-auto flex-1 space-y-5">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-on-surface mb-1">اسم المادة (عربي)</label>
                  <input type="text" value={formData.name_ar} onChange={e => setFormData({...formData, name_ar: e.target.value})} className="w-full bg-surface-container-low border-none rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-primary outline-none transition-all" />
                </div>
                <div>
                  <label className="block text-xs font-bold text-on-surface mb-1">اسم المادة (إنجليزي)</label>
                  <input type="text" value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} className="w-full bg-surface-container-low border-none rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-primary outline-none transition-all" dir="ltr" />
                </div>
              </div>

              <div className="grid grid-cols-3 gap-4">
                <div>
                  <label className="block text-xs font-bold text-on-surface mb-1">الكود</label>
                  <input type="text" value={formData.code} onChange={e => setFormData({...formData, code: e.target.value})} className="w-full bg-surface-container-low border-none rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-primary outline-none" dir="ltr" />
                </div>
                <div>
                  <label className="block text-xs font-bold text-on-surface mb-1">عدد الساعات</label>
                  <input type="number" min="1" max="10" value={formData.credit_hours} onChange={e => setFormData({...formData, credit_hours: parseInt(e.target.value)})} className="w-full bg-surface-container-low border-none rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-primary outline-none" dir="ltr" />
                </div>
                <div>
                  <label className="block text-xs font-bold text-on-surface mb-1">الترم</label>
                  <select value={formData.semester} onChange={e => setFormData({...formData, semester: parseInt(e.target.value)})} className="w-full bg-surface-container-low border-none rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-primary outline-none appearance-none">
                    <option value={1}>الأول</option>
                    <option value={2}>الثاني</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-on-surface mb-1">المستوى الدراسي</label>
                  <select value={formData.level_id} onChange={e => setFormData({...formData, level_id: e.target.value})} className="w-full bg-surface-container-low border-none rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-primary outline-none appearance-none">
                    <option value="">بدون مستوى</option>
                    {levels?.map((l: any) => <option key={l.id} value={l.id}>{l.name}</option>)}
                  </select>
                </div>
                <div className="flex items-center">
                  <label className="flex items-center gap-3 mt-4 p-3 w-full bg-surface-container-low rounded-xl cursor-pointer hover:bg-surface-container transition-colors">
                    <input type="checkbox" checked={formData.has_sections} onChange={e => setFormData({...formData, has_sections: e.target.checked})} className="w-5 h-5 rounded text-primary focus:ring-primary border-outline-variant/30" />
                    <span className="text-sm font-bold text-on-surface">يوجد سكاشن عملي؟</span>
                  </label>
                </div>
              </div>

              {/* Thumbnail Section */}
              <div className="bg-surface-container-low p-4 rounded-2xl border border-outline-variant/10">
                <div className="flex items-center justify-between mb-4">
                  <label className="text-xs font-bold text-on-surface">صورة غلاف المادة (Thumbnail)</label>
                  {isUploading && <span className="text-[10px] text-primary animate-pulse font-bold">جاري التحميل...</span>}
                </div>
                
                <div className="flex gap-4 items-center">
                  <div className="w-24 h-24 rounded-2xl bg-surface-container-highest overflow-hidden border border-outline-variant/20 flex-shrink-0">
                    {formData.thumbnail_url ? (
                      <img src={formData.thumbnail_url} alt="Course" className="w-full h-full object-cover" />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center text-on-surface-variant/30">
                        <span className="material-symbols-outlined text-3xl">image</span>
                      </div>
                    )}
                  </div>
                  
                  <div className="flex-1 space-y-2">
                    <p className="text-[10px] text-on-surface-variant leading-relaxed">
                      يفضل اختيار صورة واضحة تعبر عن المادة. سيتم تحويلها لـ WebP تلقائياً لسرعة التصفح.
                    </p>
                    <div className="flex gap-2">
                      <button 
                        onClick={() => fileInputRef.current?.click()}
                        disabled={isUploading}
                        className="px-4 py-2 bg-primary/10 text-primary text-xs font-bold rounded-lg hover:bg-primary/20 transition-colors flex items-center gap-1"
                      >
                        <span className="material-symbols-outlined text-sm">upload</span>
                        {formData.thumbnail_url ? 'تغيير الصورة' : 'رفع صورة'}
                      </button>
                      {formData.thumbnail_url && (
                        <button 
                          onClick={() => setFormData({...formData, thumbnail_url: ''})}
                          className="px-4 py-2 bg-error/10 text-error text-xs font-bold rounded-lg hover:bg-error/20 transition-colors"
                        >
                          إزالة
                        </button>
                      )}
                    </div>
                  </div>
                </div>
                
                <input 
                  type="file" 
                  ref={fileInputRef} 
                  className="hidden" 
                  accept="image/*"
                  onChange={async (e) => {
                    const file = e.target.files?.[0];
                    if (!file) return;
                    
                    setIsUploading(true);
                    try {
                      // 1. Convert to WebP
                      const webpBlob = await convertToWebP(file);
                      
                      // 2. Upload to Supabase Storage
                      const fileName = `${Date.now()}_${file.name.split('.')[0]}.webp`;
                      const { data, error } = await supabase.storage
                        .from('courses') // Bucket name
                        .upload(`thumbnails/${fileName}`, webpBlob, {
                          contentType: 'image/webp'
                        });
                        
                      if (error) throw error;
                      
                      // 3. Get Public URL
                      const { data: { publicUrl } } = supabase.storage
                        .from('courses')
                        .getPublicUrl(data.path);
                        
                      setFormData({ ...formData, thumbnail_url: publicUrl });
                    } catch (err: any) {
                      alert("خطأ في رفع الصورة: " + err.message);
                    } finally {
                      setIsUploading(false);
                    }
                  }}
                />
              </div>
            </div>
            
            <div className="px-6 py-4 border-t border-outline-variant/10 bg-surface-container-low mt-auto flex gap-3">
              <button onClick={handleSave} disabled={isSaving} className="flex-1 bg-primary text-on-primary py-3 rounded-xl font-bold hover:bg-primary/90 transition-colors shadow-sm disabled:opacity-50">
                {isSaving ? 'يتم الحفظ...' : 'حفظ التعديلات'}
              </button>
              <button onClick={() => setEditingCourse(null)} className="px-6 bg-surface-container-highest text-on-surface py-3 rounded-xl font-bold hover:bg-surface-container-highest/80 transition-colors">
                إلغاء
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
