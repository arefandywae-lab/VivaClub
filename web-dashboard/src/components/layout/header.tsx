"use client";

import { useWebSocket } from "@/hooks/use-websocket";
import { Badge } from "@/components/ui/badge";
import { Wifi, WifiOff, Menu } from "lucide-react";

export function Header({ onMenuClick }: { onMenuClick?: () => void }) {
    const { isConnected } = useWebSocket();

    return (
        <header className="flex h-16 shrink-0 items-center justify-between border-b bg-white px-4 md:px-6">
            <div className="flex items-center gap-3">
                {onMenuClick && (
                    <button
                        onClick={onMenuClick}
                        className="md:hidden p-2 -ml-2 text-slate-500 hover:bg-slate-100 rounded-md"
                    >
                        <Menu className="h-5 w-5" />
                    </button>
                )}
                <h2 className="text-xl font-semibold text-slate-800">Overview</h2>
            </div>

            <div className="flex items-center gap-4">
                {isConnected ? (
                    <Badge variant="outline" className="bg-emerald-50 text-emerald-700 border-emerald-200 gap-1.5 py-1">
                        <Wifi className="h-3.5 w-3.5" />
                        Connected
                    </Badge>
                ) : (
                    <Badge variant="outline" className="bg-rose-50 text-rose-700 border-rose-200 gap-1.5 py-1">
                        <WifiOff className="h-3.5 w-3.5" />
                        Disconnected
                    </Badge>
                )}
            </div>
        </header>
    );
}
