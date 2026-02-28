"use client";

import { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { useWebSocket } from "@/hooks/use-websocket";
import { apiFetch } from "@/lib/api";
import { Users, MicOff, DoorOpen } from "lucide-react";
import { formatDistanceToNow } from "date-fns";
import { useRouter } from "next/navigation";

export default function Home() {
  const router = useRouter();
  const { lastMessage } = useWebSocket();
  const [rooms, setRooms] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  // Fetch initial rooms
  useEffect(() => {
    fetchRooms();
  }, []);

  const fetchRooms = async () => {
    try {
      const data = await apiFetch("/community/rooms/");
      // Assuming paginated or list response
      setRooms(data.results || data);
    } catch (error) {
      console.error("Failed to fetch rooms:", error);
    } finally {
      setLoading(false);
    }
  };

  // Handle real-time WebSocket events
  useEffect(() => {
    if (!lastMessage) return;

    console.log("Processing WS message in Home:", lastMessage);

    if (lastMessage.event === "room_started") {
      fetchRooms(); // Refresh list to get full room data
    } else if (lastMessage.event === "room_finished" || lastMessage.event === "room_closed") {
      setRooms((prev) => prev.filter((r) => r.id !== lastMessage.room_id && r.id !== lastMessage.room_name)); // room_name is sometimes used by livekit
    } else if (lastMessage.event === "participant_joined") {
      setRooms((prev) => prev.map((r) => {
        if (r.id === lastMessage.room_id || r.id === lastMessage.room_name) {
          return { ...r, listeners_count: (r.listeners_count || 0) + 1 };
        }
        return r;
      }));
    } else if (lastMessage.event === "participant_left") {
      setRooms((prev) => prev.map((r) => {
        if (r.id === lastMessage.room_id || r.id === lastMessage.room_name) {
          return { ...r, listeners_count: Math.max(0, (r.listeners_count || 1) - 1) };
        }
        return r;
      }));
    }
  }, [lastMessage]);

  const handleCloseRoom = async (e: React.MouseEvent, roomId: string) => {
    e.stopPropagation();
    if (!confirm("Are you sure you want to FORCE CLOSE this room?")) return;
    try {
      await apiFetch(`/community/admin/rooms/${roomId}/close/`, { method: "POST" });
      // WS will trigger UI update
    } catch (error) {
      alert(error instanceof Error ? error.message : "Failed to close room");
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-slate-900">Live Rooms</h1>
          <p className="text-slate-500 mt-1">Monitor active rooms happening right now across the platform.</p>
        </div>
        <div className="bg-white px-4 py-2 rounded-lg border shadow-sm">
          <span className="text-sm font-medium text-slate-500">Total Active:</span>
          <span className="ml-2 text-xl font-bold text-emerald-600">{rooms.length}</span>
        </div>
      </div>

      {loading ? (
        <div className="flex h-40 items-center justify-center">
          <p className="text-slate-500 animate-pulse">Loading live rooms...</p>
        </div>
      ) : rooms.length === 0 ? (
        <Card className="border-dashed border-2 py-12 bg-slate-50/50">
          <div className="flex flex-col items-center justify-center text-center">
            <MicOff className="h-12 w-12 text-slate-300 mb-4" />
            <h3 className="text-lg font-medium text-slate-900">No Active Rooms</h3>
            <p className="text-slate-500 mt-1">There are currently no live audio rooms on the platform.</p>
          </div>
        </Card>
      ) : (
        <div className="grid gap-6 md:grid-cols-2 xl:grid-cols-3">
          {rooms.map((room) => (
            <Card
              key={room.id}
              className="overflow-hidden hover:shadow-md transition-shadow cursor-pointer hover:border-emerald-300"
              onClick={() => router.push(`/rooms/${room.id}`)}
            >
              <div className="h-2 bg-gradient-to-r from-emerald-400 to-teal-500" />
              <CardHeader className="pb-3">
                <div className="flex justify-between items-start">
                  <Badge variant="secondary" className="bg-emerald-100 text-emerald-700 capitalize">
                    {room.category || "General"}
                  </Badge>
                  {room.is_scheduled && (
                    <Badge variant="outline" className="text-amber-600 border-amber-200 bg-amber-50">
                      Scheduled
                    </Badge>
                  )}
                </div>
                <CardTitle className="mt-2 text-xl leading-tight line-clamp-2">
                  {room.title}
                </CardTitle>
                <div className="text-xs text-slate-500 mt-1 flex items-center">
                  Created {formatDistanceToNow(new Date(room.created_at))} ago
                </div>
              </CardHeader>
              <CardContent>
                <div className="flex items-center gap-3 mb-6">
                  <div className="h-10 w-10 bg-slate-100 rounded-full flex items-center justify-center text-xl overflow-hidden border">
                    {room.host_details?.avatar_url ? (
                      <img src={room.host_details.avatar_url} alt="avatar" className="w-full h-full object-cover" />
                    ) : (
                      <span className="text-slate-500 text-sm font-bold">
                        {room.host_details?.display_name?.charAt(0) || "?"}
                      </span>
                    )}
                  </div>
                  <div>
                    <p className="text-sm font-medium text-slate-900 line-clamp-1">
                      {room.host_details?.display_name || "Unknown Host"}
                    </p>
                    <p className="text-xs text-slate-500">Host</p>
                  </div>
                </div>

                <div className="flex items-center justify-between border-t pt-4">
                  <div className="flex items-center text-slate-600 bg-slate-100 px-3 py-1.5 rounded-full text-sm font-medium">
                    <Users className="h-4 w-4 mr-1.5 text-slate-500" />
                    {room.listeners_count || 0} Listening
                  </div>

                  <div className="flex gap-2">
                    <Button
                      variant="destructive"
                      size="sm"
                      onClick={(e) => handleCloseRoom(e, room.id)}
                      className="gap-1.5"
                    >
                      <DoorOpen className="h-4 w-4" />
                      Close
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
