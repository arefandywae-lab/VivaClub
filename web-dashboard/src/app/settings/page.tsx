"use client";

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Server, Activity, Webhook, ShieldCheck, Trash2, Loader2 } from "lucide-react";
import { useEffect, useState } from "react";
import { apiFetch } from "@/lib/api";

export default function SettingsPage() {
    const [apiUrl, setApiUrl] = useState("");
    const [wsUrl, setWsUrl] = useState("");
    const [cleaning, setCleaning] = useState(false);
    const [cleanupResult, setCleanupResult] = useState<any>(null);

    useEffect(() => {
        setApiUrl(process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000');
        setWsUrl(process.env.NEXT_PUBLIC_WS_URL || 'ws://localhost:8000');
    }, []);

    const handleCleanup = async () => {
        if (!confirm("Are you sure you want to delete ALL test rooms (Test Room #...) and test users (clubhouse_user_...)? This action cannot be undone!")) return;
        setCleaning(true);
        setCleanupResult(null);
        try {
            const data = await apiFetch("/auth/admin/cleanup-test-data/", { method: "POST" });
            setCleanupResult(data);
        } catch (error) {
            alert(error instanceof Error ? error.message : "Cleanup failed");
        } finally {
            setCleaning(false);
        }
    };

    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-slate-900">Platform Settings</h1>
                <p className="text-slate-500 mt-1">Configure global platform connections and application settings.</p>
            </div>

            <div className="grid gap-6 md:grid-cols-2">
                <Card className="border-slate-200">
                    <CardHeader className="pb-4">
                        <CardTitle className="flex items-center text-lg">
                            <Server className="h-5 w-5 mr-2 text-slate-500" />
                            Backend Connection
                        </CardTitle>
                        <CardDescription>Environment variables used by this Next.js dashboard</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div>
                            <p className="text-sm font-medium text-slate-500 mb-1">REST API URL</p>
                            <code className="bg-slate-100 px-3 py-2 rounded-md font-mono text-sm block border text-slate-700">
                                {apiUrl}
                            </code>
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-500 mb-1">WebSocket URL</p>
                            <code className="bg-slate-100 px-3 py-2 rounded-md font-mono text-sm block border text-slate-700">
                                {wsUrl}
                            </code>
                        </div>
                        <div className="flex items-center gap-2 pt-2">
                            <Badge variant="outline" className="text-emerald-600 bg-emerald-50 border-emerald-200">
                                <Activity className="h-3 w-3 mr-1" /> Connected
                            </Badge>
                        </div>
                    </CardContent>
                </Card>

                <Card className="border-slate-200">
                    <CardHeader className="pb-4">
                        <CardTitle className="flex items-center text-lg">
                            <Webhook className="h-5 w-5 mr-2 text-slate-500" />
                            LiveKit Integrations
                        </CardTitle>
                        <CardDescription>SFU Real-time media server bindings</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div className="rounded-lg bg-slate-50 p-4 border border-dashed border-slate-300">
                            <h4 className="font-medium text-slate-900 flex items-center mb-2">
                                <ShieldCheck className="h-4 w-4 mr-2 text-emerald-500" />
                                Webhooks Active
                            </h4>
                            <p className="text-sm text-slate-500 leading-relaxed">
                                The system is configured to receive events (participant_joined, room_started, room_finished)
                                from LiveKit at the Django webhook endpoint.
                            </p>
                            <p className="text-xs text-slate-400 mt-4 font-mono">
                                Endpoint: /api/community/webhook/livekit/
                            </p>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Danger Zone */}
            <Card className="border-red-200 bg-red-50/30">
                <CardHeader className="pb-4">
                    <CardTitle className="flex items-center text-lg text-red-700">
                        <Trash2 className="h-5 w-5 mr-2" />
                        Danger Zone — Test Data Cleanup
                    </CardTitle>
                    <CardDescription className="text-red-600/70">
                        Delete all test rooms and test users created by stress test scripts
                    </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                    <div className="text-sm text-slate-600 space-y-1">
                        <p>This will permanently delete:</p>
                        <ul className="list-disc list-inside text-slate-500 space-y-0.5">
                            <li>Rooms with titles starting with <code className="bg-red-100 px-1 rounded text-red-700">Test Room #</code> or <code className="bg-red-100 px-1 rounded text-red-700">Test Anxiety</code></li>
                            <li>Users with usernames starting with <code className="bg-red-100 px-1 rounded text-red-700">clubhouse_user_</code> or <code className="bg-red-100 px-1 rounded text-red-700">testuser_</code></li>
                            <li>Ghost profiles associated with those test users</li>
                        </ul>
                    </div>

                    <div className="flex items-center gap-4">
                        <Button
                            variant="destructive"
                            onClick={handleCleanup}
                            disabled={cleaning}
                            className="gap-2"
                        >
                            {cleaning ? (
                                <><Loader2 className="h-4 w-4 animate-spin" /> Cleaning...</>
                            ) : (
                                <><Trash2 className="h-4 w-4" /> Clean Up Test Data</>
                            )}
                        </Button>

                        {cleanupResult && (
                            <div className="text-sm text-emerald-700 bg-emerald-50 px-3 py-2 rounded-md border border-emerald-200">
                                ✓ Deleted {cleanupResult.deleted_rooms} rooms, {cleanupResult.deleted_users} users, {cleanupResult.deleted_ghost_profiles} ghost profiles
                            </div>
                        )}
                    </div>
                </CardContent>
            </Card>
        </div>
    );
}
