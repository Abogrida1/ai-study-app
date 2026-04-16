'use client';

import React, { useState } from 'react';

interface FileUploaderProps {
  onUpload: (file: File) => void;
  accept?: string;
}

const FileUploader: React.FC<FileUploaderProps> = ({ onUpload, accept = ".xlsx, .csv" }) => {
  const [isDragging, setIsDragging] = useState(false);

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = () => {
    setIsDragging(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      onUpload(e.dataTransfer.files[0]);
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      onUpload(e.target.files[0]);
    }
  };

  return (
    <div 
      onDragOver={handleDragOver}
      onDragLeave={handleDragLeave}
      onDrop={handleDrop}
      className={`border-2 border-dashed rounded-xl p-12 flex flex-col items-center justify-center transition-all cursor-pointer ${
        isDragging 
          ? 'border-primary bg-primary-container/5' 
          : 'border-outline-variant/40 bg-surface-container-low/50'
      } hover:bg-surface-container-low`}
      onClick={() => document.getElementById('fileInput')?.click()}
    >
      <input 
        id="fileInput"
        type="file"
        className="hidden"
        accept={accept}
        onChange={handleFileChange}
      />
      <div className="w-16 h-16 rounded-full bg-primary-container/5 flex items-center justify-center mb-4">
        <span className="material-symbols-outlined text-primary text-3xl">upload_file</span>
      </div>
      <p className="text-primary font-bold mb-1">Click or drag file here</p>
      <p className="text-on-surface-variant text-xs">Maximum size 25MB • Excel or CSV only</p>
    </div>
  );
};

export default FileUploader;
