import { useState } from "react";
import { Link, useParams } from "react-router";
import {
    X,
    Mic,
    Video as VideoIcon,
    MoreVertical,
    ShieldAlert,
    FileText,
    User,
    MessageSquare,
    AlertTriangle,
    Send
} from "lucide-react";

type Tab = 'notes' | 'patient' | 'chat';

export function DoctorExamRoomMobile() {
    const { id } = useParams();
    const [activeTab, setActiveTab] = useState<Tab>('patient');
    const [notes, setNotes] = useState("");
    const [isMicOn, setIsMicOn] = useState(true);
    const [isVideoOn, setIsVideoOn] = useState(true);

    return (
        <div className="h-full flex flex-col bg-[#0f172a] text-white">

            {/* 1. Sticky Video Area (Top 45%) */}
            <div className="h-[45%] bg-black relative shrink-0">
                <img
                    src="https://images.unsplash.com/photo-1544005313-94ddf0286df2?fit=crop&w=800&q=80"
                    alt="Patient"
                    className="w-full h-full object-cover opacity-90"
                />

                {/* Overlays */}
                {/* Recording Removed per user request */}

                {/* Doctor Self-View - Moved to Top Right to avoid clutter */}
                <div className="absolute top-16 right-4 w-24 h-32 bg-slate-800 rounded-xl overflow-hidden border-2 border-slate-700 shadow-xl z-20">
                    <div className="w-full h-full flex items-center justify-center bg-slate-900">
                        <User className="w-8 h-8 text-slate-600" />
                    </div>
                </div>

                {/* Floating Actions */}
                <div className="absolute bottom-4 left-1/2 -translate-x-1/2 flex gap-3">
                    <button
                        onClick={() => setIsMicOn(!isMicOn)}
                        className={`p-4 rounded-full backdrop-blur-md transition-colors ${isMicOn ? 'bg-white/20 text-white hover:bg-white/30' : 'bg-red-500 text-white'}`}
                    >
                        <Mic className="w-6 h-6" />
                    </button>
                    <button
                        onClick={() => setIsVideoOn(!isVideoOn)}
                        className={`p-4 rounded-full backdrop-blur-md transition-colors ${isVideoOn ? 'bg-white/20 text-white hover:bg-white/30' : 'bg-red-500 text-white'}`}
                    >
                        <VideoIcon className="w-6 h-6" />
                    </button>
                    <Link to="/doctor/dashboard" className="p-4 bg-red-600 rounded-full text-white shadow-lg shadow-red-900/40 hover:bg-red-700 transition-colors">
                        <X className="w-6 h-6" />
                    </Link>
                </div>
            </div>

            {/* 2. Interactive Panel (Bottom 55%) */}
            <div className="flex-1 bg-slate-50 rounded-t-[2rem] relative z-10 flex flex-col overflow-hidden">

                {/* Tabs */}
                <div className="flex p-2 bg-white border-b border-slate-200">
                    {[
                        { id: 'patient', icon: User, label: 'Profile' },
                        { id: 'notes', icon: FileText, label: 'OPD Note' },
                        { id: 'chat', icon: MessageSquare, label: 'Chat' },
                    ].map(tab => (
                        <button
                            key={tab.id}
                            onClick={() => setActiveTab(tab.id as Tab)}
                            className={`flex-1 py-3 rounded-xl flex items-center justify-center gap-2 text-sm font-medium transition-all ${activeTab === tab.id
                                ? 'bg-[#0f172a] text-white shadow-md'
                                : 'text-slate-500 hover:bg-slate-100'
                                }`}
                        >
                            <tab.icon className="w-4 h-4" />
                            {tab.label}
                        </button>
                    ))}
                </div>

                {/* Tab Content */}
                <div className="flex-1 overflow-y-auto p-4 text-slate-800">
                    {activeTab === 'patient' && (
                        <div className="space-y-4">
                            <div className="bg-orange-50 border border-orange-100 p-4 rounded-xl flex items-start gap-3">
                                <AlertTriangle className="w-5 h-5 text-orange-600 shrink-0" />
                                <div>
                                    <h4 className="text-sm font-bold text-orange-900">Risk Assessment</h4>
                                    <p className="text-xs text-orange-800 mt-1">High PHQ-9 Score (19/27). History of self-harm. Please monitor closely.</p>
                                </div>
                            </div>

                            <div className="bg-white border border-slate-200 p-4 rounded-xl space-y-3">
                                <div className="flex justify-between border-b border-slate-100 pb-2">
                                    <span className="text-xs text-slate-500 uppercase tracking-wider">Patient Name</span>
                                    <span className="text-sm font-bold">Anonymous Panda</span>
                                </div>
                                <div className="flex justify-between border-b border-slate-100 pb-2">
                                    <span className="text-xs text-slate-500 uppercase tracking-wider">Confirmed User</span>
                                    <span className="text-sm font-bold text-green-600">Yes (ID Verified)</span>
                                </div>
                                <div className="flex justify-between">
                                    <span className="text-xs text-slate-500 uppercase tracking-wider">Last Visit</span>
                                    <span className="text-sm font-bold">Jan 12, 2024</span>
                                </div>
                            </div>

                            <button className="w-full py-3 border-2 border-red-100 text-red-600 rounded-xl font-bold flex items-center justify-center gap-2 mt-4 hover:bg-red-50 transition-colors">
                                <ShieldAlert className="w-5 h-5" />
                                Report & End Session
                            </button>
                            <p className="text-[10px] text-center text-slate-400">Use this if patient violates conduct rules.</p>
                        </div>
                    )}

                    {activeTab === 'notes' && (
                        <div className="h-full flex flex-col">
                            <textarea
                                className="flex-1 w-full bg-white border border-slate-200 rounded-xl p-4 text-sm leading-relaxed focus:outline-none focus:ring-2 focus:ring-[#0d9488] resize-none"
                                placeholder="Type OPD notes here... (Auto-saved)"
                                value={notes}
                                onChange={(e) => setNotes(e.target.value)}
                            />
                            <div className="flex justify-between items-center mt-2 text-xs text-slate-500">
                                <span>{notes.length} chars</span>
                                <span className="text-[#0d9488] font-medium flex items-center gap-1">
                                    Saved <span className="w-1.5 h-1.5 bg-[#0d9488] rounded-full" />
                                </span>
                            </div>
                        </div>
                    )}

                    {activeTab === 'chat' && (
                        <div className="h-full flex flex-col justify-end">
                            <div className="space-y-3 mb-4">
                                <div className="flex justify-start">
                                    <div className="bg-slate-200 text-slate-800 px-3 py-2 rounded-2xl rounded-tl-none text-sm max-w-[80%]">
                                        Hello doctor, can you hear me?
                                    </div>
                                </div>
                                <div className="flex justify-end">
                                    <div className="bg-[#0d9488] text-white px-3 py-2 rounded-2xl rounded-tr-none text-sm max-w-[80%]">
                                        Yes, loud and clear. How are you today?
                                    </div>
                                </div>
                            </div>
                            <div className="relative">
                                <input
                                    type="text"
                                    placeholder="Type a message..."
                                    className="w-full pl-4 pr-10 py-3 bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-1 focus:ring-[#0d9488]"
                                />
                                <button className="absolute right-2 top-1/2 -translate-y-1/2 p-1.5 bg-[#0d9488] text-white rounded-lg">
                                    <Send className="w-3 h-3" />
                                </button>
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}
