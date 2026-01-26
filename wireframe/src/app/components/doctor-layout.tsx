import { Outlet, Link, useLocation } from "react-router";
import { Home, Users, User, Mic } from "lucide-react";

export function DoctorLayout() {
    const location = useLocation();

    const isActive = (path: string) => location.pathname === path;

    return (
        <div className="min-h-screen bg-gray-100 flex justify-center items-center p-4">
            {/* Mobile Device Frame */}
            <div id="mobile-frame-doctor" className="w-full max-w-[390px] h-[844px] bg-slate-50 flex flex-col rounded-[2.5rem] overflow-hidden shadow-2xl border-[8px] border-gray-800 relative ring-4 ring-gray-200/50">

                {/* Main Content Area */}
                <div className="flex-1 overflow-hidden relative">
                    <Outlet />
                </div>

                {/* Doctor Bottom Navigation */}
                {!location.pathname.includes('/doctor/room/') && (
                    <div className="bg-[#0f172a] border-t border-slate-800 shrink-0 pb-6 pt-2 z-50">
                        <div className="flex justify-around px-4">

                            <Link to="/doctor/dashboard" className="flex-1 flex flex-col items-center gap-1 p-2 group">
                                <div className={`p-1.5 rounded-xl transition-all ${isActive('/doctor/dashboard') ? 'bg-[#0d9488] text-white shadow-lg shadow-[#0d9488]/20' : 'text-slate-400 group-hover:text-white'}`}>
                                    <Home className="w-6 h-6" />
                                </div>
                                <span className={`text-[10px] font-medium transition-colors ${isActive('/doctor/dashboard') ? 'text-[#0d9488]' : 'text-slate-500'}`}>
                                    Command
                                </span>
                            </Link>

                            <Link to="/doctor/patients" className="flex-1 flex flex-col items-center gap-1 p-2 group">
                                <div className={`p-1.5 rounded-xl transition-all ${isActive('/doctor/patients') ? 'bg-[#0d9488] text-white shadow-lg shadow-[#0d9488]/20' : 'text-slate-400 group-hover:text-white'}`}>
                                    <Users className="w-6 h-6" />
                                </div>
                                <span className={`text-[10px] font-medium transition-colors ${isActive('/doctor/patients') ? 'text-[#0d9488]' : 'text-slate-500'}`}>
                                    Patients
                                </span>
                            </Link>

                            {/* Clubhouse (Community) */}
                            <Link to="/doctor/clubhouse" className="flex-1 flex flex-col items-center gap-1 p-2 group">
                                <div className={`p-1.5 rounded-xl transition-all ${isActive('/doctor/clubhouse') ? 'bg-[#0d9488] text-white shadow-lg shadow-[#0d9488]/20' : 'text-slate-400 group-hover:text-white'}`}>
                                    <Mic className="w-6 h-6" />
                                </div>
                                <span className={`text-[10px] font-medium transition-colors ${isActive('/doctor/clubhouse') ? 'text-[#0d9488]' : 'text-slate-500'}`}>
                                    Clubhouse
                                </span>
                            </Link>

                            <Link to="/doctor/profile" className="flex-1 flex flex-col items-center gap-1 p-2 group">
                                <div className={`p-1.5 rounded-xl transition-all ${isActive('/doctor/profile') ? 'bg-[#0d9488] text-white shadow-lg shadow-[#0d9488]/20' : 'text-slate-400 group-hover:text-white'}`}>
                                    <User className="w-6 h-6" />
                                </div>
                                <span className={`text-[10px] font-medium transition-colors ${isActive('/doctor/profile') ? 'text-[#0d9488]' : 'text-slate-500'}`}>
                                    Profile
                                </span>
                            </Link>

                        </div>
                        {/* iOS Home Indicator */}
                        <div className="absolute bottom-1 left-1/2 -translate-x-1/2 w-32 h-1 bg-white/20 rounded-full mb-2 pointer-events-none z-50" />
                    </div>
                )}
            </div>
        </div>
    );
}
