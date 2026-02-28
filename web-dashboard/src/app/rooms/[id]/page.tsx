"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { useWebSocket } from "@/hooks/use-websocket";
import { apiFetch } from "@/lib/api";
import { ArrowLeft, Mic, MicOff, DoorOpen, Ban, UserMinus } from "lucide-react";

export default function RoomDetail() {
    const params = useParams();
    const router = useRouter();
    const roomId = params.id as string;

    const { lastMessage } = useWebSocket();
    const [room, setRoom] = useState<any>(null);
    const [participants, setParticipants] = useState<any[]>([]); // We would fetch this from LiveKit API or backend
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchRoomDetails();
    }, [roomId]);

    const fetchRoomDetails = async () => {
        try {
            const data = await apiFetch(`/community/rooms/${roomId}/`);
            setRoom(data);

            try {
                const parts = await apiFetch(`/community/admin/rooms/${roomId}/participants/`);
                if (Array.isArray(parts)) setParticipants(parts);
            } catch (err) {
                console.error("Failed to fetch livekit parts", err);
            }
        } catch (error) {
            console.error("Failed to fetch room:", error);
        } finally {
            setLoading(false);
        }
    };

    // Real-time updates
    useEffect(() => {
        if (!lastMessage) return;

        if (
            (lastMessage.event === "room_closed" || lastMessage.event === "room_finished") &&
            (lastMessage.room_id === roomId || lastMessage.room_name === roomId)
        ) {
            alert("This room has ended.");
            router.push("/");
        }

        // Handlers for participant_joined / participant_left would update the `participants` array here
    }, [lastMessage, roomId, router]);

    const handleAction = async (action: string, identity?: string, trackSid?: string) => {
        let confirmMsg = `Are you sure you want to ${action.replace('-', ' ')}?`;
        if (identity && action !== 'close') confirmMsg = `Are you sure you want to ${action} this user?`;

        if (!confirm(confirmMsg)) return;

        try {
            if (action === "close") {
                await apiFetch(`/community/admin/rooms/${roomId}/close/`, { method: "POST" });
                router.push("/");
            } else if (action === "mute" || action === "kick") {
                await apiFetch(`/community/admin/rooms/${roomId}/${action}/`, {
                    method: "POST",
                    body: JSON.stringify({ identity, track_sid: trackSid })
                });
                fetchRoomDetails(); // Refresh list to reflect changes
            }
        } catch (error) {
            alert(error instanceof Error ? error.message : "Action failed");
        }
    };

    if (loading) return <div className="p-12 text-center animate-pulse">Loading room details...</div>;
    if (!room) return <div className="p-12 text-center text-rose-500">Room not found</div>;

    return (
        <div className="space-y-6">
            <div className="flex items-center gap-4">
                <Button variant="outline" size="icon" onClick={() => router.push("/")}>
                    <ArrowLeft className="h-4 w-4" />
                </Button>
                <div>
                    <div className="flex items-center gap-3">
                        <h1 className="text-2xl font-bold tracking-tight text-slate-900">{room.title}</h1>
                        <Badge variant="secondary" className="bg-emerald-100 text-emerald-700 capitalize">
                            {room.category || "General"}
                        </Badge>
                    </div>
                    <p className="text-slate-500">Room ID: {room.id}</p>
                </div>
            </div>

            <div className="grid gap-6 md:grid-cols-3">
                {/* Info Card */}
                <Card className="col-span-1 border-slate-200 shadow-sm">
                    <CardHeader>
                        <CardTitle>Room Info</CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div>
                            <p className="text-sm font-medium text-slate-500">Host</p>
                            <div className="flex items-center gap-2 mt-1">
                                <div className="h-8 w-8 rounded-full bg-slate-100 flex items-center justify-center border text-lg overflow-hidden">
                                    {room.host_details?.avatar_url ? (
                                        <img src={room.host_details.avatar_url} alt="avatar" className="h-full w-full object-cover" />
                                    ) : (
                                        room.host_details?.display_name?.charAt(0) || "👻"
                                    )}
                                </div>
                                <span className="font-medium text-slate-900">
                                    {room.host_details?.display_name || "Unknown"}
                                </span>
                            </div>
                        </div>

                        <div>
                            <p className="text-sm font-medium text-slate-500">Current Listeners</p>
                            <p className="text-2xl font-bold text-emerald-600">{room.listeners_count}</p>
                        </div>

                        <div className="pt-4 border-t space-y-3">
                            <Button
                                variant="destructive"
                                className="w-full gap-2"
                                onClick={() => handleAction("close")}
                            >
                                <DoorOpen className="h-4 w-4" />
                                Force Close Room
                            </Button>
                        </div>
                    </CardContent>
                </Card>

                {/* Participants Table */}
                <Card className="col-span-2 border-slate-200 shadow-sm">
                    <CardHeader>
                        <CardTitle>Participants</CardTitle>
                        <CardDescription>LiveKit connected participants (UI Mockup for MVP)</CardDescription>
                    </CardHeader>
                    <CardContent>
                        {/* Note: This is a placeholder since we don't have the LiveKit Participant API baked in yet */}
                        <Table>
                            <TableHeader>
                                <TableRow className="bg-slate-50">
                                    <TableHead>User</TableHead>
                                    <TableHead>Role</TableHead>
                                    <TableHead>Mic</TableHead>
                                    <TableHead className="text-right">Actions</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {participants.length === 0 ? (
                                    <TableRow>
                                        <TableCell colSpan={4} className="text-center py-8 text-slate-500">No active LiveKit participants</TableCell>
                                    </TableRow>
                                ) : (
                                    participants.map((p) => {
                                        // Livekit TrackType: AUDIO = 1
                                        const audioTrack = p.tracks?.find((t: any) => t.type === 1 || t.type === 'AUDIO');
                                        const isMuted = audioTrack?.muted;
                                        // Temporary check for host
                                        const isHost = p.identity === room.host || room.host_details?.display_name?.includes(p.name);

                                        return (
                                            <TableRow key={p.identity}>
                                                <TableCell className="font-medium flex items-center gap-2">
                                                    <div className="h-6 w-6 rounded-full bg-slate-100 flex items-center justify-center border text-xs overflow-hidden">
                                                        {(isHost && room.host_details?.avatar_url) ? (
                                                            <img src={room.host_details.avatar_url} alt="avatar" className="w-full h-full object-cover" />
                                                        ) : (
                                                            p.name?.charAt(0) || "👻"
                                                        )}
                                                    </div>
                                                    {p.name}
                                                </TableCell>
                                                <TableCell>
                                                    {p.is_publisher ? (
                                                        <Badge variant="outline" className="bg-amber-50 text-amber-700">Speaker</Badge>
                                                    ) : (
                                                        <Badge variant="secondary">Listener</Badge>
                                                    )}
                                                </TableCell>
                                                <TableCell>
                                                    {!audioTrack || isMuted ? <MicOff className="h-4 w-4 text-slate-300" /> : <Mic className="h-4 w-4 text-emerald-500" />}
                                                </TableCell>
                                                <TableCell className="text-right space-x-2">
                                                    {audioTrack && !isMuted && (
                                                        <Button variant="outline" size="sm" className="h-8" onClick={() => handleAction("mute", p.identity, audioTrack.sid)}>
                                                            Mute
                                                        </Button>
                                                    )}
                                                    <Button variant="outline" size="sm" className="h-8 text-rose-600 hover:text-rose-700 hover:bg-rose-50 border-rose-200" onClick={() => handleAction("kick", p.identity)}>
                                                        <UserMinus className="h-3 w-3 mr-1" />
                                                        Kick
                                                    </Button>
                                                </TableCell>
                                            </TableRow>
                                        );
                                    })
                                )}
                            </TableBody>
                        </Table>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}
