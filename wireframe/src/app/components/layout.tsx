import { Outlet, useLocation, Link } from "react-router";
import { Home, Video, Users, User } from "lucide-react";

export function Layout() {
  const location = useLocation();

  // Hide nav on specific pages (e.g. login, welcome, landing, exam room)
  const hideNavRoutes = ['/', '/login', '/assessment', '/doctor/login'];

  // Check if we are in doctor mode
  const isDoctorRoute = location.pathname.startsWith('/doctor');

  // For doctor exam room, we might want no nav at all
  const isDoctorExamRoom = location.pathname.startsWith('/doctor/room/');
  const isPatientCallRoom = location.pathname.startsWith('/telemed/room/');

  const showNav = !hideNavRoutes.includes(location.pathname) && !isDoctorExamRoom && !isPatientCallRoom;

  return (
    <div className="min-h-screen bg-gray-100 flex justify-center items-center p-4">
      {/* Mobile Device Frame */}
      <div id="mobile-frame" className="w-full max-w-[390px] h-[844px] bg-background flex flex-col rounded-[2.5rem] overflow-hidden shadow-2xl border-[8px] border-gray-800 relative ring-4 ring-gray-200/50">

        {/* Main Content Area - Layout handles the container, Pages handle the Scroll */}
        <div className="flex-1 relative overflow-hidden flex flex-col">
          <Outlet />
        </div>

        {showNav && (isDoctorRoute ? (
          /* Doctor Navigation */
          <nav className="bg-[#0f172a] border-t border-slate-700 shrink-0 pb-6 pt-2 z-50">
            <div className="flex justify-around px-4">
              <Link
                to="/doctor/dashboard"
                className={`flex flex-col items-center gap-1 p-2 ${location.pathname === "/doctor/dashboard" ? "text-[#0d9488]" : "text-slate-400"}`}
              >
                <Home className="w-6 h-6" />
                <span className="text-[10px] font-medium">Command</span>
              </Link>
              <Link
                to="/doctor/patients"
                className={`flex flex-col items-center gap-1 p-2 ${location.pathname === "/doctor/patients" ? "text-[#0d9488]" : "text-slate-400"}`}
              >
                <Users className="w-6 h-6" />
                <span className="text-[10px] font-medium">Patients</span>
              </Link>
              <Link
                to="/doctor/clubhouse"
                className={`flex flex-col items-center gap-1 p-2 ${location.pathname.startsWith("/doctor/clubhouse") ||
                  location.pathname.startsWith("/doctor/room")
                  ? "text-[var(--mint-green)]" : "text-slate-400"}`}
              >
                <Users className="w-6 h-6" />
                <span className="text-[10px] font-medium">Clubhouse</span>
              </Link>
              <Link
                to="/doctor/profile"
                className={`flex flex-col items-center gap-1 p-2 ${location.pathname === "/doctor/profile" ? "text-[#0d9488]" : "text-slate-400"}`}
              >
                <User className="w-6 h-6" />
                <span className="text-[10px] font-medium">Profile</span>
              </Link>
            </div>
          </nav>
        ) : (
          /* Patient Navigation */
          <nav className="bg-card border-t border-border shrink-0 pb-6 pt-2 z-50">
            <div className="flex justify-around px-4">
              <Link
                to="/dashboard"
                className={`flex flex-col items-center gap-1 transition-colors p-2 ${location.pathname === "/dashboard"
                  ? "text-[var(--sky-blue)]"
                  : "text-muted-foreground hover:text-foreground"
                  }`}
              >
                <Home className="w-6 h-6" />
                <span className="text-[10px] font-medium">Home</span>
              </Link>

              <Link
                to="/telemed"
                className={`flex flex-col items-center gap-1 transition-colors p-2 ${location.pathname.startsWith("/telemed") ||
                  location.pathname.startsWith("/doctor") && !location.pathname.startsWith("/doctor/login") && !location.pathname.startsWith("/doctor/dashboard")
                  || location.pathname.startsWith("/chat")
                  ? "text-[var(--sky-blue)]"
                  : "text-muted-foreground hover:text-foreground"
                  }`}
              >
                <Video className="w-6 h-6" />
                <span className="text-[10px] font-medium">Telemed</span>
              </Link>

              <Link
                to="/clubhouse"
                className={`flex flex-col items-center gap-1 transition-colors p-2 ${location.pathname.startsWith("/clubhouse") ||
                  location.pathname.startsWith("/room")
                  ? "text-[var(--mint-green)]"
                  : "text-muted-foreground hover:text-foreground"
                  }`}
              >
                <Users className="w-6 h-6" />
                <span className="text-[10px] font-medium">Clubhouse</span>
              </Link>

              <Link
                to="/profile"
                className={`flex flex-col items-center gap-1 transition-colors p-2 ${location.pathname === "/profile"
                  ? "text-[var(--sky-blue)]"
                  : "text-muted-foreground hover:text-foreground"
                  }`}
              >
                <User className="w-6 h-6" />
                <span className="text-[10px] font-medium">Profile</span>
              </Link>
            </div>
          </nav>
        ))
        }

        {/* iOS Home Indicator */}
        {showNav && (
          <div className="absolute bottom-1 left-1/2 -translate-x-1/2 w-32 h-1 bg-foreground/20 rounded-full mb-2 pointer-events-none z-50" />
        )}
      </div>
    </div>
  );
}
