import { useState } from 'react';
import { Heart, MessageCircle, User, LogOut, Settings } from 'lucide-react';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import Login from './components/Auth/Login';
import Signup from './components/Auth/Signup';
import ProfileSetup from './components/Profile/ProfileSetup';
import EditProfile from './components/Profile/EditProfile';
import Discover from './components/Discover/Discover';
import Matches from './components/Matches/Matches';
import Chat from './components/Messages/Chat';
import type { Database } from './lib/database.types';

type Profile = Database['public']['Tables']['profiles']['Row'];

type View = 'discover' | 'matches' | 'profile';

function MainApp() {
  const { user, profile, loading, signOut } = useAuth();
  const [authView, setAuthView] = useState<'login' | 'signup'>('login');
  const [currentView, setCurrentView] = useState<View>('discover');
  const [showEditProfile, setShowEditProfile] = useState(false);
  const [chatView, setChatView] = useState<{ conversationId: string; profile: Profile } | null>(null);

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-pink-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-pink-50">
        {authView === 'login' ? (
          <Login onToggle={() => setAuthView('signup')} />
        ) : (
          <Signup
            onToggle={() => setAuthView('login')}
            onProfileSetup={() => {}}
          />
        )}
      </div>
    );
  }

  if (!profile) {
    return <ProfileSetup />;
  }

  if (chatView) {
    return (
      <div className="h-screen">
        <Chat
          conversationId={chatView.conversationId}
          otherProfile={chatView.profile}
          onBack={() => setChatView(null)}
        />
      </div>
    );
  }

  return (
    <div className="h-screen flex flex-col bg-gray-50">
      <header className="bg-white border-b border-gray-200 px-6 py-4">
        <div className="max-w-7xl mx-auto flex justify-between items-center">
          <div className="flex items-center gap-2">
            <Heart className="w-8 h-8 text-pink-500" fill="currentColor" />
            <h1 className="text-2xl font-bold bg-gradient-to-r from-pink-500 to-blue-500 bg-clip-text text-transparent">
              Crotchet
            </h1>
          </div>
          <div className="flex items-center gap-4">
            <span className="text-sm text-gray-600">
              {profile.full_name}
            </span>
            <button
              onClick={() => signOut()}
              className="p-2 hover:bg-gray-100 rounded-full transition-colors"
              title="Sign out"
            >
              <LogOut className="w-5 h-5 text-gray-600" />
            </button>
          </div>
        </div>
      </header>

      <main className="flex-1 overflow-hidden">
        {currentView === 'discover' && <Discover />}
        {currentView === 'matches' && (
          <Matches onOpenChat={(conversationId, profile) => setChatView({ conversationId, profile })} />
        )}
        {currentView === 'profile' && (
          <div className="h-full overflow-auto">
            <div className="max-w-2xl mx-auto p-6">
              <div className="bg-white rounded-2xl shadow-lg p-8">
                <div className="flex justify-between items-start mb-6">
                  <h2 className="text-3xl font-bold text-gray-900">My Profile</h2>
                  <button
                    onClick={() => setShowEditProfile(true)}
                    className="p-2 hover:bg-gray-100 rounded-full transition-colors"
                  >
                    <Settings className="w-5 h-5 text-gray-600" />
                  </button>
                </div>

                <div className="space-y-6">
                  <div className="aspect-square bg-gradient-to-br from-blue-100 to-pink-100 rounded-2xl flex items-center justify-center">
                    <div className="text-9xl opacity-30">👤</div>
                  </div>

                  <div>
                    <h3 className="text-2xl font-bold text-gray-900 mb-1">
                      {profile.full_name}
                    </h3>
                    <p className="text-gray-600">@{profile.username}</p>
                  </div>

                  {profile.location && (
                    <div>
                      <h4 className="text-sm font-semibold text-gray-700 mb-1">Location</h4>
                      <p className="text-gray-600">{profile.location}</p>
                    </div>
                  )}

                  {profile.bio && (
                    <div>
                      <h4 className="text-sm font-semibold text-gray-700 mb-1">About</h4>
                      <p className="text-gray-600">{profile.bio}</p>
                    </div>
                  )}

                  <div>
                    <h4 className="text-sm font-semibold text-gray-700 mb-1">Looking for</h4>
                    <p className="text-gray-600">{profile.looking_for.join(', ')}</p>
                  </div>

                  {profile.interests.length > 0 && (
                    <div>
                      <h4 className="text-sm font-semibold text-gray-700 mb-2">Interests</h4>
                      <div className="flex flex-wrap gap-2">
                        {profile.interests.map((interest) => (
                          <span
                            key={interest}
                            className="px-3 py-1 bg-blue-50 text-blue-700 rounded-full text-sm"
                          >
                            {interest}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        )}
      </main>

      <nav className="bg-white border-t border-gray-200 px-6 py-3">
        <div className="max-w-7xl mx-auto flex justify-around">
          <button
            onClick={() => setCurrentView('discover')}
            className={`flex flex-col items-center gap-1 px-4 py-2 rounded-lg transition-colors ${
              currentView === 'discover'
                ? 'text-pink-500'
                : 'text-gray-600 hover:bg-gray-100'
            }`}
          >
            <Heart className="w-6 h-6" fill={currentView === 'discover' ? 'currentColor' : 'none'} />
            <span className="text-xs font-medium">Discover</span>
          </button>

          <button
            onClick={() => setCurrentView('matches')}
            className={`flex flex-col items-center gap-1 px-4 py-2 rounded-lg transition-colors ${
              currentView === 'matches'
                ? 'text-pink-500'
                : 'text-gray-600 hover:bg-gray-100'
            }`}
          >
            <MessageCircle className="w-6 h-6" fill={currentView === 'matches' ? 'currentColor' : 'none'} />
            <span className="text-xs font-medium">Matches</span>
          </button>

          <button
            onClick={() => setCurrentView('profile')}
            className={`flex flex-col items-center gap-1 px-4 py-2 rounded-lg transition-colors ${
              currentView === 'profile'
                ? 'text-pink-500'
                : 'text-gray-600 hover:bg-gray-100'
            }`}
          >
            <User className="w-6 h-6" fill={currentView === 'profile' ? 'currentColor' : 'none'} />
            <span className="text-xs font-medium">Profile</span>
          </button>
        </div>
      </nav>

      {showEditProfile && <EditProfile onClose={() => setShowEditProfile(false)} />}
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <MainApp />
    </AuthProvider>
  );
}
