"use client";

import { usePathname } from "next/navigation";
import { Sidebar } from "@/components/layout/sidebar";
import { Header } from "@/components/layout/header";
import { WebSocketProvider } from "@/hooks/use-websocket";

export function DashboardLayout({ children }: { children: React.ReactNode }) {
    const pathname = usePathname();

    if (pathname === "/login") {
        return <>{children}</>;
    }

    return (
        <WebSocketProvider>
            <Sidebar />
            <div className="flex-1 flex flex-col h-screen overflow-hidden">
                <Header />
                <main className="flex-1 overflow-y-auto p-6">
                    {children}
                </main>
            </div>
        </WebSocketProvider>
    );
}
