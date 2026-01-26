import { useState } from "react";
import { Calendar, Video, FileText, ChevronRight, Star, AlertCircle } from "lucide-react";

type Tab = 'appointments' | 'history';

const appointments = [
    {
        id: 1,
        doctor: "Dr. Sarah Polson",
        specialty: "Psychiatrist",
        date: "Today, 2:30 PM",
        type: "Video Call",
        status: "confirmed",
        avatar: "👩‍⚕️"
    },
    {
        id: 2,
        doctor: "Dr. James Wilson",
        specialty: "Therapist",
        date: "Jan 28, 10:00 AM",
        type: "Voice Call",
        status: "pending",
        avatar: "👨‍⚕️"
    }
];

const history = [
    {
        id: 3,
        doctor: "Dr. Sarah Polson",
        specialty: "Psychiatrist",
        date: "Jan 15, 2024",
        notes: "Follow-up required in 2 weeks",
        rating: 5,
        avatar: "👩‍⚕️"
    },
    {
        id: 4,
        doctor: "Dr. Emily Chen",
        specialty: "Clinical Psychologist",
        date: "Dec 20, 2023",
        notes: "Initial consultation completed",
        rating: 5,
        avatar: "👩‍⚕️"
    }
];

export function ProfilePage() {
    const [activeTab, setActiveTab] = useState<Tab>('appointments');

    return (
        <div className="h-full overflow-y-auto pb-24 bg-background scrollbar-hide">
            {/* Profile Header */}
            <div className="bg-gradient-to-b from-[var(--sky-blue)]/20 to-background p-6 pt-10">
                <div className="flex items-center gap-4 mb-6">
                    <div className="w-20 h-20 rounded-full bg-gradient-to-br from-[var(--sky-blue)] to-[var(--mint-green)] p-1">
                        <div className="w-full h-full rounded-full bg-white flex items-center justify-center">
                            <span className="text-3xl">🐼</span>
                        </div>
                    </div>
                    <div>
                        <h1 className="text-2xl font-bold text-foreground">Anonymous Panda</h1>
                        <p className="text-sm text-muted-foreground">Member since Jan 2024</p>
                    </div>
                </div>

                {/* Quick Stats */}
                <div className="flex gap-4 mb-2">
                    <div className="flex-1 bg-white/50 backdrop-blur-sm rounded-2xl p-3 border border-border/50">
                        <p className="text-xs text-muted-foreground uppercase font-bold tracking-wider">Mood</p>
                        <div className="flex items-center gap-2 mt-1">
                            <span className="text-xl">🙂</span>
                            <span className="text-sm font-medium">Good</span>
                        </div>
                    </div>
                    <div className="flex-1 bg-white/50 backdrop-blur-sm rounded-2xl p-3 border border-border/50">
                        <p className="text-xs text-muted-foreground uppercase font-bold tracking-wider">Streak</p>
                        <div className="flex items-center gap-2 mt-1">
                            <span className="text-xl">🔥</span>
                            <span className="text-sm font-medium">5 Days</span>
                        </div>
                    </div>
                </div>
            </div>

            <div className="px-4">
                {/* Tabs */}
                <div className="flex p-1 bg-muted/50 rounded-2xl mb-6">
                    <button
                        onClick={() => setActiveTab('appointments')}
                        className={`flex-1 py-3 text-sm font-medium rounded-xl transition-all ${activeTab === 'appointments'
                            ? "bg-white text-foreground shadow-sm"
                            : "text-muted-foreground hover:text-foreground"
                            }`}
                    >
                        Upcoming
                    </button>
                    <button
                        onClick={() => setActiveTab('history')}
                        className={`flex-1 py-3 text-sm font-medium rounded-xl transition-all ${activeTab === 'history'
                            ? "bg-white text-foreground shadow-sm"
                            : "text-muted-foreground hover:text-foreground"
                            }`}
                    >
                        History
                    </button>
                </div>

                {/* Content */}
                {/* Content */}
                <div className="space-y-4 animate-in fade-in slide-in-from-bottom-2 duration-300">
                    {activeTab === 'appointments' ? (
                        <>
                            {/* Upcoming Alert */}
                            <div className="bg-[var(--buttery-yellow)]/10 border border-[var(--buttery-yellow)]/30 rounded-2xl p-4 flex items-start gap-3">
                                <AlertCircle className="w-5 h-5 text-[#f97316] shrink-0 mt-0.5" />
                                <div>
                                    <h4 className="text-sm font-semibold text-foreground">Upcoming Session</h4>
                                    <p className="text-xs text-muted-foreground mt-1">
                                        You have a session starting in 15 minutes. Please find a quiet space.
                                    </p>
                                </div>
                            </div>

                            {appointments.map((apt) => (
                                <div key={apt.id} className="bg-card rounded-2xl p-5 border border-border shadow-sm">
                                    <div className="flex justify-between items-start mb-4">
                                        <div className="flex gap-3">
                                            <div className="w-12 h-12 rounded-full bg-muted flex items-center justify-center text-2xl">
                                                {apt.avatar}
                                            </div>
                                            <div>
                                                <h3 className="font-semibold text-foreground">{apt.doctor}</h3>
                                                <p className="text-xs text-muted-foreground">{apt.specialty}</p>
                                            </div>
                                        </div>
                                        {apt.status === 'confirmed' && (
                                            <div className="bg-[#dcfce7] text-[#15803d] text-[10px] font-bold px-2 py-1 rounded-full uppercase">
                                                Confirmed
                                            </div>
                                        )}
                                    </div>

                                    <div className="space-y-3 mb-4">
                                        <div className="flex items-center gap-3 text-sm text-foreground/80">
                                            <Calendar className="w-4 h-4 text-muted-foreground" />
                                            {apt.date}
                                        </div>
                                        <div className="flex items-center gap-3 text-sm text-foreground/80">
                                            <Video className="w-4 h-4 text-muted-foreground" />
                                            {apt.type}
                                        </div>
                                    </div>

                                    <button className="w-full py-3 bg-[var(--sky-blue)] text-white rounded-xl font-medium shadow-md hover:brightness-95 transition-all active:scale-[0.98]">
                                        Join Session
                                    </button>
                                </div>
                            ))}
                        </>
                    ) : (
                        <>
                            <div className="flex items-center justify-between mb-2 px-1">
                                <h3 className="text-sm font-semibold text-foreground">Past Consultations</h3>
                                <button className="text-xs text-[var(--sky-blue)] font-medium">Download All</button>
                            </div>

                            {history.map((record) => (
                                <div key={record.id} className="bg-card rounded-2xl p-5 border border-border shadow-sm group">
                                    <div className="flex justify-between items-start mb-3">
                                        <div className="flex gap-3">
                                            <div className="w-10 h-10 rounded-full bg-muted flex items-center justify-center text-xl grayscale group-hover:grayscale-0 transition-all">
                                                {record.avatar}
                                            </div>
                                            <div>
                                                <h3 className="font-medium text-foreground">{record.doctor}</h3>
                                                <p className="text-xs text-muted-foreground">{record.date}</p>
                                            </div>
                                        </div>
                                        <div className="flex items-center gap-1 text-[#facc15]">
                                            <Star className="w-3 h-3 fill-current" />
                                            <span className="text-xs font-bold text-foreground">{record.rating}.0</span>
                                        </div>
                                    </div>

                                    <div className="bg-muted/30 rounded-xl p-3 mb-3">
                                        <div className="flex items-start gap-2">
                                            <FileText className="w-4 h-4 text-muted-foreground shrink-0 mt-0.5" />
                                            <p className="text-xs text-muted-foreground italic">"{record.notes}"</p>
                                        </div>
                                    </div>

                                    <button className="w-full py-2 border border-border rounded-lg text-xs font-medium hover:bg-muted transition-colors flex items-center justify-center gap-2">
                                        View Summary
                                        <ChevronRight className="w-3 h-3" />
                                    </button>
                                </div>
                            ))}
                        </>
                    )}

                    {/* Logout Button */}
                    <div className="pt-8 pb-4">
                        <button
                            onClick={() => { window.location.href = '/'; }}
                            className="w-full py-3 border border-[#fecaca] text-[#ef4444] rounded-xl font-medium hover:bg-[#fef2f2] transition-colors"
                        >
                            Log Out
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}
