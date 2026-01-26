import { createBrowserRouter } from "react-router";
import { Layout } from "./components/layout";
import { DoctorLayout } from "./components/doctor-layout";
import { WelcomePage } from "./pages/welcome";
import { LoginPage } from "./pages/login";
import { DashboardPage } from "./pages/dashboard";
import { TelemedPage } from "./pages/telemed";
import { PatientVideoCallPage } from "./pages/patient-call";
import { DoctorProfilePage } from "./pages/doctor-profile";
import { ChatPage } from "./pages/chat";
import { ClubhousePage } from "./pages/clubhouse";
import { AudioRoomPage } from "./pages/audio-room";
import { CreateRoomPage } from "./pages/create-room";
import { DoctorLoginPage } from "./pages/doctor/doctor-login";
import { DoctorDashboardPage } from "./pages/doctor/dashboard-mobile";
import { DoctorPatientListPage } from "./pages/doctor/patient-list";
import { DoctorMyProfilePage } from "./pages/doctor/profile";
import { DoctorExamRoomMobile } from "./pages/doctor/exam-room-mobile";
import { AssessmentPage } from "./pages/assessment";
import { ProfilePage } from "./pages/profile";
import { AppointmentBookingPage } from "./pages/appointment-booking";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: Layout,
    children: [
      { index: true, Component: WelcomePage },
      { path: "login", Component: LoginPage },
      { path: "dashboard", Component: DashboardPage },
      { path: "profile", Component: ProfilePage },
      { path: "telemed", Component: TelemedPage },
      { path: "telemed/room/:id", Component: PatientVideoCallPage }, // New Patient Video Room
      { path: "doctor-profile", Component: DoctorProfilePage },
      { path: "chat/:doctorId", Component: ChatPage },
      { path: "clubhouse", Component: ClubhousePage },
      { path: "room/:id", Component: AudioRoomPage },
      { path: "clubhouse/create", Component: CreateRoomPage },
      { path: "assessment", Component: AssessmentPage },
      { path: "appointment/book/:doctorId", Component: AppointmentBookingPage },
      { path: "doctor/login", Component: DoctorLoginPage },
    ],
  },
  {
    path: "/doctor",
    Component: DoctorLayout,
    children: [
      { path: "dashboard", Component: DoctorDashboardPage },
      { path: "patients", Component: DoctorPatientListPage },
      { path: "profile", Component: DoctorMyProfilePage },
      { path: "clubhouse", Component: ClubhousePage },
      { path: "room/:id", Component: DoctorExamRoomMobile }
    ]
  },
]);
