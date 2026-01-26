import { useState } from "react";
import { Link } from "react-router";
import {
    Activity,
    Calendar,
    Clock,
    Users,
    Bell,
    ChevronRight,
    Video,
    LogOut,
    Power
} from "lucide-react";

export function DoctorDashboardPage() {
    const [isOnline, setIsOnline] = useState(false);

    // Mock Schedule Data
    const schedule = [
        { id: 1, time: "09:00", patient: "Anonymous Panda", type: "Telemed", status: "waiting", severe: true },
        { id: 2, time: "10:30", patient: "Gentle Wave", type: "Follow-up", status: "confirmed", severe: false },
        { id: 3, time: "13:00", patient: "Calm Spirit", type: "Assessment", status: "confirmed", severe: false },
    ];

    return (
        <div className="h-full flex flex-col bg-slate-50">
            {/* Header / Status Bar */}
            <div className="bg-[#0f172a] text-white p-6 pb-8 rounded-b-[2rem] shadow-lg relative z-10">
                <div className="flex justify-between items-start mb-6">
                    <div>
                        <h1 className="text-xl font-bold">Dr. Sarah Polson</h1>
                        <p className="text-slate-400 text-xs">Psychiatrist • ID: 88291</p>
                    </div>
                    <div className="flex gap-3">
                        <button className="p-2 bg-slate-800 rounded-full hover:bg-slate-700 transition-colors relative">
                            <Bell className="w-5 h-5 text-slate-300" />
                            <span className="absolute top-1 right-1 w-2.5 h-2.5 bg-red-500 rounded-full border-2 border-slate-800"></span>
                        </button>
                        <button className="p-2 bg-slate-800 rounded-full hover:bg-red-900/50 text-slate-300 hover:text-red-400 transition-colors">
                            <LogOut className="w-5 h-5" />
                        </button>
                    </div>
                </div>

                {/* Status Toggle Card */}
                <div className="bg-[#1e293b] rounded-2xl p-4 flex items-center justify-between border border-slate-700 shadow-xl">
                    <div className="flex items-center gap-3">
                        <div className={`w-3 h-3 rounded-full ${isOnline ? 'bg-green-500 shadow-[0_0_10px_rgba(34,197,94,0.5)]' : 'bg-slate-500'}`} />
                        <div>
                            <p className="font-semibold text-sm">{isOnline ? 'Online' : 'Offline'}</p>
                            <p className="text-[10px] text-slate-400">
                                {isOnline ? 'Ready for Walk-ins' : 'Not accepting new cases'}
                            </p>
                        </div>
                    </div>
                    <button
                        onClick={() => setIsOnline(!isOnline)}
                        className={`w-12 h-7 rounded-full transition-colors relative ${isOnline ? 'bg-[#0d9488]' : 'bg-slate-600'}`}
                    >
                        <div className={`absolute top-1 w-5 h-5 bg-white rounded-full transition-transform shadow-sm ${isOnline ? 'left-6' : 'left-1'}`} />
                    </button>
                </div>
            </div>

            {/* Main Content */}
            <div className="flex-1 overflow-y-auto -mt-4 pt-6 px-4 space-y-6 pb-24">

                {/* Quick Stats */}
                <div className="grid grid-cols-2 gap-3">
                    <div className="bg-white p-4 rounded-2xl shadow-sm border border-slate-100">
                        <div className="flex items-center gap-2 mb-2 text-slate-500">
                            <Activity className="w-4 h-4" />
                            <span className="text-xs font-semibold uppercase">Performance</span>
                        </div>
                        <p className="text-2xl font-bold text-[#0f172a]">98%</p>
                        <p className="text-[10px] text-green-600 font-medium">+2.4% vs last week</p>
                    </div>
                    <div className="bg-white p-4 rounded-2xl shadow-sm border border-slate-100">
                        <div className="flex items-center gap-2 mb-2 text-slate-500">
                            <Users className="w-4 h-4" />
                            <span className="text-xs font-semibold uppercase">Patients</span>
                        </div>
                        <p className="text-2xl font-bold text-[#0f172a]">12</p>
                        <p className="text-[10px] text-slate-400">4 Remaining today</p>
                    </div>
                </div>

                {/* Critical Alerts (Conditional) */}
                <div className="bg-red-50 border border-red-100 rounded-2xl p-4 flex items-start gap-3 shadow-sm animate-pulse">
                    <div className="bg-red-100 p-2 rounded-full">
                        <Activity className="w-5 h-5 text-red-600" />
                    </div>
                    <div className="flex-1">
                        <h3 className="text-sm font-bold text-red-900">Emergency Alert</h3>
                        <p className="text-xs text-red-700 mt-1">Patient #9921 triggers high-risk keywords. Review immediately.</p>
                    </div>
                    <button className="text-xs bg-white border border-red-200 text-red-700 px-3 py-1.5 rounded-lg font-semibold shadow-sm">
                        View
                    </button>
                </div>

                {/* Schedule */}
                <div>
                    <div className="flex items-center justify-between mb-3 px-1">
                        <h2 className="font-bold text-slate-800 text-lg">Today's Schedule</h2>
                        <Link to="#" className="text-xs text-[#0d9488] font-semibold">View Calendar</Link>
                    </div>

                    <div className="space-y-3">
                        {schedule.map((item) => (
                            <div key={item.id} className="bg-white rounded-2xl p-4 shadow-sm border border-slate-100 relative overflow-hidden group">
                                {item.status === 'waiting' && (
                                    <div className="absolute left-0 top-0 bottom-0 w-1.5 bg-[#0d9488]" />
                                )}
                                <div className="flex justify-between items-start mb-3">
                                    <div className="flex items-center gap-2 text-sm font-semibold text-slate-700">
                                        <Clock className="w-4 h-4 text-slate-400" />
                                        {item.time}
                                    </div>
                                    <span className={`text-[10px] px-2 py-1 rounded-full font-bold uppercase tracking-wide ${item.status === 'waiting' ? 'bg-orange-100 text-orange-700' : 'bg-slate-100 text-slate-600'
                                        }`}>
                                        {item.status}
                                    </span>
                                </div>

                                <div className="flex justify-between items-center">
                                    <div>
                                        <h3 className="font-bold text-slate-900">{item.patient}</h3>
                                        <p className="text-xs text-slate-500 mt-0.5">{item.type}</p>
                                    </div>
                                    {item.status === 'waiting' && (
                                        <Link
                                            to={`/doctor/room/${item.id}`}
                                            className="bg-[#0d9488] text-white p-2.5 rounded-xl shadow-lg shadow-[#0d9488]/20 active:scale-95 transition-all"
                                        >
                                            <Video className="w-5 h-5" />
                                        </Link>
                                    )}
                                </div>

                                {item.severe && (
                                    <div className="mt-3 pt-3 border-t border-slate-50 flex items-center gap-2">
                                        <span className="w-2 h-2 rounded-full bg-red-500 animate-pulse"></span>
                                        <p className="text-[10px] text-red-600 font-medium">Prioritize: High PHQ-9 Score (Severe)</p>
                                    </div>
                                )}
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
}
