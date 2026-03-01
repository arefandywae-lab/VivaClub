"use client";

import { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Bot, Play, Square, Mic, MicOff, LogOut, Trash2, Plus, Loader2, Music, Radio } from "lucide-react";

const BOT_API = process.env.NEXT_PUBLIC_BOT_API_URL || "http://localhost:9090";

async function botFetch(endpoint: string, options: RequestInit = {}) {
    const headers = new Headers(options.headers || {});
    headers.set("Content-Type", "application/json");
    const response = await fetch(`${BOT_API}${endpoint}`, { ...options, headers });
    if (!response.ok) {
        const err = await response.json().catch(() => ({}));
        throw new Error(err.detail || `Request failed: ${response.status}`);
    }
    return response.json();
}

export default function BotsPage() {
    const [bots, setBots] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [actionLoading, setActionLoading] = useState<string | null>(null);

    // Spawn form
    const [spawnRoomId, setSpawnRoomId] = useState("");
    const [spawnName, setSpawnName] = useState("");
    const [spawning, setSpawning] = useState(false);

    // Audio URL per bot
    const [audioUrls, setAudioUrls] = useState<Record<string, string>>({});

    useEffect(() => {
        fetchBots();
        const interval = setInterval(fetchBots, 5000); // Poll every 5s
        return () => clearInterval(interval);
    }, []);

    const fetchBots = async () => {
        try {
            const data = await botFetch("/bots");
            setBots(data.bots || []);
        } catch (error) {
            console.error("Failed to fetch bots:", error);
        } finally {
            setLoading(false);
        }
    };

    const handleSpawn = async () => {
        if (!spawnRoomId.trim()) return alert("Enter a Room ID");
        setSpawning(true);
        try {
            await botFetch("/bots/spawn", {
                method: "POST",
                body: JSON.stringify({ room_id: spawnRoomId.trim(), name: spawnName.trim() || undefined }),
            });
            setSpawnRoomId("");
            setSpawnName("");
            await fetchBots();
        } catch (error) {
            alert(error instanceof Error ? error.message : "Failed to spawn bot");
        } finally {
            setSpawning(false);
        }
    };

    const handleAction = async (botId: string, action: string, method: string = "POST", body?: any) => {
        setActionLoading(`${botId}-${action}`);
        try {
            await botFetch(`/bots/${botId}${action ? '/' + action : ''}`, {
                method,
                body: body ? JSON.stringify(body) : undefined,
            });
            await fetchBots();
        } catch (error) {
            alert(error instanceof Error ? error.message : `Action failed`);
        } finally {
            setActionLoading(null);
        }
    };

    const handlePlay = async (botId: string) => {
        const url = audioUrls[botId];
        if (!url?.trim()) return alert("Enter a YouTube or audio URL");
        await handleAction(botId, "play", "POST", { url: url.trim() });
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-900">Bot Management</h1>
                    <p className="text-slate-500 mt-1">Manage virtual participants in rooms for testing and content.</p>
                </div>
                <div className="bg-white px-4 py-2 rounded-lg border shadow-sm self-start sm:self-auto">
                    <span className="text-sm font-medium text-slate-500">Active Bots:</span>
                    <span className="ml-2 text-xl font-bold text-emerald-600">{bots.length}</span>
                </div>
            </div>

            {/* Spawn Controls */}
            <Card className="border-emerald-200 bg-emerald-50/30">
                <CardHeader className="pb-4">
                    <CardTitle className="flex items-center text-lg text-emerald-700">
                        <Plus className="h-5 w-5 mr-2" />
                        Spawn New Bot
                    </CardTitle>
                </CardHeader>
                <CardContent>
                    <div className="flex flex-col md:flex-row gap-3 md:items-end w-full">
                        <div className="w-full md:flex-1">
                            <label className="text-sm font-medium text-slate-600 mb-1 block">Room ID</label>
                            <Input
                                placeholder="Paste room UUID here..."
                                value={spawnRoomId}
                                onChange={(e) => setSpawnRoomId(e.target.value)}
                            />
                        </div>
                        <div className="w-full md:w-48">
                            <label className="text-sm font-medium text-slate-600 mb-1 block">Bot Name (optional)</label>
                            <Input
                                placeholder="DJ Bot"
                                value={spawnName}
                                onChange={(e) => setSpawnName(e.target.value)}
                            />
                        </div>
                        <Button
                            onClick={handleSpawn}
                            disabled={spawning}
                            className="bg-emerald-600 hover:bg-emerald-700 gap-2 w-full md:w-auto"
                        >
                            {spawning ? <Loader2 className="h-4 w-4 animate-spin" /> : <Bot className="h-4 w-4" />}
                            Spawn
                        </Button>
                    </div>
                </CardContent>
            </Card>

            {/* Bot List */}
            <Card className="border-slate-200 shadow-sm">
                <CardHeader>
                    <CardTitle>Active Bots</CardTitle>
                </CardHeader>
                <CardContent>
                    {loading ? (
                        <div className="py-12 text-center text-slate-500 animate-pulse">Loading bots...</div>
                    ) : bots.length === 0 ? (
                        <div className="py-12 text-center">
                            <Bot className="h-12 w-12 text-slate-300 mx-auto mb-4" />
                            <h3 className="text-lg font-medium text-slate-900">No Active Bots</h3>
                            <p className="text-slate-500 mt-1">Spawn a bot to get started.</p>
                        </div>
                    ) : (
                        <Table>
                            <TableHeader>
                                <TableRow className="bg-slate-50">
                                    <TableHead>Bot</TableHead>
                                    <TableHead>Room</TableHead>
                                    <TableHead>Status</TableHead>
                                    <TableHead>Audio</TableHead>
                                    <TableHead className="text-right">Actions</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {bots.map((bot) => (
                                    <TableRow key={bot.bot_id}>
                                        <TableCell>
                                            <div className="flex items-center gap-2">
                                                <Bot className="h-5 w-5 text-emerald-600" />
                                                <div>
                                                    <p className="font-medium text-slate-900">{bot.name}</p>
                                                    <p className="text-xs text-slate-400 font-mono">{bot.bot_id}</p>
                                                </div>
                                            </div>
                                        </TableCell>
                                        <TableCell>
                                            <code className="text-xs bg-slate-100 px-2 py-1 rounded">{bot.room_id || "—"}</code>
                                        </TableCell>
                                        <TableCell>
                                            <div className="flex gap-1">
                                                {bot.is_connected ? (
                                                    <Badge className="bg-emerald-100 text-emerald-700">Connected</Badge>
                                                ) : (
                                                    <Badge variant="secondary">Disconnected</Badge>
                                                )}
                                                {bot.is_muted ? (
                                                    <Badge variant="outline" className="text-red-600 border-red-200">Muted</Badge>
                                                ) : (
                                                    <Badge variant="outline" className="text-emerald-600 border-emerald-200">Live</Badge>
                                                )}
                                            </div>
                                        </TableCell>
                                        <TableCell>
                                            {bot.is_playing ? (
                                                <div className="flex items-center gap-1">
                                                    <Music className="h-3 w-3 text-purple-600 animate-pulse" />
                                                    <span className="text-xs text-purple-600 truncate max-w-32" title={bot.current_url}>{bot.current_url}</span>
                                                </div>
                                            ) : (
                                                <div className="flex items-center gap-2">
                                                    <Input
                                                        placeholder="YouTube or radio URL..."
                                                        className="h-8 text-xs"
                                                        value={audioUrls[bot.bot_id] || ""}
                                                        onChange={(e) => setAudioUrls({ ...audioUrls, [bot.bot_id]: e.target.value })}
                                                    />
                                                    <Button
                                                        size="sm"
                                                        variant="outline"
                                                        className="h-8 gap-1 text-purple-600 border-purple-200 hover:bg-purple-50"
                                                        onClick={() => handlePlay(bot.bot_id)}
                                                        disabled={actionLoading === `${bot.bot_id}-play`}
                                                    >
                                                        <Play className="h-3 w-3" /> Play
                                                    </Button>
                                                </div>
                                            )}
                                        </TableCell>
                                        <TableCell className="text-right">
                                            <div className="flex justify-end gap-1">
                                                {bot.is_playing && (
                                                    <Button
                                                        size="sm"
                                                        variant="outline"
                                                        className="h-8 gap-1"
                                                        onClick={() => handleAction(bot.bot_id, "stop")}
                                                        disabled={actionLoading === `${bot.bot_id}-stop`}
                                                    >
                                                        <Square className="h-3 w-3" /> Stop
                                                    </Button>
                                                )}
                                                <Button
                                                    size="sm"
                                                    variant="outline"
                                                    className={`h-8 gap-1 ${bot.is_muted ? 'text-emerald-600 border-emerald-200' : 'text-red-600 border-red-200'}`}
                                                    onClick={() => handleAction(bot.bot_id, bot.is_muted ? "unmute" : "mute")}
                                                    disabled={actionLoading?.startsWith(`${bot.bot_id}-`)}
                                                >
                                                    {bot.is_muted ? <><Mic className="h-3 w-3" /> Unmute</> : <><MicOff className="h-3 w-3" /> Mute</>}
                                                </Button>
                                                <Button
                                                    size="sm"
                                                    variant="outline"
                                                    className="h-8 gap-1 text-orange-600 border-orange-200 hover:bg-orange-50"
                                                    onClick={() => handleAction(bot.bot_id, "leave")}
                                                    disabled={actionLoading === `${bot.bot_id}-leave`}
                                                >
                                                    <LogOut className="h-3 w-3" /> Leave
                                                </Button>
                                                <Button
                                                    size="sm"
                                                    variant="outline"
                                                    className="h-8 gap-1 text-red-600 border-red-200 hover:bg-red-50"
                                                    onClick={() => {
                                                        if (confirm(`Kill bot "${bot.name}"?`)) {
                                                            handleAction(bot.bot_id, "", "DELETE");
                                                        }
                                                    }}
                                                    disabled={actionLoading === `${bot.bot_id}-`}
                                                >
                                                    <Trash2 className="h-3 w-3" /> Kill
                                                </Button>
                                            </div>
                                        </TableCell>
                                    </TableRow>
                                ))}
                            </TableBody>
                        </Table>
                    )}
                </CardContent>
            </Card>
        </div>
    );
}
