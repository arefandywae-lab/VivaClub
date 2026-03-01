import { Home, Users, Settings, Activity, LogOut, Bot } from "lucide-react";
import Link from "next/link";
import { useEffect, useState } from "react";

export function Sidebar() {
    const [profile, setProfile] = useState<any>(null);

    useEffect(() => {
        try {
            const p = localStorage.getItem('adminProfile');
            if (p) setProfile(JSON.parse(p));
        } catch (e) { }
    }, []);

    return (
        <div className="flex h-screen w-64 flex-col border-r bg-slate-950 text-slate-300">
            <div className="flex h-16 items-center border-b border-slate-800 px-6">
                <Activity className="mr-2 h-6 w-6 text-emerald-500" />
                <span className="font-bold text-lg text-white">Viva Dashboard</span>
            </div>

            <nav className="flex-1 space-y-1 p-4">
                <Link href="/" className="flex items-center rounded-lg bg-slate-900 px-4 py-3 text-emerald-400">
                    <Home className="mr-3 h-5 w-5" />
                    Live Rooms
                </Link>
                <Link href="/users" className="flex items-center rounded-lg px-4 py-3 hover:bg-slate-900 hover:text-emerald-400 transition-colors">
                    <Users className="mr-3 h-5 w-5" />
                    User Management
                </Link>
                <Link href="/bots" className="flex items-center rounded-lg px-4 py-3 hover:bg-slate-900 hover:text-emerald-400 transition-colors">
                    <Bot className="mr-3 h-5 w-5" />
                    Bot Management
                </Link>
                <Link href="/settings" className="flex items-center rounded-lg px-4 py-3 hover:bg-slate-900 hover:text-emerald-400 transition-colors">
                    <Settings className="mr-3 h-5 w-5" />
                    Settings
                </Link>
            </nav>

            <div className="border-t border-slate-800 p-4">
                <div className="flex items-center gap-3">
                    <div className="h-8 w-8 rounded-full bg-emerald-600 flex items-center justify-center text-white font-bold overflow-hidden">
                        {profile?.ghost_profile?.avatar ? (
                            <img src={profile.ghost_profile.avatar} alt="avatar" className="w-full h-full object-cover" />
                        ) : (
                            profile?.display_name?.charAt(0) || "A"
                        )}
                    </div>
                    <div className="overflow-hidden">
                        <p className="text-sm font-medium text-white truncate">{profile?.display_name || "Admin User"}</p>
                        <p className="text-xs text-slate-500 truncate">{profile?.email || profile?.username || "admin@vivaclubs.site"}</p>
                    </div>
                </div>
                <button
                    onClick={() => {
                        localStorage.removeItem('adminToken');
                        localStorage.removeItem('adminRefreshToken');
                        localStorage.removeItem('adminProfile');
                        window.location.href = '/login';
                    }}
                    className="mt-4 flex w-full items-center justify-center rounded-md bg-rose-500/10 px-3 py-2 text-sm font-medium text-rose-500 hover:bg-rose-500/20 transition-colors"
                >
                    <LogOut className="mr-2 h-4 w-4" />
                    Sign Out
                </button>
            </div>
        </div>
    );
}
