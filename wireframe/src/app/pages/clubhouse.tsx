import { useState } from "react";
import { Link } from "react-router";
import { Users, Mic, Heart, Plus, ArrowLeft, ShieldCheck, Sparkles } from "lucide-react";

type Category = {
  id: string;
  name: string;
  icon: string;
  color: string;
  borderColor: string;
};

const categories: Category[] = [
  { id: 'all', name: 'All Topics', icon: '🌟', color: 'bg-gradient-to-br from-[#fefce8] to-[#fff7ed]', borderColor: 'border-[#ffedd5]' },
  { id: 'anxiety', name: 'Anxiety', icon: '😰', color: 'bg-gradient-to-br from-[#fff7ed] to-[#fef2f2]', borderColor: 'border-[#ffedd5]' },
  { id: 'burnout', name: 'Burnout', icon: '😫', color: 'bg-gradient-to-br from-[#fef2f2] to-[#fdf2f8]', borderColor: 'border-[#fee2e2]' },
  { id: 'relationships', name: 'Relationships', icon: '❤️', color: 'bg-gradient-to-br from-[#fdf2f8] to-[#fff1f2]', borderColor: 'border-[#fce7f3]' },
  { id: 'depression', name: 'Depression', icon: '🌧️', color: 'bg-gradient-to-br from-[#eff6ff] to-[#ecfeff]', borderColor: 'border-[#dbeafe]' },
  { id: 'sleep', name: 'Sleep', icon: '😴', color: 'bg-gradient-to-br from-[#eef2ff] to-[#f5f3ff]', borderColor: 'border-[#e0e7ff]' },
];

const rooms = [
  {
    id: "official-1",
    topic: "Ask a Psychiatrist: Open Q&A",
    participants: 142,
    gradient: "from-[var(--sky-blue)]/30 to-[var(--mint-green)]/30",
    borderColor: "border-[var(--sky-blue)]/40",
    category: "anxiety",
    isOfficial: true,
    host: "Dr. Sarah Polson",
  },
  {
    id: "1",
    topic: "Dealing with Burnout",
    participants: 24,
    gradient: "from-[var(--buttery-yellow)]/20 to-[var(--cotton-pink)]/20",
    borderColor: "border-[var(--cotton-pink)]/30",
    category: "burnout",
    isOfficial: false,
  },
  {
    id: "2",
    topic: "Anxiety Management Techniques",
    participants: 18,
    gradient: "from-[var(--sky-blue)]/20 to-[var(--mint-green)]/20",
    borderColor: "border-[var(--mint-green)]/30",
    category: "anxiety",
    isOfficial: false,
  },
  {
    id: "3",
    topic: "Grief and Loss Support",
    participants: 12,
    gradient: "from-[var(--cotton-pink)]/20 to-[var(--sky-blue)]/20",
    borderColor: "border-[var(--cotton-pink)]/30",
    category: "relationships",
    isOfficial: false,
  },
  {
    id: "4",
    topic: "Building Self-Confidence",
    participants: 31,
    gradient: "from-[var(--mint-green)]/20 to-[var(--buttery-yellow)]/20",
    borderColor: "border-[var(--buttery-yellow)]/30",
    category: "all",
    isOfficial: false,
  },
  {
    id: "5",
    topic: "Mindfulness & Meditation",
    participants: 45,
    gradient: "from-[var(--sky-blue)]/20 to-[var(--cotton-pink)]/20",
    borderColor: "border-[var(--sky-blue)]/30",
    category: "sleep",
    isOfficial: false,
  },
];

