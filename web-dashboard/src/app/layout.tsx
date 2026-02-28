import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { AuthGuard } from "@/components/auth/auth-guard";
import { DashboardLayout } from "@/components/dashboard/dashboard-layout";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Viva Dashboard",
  description: "Real-time admin dashboard for VivaClub",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${inter.className} bg-slate-50 flex h-screen overflow-hidden`}>
        <AuthGuard>
          <DashboardLayout>
            {children}
          </DashboardLayout>
        </AuthGuard>
      </body>
    </html>
  );
}
