export default function SettingsPage() {
    return (
        <div className="flex h-[80vh] w-full flex-col items-center justify-center space-y-4">
            <h1 className="text-3xl font-bold tracking-tight text-slate-900">Settings</h1>
            <p className="text-slate-500 text-center max-w-md">
                This feature is currently under development. You will be able to configure global platform settings,
                webhooks, and API keys here.
            </p>
            <div className="pt-6">
                <div className="rounded-full bg-slate-100 px-6 py-2 border border-slate-200 text-sm font-medium text-slate-600">
                    Coming Soon ⚙️
                </div>
            </div>
        </div>
    );
}
