"use client";

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

const Sidebar = () => {
  const pathname = usePathname();

  const navItems: { icon: string; label: string; href: string; active?: boolean }[] = [
    { icon: 'inbox', label: 'Inbox', href: '#' },
    { icon: 'group', label: 'Team Chat', href: '#' },
    { icon: 'manage_accounts', label: 'User Management', href: '#' },
    { icon: 'analytics', label: 'System Logs', href: '#' },
    { icon: 'cloud_upload', label: 'Upload Center', href: '/upload-center', active: pathname === '/' },
    { icon: 'menu_book', label: 'Courses (المواد)', href: '/data/courses' },
    { icon: 'school', label: 'Students (الطلاب)', href: '/data/students' },
    { icon: 'local_hospital', label: 'Doctors (الدكاترة)', href: '/data/doctors' },
    { icon: 'assignment_ind', label: 'TAs (المعيدين)', href: '/data/tas' },
  ];

  return (
    <aside className="hidden lg:flex flex-col h-full fixed left-0 top-0 z-40 bg-surface-container-low w-72 border-r border-outline-variant/10">
      <div className="px-6 py-8">
        <div className="flex items-center gap-3 mb-10">
          <div className="w-10 h-10 rounded-full bg-primary-container flex items-center justify-center">
            <span className="material-symbols-outlined text-white">account_balance</span>
          </div>
          <h1 className="text-primary font-bold font-headline text-xl">Academic Luminary</h1>
        </div>
        
        <div className="flex items-center gap-3 mb-8 p-3 rounded-xl bg-surface-container-highest">
          <img 
            alt="Dr. Atheneum" 
            className="w-10 h-10 rounded-full object-cover" 
            src="https://lh3.googleusercontent.com/aida-public/AB6AXuDsXBsz2XstfMSJW8o7-_eX0ZQVknWcHhHgfK_NLPyWbDq0PBm9XBhBLw8ab9NDfaZnL6aVlNI4x3jltwf8SUMUzvX8RNqtBWlGV85dSSuqzx8sQTlM1F7CJmlFt6-y0a12M0PLXtC8D2Ldx7zoztRauGLo6anXBdDJBort72nRcQPRYYxSkOWQsKa1g7BweLHEbITQFyUVFTpvmQrmOMw7_bpFLQU0oZeuxgUQ_WixsD1q2y_1AJNjBpq8UiDZUrVE7j7irET67Q5z"
          />
          <div>
            <p className="font-headline font-bold text-primary text-sm">Dr. Atheneum</p>
            <p className="text-[10px] text-on-surface-variant uppercase tracking-wider font-bold">Lead Administrator</p>
          </div>
        </div>

        <nav className="space-y-1">
          {navItems.map((item) => {
            const isActive = pathname === item.href || item.active;
            return (
              <Link
                key={item.label}
                href={item.href}
                className={`flex items-center gap-3 px-4 py-3 transition-all duration-200 ease-in-out font-medium text-sm ${
                  isActive 
                    ? 'bg-white text-primary rounded-r-full font-bold shadow-sm' 
                    : 'text-on-surface-variant hover:bg-surface-container-highest'
                }`}
              >
                <span className={`material-symbols-outlined ${isActive ? 'fill-1' : ''}`}>
                  {item.icon}
                </span> 
                {item.label}
              </Link>
            );
          })}
        </nav>
      </div>
    </aside>
  );
};

export default Sidebar;
