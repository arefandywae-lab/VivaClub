import { useState } from "react";
import { useNavigate } from "react-router";
import { Phone, Mail, Lock, MessageSquare, ArrowRight, CheckCircle2 } from "lucide-react";

type LoginMethod = 'phone' | 'email';
type AuthMethod = 'otp' | 'password';

export function LoginPage() {
  const navigate = useNavigate();
  const [loginMethod, setLoginMethod] = useState<LoginMethod>('phone');
  const [authMethod, setAuthMethod] = useState<AuthMethod>('otp');

  const [identifier, setIdentifier] = useState("");
  const [credential, setCredential] = useState("");
  const [otpSent, setOtpSent] = useState(false);

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    if (authMethod === 'otp' && !otpSent) {
      // Simulate sending OTP
      setOtpSent(true);
      return; // Stop here, wait for OTP input
    }
    // Mock login success
    navigate("/dashboard");
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-6 bg-gradient-to-br from-[var(--sky-blue)]/10 via-[var(--mint-green)]/10 to-[var(--cotton-pink)]/10">
      <div className="max-w-md w-full space-y-8">
        <div className="text-center space-y-2">
          <h1 className="text-3xl font-semibold text-foreground">Welcome Back</h1>
          <p className="text-muted-foreground">Sign in to continue your journey</p>
        </div>

        <div className="bg-card rounded-[1.5rem] p-8 shadow-xl border border-border">
          {/* Login Method Tabs */}
          <div className="flex p-1 bg-muted/50 rounded-[1rem] mb-6">
            <button
              onClick={() => { setLoginMethod('phone'); setIdentifier(''); setOtpSent(false); }}
              className={`flex-1 py-2 text-sm font-medium rounded-[0.8rem] transition-all flex items-center justify-center gap-2 ${loginMethod === 'phone'
                ? "bg-white text-foreground shadow-sm"
                : "text-muted-foreground hover:text-foreground"
                }`}
            >
              <Phone className="w-4 h-4" />
              Phone
            </button>
            <button
              onClick={() => { setLoginMethod('email'); setIdentifier(''); setOtpSent(false); }}
              className={`flex-1 py-2 text-sm font-medium rounded-[0.8rem] transition-all flex items-center justify-center gap-2 ${loginMethod === 'email'
                ? "bg-white text-foreground shadow-sm"
                : "text-muted-foreground hover:text-foreground"
                }`}
            >
              <Mail className="w-4 h-4" />
              Email
            </button>
          </div>

          <form onSubmit={handleLogin} className="space-y-6">
            <div className="space-y-4">
              {/* Identifier Input */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-foreground ml-1">
                  {loginMethod === 'phone' ? 'Phone Number' : 'Email Address'}
                </label>
                <div className="relative">
                  <div className="absolute left-4 top-1/2 -translate-y-1/2 text-muted-foreground">
                    {loginMethod === 'phone' ? <Phone className="w-4 h-4" /> : <Mail className="w-4 h-4" />}
                  </div>
                  <input
                    type={loginMethod === 'phone' ? 'tel' : 'email'}
                    value={identifier}
                    onChange={(e) => setIdentifier(e.target.value)}
                    placeholder={loginMethod === 'phone' ? '081 234 5678' : 'you@example.com'}
                    className="w-full pl-10 pr-4 py-3 rounded-[1rem] bg-input-background border border-border focus:outline-none focus:ring-2 focus:ring-[var(--sky-blue)] transition-all"
                    required
                  />
                </div>
              </div>

              {/* Auth Method Selection (Only show if not yet OTP sent flow) */}
              {!otpSent && (
                <div className="flex gap-4">
                  <label className="flex items-center gap-2 text-sm text-foreground cursor-pointer">
                    <input
                      type="radio"
                      name="authMethod"
                      checked={authMethod === 'otp'}
                      onChange={() => setAuthMethod('otp')}
                      className="text-[var(--sky-blue)] focus:ring-[var(--sky-blue)]"
                    />
                    Use OTP
                  </label>
                  <label className="flex items-center gap-2 text-sm text-foreground cursor-pointer">
                    <input
                      type="radio"
                      name="authMethod"
                      checked={authMethod === 'password'}
                      onChange={() => setAuthMethod('password')}
                      className="text-[var(--sky-blue)] focus:ring-[var(--sky-blue)]"
                    />
                    Password
                  </label>
                </div>
              )}

              {/* Credential Input */}
              {(authMethod === 'password' || otpSent) && (
                <div className="space-y-2 animate-in fade-in slide-in-from-top-2">
                  <label className="text-sm font-medium text-foreground ml-1">
                    {authMethod === 'password' ? 'Password' : 'Enter OTP Code'}
                  </label>
                  <div className="relative">
                    <div className="absolute left-4 top-1/2 -translate-y-1/2 text-muted-foreground">
                      {authMethod === 'password' ? <Lock className="w-4 h-4" /> : <MessageSquare className="w-4 h-4" />}
                    </div>
                    <input
                      type={authMethod === 'password' ? 'password' : 'text'}
                      value={credential}
                      onChange={(e) => setCredential(e.target.value)}
                      placeholder={authMethod === 'password' ? '••••••••' : '123456'}
                      className="w-full pl-10 pr-4 py-3 rounded-[1rem] bg-input-background border border-border focus:outline-none focus:ring-2 focus:ring-[var(--sky-blue)] transition-all"
                      autoFocus={otpSent}
                    />
                    {otpSent && (
                      <div className="absolute right-4 top-1/2 -translate-y-1/2 text-[var(--mint-green)] flex items-center gap-1 text-xs font-medium">
                        <CheckCircle2 className="w-3 h-3" /> Sent
                      </div>
                    )}
                  </div>
                </div>
              )}
            </div>

            <button
              type="submit"
              className="w-full py-4 px-6 bg-gradient-to-r from-[var(--sky-blue)] to-[var(--mint-green)] text-white rounded-[1.5rem] font-medium shadow-lg hover:shadow-xl transition-all flex items-center justify-center gap-2 group"
            >
              {authMethod === 'otp' && !otpSent ? 'Send OTP Code' : 'Sign In'}
              <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
            </button>
          </form>

          <p className="mt-6 text-xs text-center text-muted-foreground">
            By continuing, you agree to our Terms of Service and Privacy Policy
          </p>

          <div className="pt-8 text-center">
            <button
              onClick={() => navigate('/doctor/login')}
              className="text-xs font-semibold text-[var(--sky-blue)] hover:underline opacity-80 hover:opacity-100 transition-opacity"
            >
              Professional Access (Doctors & Staff)
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
