import { useState } from "react";
import { Link, useParams } from "react-router";
import {
    X,
    Mic,
    Video as VideoIcon,
    MessageSquare,
    FileText,
    User,
    Send,
    Star,
    ShieldCheck,
    Phone
} from "lucide-react";

type Tab = 'chat' | 'details' | 'notes';

export function PatientVideoCallPage() {
    const { id } = useParams();
    const [activeTab, setActiveTab] = useState<Tab>('chat');
    const [isMicOn, setIsMicOn] = useState(true);
    const [isVideoOn, setIsVideoOn] = useState(true);
    const [message, setMessage] = useState("");

    return (
        <div className="h-full flex flex-col bg-[#f0f9ff]">

            {/* 1. Sticky Video Area (Top 45%) */}
            <div className="h-[45%] bg-black relative shrink-0">
                <img
                    src="https://images.unsplash.com/photo-1559839734-2b71ea197ec2?fit=crop&w=800&q=80"
                    alt="Doctor"
                    className="w-full h-full object-cover opacity-90"
                />

                {/* Overlays */}
                <div className="absolute top-4 left-4 bg-black/40 backdrop-blur-md px-3 py-1 rounded-full text-xs font-medium text-white flex items-center gap-2">
                    <ShieldCheck className="w-3 h-3 text-[#0d9488]" />
                    Encrypted
                </div>

                {/* Patient Self-View - Moved to Top Right */}
                <div className="absolute top-16 right-4 w-24 h-32 bg-slate-800 rounded-xl overflow-hidden border-2 border-white/20 shadow-xl z-20">
                    {/* Mock User Image */}
                    <img
                        src="https://images.unsplash.com/photo-1544005313-94ddf0286df2?fit=crop&w=200&q=80"
                        className="w-full h-full object-cover"
                        alt="Me"
                    />
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
                    <Link to="/telemed" className="p-4 bg-red-500 rounded-full text-white shadow-lg shadow-red-500/40 hover:bg-red-600 transition-colors">
                        <Phone className="w-6 h-6 fill-current rotate-[135deg]" />
                    </Link>
                </div>
            </div>

            {/* 2. Interactive Panel (Bottom 55%) */}
            <div className="flex-1 bg-white rounded-t-[2rem] relative z-10 flex flex-col overflow-hidden shadow-[0_-4px_20px_rgba(0,0,0,0.05)]">

                {/* Tabs */}
                <div className="flex p-2 border-b border-slate-100">
                    {[
                        { id: 'chat', icon: MessageSquare, label: 'Chat' },
                        { id: 'details', icon: User, label: 'Doctor Info' },
                        { id: 'notes', icon: FileText, label: 'My Notes' },
                    ].map(tab => (
                        <button
                            key={tab.id}
                            onClick={() => setActiveTab(tab.id as Tab)}
                            className={`flex-1 py-3 rounded-xl flex items-center justify-center gap-2 text-sm font-medium transition-all ${activeTab === tab.id
                                ? 'bg-[var(--sky-blue)] text-white shadow-md'
                                : 'text-slate-500 hover:bg-slate-50'
                                }`}
                        >
                            <tab.icon className="w-4 h-4" />
                            {tab.label}
                        </button>
                    ))}
                </div>

                {/* Tab Content */}
                <div className="flex-1 overflow-y-auto p-4 text-slate-800 bg-slate-50/50">

                    {activeTab === 'chat' && (
                        <div className="h-full flex flex-col justify-end">
                            <div className="space-y-3 mb-4">
                                <div className="flex justify-start">
                                    <div className="bg-white border border-slate-200 text-slate-800 px-3 py-2 rounded-2xl rounded-tl-none text-sm max-w-[80%] shadow-sm">
                                        Hello! I'm Dr. Sarah. Can you hear me clearly?
                                    </div>
                                </div>
                                <div className="flex justify-start">
                                    <div className="bg-white border border-slate-200 text-slate-800 px-3 py-2 rounded-2xl rounded-tl-none text-sm max-w-[80%] shadow-sm">
                                        We can start whenever you are ready.
                                    </div>
                                </div>
                                <div className="flex justify-end">
                                    <div className="bg-[var(--sky-blue)] text-white px-3 py-2 rounded-2xl rounded-tr-none text-sm max-w-[80%] shadow-sm">
                                        Yes, loud and clear!
                                    </div>
                                </div>
                            </div>
                            <div className="relative">
                                <input
                                    type="text"
                                    placeholder="Type a message..."
                                    value={message}
                                    onChange={(e) => setMessage(e.target.value)}
                                    className="w-full pl-4 pr-10 py-3 bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[var(--sky-blue)] transition-all"
                                />
                                <button className="absolute right-2 top-1/2 -translate-y-1/2 p-1.5 bg-[var(--sky-blue)] text-white rounded-lg hover:bg-sky-500 transition-colors">
                                    <Send className="w-3 h-3" />
                                </button>
                            </div>
                        </div>
                    )}

                    {activeTab === 'details' && (
                        <div className="space-y-4">
                            <div className="bg-white p-4 rounded-2xl border border-slate-100 shadow-sm text-center">
                                <img
                                    src="https://images.unsplash.com/photo-1559839734-2b71ea197ec2?fit=crop&w=200&q=80"
                                    className="w-20 h-20 rounded-full mx-auto mb-3 object-cover border-4 border-slate-50"
                                />
                                <h2 className="text-lg font-bold text-slate-800">Dr. Sarah Johnson</h2>
                                <p className="text-[var(--sky-blue)] font-medium text-sm">Clinical Psychologist</p>

                                <div className="flex justify-center items-center gap-1 mt-2 text-yellow-500 text-sm font-bold">
                                    <Star className="w-4 h-4 fill-current" />
                                    4.9 (1,024 Reviews)
                                </div>
                            </div>

                            <div className="bg-blue-50 p-4 rounded-xl border border-blue-100 text-sm text-blue-800">
                                <h3 className="font-bold mb-1 flex items-center gap-2">
                                    <ShieldCheck className="w-4 h-4" />
                                    Verified Specialist
                                </h3>
                                <p className="opacity-80 text-xs">Dr. Sarah has 12 years of experience in Anxiety & Trauma therapy.</p>
                            </div>
                        </div>
                    )}

                    {activeTab === 'notes' && (
                        <div className="h-full flex flex-col">
                            <p className="text-xs text-slate-500 mb-2 ml-1">Private Personal Notes (Only you can see this)</p>
                            <textarea
                                className="flex-1 w-full bg-white border border-slate-200 rounded-xl p-4 text-sm leading-relaxed focus:outline-none focus:ring-2 focus:ring-[var(--sky-blue)] resize-none"
                                placeholder="Write down things you want to remember from this session..."
                            />
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}
