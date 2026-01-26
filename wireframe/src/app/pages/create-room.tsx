import { useState } from "react";
import { useNavigate, Link } from "react-router";
import { ArrowLeft, Mic, Sparkles } from "lucide-react";

const categories = [
    { id: 'anxiety', name: 'Anxiety', icon: '😰', color: 'bg-orange-50 border-orange-200' },
    { id: 'burnout', name: 'Burnout', icon: '😫', color: 'bg-red-50 border-red-200' },
    { id: 'relationships', name: 'Relationships', icon: '❤️', color: 'bg-pink-50 border-pink-200' },
    { id: 'depression', name: 'Depression', icon: '🌧️', color: 'bg-blue-50 border-blue-200' },
    { id: 'sleep', name: 'Sleep', icon: '😴', color: 'bg-indigo-50 border-indigo-200' },
    { id: 'general', name: 'General', icon: '🌟', color: 'bg-yellow-50 border-yellow-200' },
];

export function CreateRoomPage() {
    const navigate = useNavigate();
    const [topic, setTopic] = useState("");
    const [selectedCategory, setSelectedCategory] = useState("general");

    const handleCreate = () => {
        if (!topic.trim()) return;
        // simulating room creation with a random ID
        const randomId = Math.random().toString(36).substring(7);
        navigate(`/room/${randomId}`);
    };

    return (
        <div className="h-full flex flex-col bg-background">
            {/* Header */}
            <div className="shrink-0 p-4 flex items-center gap-4 border-b border-border/50">
                <Link to="/clubhouse" className="p-2 -ml-2 rounded-full hover:bg-muted transition-colors">
                    <ArrowLeft className="w-5 h-5" />
                </Link>
                <h1 className="text-xl font-bold">Start a Room</h1>
            </div>

            <div className="flex-1 overflow-y-auto p-6 space-y-8 scrollbar-hide">

                {/* Topic Input */}
                <div className="space-y-3">
                    <label className="text-sm font-medium text-muted-foreground uppercase tracking-wider">
                        What's the topic?
                    </label>
                    <textarea
                        value={topic}
                        onChange={(e) => setTopic(e.target.value)}
                        placeholder="e.g., Struggling with Monday anxiety..."
                        className="w-full h-32 p-4 text-xl font-medium bg-muted/30 rounded-[1.5rem] border-2 border-transparent focus:border-[var(--sky-blue)] focus:bg-white transition-all resize-none placeholder:text-muted-foreground/50 outline-none"
                        autoFocus
                    />
                </div>

                {/* Category Selection */}
                <div className="space-y-3">
                    <label className="text-sm font-medium text-muted-foreground uppercase tracking-wider">
                        Select a Topic
                    </label>
                    <div className="grid grid-cols-2 gap-3">
                        {categories.map((cat) => (
                            <button
                                key={cat.id}
                                onClick={() => setSelectedCategory(cat.id)}
                                className={`p-3 rounded-xl border-2 text-left transition-all flex items-center gap-3 ${selectedCategory === cat.id
                                        ? `${cat.color} border-current ring-1 ring-offset-2 ring-current`
                                        : "bg-white border-border hover:border-gray-300"
                                    }`}
                            >
                                <span className="text-xl">{cat.icon}</span>
                                <span className="font-medium text-sm text-foreground">{cat.name}</span>
                            </button>
                        ))}
                    </div>
                </div>
            </div>

            {/* Footer / Go Live Button */}
            <div className="p-6 bg-background border-t border-border/50">
                <button
                    onClick={handleCreate}
                    disabled={!topic.trim()}
                    className="w-full py-4 bg-gradient-to-r from-[var(--buttery-yellow)] to-[var(--cotton-pink)] text-[#2d3748] rounded-[1.5rem] font-bold text-lg shadow-lg hover:shadow-xl hover:brightness-95 disabled:opacity-50 disabled:shadow-none transition-all active:scale-[0.98] flex items-center justify-center gap-2"
                >
                    <Sparkles className="w-5 h-5" />
                    Go Live Now
                </button>
            </div>
        </div>
    );
}
