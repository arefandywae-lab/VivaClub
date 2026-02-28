"use client";

import { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { apiFetch } from "@/lib/api";
import { formatDistanceToNow } from "date-fns";
import { Shield, ShieldAlert, UserIcon } from "lucide-react";

export default function UsersPage() {
    const [users, setUsers] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchUsers();
    }, []);

    const fetchUsers = async () => {
        try {
            const data = await apiFetch("/auth/admin/users/"); // matches /api/auth/admin/users/
            setUsers(data.results || data);
        } catch (error) {
            console.error("Failed to fetch users:", error);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-900">User Management</h1>
                    <p className="text-slate-500 mt-1">View and manage all registered users on the platform.</p>
                </div>
                <div className="bg-white px-4 py-2 rounded-lg border shadow-sm">
                    <span className="text-sm font-medium text-slate-500">Total Users:</span>
                    <span className="ml-2 text-xl font-bold text-emerald-600">{users.length}</span>
                </div>
            </div>

            <Card className="border-slate-200 shadow-sm">
                <CardHeader>
                    <CardTitle>Registered Users</CardTitle>
                </CardHeader>
                <CardContent>
                    {loading ? (
                        <div className="py-12 text-center text-slate-500 animate-pulse">Loading users...</div>
                    ) : users.length === 0 ? (
                        <div className="py-12 text-center text-slate-500">No users found.</div>
                    ) : (
                        <Table>
                            <TableHeader>
                                <TableRow className="bg-slate-50">
                                    <TableHead>User / Ghost Profile</TableHead>
                                    <TableHead>Email / Phone</TableHead>
                                    <TableHead>Role</TableHead>
                                    <TableHead>Status</TableHead>
                                    <TableHead className="text-right">Actions</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {users.map((user) => (
                                    <TableRow key={user.id}>
                                        <TableCell>
                                            <div className="flex items-center gap-3">
                                                <div className="h-8 w-8 rounded-full bg-slate-100 flex items-center justify-center border overflow-hidden">
                                                    {user.ghost_profile?.avatar ? (
                                                        <img src={user.ghost_profile.avatar} alt="avatar" className="w-full h-full object-cover" />
                                                    ) : (
                                                        <UserIcon className="h-4 w-4 text-slate-400" />
                                                    )}
                                                </div>
                                                <div>
                                                    <p className="font-medium text-slate-900">{user.display_name || user.username}</p>
                                                    {user.ghost_profile && (
                                                        <p className="text-xs text-slate-500">Ghost: {user.ghost_profile.display_name}</p>
                                                    )}
                                                </div>
                                            </div>
                                        </TableCell>
                                        <TableCell>
                                            <p className="text-sm text-slate-900">{user.email || "No Email"}</p>
                                            <p className="text-xs text-slate-500">{user.phone_number || "No Phone"}</p>
                                        </TableCell>
                                        <TableCell>
                                            {user.is_staff ? (
                                                <Badge variant="default" className="bg-purple-100 text-purple-700 hover:bg-purple-200 border-purple-200">
                                                    <ShieldAlert className="h-3 w-3 mr-1" /> Admin
                                                </Badge>
                                            ) : user.role === 'doctor' ? (
                                                <Badge variant="outline" className="text-blue-600 border-blue-200 bg-blue-50">Doctor</Badge>
                                            ) : (
                                                <Badge variant="secondary" className="bg-slate-100 text-slate-700">Patient</Badge>
                                            )}
                                        </TableCell>
                                        <TableCell>
                                            {user.is_online ? (
                                                <span className="flex items-center text-xs font-medium text-emerald-600">
                                                    <span className="h-2 w-2 rounded-full bg-emerald-500 mr-2" /> Online
                                                </span>
                                            ) : (
                                                <span className="flex items-center text-xs font-medium text-slate-500">
                                                    <span className="h-2 w-2 rounded-full bg-slate-300 mr-2" /> Offline
                                                </span>
                                            )}
                                        </TableCell>
                                        <TableCell className="text-right">
                                            <Badge variant="outline" className="cursor-not-allowed opacity-50">Manage</Badge>
                                        </TableCell>
                                    </TableRow>
                                ))}
                            </TableBody>
                        </Table>
                    )}
                </CardContent>
            </Card>
        </div>
    );
}
