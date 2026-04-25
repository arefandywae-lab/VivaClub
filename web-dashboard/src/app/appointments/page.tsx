"use client";

import { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { apiFetch } from "@/lib/api";
import { Video, Calendar, User, Clock, CheckCircle2, XCircle, AlertCircle } from "lucide-react";
import { format } from "date-fns";

export default function AppointmentsPage() {
    const [appointments, setAppointments] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchAppointments();
    }, []);

    const fetchAppointments = async () => {
        try {
            const data = await apiFetch("/clinical/appointments/admin-list/");
            setAppointments(data.results || data);
        } catch (error) {
            console.error("Failed to fetch appointments:", error);
            setAppointments([]);
        } finally {
            setLoading(false);
        }
    };

    const getStatusBadge = (status: string) => {
        switch (status.toLowerCase()) {
            case "completed":
                return <Badge className="bg-emerald-100 text-emerald-700 hover:bg-emerald-100 border-emerald-200"><CheckCircle2 className="w-3 h-3 mr-1" /> Completed</Badge>;
            case "upcoming":
                return <Badge className="bg-blue-100 text-blue-700 hover:bg-blue-100 border-blue-200"><Clock className="w-3 h-3 mr-1" /> Upcoming</Badge>;
            case "cancelled":
                return <Badge className="bg-rose-100 text-rose-700 hover:bg-rose-100 border-rose-200"><XCircle className="w-3 h-3 mr-1" /> Cancelled</Badge>;
            default:
                return <Badge variant="outline"><AlertCircle className="w-3 h-3 mr-1" /> {status}</Badge>;
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-900">Medical Appointments</h1>
                    <p className="text-slate-500 mt-1">Manage and monitor doctor-patient video consultations.</p>
                </div>
                <Button onClick={fetchAppointments} variant="outline" size="sm">
                    Refresh List
                </Button>
            </div>

            <div className="grid gap-6">
                <Card className="border-slate-200">
                    <CardHeader>
                        <CardTitle>Recent Sessions</CardTitle>
                        <CardDescription>A list of recent and upcoming video call sessions.</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="relative overflow-x-auto rounded-lg border">
                            <table className="w-full text-sm text-left text-slate-500">
                                <thead className="text-xs text-slate-700 uppercase bg-slate-50 border-b">
                                    <tr>
                                        <th className="px-6 py-4 font-semibold">Patient</th>
                                        <th className="px-6 py-4 font-semibold">Doctor</th>
                                        <th className="px-6 py-4 font-semibold">Date & Time</th>
                                        <th className="px-6 py-4 font-semibold">Type</th>
                                        <th className="px-6 py-4 font-semibold">Status</th>
                                        <th className="px-6 py-4 font-semibold">Actions</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y">
                                    {appointments.map((apt) => (
                                        <tr key={apt.id} className="bg-white hover:bg-slate-50 transition-colors">
                                            <td className="px-6 py-4">
                                                <div className="flex items-center">
                                                    <div className="h-8 w-8 rounded-full bg-slate-100 flex items-center justify-center mr-3 text-slate-400">
                                                        <User size={16} />
                                                    </div>
                                                    <span className="font-medium text-slate-900">{apt.patient_name}</span>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 text-slate-700">{apt.doctor_name}</td>
                                            <td className="px-6 py-4">
                                                <div className="flex flex-col">
                                                    <span className="text-slate-900 font-medium">{format(new Date(apt.scheduled_at), "MMM d, yyyy")}</span>
                                                    <span className="text-xs text-slate-500">{format(new Date(apt.scheduled_at), "hh:mm a")}</span>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4">
                                                <div className="flex items-center text-slate-600">
                                                    <Video size={14} className="mr-1.5 text-slate-400" />
                                                    {apt.type}
                                                </div>
                                            </td>
                                            <td className="px-6 py-4">
                                                {getStatusBadge(apt.status)}
                                            </td>
                                            <td className="px-6 py-4">
                                                <Button variant="ghost" size="sm" className="text-blue-600 hover:text-blue-700 hover:bg-blue-50">
                                                    View Details
                                                </Button>
                                            </td>
                                        </tr>
                                    ))}
                                    {appointments.length === 0 && !loading && (
                                        <tr>
                                            <td colSpan={6} className="px-6 py-10 text-center text-slate-400 italic">
                                                No appointments found.
                                            </td>
                                        </tr>
                                    )}
                                </tbody>
                            </table>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}
