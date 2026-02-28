"use client";

import { useEffect, useState, createContext, useContext } from 'react';

type WebSocketEvent = {
    event: string;
    room_title?: string;
    room_id?: string;
    room_name?: string;
    participant_identity?: string;
    participant_name?: string;
};

interface WebSocketContextProps {
    isConnected: boolean;
    messages: WebSocketEvent[];
    lastMessage: WebSocketEvent | null;
}

const WebSocketContext = createContext<WebSocketContextProps>({
    isConnected: false,
    messages: [],
    lastMessage: null,
});

export const useWebSocket = () => useContext(WebSocketContext);

export function WebSocketProvider({ children }: { children: React.ReactNode }) {
    const [isConnected, setIsConnected] = useState(false);
    const [messages, setMessages] = useState<WebSocketEvent[]>([]);
    const [lastMessage, setLastMessage] = useState<WebSocketEvent | null>(null);

    useEffect(() => {
        // Only attempt connection if we have a token (AuthGuard handles redirects)
        const token = typeof window !== 'undefined' ? localStorage.getItem('adminToken') : null;
        if (!token) return;

        // In production, this should use WSS and an auth token
        const wsUrl = process.env.NEXT_PUBLIC_WS_URL || 'ws://localhost:8000';

        // Pass token as query parameter
        const ws = new WebSocket(`${wsUrl}/ws/admin/dashboard/?token=${token}`);

        ws.onopen = () => {
            console.log('Connected to Admin WebSocket');
            setIsConnected(true);
        };

        ws.onclose = () => {
            console.log('Disconnected from Admin WebSocket');
            setIsConnected(false);
        };

        ws.onmessage = (event) => {
            try {
                const data = JSON.parse(event.data);
                console.log('Received WS Event:', data);
                setLastMessage(data);
                setMessages((prev) => [data, ...prev].slice(0, 100)); // Keep last 100 events
            } catch (err) {
                console.error('Error parsing WebSocket message', err);
            }
        };

        return () => {
            ws.close();
        };
    }, []);

    return (
        <WebSocketContext.Provider value={{ isConnected, messages, lastMessage }}>
            {children}
        </WebSocketContext.Provider>
    );
}
