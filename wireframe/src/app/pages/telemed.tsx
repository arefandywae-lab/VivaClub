import { Link } from "react-router";
import { Star, Calendar, Shield } from "lucide-react";

const doctors = [
  {
    id: "1",
    name: "Dr. Sarah Johnson",
    specialty: "Clinical Psychologist",
    experience: "12 years",
    rating: 4.9,
    reviews: 234,
    availability: "Available Today",
    image: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&h=400&fit=crop",
  },
  {
    id: "2",
    name: "Dr. Michael Chen",
    specialty: "Psychiatrist",
    experience: "15 years",
    rating: 4.8,
    reviews: 189,
    availability: "Next available: Tomorrow",
    image: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400&h=400&fit=crop",
  },
  {
    id: "3",
    name: "Dr. Emily Rodriguez",
    specialty: "Anxiety & Depression Specialist",
    experience: "8 years",
    rating: 4.9,
    reviews: 156,
    availability: "Available Today",
    image: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=400&h=400&fit=crop",
  },
  {
    id: "4",
    name: "Dr. James Thompson",
    specialty: "Trauma Counselor",
    experience: "10 years",
    rating: 4.7,
    reviews: 142,
    availability: "Available Today",
    image: "https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&h=400&fit=crop",
  },
];

export function TelemedPage() {
  return (
    <div className="h-full overflow-y-auto pb-24 bg-background scrollbar-hide">
      <div className="max-w-screen-lg mx-auto">
        {/* Header */}
        <div className="bg-gradient-to-r from-[var(--sky-blue)] to-[var(--mint-green)] p-6 text-white">
          <div className="flex items-center gap-2 mb-2">
            <Shield className="w-5 h-5" />
            <span className="text-sm font-medium">Secure End-to-End Encrypted</span>
          </div>
          <h1 className="text-3xl font-semibold mb-2">Professional Care</h1>
          <p className="text-white/90">Connect with verified mental health specialists</p>
        </div>

        {/* Filters */}
        <div className="p-4 bg-card border-b border-border">
          <div className="flex gap-2 overflow-x-auto pb-2">
            <button className="px-4 py-2 bg-[var(--sky-blue)] text-white rounded-[1rem] text-sm font-medium whitespace-nowrap">
              All Specialists
            </button>
            <button className="px-4 py-2 bg-muted text-foreground rounded-[1rem] text-sm font-medium whitespace-nowrap hover:bg-muted/80">
              Psychologists
            </button>
            <button className="px-4 py-2 bg-muted text-foreground rounded-[1rem] text-sm font-medium whitespace-nowrap hover:bg-muted/80">
              Psychiatrists
            </button>
            <button className="px-4 py-2 bg-muted text-foreground rounded-[1rem] text-sm font-medium whitespace-nowrap hover:bg-muted/80">
              Counselors
            </button>
          </div>
        </div>

        {/* Doctor List */}
        <div className="p-4 space-y-4">
          {doctors.map((doctor) => (
            <Link
              key={doctor.id}
              to={`/doctor-profile?id=${doctor.id}`} // Using query param correctly for re-used profile page
              className="block bg-card rounded-[1.5rem] p-5 border border-border shadow-sm hover:shadow-md transition-all"
            >
              <div className="flex gap-4">
                <img
                  src={doctor.image}
                  alt={doctor.name}
                  className="w-20 h-20 rounded-[1rem] object-cover"
                />
                <div className="flex-1 min-w-0">
                  <h3 className="font-semibold text-foreground mb-1">{doctor.name}</h3>
                  <p className="text-sm text-[var(--sky-blue)] mb-2">{doctor.specialty}</p>
                  <div className="flex items-center gap-4 text-xs text-muted-foreground mb-2">
                    <span>{doctor.experience} experience</span>
                    <div className="flex items-center gap-1">
                      <Star className="w-3 h-3 fill-[var(--buttery-yellow)] text-[var(--buttery-yellow)]" />
                      <span>{doctor.rating}</span>
                      <span>({doctor.reviews})</span>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <Calendar className="w-4 h-4 text-[var(--mint-green)]" />
                    <span className="text-sm font-medium text-[var(--mint-green)]">
                      {doctor.availability}
                    </span>
                  </div>
                </div>
              </div>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}
