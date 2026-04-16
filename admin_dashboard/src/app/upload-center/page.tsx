'use client';

import React, { useState, useCallback } from 'react';
import Sidebar from '@/components/Sidebar';
import Header from '@/components/Header';

// Upload step configuration
const UPLOAD_STEPS = [
  {
    key: 'courses',
    title: 'المواد الدراسية',
    titleEn: 'Courses',
    icon: 'menu_book',
    description: 'رفع ملف المواد بأكوادها ومعلوماتها',
    descEn: 'Upload courses with codes, names, and level info',
    columns: ['code', 'name', 'name_ar', 'credit_hours', 'level', 'semester', 'has_sections'],
    required: true,
    order: 1,
  },
  {
    key: 'students',
    title: 'الطلاب',
    titleEn: 'Students',
    icon: 'school',
    description: 'رفع بيانات الطلاب وأكوادهم ومواد كل طالب',
    descEn: 'Upload students with IDs, passwords, and course enrollments',
    columns: ['university_id', 'password', 'full_name', 'level', 'section', 'courses'],
    required: true,
    order: 2,
  },
  {
    key: 'doctors',
    title: 'الدكاترة',
    titleEn: 'Doctors',
    icon: 'medication',
    description: 'رفع بيانات الدكاترة والمواد اللي بيدرسوها',
    descEn: 'Upload doctors with credentials and course assignments',
    columns: ['university_id', 'password', 'full_name', 'course_codes'],
    required: true,
    order: 3,
  },
  {
    key: 'tas',
    title: 'المعيدين',
    titleEn: 'Teaching Assistants',
    icon: 'support_agent',
    description: 'رفع بيانات المعيدين والسكاشن المسؤولين عنها',
    descEn: 'Upload TAs with credentials and section assignments',
    columns: ['university_id', 'password', 'full_name', 'course_code', 'sections'],
    required: true,
    order: 4,
  }
] as const;

type UploadResult = {
  total: number;
  success: number;
  errors: string[];
};

type StepStatus = 'pending' | 'uploading' | 'success' | 'error';

