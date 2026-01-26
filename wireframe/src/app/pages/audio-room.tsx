import { useState } from "react";
import { Link, useParams } from "react-router";
import { ArrowLeft, Mic, MicOff, Volume2, LogOut, Hand, Sparkles, UserCheck } from "lucide-react";

const avatarColors = [
  "bg-[#f3e8ff] text-[#9333ea]",
  "bg-[#dbeafe] text-[#2563eb]",
  "bg-[#fef9c3] text-[#ca8a04]",
  "bg-[#fce7f3] text-[#db2777]",
  "bg-[#dcfce7] text-[#16a34a]",
  "bg-[#ffedd5] text-[#ea580c]",
];

type Participant = {
  id: number;
  name: string;
  speaking: boolean;
  muted: boolean;
  role: 'owner' | 'moderator' | 'listener';
  handRaised?: boolean;
  avatar: string;
};

// Mock Participants with Roles
const participants: Participant[] = [
  { id: 1, name: "Dr. Sarah Polson", speaking: true, muted: false, role: 'owner', avatar: "👩‍⚕️" },
  { id: 2, name: "Anonymous Panda", speaking: false, muted: false, role: 'moderator', avatar: "🐼" },
  { id: 3, name: "Gentle Wave", speaking: false, muted: false, role: 'listener', avatar: "🌊" },
  { id: 4, name: "Peaceful Cloud", speaking: false, muted: true, role: 'listener', handRaised: true, avatar: "☁️" },
  { id: 5, name: "Kind Heart", speaking: false, muted: true, role: 'listener', avatar: "💝" },
  { id: 6, name: "Brave Soul", speaking: false, muted: true, role: 'listener', avatar: "🦁" },
  { id: 7, name: "Calm Spirit", speaking: false, muted: true, role: 'listener', avatar: "🕊️" },
  { id: 8, name: "Wise Owl", speaking: false, muted: true, role: 'listener', avatar: "🦉" },
];

export function AudioRoomPage() {
  const { id } = useParams();
  const [isMuted, setIsMuted] = useState(true);
  const [handRaised, setHandRaised] = useState(false);

  // Filter participants
  const speakers = participants.filter(p => p.role === 'owner' || p.role === 'moderator' || p.speaking); // Simplified for mock: owners/mods are "on stage"
  const listeners = participants.filter(p => !speakers.includes(p));

  return (
    <div className="h-full flex flex-col relative bg-gradient-to-b from-[var(--buttery-yellow)]/10 via-white to-white">
      {/* Header */}
      <div className="shrink-0 z-10 bg-white/80 backdrop-blur-md p-4 flex items-center justify-between border-b border-border/50">
        <Link to="/clubhouse" className="p-2 -ml-2 rounded-full hover:bg-muted transition-colors">
          <ArrowLeft className="w-5 h-5" />
        </Link>
        <div className="flex-1 text-center">
          <h1 className="text-sm font-semibold truncate max-w-[200px] mx-auto">Dealing with Burnout</h1>
          <p className="text-[10px] text-muted-foreground">{participants.length} people here</p>
        </div>
        <button className="p-2 -mr-2 text-[#ef4444] rounded-full hover:bg-[#fef2f2] transition-colors">
          <LogOut className="w-5 h-5" />
        </button>
      </div>

      <div className="flex-1 overflow-y-auto p-6 space-y-6 pb-32 scrollbar-hide">

        {/* Sharing Space (Stage) */}
        <div>
          <div className="flex items-center gap-2 mb-4 px-2">
            <Sparkles className="w-4 h-4 text-[var(--sky-blue)]" />
            <h3 className="font-medium text-sm text-muted-foreground">Sharing Space</h3>
          </div>
          <div className="grid grid-cols-3 gap-y-6 gap-x-4">
            {speakers.map((participant, i) => (
              <div key={participant.id} className="flex flex-col items-center gap-2 relative group">
                <div className="relative">
                  <div
                    className={`w-20 h-20 rounded-full ${avatarColors[i % avatarColors.length]} flex items-center justify-center ring-4 ring-offset-2 ring-[var(--sky-blue)]/20 shadow-sm`}
                  >
                    <span className="text-3xl">{participant.avatar}</span>
                  </div>
                  {/* Role Badge */}
                  <div className="absolute -top-1 -right-1 px-1.5 py-0.5 bg-[#262626] text-white text-[9px] rounded-full flex items-center gap-1 shadow-md">
                    {participant.role === 'owner' && <Sparkles className="w-2.5 h-2.5" />}
                    {participant.role === 'moderator' && <UserCheck className="w-2.5 h-2.5" />}
                    <span className="capitalize">{participant.role}</span>
                  </div>

                  {participant.speaking && (
                    <div className="absolute -bottom-1 -right-1 w-7 h-7 rounded-full bg-[var(--mint-green)] border-2 border-white flex items-center justify-center shadow-md animate-pulse">
                      <Mic className="w-3.5 h-3.5 text-white" />
                    </div>
                  )}
                </div>
                <p className="text-sm font-semibold text-foreground text-center leading-tight">
                  {participant.name}
                </p>
              </div>
            ))}
          </div>
        </div>

        {/* Listeners */}
        <div className="bg-muted/30 rounded-[2rem] p-6">
          <h3 className="font-medium text-sm text-muted-foreground mb-4">Listeners ({listeners.length})</h3>
          <div className="grid grid-cols-4 gap-4">
            {listeners.map((participant, i) => (
              <div key={participant.id} className="flex flex-col items-center gap-2">
                <div className="relative">
                  <div
                    className={`w-14 h-14 rounded-full bg-white border border-border flex items-center justify-center shadow-sm`}
                  >
                    <span className="text-2xl opacity-80">{participant.avatar}</span>
                  </div>
                  {participant.handRaised && (
                    <div className="absolute -top-2 -right-1 w-6 h-6 rounded-full bg-[var(--buttery-yellow)] border-2 border-white flex items-center justify-center shadow-md animate-bounce">
                      <Hand className="w-3 h-3 text-[#a16207]" />
                    </div>
                  )}
                </div>
                <p className="text-[10px] text-muted-foreground text-center truncate w-full px-1">
                  {participant.name}
                </p>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Bottom Controls */}
      <div className="absolute bottom-4 left-0 right-0 p-4 pointer-events-none">
        <div className="max-w-[350px] mx-auto flex items-center justify-between gap-4 pointer-events-auto">
          <button
            onClick={() => setIsMuted(!isMuted)}
            className={`flex-1 h-14 rounded-full flex items-center justify-center gap-2 transition-all shadow-lg ${isMuted ? 'bg-white text-foreground' : 'bg-[#262626] text-white'}`}
          >
            {isMuted ? <MicOff className="w-5 h-5" /> : <Mic className="w-5 h-5" />}
            <span className="font-medium">{isMuted ? 'Muted' : 'Speaking'}</span>
          </button>

          <button
            onClick={() => setHandRaised(!handRaised)}
            className={`h-14 w-14 rounded-full flex items-center justify-center shadow-lg transition-all ${handRaised ? 'bg-[var(--buttery-yellow)] text-[#854d0e]' : 'bg-white text-foreground'}`}
          >
            <Hand className="w-6 h-6" />
          </button>
        </div>
      </div>
    </div>
  );
}
