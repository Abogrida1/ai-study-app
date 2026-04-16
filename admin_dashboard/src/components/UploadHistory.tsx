import React from 'react';

const UploadHistory = () => {
  const history = [
    {
      filename: "spring_enrollment_final.xlsx",
      category: "Students",
      timestamp: "Today, 10:45 AM",
      status: "SUCCESS",
      statusColor: "bg-green-100 text-green-800"
    },
    {
      filename: "faculty_directory_v2.csv",
      category: "Users",
      timestamp: "Yesterday, 4:20 PM",
      status: "PENDING",
      statusColor: "bg-orange-100 text-orange-800"
    },
    {
      filename: "conflict_report_temp.xlsx",
      category: "Lectures",
      timestamp: "Oct 24, 9:15 AM",
      status: "FAILED",
      statusColor: "bg-error-container text-on-error-container"
    }
  ];

  return (
    <div className="mt-12 bg-surface-container-low rounded-2xl p-8">
      <div className="flex items-center justify-around md:justify-between mb-8">
        <h3 className="font-headline text-xl font-bold text-primary">Upload History & Logs</h3>
        <button className="text-sm font-semibold text-primary px-4 py-2 hover:bg-white rounded-lg transition-colors">
          View All Logs
        </button>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full text-left">
          <thead>
            <tr className="text-[11px] uppercase tracking-widest text-on-surface-variant font-bold border-b border-outline-variant/30">
              <th className="pb-4 px-2">Filename</th>
              <th className="pb-4 px-2">Category</th>
              <th className="pb-4 px-2">Timestamp</th>
              <th className="pb-4 px-2">Status</th>
              <th className="pb-4 px-2 text-right">Action</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-outline-variant/10">
            {history.map((item, idx) => (
              <tr key={idx} className="text-sm hover:bg-surface-container-high/30 transition-colors">
                <td className="py-4 px-2 font-medium">{item.filename}</td>
                <td className="py-4 px-2">{item.category}</td>
                <td className="py-4 px-2 text-on-surface-variant">{item.timestamp}</td>
                <td className="py-4 px-2">
                  <span className={`${item.statusColor} px-3 py-1 rounded-full text-[10px] font-bold`}>
                    {item.status}
                  </span>
                </td>
                <td className="py-4 px-2 text-right">
                  <button className="text-primary-container p-1 hover:bg-primary-fixed rounded transition-colors">
                    <span className="material-symbols-outlined text-lg">
                      {item.status === 'FAILED' ? 'error' : 'visibility'}
                    </span>
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default UploadHistory;