const UploadCenter = () => {
  const [activeStep, setActiveStep] = useState(0);
  const [stepStatuses, setStepStatuses] = useState<Record<string, StepStatus>>({});
  const [stepResults, setStepResults] = useState<Record<string, UploadResult>>({});
  const [isDragging, setIsDragging] = useState(false);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);

  const currentStep = UPLOAD_STEPS[activeStep];

  const handleFile = useCallback((file: File) => {
    setSelectedFile(file);
  }, []);

  const handleDragOver = (e: React.DragEvent) => { e.preventDefault(); setIsDragging(true); };
  const handleDragLeave = () => setIsDragging(false);
  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    if (e.dataTransfer.files?.[0]) handleFile(e.dataTransfer.files[0]);
  };

  const handleUpload = async () => {
    if (!selectedFile) return;

    setStepStatuses(prev => ({ ...prev, [currentStep.key]: 'uploading' }));

    try {
      const formData = new FormData();
      formData.append('file', selectedFile);
      formData.append('type', currentStep.key);

      const res = await fetch('/api/upload', { method: 'POST', body: formData });
      const result: UploadResult = await res.json();

      if (!res.ok) {
        throw new Error((result as unknown as { error: string }).error || 'Upload failed');
      }

      setStepResults(prev => ({ ...prev, [currentStep.key]: result }));
      const hasSuccessOrSkipped = result.total > 0;
      setStepStatuses(prev => ({ ...prev, [currentStep.key]: hasSuccessOrSkipped ? 'success' : 'error' }));
      setSelectedFile(null);
    } catch (err) {
      setStepStatuses(prev => ({ ...prev, [currentStep.key]: 'error' }));
      setStepResults(prev => ({
        ...prev,
        [currentStep.key]: { total: 0, success: 0, errors: [err instanceof Error ? err.message : 'Unknown error'] }
      }));
    }
  };

  const getStepIcon = (status: StepStatus | undefined) => {
    switch (status) {
      case 'uploading': return 'sync';
      case 'success': return 'check_circle';
      case 'error': return 'error';
      default: return 'radio_button_unchecked';
    }
  };

  const getStepColor = (status: StepStatus | undefined) => {
    switch (status) {
      case 'uploading': return 'text-amber-400';
      case 'success': return 'text-emerald-400';
      case 'error': return 'text-red-400';
      default: return 'text-on-surface-variant/40';
    }
  };

  return (
    <div className="flex min-h-screen bg-background text-on-surface">
      <Sidebar />
      
      <main className="lg:ml-72 flex-1 pb-24 lg:pb-12">
        <Header />
        
        <section className="px-6 md:px-8 mt-4">
          {/* Title */}
          <div className="mb-8">
            <p className="text-on-surface-variant font-medium mb-1 text-sm">مركز إدارة البيانات</p>
            <h3 className="font-headline text-3xl font-bold text-primary mb-3 tracking-tight">
              رفع البيانات الأكاديمية
            </h3>
            <p className="text-on-surface-variant text-sm max-w-xl">
              رفع بيانات الجامعة — ملفات Excel للمواد، الطلاب، الدكاترة، والمعيدين
            </p>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
            
            {/* Steps Timeline — Left Side */}
            <div className="lg:col-span-4">
              <div className="bg-surface-container-low rounded-2xl border border-outline-variant/10 p-6 sticky top-6">
                <h4 className="font-headline font-bold text-lg mb-6 flex items-center gap-2">
                  <span className="material-symbols-outlined text-primary">format_list_numbered</span>
                  خطوات الرفع
                </h4>

                <div className="space-y-2">
                  {UPLOAD_STEPS.map((step, idx) => {
                    const status = stepStatuses[step.key];
                    const isActive = idx === activeStep;
                    const isCompleted = status === 'success';
                    const canAccess = true; // شيلنا القيد عشان تختار براحتك

                    return (
                      <button
                        key={step.key}
                        onClick={() => canAccess ? setActiveStep(idx) : null}
                        disabled={!canAccess}
                        className={`w-full flex items-center gap-4 p-4 rounded-xl transition-all duration-200 text-left ${
                          isActive
                            ? 'bg-primary/10 border-2 border-primary shadow-sm'
                            : isCompleted
                              ? 'bg-emerald-500/5 border border-emerald-500/20'
                              : canAccess
                                ? 'bg-surface-container-lowest border border-outline-variant/10 hover:border-primary/30 cursor-pointer'
                                : 'bg-surface-container-lowest/50 border border-outline-variant/5 opacity-50 cursor-not-allowed'
                        }`}
                      >
                        {/* Step Number / Status Icon */}
                        <div className={`w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${
                          isActive ? 'bg-primary' :
                          isCompleted ? 'bg-emerald-500' :
                          'bg-surface-container-highest'
                        }`}>
                          {status ? (
                            <span className={`material-symbols-outlined text-base ${isActive || isCompleted ? 'text-white' : getStepColor(status)} ${status === 'uploading' ? 'animate-spin' : ''}`}>
                              {getStepIcon(status)}
                            </span>
                          ) : (
                            <span className={`text-sm font-bold ${isActive ? 'text-white' : 'text-on-surface-variant'}`}>
                              {idx + 1}
                            </span>
                          )}
                        </div>

                        {/* Step Info */}
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2">
                            <span className={`material-symbols-outlined text-base ${isActive ? 'text-primary' : 'text-on-surface-variant'}`}>
                              {step.icon}
                            </span>
                            <p className={`font-bold text-sm ${isActive ? 'text-primary' : 'text-on-surface'}`}>
                              {step.titleEn}
                            </p>
                          </div>
                          <p className="text-[11px] text-on-surface-variant mt-0.5 truncate">{step.title}</p>
                          
                          {/* Result summary */}
                          {stepResults[step.key] && (
                            <p className={`text-[10px] mt-1 font-semibold ${
                              stepResults[step.key].errors.length > 0 ? 'text-amber-500' : 'text-emerald-500'
                            }`}>
                              ✓ {stepResults[step.key].success}/{stepResults[step.key].total} records
                              {stepResults[step.key].errors.length > 0 && ` • ${stepResults[step.key].errors.length} warnings`}
                            </p>
                          )}
                        </div>
                      </button>
                    );
                  })}
                </div>

                {/* Overall status */}
                {Object.values(stepStatuses).filter(s => s === 'success').length === 4 && (
                  <div className="mt-6 bg-emerald-500/10 border border-emerald-500/20 rounded-xl p-4 text-center">
                    <span className="material-symbols-outlined text-emerald-500 text-3xl mb-2">celebration</span>
                    <p className="text-emerald-600 font-bold text-sm">All data uploaded!</p>
                    <p className="text-emerald-600/70 text-[11px]">تم رفع كل البيانات بنجاح</p>
                  </div>
                )}
              </div>
            </div>

            {/* Upload Area — Right Side */}
            <div className="lg:col-span-8">
              <div className="bg-surface-container-low rounded-2xl border border-outline-variant/10 overflow-hidden">
                {/* Step Header */}
                <div className="px-8 py-6 border-b border-outline-variant/10 bg-surface-container-lowest">
                  <div className="flex items-center gap-3 mb-2">
                    <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center">
                      <span className="material-symbols-outlined text-primary">{currentStep.icon}</span>
                    </div>
                    <div>
                      <h4 className="font-headline font-bold text-lg text-on-surface">
                        Step {activeStep + 1}: {currentStep.titleEn}
                      </h4>
                      <p className="text-on-surface-variant text-xs">{currentStep.description}</p>
                    </div>
                  </div>
                </div>

                <div className="p-8">
                  {/* Expected Columns */}
                  <div className="mb-6">
                    <p className="text-[11px] text-on-surface-variant font-bold uppercase tracking-wider mb-3">
                      Expected Columns
                    </p>
                    <div className="flex flex-wrap gap-2">
                      {currentStep.columns.map(col => (
                        <span
                          key={col}
                          className="px-3 py-1.5 bg-primary/5 text-primary text-[11px] font-mono font-semibold rounded-lg border border-primary/10"
                        >
                          {col}
                        </span>
                      ))}
                    </div>
                  </div>

                  {/* Upload Zone */}
                  {stepStatuses[currentStep.key] === 'uploading' ? (
                    /* Uploading State */
                    <div className="border-2 border-primary/20 rounded-xl bg-primary/5 p-16 flex flex-col items-center justify-center">
                      <span className="material-symbols-outlined text-primary text-5xl mb-4 animate-spin">sync</span>
                      <p className="text-primary font-bold text-lg mb-1">Processing Data...</p>
                      <p className="text-on-surface-variant text-xs">جاري معالجة الملف ورفع البيانات</p>
                    </div>
                  ) : stepStatuses[currentStep.key] === 'success' || stepStatuses[currentStep.key] === 'error' ? (
                    /* Result State */
                    <div className="space-y-4">
                      <div className={`border-2 rounded-xl p-8 text-center ${
                        stepStatuses[currentStep.key] === 'success' 
                          ? 'border-emerald-500/20 bg-emerald-500/5'
                          : 'border-red-500/20 bg-red-500/5'
                      }`}>
                        <span className={`material-symbols-outlined text-5xl mb-3 ${
                          stepStatuses[currentStep.key] === 'success' ? 'text-emerald-500' : 'text-red-500'
                        }`}>
                          {stepStatuses[currentStep.key] === 'success' ? 'check_circle' : 'error'}
                        </span>
                        <p className={`font-bold text-lg mb-1 ${
                          stepStatuses[currentStep.key] === 'success' ? 'text-emerald-600' : 'text-red-600'
                        }`}>
                          {stepResults[currentStep.key]?.success || 0} / {stepResults[currentStep.key]?.total || 0} Records Processed
                        </p>
                      </div>

                      {/* Error Log */}
                      {stepResults[currentStep.key]?.errors.length > 0 && (
                        <div className="bg-surface-container-lowest rounded-xl border border-outline-variant/10 p-4 max-h-48 overflow-y-auto">
                          <p className="text-[11px] text-on-surface-variant font-bold uppercase tracking-wider mb-2">
                            تحذيرات وأخطاء ({stepResults[currentStep.key].errors.length})
                          </p>
                          {stepResults[currentStep.key].errors.map((err, i) => (
                            <p key={i} className="text-xs text-amber-600 py-1 border-b border-outline-variant/5 last:border-0">
                              • {err}
                            </p>
                          ))}
                        </div>
                      )}

                      <div className="flex gap-3">
                        {/* Re-upload */}
                        <button
                          onClick={() => {
                            setStepStatuses(prev => ({ ...prev, [currentStep.key]: 'pending' }));
                            setStepResults(prev => { const n = { ...prev }; delete n[currentStep.key]; return n; });
                            setSelectedFile(null);
                          }}
                          className="flex-1 py-3 rounded-xl bg-surface-container-highest text-on-surface font-bold text-sm hover:bg-surface-container-high transition-colors flex items-center justify-center gap-2"
                        >
                          <span className="material-symbols-outlined text-base">refresh</span>
                          إعادة الرفع
                        </button>
                        
                        {/* Next Step */}
                        {activeStep < 3 && stepResults[currentStep.key] && (
                          <button
                            onClick={() => setActiveStep(prev => prev + 1)}
                            className="flex-1 py-3 rounded-xl bg-primary text-white font-bold text-sm hover:opacity-90 transition-opacity flex items-center justify-center gap-2"
                          >
                            الخطوة التالية
                            <span className="material-symbols-outlined text-base">arrow_forward</span>
                          </button>
                        )}
                      </div>
                    </div>
                  ) : (
                    /* Default Upload State */
                    <div className="space-y-4">
                      <div
                        onDragOver={handleDragOver}
                        onDragLeave={handleDragLeave}
                        onDrop={handleDrop}
                        onClick={() => document.getElementById('fileInput')?.click()}
                        className={`border-2 border-dashed rounded-xl p-16 flex flex-col items-center justify-center transition-all cursor-pointer ${
                          isDragging
                            ? 'border-primary bg-primary/5 scale-[1.01]'
                            : selectedFile
                              ? 'border-emerald-500/40 bg-emerald-500/5'
                              : 'border-outline-variant/30 bg-surface-container-lowest hover:border-primary/30 hover:bg-primary/[0.02]'
                        }`}
                      >
                        <input
                          id="fileInput"
                          type="file"
                          className="hidden"
                          accept=".xlsx,.xls,.csv"
                          onChange={(e) => e.target.files?.[0] && handleFile(e.target.files[0])}
                        />
                        
                        {selectedFile ? (
                          <>
                            <div className="w-16 h-16 rounded-2xl bg-emerald-500/10 flex items-center justify-center mb-4">
                              <span className="material-symbols-outlined text-emerald-500 text-3xl">description</span>
                            </div>
                            <p className="text-emerald-600 font-bold mb-1">{selectedFile.name}</p>
                            <p className="text-on-surface-variant text-xs">
                              {(selectedFile.size / 1024).toFixed(1)} KB — Click to change file
                            </p>
                          </>
                        ) : (
                          <>
                            <div className="w-16 h-16 rounded-2xl bg-primary/5 flex items-center justify-center mb-4">
                              <span className="material-symbols-outlined text-primary text-3xl">upload_file</span>
                            </div>
                            <p className="text-primary font-bold mb-1">اضغط هنا أو اسحب الملف</p>
                            <p className="text-on-surface-variant text-xs">ملف إكسيل (.xlsx, .xls) • أقصى حجم 25MB</p>
                          </>
                        )}
                      </div>

                      {/* Upload Button */}
                      <button
                        onClick={handleUpload}
                        disabled={!selectedFile}
                        className={`w-full py-4 rounded-xl font-bold text-sm flex items-center justify-center gap-2 transition-all ${
                          selectedFile
                            ? 'bg-primary text-white shadow-lg shadow-primary/20 hover:opacity-90 active:scale-[0.99]'
                            : 'bg-surface-container-highest text-on-surface-variant/50 cursor-not-allowed'
                        }`}
                      >
                        <span className="material-symbols-outlined text-lg">cloud_upload</span>
                        رفع ومعالجة ({currentStep.title})
                      </button>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>

      {/* Mobile NavBar */}
      <nav className="lg:hidden fixed bottom-6 left-1/2 -translate-x-1/2 w-[90%] z-50 flex justify-around items-center px-4 py-3 bg-white/80 backdrop-blur-xl shadow-2xl rounded-2xl border border-white/20">
        <a className="flex flex-col items-center justify-center text-on-surface-variant p-2 text-[10px] font-bold" href="#">
          <span className="material-symbols-outlined text-xl">chat_bubble</span>
        </a>
        <a className="flex flex-col items-center justify-center text-on-surface-variant p-2 text-[10px] font-bold" href="#">
          <span className="material-symbols-outlined text-xl">contacts</span>
        </a>
        <a className="flex flex-col items-center justify-center bg-primary text-white rounded-xl px-4 py-2 text-[10px] font-bold shadow-lg shadow-primary/30" href="#">
          <span className="material-symbols-outlined text-xl fill-1">dashboard_customize</span>
        </a>
        <a className="flex flex-col items-center justify-center text-on-surface-variant p-2 text-[10px] font-bold" href="#">
          <span className="material-symbols-outlined text-xl">analytics</span>
        </a>
      </nav>
    </div>
  );
};

export default UploadCenter;
