import { User, Settings, Shield, LogOut, Bell } from "lucide-react";
import { Link } from "react-router";

export function DoctorMyProfilePage() {
    return (
        <div className="h-full flex flex-col bg-slate-50">
            <div className="bg-[#0f172a] text-white p-6 pb-8 rounded-b-[2rem] shadow-sm text-center relative overflow-hidden shrink-0 z-0">
                <div className="absolute top-0 left-0 w-full h-full bg-gradient-to-b from-[#0d9488]/10 to-transparent pointer-events-none" />

                <div className="w-20 h-20 bg-white/10 backdrop-blur-md rounded-full mx-auto flex items-center justify-center mb-3 border-2 border-white/20">
                    <User className="w-8 h-8 text-white/80" />
                </div>
                <h1 className="text-xl font-bold">Dr. Sarah Polson</h1>
                <p className="text-[#0d9488] font-medium text-sm">Psychiatrist</p>
                <p className="text-slate-400 text-xs mt-0.5">License ID: 88291-MD</p>
            </div>

            <div className="flex-1 overflow-y-auto px-4 mt-4 space-y-3 pb-12 relative z-10">
                {/* Stats Card */}
                <div className="bg-white p-3 rounded-xl shadow-sm border border-slate-100 flex justify-around text-center">
                    <div>
                        <p className="text-xl font-bold text-slate-800">1,240</p>
                        <p className="text-[10px] text-slate-400 uppercase tracking-wide">Consults</p>
                    </div>
                    <div className="w-px bg-slate-100" />
                    <div>
                        <p className="text-2xl font-bold text-slate-800">4.9</p>
                        <p className="text-[10px] text-slate-400 uppercase tracking-wide">Rating</p>
                    </div>
                    <div className="w-px bg-slate-100" />
                    <div>
                        <p className="text-2xl font-bold text-slate-800">5yr</p>
                        <p className="text-[10px] text-slate-400 uppercase tracking-wide">Exp</p>
                    </div>
                </div>

                {/* Menu */}
                <div className="bg-white rounded-2xl border border-slate-100 overflow-hidden">
                    <button className="w-full flex items-center gap-3 p-4 border-b border-slate-50 hover:bg-slate-50 transition-colors">
                        <div className="p-2 bg-slate-100 rounded-lg text-slate-600"><Settings className="w-5 h-5" /></div>
                        <span className="flex-1 text-left font-medium text-slate-700">Account Settings</span>
                    </button>
                    <button className="w-full flex items-center gap-3 p-4 border-b border-slate-50 hover:bg-slate-50 transition-colors">
                        <div className="p-2 bg-slate-100 rounded-lg text-slate-600"><Bell className="w-5 h-5" /></div>
                        <span className="flex-1 text-left font-medium text-slate-700">Notifications</span>
                    </button>
                    <button className="w-full flex items-center gap-3 p-4 border-b border-slate-50 hover:bg-slate-50 transition-colors">
                        <div className="p-2 bg-slate-100 rounded-lg text-slate-600"><Shield className="w-5 h-5" /></div>
                        <span className="flex-1 text-left font-medium text-slate-700">Privacy & Security</span>
                    </button>
                </div>

                <Link
                    to="/"
                    className="w-full p-4 bg-red-50 text-red-600 rounded-2xl font-bold flex items-center justify-center gap-2 hover:bg-red-100 transition-colors"
                >
                    <LogOut className="w-5 h-5" />
                    Sign Out
                </Link>
            </div>
        </div>
    );
}
