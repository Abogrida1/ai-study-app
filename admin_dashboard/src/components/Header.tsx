import React from 'react';

const Header = () => {
  return (
    <header className="flex items-center justify-between px-8 py-6 w-full max-w-full bg-surface-container-low top-0 sticky z-30 transition-colors border-b border-outline-variant/5">
      <h2 className="font-headline tracking-tight text-primary font-extrabold text-2xl">Upload Center</h2>
      <div className="flex items-center gap-4">
        <button className="p-2 rounded-full hover:bg-surface-container-high transition-colors active:scale-95">
          <span className="material-symbols-outlined text-outline">search</span>
        </button>
        <button className="p-2 rounded-full hover:bg-surface-container-high transition-colors active:scale-95">
          <span className="material-symbols-outlined text-outline">notifications</span>
        </button>
        <div className="w-px h-6 bg-outline-variant/30"></div>
        <button className="p-2 rounded-full hover:bg-surface-container-high transition-colors active:scale-95">
          <span className="material-symbols-outlined text-primary">settings</span>
        </button>
      </div>
    </header>
  );
};

export default Header;
