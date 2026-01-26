import { Link } from "react-router";
import { Video, Users, Heart, Shield, AlertCircle } from "lucide-react";

export function DashboardPage() {
  return (
    <div className="h-full overflow-y-auto pb-24 bg-background scrollbar-hide">
      <div className="max-w-screen-lg mx-auto p-6 space-y-8">
        {/* Header */}
        <div className="space-y-2">
          <h1 className="text-3xl font-semibold text-foreground">Welcome to Viva Club</h1>
          <p className="text-muted-foreground">Your safe space for mental health & community</p>
        </div>

        {/* Quick Actions - SOS */}
        <div className="bg-gradient-to-r from-[#fef2f2] to-[#fdf2f8] rounded-[1.5rem] p-6 border border-[#fee2e2] shadow-sm">
          <div className="flex items-start gap-4">
            <div className="w-12 h-12 rounded-full bg-[#fee2e2] flex items-center justify-center flex-shrink-0">
              <AlertCircle className="w-6 h-6 text-[#ef4444]" />
            </div>
            <div className="flex-1">
              <h3 className="font-medium text-foreground mb-1">Need Immediate Help?</h3>
              <p className="text-sm text-muted-foreground mb-3">
                If you're in crisis, reach out for emergency support
              </p>
              <button className="px-4 py-2 bg-[#ef4444] text-white rounded-[1rem] text-sm font-medium hover:bg-[#dc2626] transition-colors">
                Emergency Help (SOS)
              </button>
            </div>
          </div>
        </div>

        {/* Upcoming Appointment Widget (Dynamic) */}
        {(() => {
          const appointmentStr = localStorage.getItem("upcoming_appointment");
          if (appointmentStr) {
            const appt = JSON.parse(appointmentStr);
            return (
              <div className="bg-white rounded-[1.5rem] p-6 border border-[var(--sky-blue)]/30 shadow-md relative overflow-hidden">
                <div className="absolute top-0 left-0 w-2 h-full bg-[var(--sky-blue)]" />
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <h3 className="tex-lg font-bold text-foreground">Upcoming Session</h3>
                    <p className="text-sm text-[var(--sky-blue)] font-medium">with {appt.doctorName}</p>
                  </div>
                  <span className="px-3 py-1 bg-[var(--sky-blue)]/10 text-[var(--sky-blue)] text-xs font-bold rounded-full">
                    {appt.time} • {appt.date}
                  </span>
                </div>
                <div className="flex gap-3">
                  <Link
                    to={`/telemed/room/${appt.doctorId}`}
                    className="flex-1 py-3 bg-[var(--sky-blue)] text-white text-center rounded-xl font-bold shadow-lg shadow-sky-200"
                  >
                    Join Room
                  </Link>
                  <button className="px-4 py-3 bg-slate-100 text-slate-600 rounded-xl font-medium">
                    Reschedule
                  </button>
                </div>
              </div>
            );
          }
          return null;
        })()}

        {/* Main Features */}
        <div className="grid gap-4">
          {/* Telemedicine Card */}
          <Link
            to="/telemed"
            className="block bg-gradient-to-br from-[var(--sky-blue)]/10 to-[var(--mint-green)]/10 rounded-[1.5rem] p-6 border border-[var(--sky-blue)]/20 shadow-lg hover:shadow-xl transition-all group"
          >
            <div className="flex items-start gap-4">
              <div className="w-14 h-14 rounded-[1rem] bg-gradient-to-br from-[var(--sky-blue)] to-[var(--mint-green)] flex items-center justify-center flex-shrink-0 shadow-md group-hover:scale-110 transition-transform">
                <Video className="w-7 h-7 text-white" />
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <h2 className="text-xl font-semibold text-foreground">Talk to a Specialist</h2>
                  <Shield className="w-4 h-4 text-[var(--sky-blue)]" />
                </div>
                <p className="text-sm text-muted-foreground mb-3">
                  Connect with verified mental health professionals for secure telemedicine consultations
                </p>
                <div className="inline-flex items-center text-sm font-medium text-[var(--sky-blue)] group-hover:gap-2 transition-all">
                  Book Appointment
                  <span className="ml-1 group-hover:ml-2 transition-all">→</span>
                </div>
              </div>
            </div>
          </Link>

          {/* Clubhouse Card */}
          <Link
            to="/clubhouse"
            className="block bg-gradient-to-br from-[var(--buttery-yellow)]/10 to-[var(--cotton-pink)]/10 rounded-[1.5rem] p-6 border border-[var(--cotton-pink)]/20 shadow-lg hover:shadow-xl transition-all group"
          >
            <div className="flex items-start gap-4">
              <div className="w-14 h-14 rounded-[1rem] bg-gradient-to-br from-[var(--buttery-yellow)] to-[var(--cotton-pink)] flex items-center justify-center flex-shrink-0 shadow-md group-hover:scale-110 transition-transform">
                <Users className="w-7 h-7 text-[#2d3748]" />
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <h2 className="text-xl font-semibold text-foreground">Join Anonymous Group</h2>
                  <Heart className="w-4 h-4 text-[var(--cotton-pink)]" fill="var(--cotton-pink)" />
                </div>
                <p className="text-sm text-muted-foreground mb-3">
                  Share experiences safely in anonymous audio rooms with supportive community members
                </p>
                <div className="inline-flex items-center text-sm font-medium text-[var(--cotton-pink)] group-hover:gap-2 transition-all">
                  Explore Rooms
                  <span className="ml-1 group-hover:ml-2 transition-all">→</span>
                </div>
              </div>
            </div>
          </Link>
        </div>

        {/* Daily Check-in */}
        <Link
          to="/assessment"
          className="block bg-card rounded-[1.5rem] p-6 border border-border shadow-sm hover:shadow-md transition-all"
        >
          <div className="flex items-center justify-between">
            <div>
              <h3 className="font-medium text-foreground mb-1">Daily Mood Check-in</h3>
              <p className="text-sm text-muted-foreground">Track your mental wellness journey</p>
            </div>
            <div className="w-10 h-10 rounded-full bg-[var(--buttery-yellow)]/20 flex items-center justify-center">
              <Heart className="w-5 h-5 text-[var(--buttery-yellow)]" />
            </div>
          </div>
        </Link>
      </div>
    </div>
  );
}
