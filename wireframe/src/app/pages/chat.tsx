import { useState } from "react";
import { Link, useParams } from "react-router";
import { ArrowLeft, Send, Shield, Image, Video, Phone } from "lucide-react";

export function ChatPage() {
  const { doctorId } = useParams();
  const [message, setMessage] = useState("");
  const [messages, setMessages] = useState([
    {
      id: 1,
      sender: "doctor",
      text: "Hello! I'm Dr. Sarah Johnson. How are you feeling today?",
      time: "10:00 AM",
    },
    {
      id: 2,
      sender: "patient",
      text: "Hi Dr. Johnson, I've been feeling a bit anxious lately.",
      time: "10:02 AM",
    },
    {
      id: 3,
      sender: "doctor",
      text: "I understand. Can you tell me more about what's been triggering these feelings?",
      time: "10:03 AM",
    },
  ]);

  const handleSend = () => {
    if (!message.trim()) return;

    setMessages([
      ...messages,
      {
        id: messages.length + 1,
        sender: "patient",
        text: message,
        time: new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
      },
    ]);
    setMessage("");
  };

  return (
    <div className="h-full flex flex-col bg-background">
      {/* Header */}
      <div className="bg-gradient-to-r from-[var(--sky-blue)] to-[var(--mint-green)] p-4 text-white flex items-center gap-4">
        <Link to={`/doctor-profile?id=${doctorId}`}>
          <ArrowLeft className="w-6 h-6" />
        </Link>
        <img
          src="https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=100&h=100&fit=crop"
          alt="Dr. Sarah Johnson"
          className="w-12 h-12 rounded-full"
        />
        <div className="flex-1">
          <h2 className="font-semibold">Dr. Sarah Johnson</h2>
          <div className="flex items-center gap-1 text-sm text-white/80">
            <Shield className="w-3 h-3" />
            <span>Secure End-to-End Encrypted</span>
          </div>
        </div>
        <div className="flex gap-2">
          <button className="w-10 h-10 rounded-full bg-white/20 hover:bg-white/30 flex items-center justify-center transition-colors">
            <Phone className="w-5 h-5" />
          </button>
          <button className="w-10 h-10 rounded-full bg-white/20 hover:bg-white/30 flex items-center justify-center transition-colors">
            <Video className="w-5 h-5" />
          </button>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4 pb-4">
        {messages.map((msg) => (
          <div
            key={msg.id}
            className={`flex ${msg.sender === "patient" ? "justify-end" : "justify-start"}`}
          >
            <div
              className={`max-w-[75%] ${msg.sender === "patient"
                ? "bg-[var(--sky-blue)] text-white rounded-[1.5rem] rounded-br-md"
                : "bg-card border border-border rounded-[1.5rem] rounded-bl-md"
                } px-4 py-3 shadow-sm`}
            >
              <p className={msg.sender === "patient" ? "text-white" : "text-foreground"}>
                {msg.text}
              </p>
              <span
                className={`text-xs ${msg.sender === "patient" ? "text-white/70" : "text-muted-foreground"
                  } mt-1 block`}
              >
                {msg.time}
              </span>
            </div>
          </div>
        ))}
      </div>

      {/* Input */}
      <div className="border-t border-border bg-card p-4">
        <div className="max-w-screen-lg mx-auto flex items-center gap-2">
          <button className="w-10 h-10 rounded-full bg-muted hover:bg-muted/80 flex items-center justify-center transition-colors">
            <Image className="w-5 h-5 text-muted-foreground" />
          </button>
          <input
            type="text"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onKeyPress={(e) => e.key === "Enter" && handleSend()}
            placeholder="Type your message..."
            className="flex-1 px-4 py-3 rounded-[1.5rem] bg-input-background border border-border focus:outline-none focus:ring-2 focus:ring-[var(--sky-blue)] transition-all"
          />
          <button
            onClick={handleSend}
            className="w-10 h-10 rounded-full bg-gradient-to-r from-[var(--sky-blue)] to-[var(--mint-green)] flex items-center justify-center shadow-md hover:shadow-lg transition-all"
          >
            <Send className="w-5 h-5 text-white" />
          </button>
        </div>
      </div>
    </div>
  );
}
