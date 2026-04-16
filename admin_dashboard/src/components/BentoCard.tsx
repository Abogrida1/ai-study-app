import React from 'react';

interface BentoCardProps {
  title: string;
  description: string;
  icon: string;
  className?: string;
  children?: React.ReactNode;
  footer?: React.ReactNode;
  variant?: 'default' | 'primary' | 'error';
}

const BentoCard: React.FC<BentoCardProps> = ({ 
  title, 
  description, 
  icon, 
  className = "", 
  children, 
  footer,
  variant = 'default'
}) => {
  const baseStyles = "rounded-xl p-6 shadow-sm border border-outline-variant/10 transition-all hover:shadow-md";
  const variants = {
    default: "bg-surface-container-lowest",
    primary: "bg-primary text-white",
    error: "bg-surface-container-lowest" // Error styling is handled inside for lectures
  };

  return (
    <div className={`${baseStyles} ${variants[variant]} ${className}`}>
      <div className="flex justify-between items-start mb-4">
        <div>
          <h4 className={`font-headline text-lg font-bold mb-1 ${variant === 'primary' ? 'text-white' : 'text-primary'}`}>
            {title}
          </h4>
          <p className={`text-xs ${variant === 'primary' ? 'text-white/70' : 'text-on-surface-variant'}`}>
            {description}
          </p>
        </div>
        <span className={`material-symbols-outlined text-2xl ${
          variant === 'primary' ? 'text-white/30' : 
          variant === 'error' ? 'text-error' : 'text-primary/20'
        }`}>
          {icon}
        </span>
      </div>
      
      <div className="flex-1">
        {children}
      </div>

      {footer && (
        <div className="mt-4">
          {footer}
        </div>
      )}
    </div>
  );
};

export default BentoCard;
