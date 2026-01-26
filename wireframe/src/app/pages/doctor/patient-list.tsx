import { Search, User, Filter } from "lucide-react";

export function DoctorPatientListPage() {
    const patients = [
        { id: 1, name: "Anonymous Panda", lastVisit: "Today", status: "Active", risk: "High" },
        { id: 2, name: "Gentle Wave", lastVisit: "Yesterday", status: "Stable", risk: "Low" },
        { id: 3, name: "Calm Spirit", lastVisit: "Jan 10", status: "Stable", risk: "Low" },
        { id: 4, name: "Silent Mountain", lastVisit: "Jan 05", status: "Inactive", risk: "Medium" },
        { id: 5, name: "Bright Star", lastVisit: "Dec 28", status: "Active", risk: "Low" },
    ];

    return (
        <div className="h-full flex flex-col bg-slate-50">
            <div className="bg-[#0f172a] text-white p-6 pb-6 rounded-b-[2rem] shadow-lg">
                <h1 className="text-xl font-bold mb-4">My Patients</h1>

                <div className="relative">
                    <input
                        type="text"
                        placeholder="Search patients..."
                        className="w-full pl-10 pr-4 py-3 rounded-xl bg-[#1e293b] border border-slate-700 text-white focus:outline-none focus:border-[#0d9488]"
                    />
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
                </div>
            </div>

            <div className="flex-1 overflow-y-auto p-4 space-y-3">
                <div className="flex justify-between items-center mb-2 px-1">
                    <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">All Patients ({patients.length})</span>
                    <button className="text-slate-400 hover:text-[#0d9488]">
                        <Filter className="w-4 h-4" />
                    </button>
                </div>

                {patients.map(p => (
                    <div key={p.id} className="bg-white p-4 rounded-xl border border-slate-100 shadow-sm flex items-center justify-between hover:bg-slate-50 transition-colors cursor-pointer">
                        <div className="flex items-center gap-3">
                            <div className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center text-slate-500">
                                <User className="w-5 h-5" />
                            </div>
                            <div>
                                <h3 className="font-bold text-slate-800">{p.name}</h3>
                                <p className="text-xs text-slate-500">Last visit: {p.lastVisit}</p>
                            </div>
                        </div>
                        <div className="text-right">
                            <span className={`text-[10px] px-2 py-1 rounded-full font-bold uppercase ${p.risk === 'High' ? 'bg-red-100 text-red-600' :
                                    p.risk === 'Medium' ? 'bg-orange-100 text-orange-600' :
                                        'bg-green-100 text-green-600'
                                }`}>
                                {p.risk} Risk
                            </span>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
}
