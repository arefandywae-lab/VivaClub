import { useState, useEffect } from "react";
import { useNavigate, useParams, Link, useSearchParams } from "react-router";
import { Calendar, Clock, AlertCircle, CheckCircle2, ArrowLeft } from "lucide-react";

export function AppointmentBookingPage() {
    const { doctorId } = useParams();
    const [searchParams] = useSearchParams();
    const navigate = useNavigate();

    const [step, setStep] = useState<'loading' | 'gate' | 'form' | 'success'>('loading');
    const [symptoms, setSymptoms] = useState("");

    // State for time selection (defaults from URL or empty)
    const [selectedDate, setSelectedDate] = useState(searchParams.get("date") || "Tomorrow");
    const [selectedTime, setSelectedTime] = useState(searchParams.get("time") || "10:00 AM");

    useEffect(() => {
        // Check PHQ-9 status
        const phqDate = localStorage.getItem("phq9_completed_date");
        const today = new Date().toISOString().split("T")[0];

        // Simulate loading check
        setTimeout(() => {
            if (phqDate === today) {
                setStep('form');
            } else {
                setStep('gate');
            }
        }, 800);
    }, []);

    const handleBook = (e: React.FormEvent) => {
        e.preventDefault();

        // Save Appointment Mock to Local Storage
        const appointment = {
            id: Date.now(),
            doctorId,
            doctorName: "Dr. Sarah Johnson", // Mock name
            time: selectedTime,
            date: selectedDate,
            status: "confirmed"
        };

        localStorage.setItem("upcoming_appointment", JSON.stringify(appointment));
        setStep('success');

        // Auto redirect after 2s
        setTimeout(() => {
            navigate("/dashboard");
        }, 2000);
    };

    if (step === 'loading') {
        return (
            <div className="h-full flex items-center justify-center bg-background">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-[var(--sky-blue)]"></div>
            </div>
        );
    }

    if (step === 'gate') {
        return (
            <div className="h-full flex flex-col p-6 bg-background items-center justify-center text-center space-y-6">
                <div className="w-16 h-16 bg-orange-100 rounded-full flex items-center justify-center">
                    <AlertCircle className="w-8 h-8 text-orange-500" />
                </div>
                <div>
                    <h2 className="text-xl font-bold text-foreground mb-2">Assessment Required</h2>
                    <p className="text-muted-foreground">To ensure the best care, we need you to complete a quick mood check-in (PHQ-9) before booking.</p>
                </div>
                <Link
                    to="/assessment"
                    className="w-full py-4 bg-[var(--sky-blue)] text-white rounded-[1.5rem] font-bold shadow-lg"
                >
                    Start Assessment
                </Link>
                <Link to="/telemed" className="text-sm text-muted-foreground">Cancel</Link>
            </div>
        );
    }

    if (step === 'success') {
        return (
            <div className="h-full flex flex-col p-6 bg-background items-center justify-center text-center space-y-6">
                <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center animate-in zoom-in">
                    <CheckCircle2 className="w-10 h-10 text-green-600" />
                </div>
                <div>
                    <h2 className="text-2xl font-bold text-foreground mb-2">Booking Confirmed!</h2>
                    <p className="text-muted-foreground">Your appointment has been scheduled.</p>
                </div>
            </div>
        );
    }

    return (
        <div className="h-full flex flex-col bg-background p-6 overflow-y-auto">
            <Link to={`/doctor-profile?id=${doctorId}`} className="inline-flex items-center gap-2 mb-6 text-muted-foreground">
                <ArrowLeft className="w-5 h-5" />
                Back
            </Link>

            <h1 className="text-2xl font-bold text-foreground mb-6">Finalize Booking</h1>

            <div className="bg-card border border-border rounded-[1.5rem] p-6 mb-6">
                <div className="flex items-center gap-4 mb-4">
                    <img
                        src="https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=100&h=100&fit=crop"
                        className="w-16 h-16 rounded-2xl object-cover"
                    />
                    <div>
                        <h3 className="font-bold text-foreground">Dr. Sarah Johnson</h3>
                        <p className="text-sm text-[var(--sky-blue)]">Clinical Psychologist</p>
                    </div>
                </div>

                {/* Date/Time Selection Display (or Edit) */}
                <div className="grid grid-cols-2 gap-3 mb-2">
                    <div className="p-3 bg-muted/50 rounded-xl border border-transparent focus-within:border-[var(--sky-blue)]">
                        <label className="text-xs text-muted-foreground block mb-1">Date</label>
                        <div className="flex items-center gap-2 font-medium">
                            <Calendar className="w-4 h-4 text-[var(--sky-blue)]" />
                            <select
                                value={selectedDate}
                                onChange={(e) => setSelectedDate(e.target.value)}
                                className="bg-transparent focus:outline-none w-full appearance-none"
                            >
                                <option value="Today">Today</option>
                                <option value="Tomorrow">Tomorrow</option>
                                <option value="Fri, Jan 28">Fri, Jan 28</option>
                            </select>
                        </div>
                    </div>
                    <div className="p-3 bg-muted/50 rounded-xl border border-transparent focus-within:border-[var(--sky-blue)]">
                        <label className="text-xs text-muted-foreground block mb-1">Time</label>
                        <div className="flex items-center gap-2 font-medium">
                            <Clock className="w-4 h-4 text-[var(--sky-blue)]" />
                            <select
                                value={selectedTime}
                                onChange={(e) => setSelectedTime(e.target.value)}
                                className="bg-transparent focus:outline-none w-full appearance-none"
                            >
                                <option value="10:00 AM">10:00 AM</option>
                                <option value="11:30 AM">11:30 AM</option>
                                <option value="2:00 PM">2:00 PM</option>
                                <option value="4:30 PM">4:30 PM</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <form onSubmit={handleBook} className="space-y-6">
                <div className="space-y-2">
                    <label className="text-sm font-medium text-foreground ml-1">How are you feeling?</label>
                    <textarea
                        className="w-full h-32 p-4 rounded-[1.5rem] bg-input-background border border-border focus:outline-none focus:ring-2 focus:ring-[var(--sky-blue)] resize-none"
                        placeholder="Briefly describe your symptoms or what you'd like to discuss..."
                        value={symptoms}
                        onChange={(e) => setSymptoms(e.target.value)}
                        required
                    />
                </div>

                <button
                    type="submit"
                    className="w-full py-4 bg-gradient-to-r from-[var(--sky-blue)] to-[var(--mint-green)] text-white rounded-[1.5rem] font-bold shadow-lg"
                >
                    Confirm Booking
                </button>
            </form>
        </div>
    );
}