export function ClubhousePage() {
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);

  const filteredRooms = selectedCategory && selectedCategory !== 'all'
    ? rooms.filter(r => r.category === selectedCategory || r.category === 'all')
    : rooms;

  // Sorting: Official rooms first
  filteredRooms.sort((a, b) => Number(b.isOfficial) - Number(a.isOfficial));

  return (
    <div className="h-full flex flex-col relative">
      {/* Header - Fixed at top */}
      <div className="shrink-0 z-10 bg-background/80 backdrop-blur-md border-b border-border/50 p-4">
        {selectedCategory ? (
          <div className="flex items-center gap-2">
            <button
              onClick={() => setSelectedCategory(null)}
              className="p-2 -ml-2 rounded-full hover:bg-muted transition-colors"
            >
              <ArrowLeft className="w-5 h-5" />
            </button>
            <h1 className="text-xl font-semibold capitalize">{categories.find(c => c.id === selectedCategory)?.name || 'Rooms'}</h1>
          </div>
        ) : (
          <div>
            <div className="flex items-center gap-2 mb-1">
              <Heart className="w-5 h-5 text-[var(--cotton-pink)]" fill="currentColor" />
              <span className="text-sm font-medium text-muted-foreground">Safe Space</span>
            </div>
            <h1 className="text-2xl font-bold">Clubhouse</h1>
          </div>
        )}
      </div>

      {/* Scrollable Content Area */}
      <div className="flex-1 overflow-y-auto p-4 space-y-6 pb-24 scrollbar-hide">
        {/* Category Grid (Only show if no category selected) */}
        {!selectedCategory && (
          <div className="space-y-4">
            <div className="bg-[var(--cotton-pink)]/10 rounded-[1.5rem] p-5 border border-[var(--cotton-pink)]/20">
              <h3 className="font-medium text-foreground mb-1">Room Guidelines</h3>
              <p className="text-xs text-muted-foreground">
                This is a safe space. Please be respectful and kind. All conversations are anonymous.
              </p>
            </div>

            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold">Explore Topics</h2>
            </div>
            <div className="grid grid-cols-2 gap-3">
              {categories.map((cat) => (
                <button
                  key={cat.id}
                  onClick={() => setSelectedCategory(cat.id)}
                  className={`flex flex-col items-center justify-center p-4 rounded-[1.5rem] border ${cat.borderColor} ${cat.color} hover:brightness-95 transition-all shadow-sm`}
                >
                  <span className="text-3xl mb-2">{cat.icon}</span>
                  <span className="font-medium text-sm text-foreground/90">{cat.name}</span>
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Room List */}
        {selectedCategory && (
          <div className="space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-300">
            {filteredRooms.map((room) => (
              <Link
                key={room.id}
                to={`/room/${room.id}`}
                className={`block bg-gradient-to-br ${room.gradient} rounded-[1.5rem] p-5 border ${room.borderColor} shadow-sm hover:shadow-md transition-all relative overflow-hidden`}
              >
                {/* Official Badge */}
                {room.isOfficial && (
                  <div className="absolute top-0 right-0 bg-[var(--sky-blue)] text-white text-[10px] font-bold px-3 py-1 rounded-bl-[1rem]">
                    OFFICIAL
                  </div>
                )}

                <div className="flex items-start justify-between mb-3 pr-6">
                  <div>
                    <h3 className="text-lg font-bold text-foreground leading-tight">
                      {room.topic}
                    </h3>
                    {room.isOfficial && (
                      <div className="flex items-center gap-1 mt-1 text-xs font-medium text-[var(--sky-blue)]">
                        <ShieldCheck className="w-3 h-3" />
                        <span>Hosted by {room.host}</span>
                      </div>
                    )}
                  </div>
                </div>

                <div className="flex items-center justify-between mt-4">
                  <div className="flex -space-x-2">
                    {[...Array(3)].map((_, i) => (
                      <div key={i} className="w-6 h-6 rounded-full border-2 border-white bg-[#e5e7eb]" />
                    ))}
                    <div className="w-6 h-6 rounded-full border-2 border-white bg-[#f3f4f6] flex items-center justify-center text-[10px] text-[#6b7280] font-medium z-10">
                      +{room.participants - 3}
                    </div>
                  </div>
                  <div className="flex items-center gap-1.5 text-sm font-medium text-muted-foreground/80 bg-white/40 px-3 py-1 rounded-full">
                    <Users className="w-3.5 h-3.5" />
                    <span>{room.participants}</span>
                  </div>
                </div>
              </Link>
            ))}
          </div>
        )}
      </div>

      {/* Floating Action Button - Outside Scroll Area */}
      {selectedCategory && (
        <div className="absolute bottom-4 right-4 z-20">
          <Link
            to="/clubhouse/create"
            className="flex items-center gap-2 bg-gradient-to-r from-[var(--buttery-yellow)] to-[var(--cotton-pink)] text-[#2d3748] px-5 py-3 rounded-full shadow-xl border border-white/20 font-semibold hover:shadow-2xl transition-transform active:scale-95"
          >
            <Plus className="w-5 h-5" />
            <span>Create Room</span>
          </Link>
        </div>
      )}
    </div>
  );
}
