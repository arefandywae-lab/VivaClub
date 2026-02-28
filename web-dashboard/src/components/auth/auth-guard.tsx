"use client";

import { useEffect, useState } from "react";
import { useRouter, usePathname } from "next/navigation";

export function AuthGuard({ children }: { children: React.ReactNode }) {
    const router = useRouter();
    const pathname = usePathname();
    const [isAuthenticated, setIsAuthenticated] = useState(false);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        const token = localStorage.getItem("adminToken");

        if (!token && pathname !== "/login") {
            router.push("/login");
        } else if (token && pathname === "/login") {
            router.push("/");
        } else {
            setIsAuthenticated(!!token);
            setIsLoading(false);
        }
    }, [pathname, router]);

    // If loading or redirecting, don't render anything
    if (isLoading || (!isAuthenticated && pathname !== "/login")) {
        return (
            <div className="flex h-screen w-screen items-center justify-center bg-slate-50">
                <div className="animate-pulse flex flex-col items-center">
                    <div className="h-10 w-10 border-4 border-emerald-500 border-t-transparent rounded-full animate-spin"></div>
                    <p className="mt-4 text-slate-500 font-medium">Authenticating session...</p>
                </div>
            </div>
        );
    }

    // If we are on the login page, just render the children (no layout)
    // Our RootLayout has the Sidebar/Header, so we actually want to handle this differently.
    if (pathname === "/login") {
        return <>{children}</>;
    }

    // If authenticated and on a protected route, render with layout wrappers configured in RootLayout
    return <>{children}</>;
}
