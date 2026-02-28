"use client";

import { useWebSocket } from "@/hooks/use-websocket";
import { Badge } from "@/components/ui/badge";
import { Wifi, WifiOff } from "lucide-react";

export function Header() {
    const { isConnected } = useWebSocket();

    return (
        <header className="flex h-16 items-center justify-between border-b bg-white px-6">
            <h2 className="text-xl font-semibold text-slate-800">Overview</h2>

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
