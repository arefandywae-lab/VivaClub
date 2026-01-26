import { useState } from "react";
import { useNavigate, Link } from "react-router";
import { Stethoscope, ShieldCheck, ArrowRight, Lock, UserSquare2 } from "lucide-react";

export function DoctorLoginPage() {
    const navigate = useNavigate();
    const [licenseId, setLicenseId] = useState("");
    const [password, setPassword] = useState("");
    const [isLoading, setIsLoading] = useState(false);

    const handleLogin = (e: React.FormEvent) => {
        e.preventDefault();
        setIsLoading(true);

        // Simulate API call
        setTimeout(() => {
            setIsLoading(false);
            navigate("/doctor/dashboard");
        }, 1000);
    };

    return (
        <div className="min-h-screen flex flex-col items-center justify-center p-6 bg-[#0f172a] text-white">
            {/* Background decoration */}
            <div className="absolute top-0 left-0 w-full h-64 bg-gradient-to-b from-[#0d9488]/20 to-transparent pointer-events-none" />

            <div className="max-w-md w-full space-y-8 relative z-10">
                <div className="text-center space-y-4">
                    <div className="w-16 h-16 bg-[#0d9488] rounded-2xl mx-auto flex items-center justify-center shadow-lg shadow-[#0d9488]/20">
                        <Stethoscope className="w-8 h-8 text-white" />
                    </div>
                    <h1 className="text-2xl font-bold tracking-tight">Viva Professional</h1>
                    <p className="text-slate-400 text-sm">Secure access for verified medical staff</p>
                </div>

                <div className="bg-[#1e293b] rounded-[1.5rem] p-8 shadow-2xl border border-slate-700/50">
                    <form onSubmit={handleLogin} className="space-y-6">
                        <div className="space-y-4">
                            {/* License ID Input */}
                            <div className="space-y-2">
                                <label className="text-xs font-semibold text-slate-400 uppercase tracking-wider ml-1">
                                    Medical License ID
                                </label>
                                <div className="relative">
                                    <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500">
                                        <UserSquare2 className="w-4 h-4" />
                                    </div>
                                    <input
                                        type="text"
                                        value={licenseId}
                                        onChange={(e) => setLicenseId(e.target.value)}
                                        placeholder="MD-2024-XXXX"
                                        className="w-full pl-10 pr-4 py-3 rounded-xl bg-[#0f172a] border border-slate-700 focus:outline-none focus:border-[#0d9488] focus:ring-1 focus:ring-[#0d9488] transition-all text-white placeholder:text-slate-600 font-mono"
                                        required
                                    />
                                </div>
                            </div>

                            {/* Password Input */}
                            <div className="space-y-2">
                                <label className="text-xs font-semibold text-slate-400 uppercase tracking-wider ml-1">
                                    Password
                                </label>
                                <div className="relative">
                                    <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500">
                                        <Lock className="w-4 h-4" />
                                    </div>
                                    <input
                                        type="password"
                                        value={password}
                                        onChange={(e) => setPassword(e.target.value)}
                                        placeholder="••••••••"
                                        className="w-full pl-10 pr-4 py-3 rounded-xl bg-[#0f172a] border border-slate-700 focus:outline-none focus:border-[#0d9488] focus:ring-1 focus:ring-[#0d9488] transition-all text-white placeholder:text-slate-600"
                                        required
                                    />
                                </div>
                            </div>
                        </div>

                        <button
                            type="submit"
                            disabled={isLoading}
                            className="w-full py-4 px-6 bg-[#0d9488] hover:bg-[#0f766e] text-white rounded-xl font-medium shadow-lg hover:shadow-[#0d9488]/25 transition-all flex items-center justify-center gap-2 group disabled:opacity-70 disabled:cursor-not-allowed"
                        >
                            {isLoading ? (
                                <span className="animate-pulse">Verifying Credentials...</span>
                            ) : (
                                <>
                                    <ShieldCheck className="w-4 h-4" />
                                    Secure Login
                                    <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                                </>
                            )}
                        </button>
                    </form>
                </div>

                <div className="text-center">
                    <Link to="/login" className="text-xs text-slate-500 hover:text-[#0d9488] transition-colors">
                        &larr; Return to Patient Portal
                    </Link>
                </div>
            </div>
        </div>
    );
}
