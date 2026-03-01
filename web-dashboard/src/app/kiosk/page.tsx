import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { MonitorSmartphone } from "lucide-react";

export default function KioskPage() {
    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-slate-900">Kiosk Management</h1>
                <p className="text-slate-500 mt-2">Manage physical kiosk devices and access points.</p>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                        <MonitorSmartphone className="h-5 w-5 text-emerald-500" />
                        Active Kiosks
                    </CardTitle>
                </CardHeader>
                <CardContent>
                    <div className="flex flex-col items-center justify-center py-12 text-center">
                        <div className="h-12 w-12 rounded-full bg-slate-100 flex items-center justify-center mb-4">
                            <MonitorSmartphone className="h-6 w-6 text-slate-400" />
                        </div>
                        <h3 className="text-lg font-medium text-slate-900">No kiosks configured</h3>
                        <p className="text-sm text-slate-500 max-w-sm mt-1">
                            You haven't added any kiosk devices yet. This feature will allow you to generate access tokens and manage lobby screens.
                        </p>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
}
