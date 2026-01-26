import { Link } from "react-router";
import { Heart, Shield } from "lucide-react";

export function WelcomePage() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-6 bg-gradient-to-br from-[var(--sky-blue)]/10 via-[var(--mint-green)]/10 to-[var(--buttery-yellow)]/10">
      <div className="max-w-md w-full space-y-8 text-center">
        <div className="flex justify-center">
          <div className="w-24 h-24 rounded-[2rem] bg-gradient-to-br from-[var(--sky-blue)] to-[var(--mint-green)] flex items-center justify-center shadow-lg">
            <Heart className="w-12 h-12 text-white" fill="white" />
          </div>
        </div>

        <div className="space-y-3">
          <h1 className="text-4xl font-semibold text-foreground">Viva Club</h1>
          <p className="text-lg text-muted-foreground">
            Your Safe Space for Mind & Community
          </p>
        </div>

        <div className="bg-card/50 backdrop-blur-sm rounded-[1.5rem] p-6 space-y-4 border border-border shadow-lg">
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-full bg-[var(--sky-blue)]/20 flex items-center justify-center flex-shrink-0">
              <Shield className="w-5 h-5 text-[var(--sky-blue)]" />
            </div>
            <div className="text-left">
              <h3 className="font-medium text-foreground">Professional Care</h3>
              <p className="text-sm text-muted-foreground">
                Connect with verified mental health specialists
              </p>
            </div>
          </div>

          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-full bg-[var(--cotton-pink)]/20 flex items-center justify-center flex-shrink-0">
              <Heart className="w-5 h-5 text-[var(--cotton-pink)]" />
            </div>
            <div className="text-left">
              <h3 className="font-medium text-foreground">Anonymous Support</h3>
              <p className="text-sm text-muted-foreground">
                Share freely in our safe audio community
              </p>
            </div>
          </div>
        </div>

        <Link
          to="/login"
          className="block w-full py-4 px-6 bg-gradient-to-r from-[var(--sky-blue)] to-[var(--mint-green)] text-white rounded-[1.5rem] font-medium shadow-lg hover:shadow-xl transition-all"
        >
          Get Started
        </Link>

        <p className="text-xs text-muted-foreground">
          We respect your privacy. Minimal data collected.
        </p>
      </div>
    </div>
  );
}
