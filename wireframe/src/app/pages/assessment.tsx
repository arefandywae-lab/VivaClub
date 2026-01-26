import { useState } from "react";
import { Link } from "react-router";
import { ArrowLeft, CheckCircle } from "lucide-react";

const questions = [
  {
    id: 1,
    question: "How are you feeling today?",
    options: [
      { text: "Very Good", emoji: "😊", color: "var(--mint-green)" },
      { text: "Good", emoji: "🙂", color: "var(--sky-blue)" },
      { text: "Okay", emoji: "😐", color: "var(--buttery-yellow)" },
      { text: "Not Great", emoji: "😔", color: "var(--cotton-pink)" },
      { text: "Struggling", emoji: "😢", color: "#fc8181" },
    ],
  },
  {
    id: 2,
    question: "How well did you sleep last night?",
    options: [
      { text: "Very Well", emoji: "😴", color: "var(--mint-green)" },
      { text: "Well", emoji: "😌", color: "var(--sky-blue)" },
      { text: "Okay", emoji: "😐", color: "var(--buttery-yellow)" },
      { text: "Poorly", emoji: "😪", color: "var(--cotton-pink)" },
      { text: "Very Poorly", emoji: "😩", color: "#fc8181" },
    ],
  },
  {
    id: 3,
    question: "How stressed do you feel?",
    options: [
      { text: "Not at all", emoji: "😊", color: "var(--mint-green)" },
      { text: "A little", emoji: "🙂", color: "var(--sky-blue)" },
      { text: "Moderately", emoji: "😐", color: "var(--buttery-yellow)" },
      { text: "Quite a bit", emoji: "😰", color: "var(--cotton-pink)" },
      { text: "Extremely", emoji: "😫", color: "#fc8181" },
    ],
  },
];

export function AssessmentPage() {
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [answers, setAnswers] = useState<string[]>([]);
  const [completed, setCompleted] = useState(false);

  const handleAnswer = (answer: string) => {
    const newAnswers = [...answers, answer];
    setAnswers(newAnswers);

    if (currentQuestion < questions.length - 1) {
      setCurrentQuestion(currentQuestion + 1);
    } else {
      // Save completion date for appointment booking gatekeeping
      const today = new Date().toISOString().split("T")[0];
      localStorage.setItem("phq9_completed_date", today);

      setCompleted(true);
    }
  };

  if (completed) {
    return (
      <div className="h-full overflow-y-auto bg-gradient-to-br from-[var(--sky-blue)]/10 via-[var(--mint-green)]/10 to-[var(--buttery-yellow)]/10 flex items-center justify-center p-6 scrollbar-hide">
        <div className="max-w-md w-full text-center space-y-6">
          <div className="flex justify-center">
            <div className="w-24 h-24 rounded-full bg-gradient-to-br from-[var(--mint-green)] to-[var(--sky-blue)] flex items-center justify-center">
              <CheckCircle className="w-12 h-12 text-white" />
            </div>
          </div>

          <div className="space-y-2">
            <h1 className="text-3xl font-semibold text-foreground">Thank You!</h1>
            <p className="text-muted-foreground">Your daily mood check-in is complete</p>
          </div>

          <div className="bg-card rounded-[1.5rem] p-6 border border-border shadow-sm text-left">
            <h3 className="font-medium text-foreground mb-3">Quick Insights</h3>
            <p className="text-sm text-muted-foreground leading-relaxed">
              Based on your responses, consider taking some time for self-care today. Remember, it's okay to reach out for support when you need it.
            </p>
          </div>

          <Link
            to="/dashboard"
            className="block w-full py-4 px-6 bg-gradient-to-r from-[var(--sky-blue)] to-[var(--mint-green)] text-white rounded-[1.5rem] font-medium shadow-lg hover:shadow-xl transition-all"
          >
            Back to Dashboard
          </Link>
        </div>
      </div>
    );
  }

  const question = questions[currentQuestion];
  const progress = ((currentQuestion + 1) / questions.length) * 100;

  return (
    <div className="h-full overflow-y-auto bg-gradient-to-br from-[var(--sky-blue)]/10 via-[var(--mint-green)]/10 to-[var(--buttery-yellow)]/10 scrollbar-hide">
      {/* Header */}
      <div className="bg-gradient-to-r from-[var(--sky-blue)] to-[var(--mint-green)] p-6 text-white">
        <Link to="/dashboard" className="inline-flex items-center gap-2 mb-4 text-white/90 hover:text-white">
          <ArrowLeft className="w-5 h-5" />
          <span>Back</span>
        </Link>
        <h1 className="text-2xl font-semibold">Daily Mood Check-in</h1>
        <p className="text-white/90 text-sm mt-1">
          Question {currentQuestion + 1} of {questions.length}
        </p>
      </div>

      {/* Progress Bar */}
      <div className="bg-card border-b border-border p-4">
        <div className="h-2 bg-muted rounded-full overflow-hidden">
          <div
            className="h-full bg-gradient-to-r from-[var(--sky-blue)] to-[var(--mint-green)] transition-all duration-300"
            style={{ width: `${progress}%` }}
          />
        </div>
      </div>

      {/* Question */}
      <div className="max-w-screen-lg mx-auto p-6 space-y-6">
        <div className="bg-card rounded-[1.5rem] p-8 border border-border shadow-lg text-center">
          <h2 className="text-2xl font-semibold text-foreground mb-8">{question.question}</h2>

          <div className="space-y-3">
            {question.options.map((option, i) => (
              <button
                key={i}
                onClick={() => handleAnswer(option.text)}
                className="w-full p-5 bg-muted/50 hover:bg-muted rounded-[1.5rem] transition-all border-2 border-transparent hover:border-[var(--sky-blue)] flex items-center gap-4 group"
              >
                <div
                  className="w-14 h-14 rounded-full flex items-center justify-center text-2xl flex-shrink-0"
                  style={{ backgroundColor: `${option.color}20` }}
                >
                  {option.emoji}
                </div>
                <span className="font-medium text-foreground group-hover:text-[var(--sky-blue)] transition-colors text-left flex-1">
                  {option.text}
                </span>
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
