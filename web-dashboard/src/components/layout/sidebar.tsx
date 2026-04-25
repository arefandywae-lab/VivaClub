import { Home, Users, Settings, Activity, LogOut, Bot, MonitorSmartphone, X, Calendar } from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";

interface SidebarProps {
    isOpen?: boolean;
    setIsOpen?: (v: boolean) => void;
}

export function Sidebar({ isOpen = false, setIsOpen }: SidebarProps) {
    const [profile, setProfile] = useState<any>(null);
    const pathname = usePathname();

    useEffect(() => {
        try {
            const p = localStorage.getItem('adminProfile');
            if (p) setProfile(JSON.parse(p));
        } catch (e) { }
    }, []);

    const isActive = (path: string) => {
        if (path === "/" && pathname === "/") return true;
        if (path !== "/" && pathname.startsWith(path)) return true;
        return false;
    };

    const getLinkClass = (path: string) => {
        const active = isActive(path);
        return `flex items-center rounded-lg px-4 py-3 transition-colors ${
            active 
                ? "bg-slate-900 text-emerald-400 font-medium" 
                : "text-slate-400 hover:bg-slate-900/50 hover:text-emerald-400"
        }`;
    };

    return (
        <div className={`
            fixed inset-y-0 left-0 z-50 flex h-full w-64 flex-col border-r bg-slate-950 text-slate-300
            transform transition-transform duration-300 ease-in-out
            md:relative md:translate-x-0
            ${isOpen ? "translate-x-0" : "-translate-x-full"}
        `}>
            <div className="flex h-16 shrink-0 items-center justify-between border-b border-slate-800 px-6">
                <div className="flex items-center">
                    <Activity className="mr-2 h-6 w-6 text-emerald-500" />
                    <span className="font-bold text-lg text-white">Viva Dashboard</span>
                </div>
                {setIsOpen && (
                    <button
                        onClick={() => setIsOpen(false)}
                        className="md:hidden p-1 text-slate-400 hover:text-white rounded-md"
                    >
                        <X className="h-5 w-5" />
                    </button>
                )}
            </div>

            <nav className="flex-1 space-y-1 p-4 overflow-y-auto overflow-x-hidden">
                <Link onClick={() => setIsOpen?.(false)} href="/" className={getLinkClass("/")}>
                    <Home className="mr-3 h-5 w-5 shrink-0" />
                    Live Rooms
                </Link>
                <Link onClick={() => setIsOpen?.(false)} href="/users" className={getLinkClass("/users")}>
                    <Users className="mr-3 h-5 w-5 shrink-0" />
                    User Management
                </Link>
                <Link onClick={() => setIsOpen?.(false)} href="/bots" className={getLinkClass("/bots")}>
                    <Bot className="mr-3 h-5 w-5 shrink-0" />
                    Bot Management
                </Link>
                <Link onClick={() => setIsOpen?.(false)} href="/appointments" className={getLinkClass("/appointments")}>
                    <Calendar className="mr-3 h-5 w-5 shrink-0" />
                    Video Calls
                </Link>
                <Link onClick={() => setIsOpen?.(false)} href="/kiosk" className={getLinkClass("/kiosk")}>
                    <MonitorSmartphone className="mr-3 h-5 w-5 shrink-0" />
                    Kiosk Management
                </Link>
                <Link onClick={() => setIsOpen?.(false)} href="/settings" className={getLinkClass("/settings")}>
                    <Settings className="mr-3 h-5 w-5 shrink-0" />
                    Settings
                </Link>
            </nav>


            <div className="shrink-0 border-t border-slate-800 p-4">
                <div className="flex items-center gap-3">
                    <div className="h-8 w-8 shrink-0 rounded-full bg-emerald-600 flex items-center justify-center text-white font-bold overflow-hidden">
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
        </div >
    );
}
