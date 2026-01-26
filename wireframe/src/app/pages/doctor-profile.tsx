import { Link, useSearchParams } from "react-router";
import { Star, Calendar, Shield, ArrowLeft, Clock, Award, MessageCircle } from "lucide-react";

export function DoctorProfilePage() {
  const [searchParams] = useSearchParams();
  const id = searchParams.get("id") || "1";

  // Mock doctor data
  const doctor = {
    id,
    name: "Dr. Sarah Johnson",
    specialty: "Clinical Psychologist",
    experience: "12 years",
    rating: 4.9,
    reviews: 234,
    image: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&h=400&fit=crop",
    about:
      "Dr. Sarah Johnson is a licensed clinical psychologist specializing in cognitive behavioral therapy and mindfulness-based interventions. She has extensive experience working with anxiety, depression, and stress management.",
    education: [
      "Ph.D. in Clinical Psychology, Stanford University",
      "M.A. in Psychology, UC Berkeley",
    ],
    certifications: ["Licensed Clinical Psychologist", "CBT Certified Therapist"],
  };

  const availableSlots = [
    { time: "10:00 AM", date: "Today" },
    { time: "2:00 PM", date: "Today" },
    { time: "4:30 PM", date: "Today" },
    { time: "9:00 AM", date: "Tomorrow" },
    { time: "11:30 AM", date: "Tomorrow" },
    { time: "3:00 PM", date: "Tomorrow" },
  ];

  return (
    <div className="h-full overflow-y-auto pb-24 bg-background scrollbar-hide">
      {/* Header */}
      <div className="bg-gradient-to-r from-[var(--sky-blue)] to-[var(--mint-green)] p-6 text-white">
        <Link to="/telemed" className="inline-flex items-center gap-2 mb-4 text-white/90 hover:text-white">
          <ArrowLeft className="w-5 h-5" />
          <span>Back</span>
        </Link>
        <div className="flex gap-4">
          <img
            src={doctor.image}
            alt={doctor.name}
            className="w-24 h-24 rounded-[1.5rem] object-cover border-4 border-white/20"
          />
          <div className="flex-1">
            <h1 className="text-2xl font-semibold mb-1">{doctor.name}</h1>
            <p className="text-white/90 mb-2">{doctor.specialty}</p>
            <div className="flex items-center gap-3 text-sm">
              <div className="flex items-center gap-1">
                <Star className="w-4 h-4 fill-[var(--buttery-yellow)] text-[var(--buttery-yellow)]" />
                <span>{doctor.rating}</span>
                <span className="text-white/70">({doctor.reviews} reviews)</span>
              </div>
              <span className="text-white/70">•</span>
              <span>{doctor.experience}</span>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-screen-lg mx-auto p-6 space-y-6">
        {/* Security Badge */}
        <div className="bg-[var(--sky-blue)]/10 rounded-[1.5rem] p-4 border border-[var(--sky-blue)]/20">
          <div className="flex items-center gap-2 text-[var(--sky-blue)]">
            <Shield className="w-5 h-5" />
            <span className="font-medium">Secure End-to-End Encrypted Sessions</span>
          </div>
        </div>

        {/* About */}
        <div className="bg-card rounded-[1.5rem] p-6 border border-border shadow-sm">
          <h2 className="font-semibold text-foreground mb-3">About</h2>
          <p className="text-muted-foreground text-sm leading-relaxed">{doctor.about}</p>
        </div>

        {/* Education & Certifications */}
        <div className="bg-card rounded-[1.5rem] p-6 border border-border shadow-sm space-y-4">
          <div>
            <div className="flex items-center gap-2 mb-3">
              <Award className="w-5 h-5 text-[var(--mint-green)]" />
              <h2 className="font-semibold text-foreground">Education</h2>
            </div>
            <ul className="space-y-2">
              {doctor.education.map((edu, i) => (
                <li key={i} className="text-sm text-muted-foreground flex items-start gap-2">
                  <span className="text-[var(--mint-green)] mt-1">•</span>
                  <span>{edu}</span>
                </li>
              ))}
            </ul>
          </div>
          <div>
            <h3 className="font-medium text-foreground mb-2">Certifications</h3>
            <ul className="space-y-2">
              {doctor.certifications.map((cert, i) => (
                <li key={i} className="text-sm text-muted-foreground flex items-start gap-2">
                  <span className="text-[var(--sky-blue)] mt-1">•</span>
                  <span>{cert}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>

        {/* Available Slots */}
        <div className="bg-card rounded-[1.5rem] p-6 border border-border shadow-sm">
          <div className="flex items-center gap-2 mb-4">
            <Calendar className="w-5 h-5 text-[var(--mint-green)]" />
            <h2 className="font-semibold text-foreground">Available Slots</h2>
          </div>
          <div className="grid grid-cols-2 gap-3">
            {availableSlots.map((slot, i) => (
              <Link
                key={i}
                to={`/appointment/book/${id}?time=${encodeURIComponent(slot.time)}&date=${encodeURIComponent(slot.date)}`}
                className="p-4 bg-[var(--mint-green)]/10 hover:bg-[var(--mint-green)]/20 rounded-[1rem] border border-[var(--mint-green)]/20 transition-colors"
              >
                <div className="flex items-center gap-2 mb-1">
                  <Clock className="w-4 h-4 text-[var(--mint-green)]" />
                  <span className="font-medium text-foreground">{slot.time}</span>
                </div>
                <span className="text-sm text-muted-foreground">{slot.date}</span>
              </Link>
            ))}
          </div>
        </div>

        {/* Actions */}
        <div className="flex gap-3">
          <Link
            to={`/chat/${id}`}
            className="flex-1 py-4 px-6 bg-white border-2 border-[var(--sky-blue)] text-[var(--sky-blue)] text-center rounded-[1.5rem] font-bold shadow-sm hover:bg-[var(--sky-blue)]/5 transition-all flex items-center justify-center gap-2"
          >
            <MessageCircle className="w-5 h-5" />
            Chat
          </Link>
          <Link
            to={`/appointment/book/${id}`}
            className="flex-[2] py-4 px-6 bg-gradient-to-r from-[var(--sky-blue)] to-[var(--mint-green)] text-white text-center rounded-[1.5rem] font-medium shadow-lg hover:shadow-xl transition-all"
          >
            Book Appointment
          </Link>
        </div>
      </div>
    </div>
  );
}
