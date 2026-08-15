import { Link } from 'react-router-dom'
import { sessions } from '../data/sessions'
import { SessionType } from '../types/session'
import { BookOpen, Map, Users, Music, Globe, Lightbulb, Languages, MessageCircle } from 'lucide-react'
import './HomePage.css'

const typeIcons: Record<SessionType, React.ReactNode> = {
  presentation: <BookOpen size={32} />,
  quiz: <Lightbulb size={32} />,
  'virtual-tour': <Map size={32} />,
  biography: <Users size={32} />,
  cultural: <Music size={32} />,
  science: <Globe size={32} />,
  language: <Languages size={32} />,
  discussion: <MessageCircle size={32} />
}

const typeLabels: Record<SessionType, string> = {
  presentation: 'Презентация',
  quiz: 'Викторина',
  'virtual-tour': 'Виртуальное путешествие',
  biography: 'Биография',
  cultural: 'Культура',
  science: 'Наука',
  language: 'Языки',
  discussion: 'Дискуссия'
}

function HomePage() {
  const categories = Array.from(new Set(sessions.map(s => s.category)))

  return (
    <div className="home-page">
      <header className="home-header">
        <h1>Tagesförderstätte</h1>
        <p className="subtitle">Интерактивные занятия и образовательные программы</p>
      </header>

      <main className="home-main">
        <section className="categories-section">
          <h2>Категории</h2>
          <div className="categories-grid">
            {categories.map(category => (
              <div key={category} className="category-card">
                <h3>{category}</h3>
                <p>{sessions.filter(s => s.category === category).length} занятий</p>
              </div>
            ))}
          </div>
        </section>

        <section className="sessions-section">
          <h2>Доступные занятия</h2>
          <div className="sessions-grid">
            {sessions.map(session => (
              <Link 
                key={session.id} 
                to={`/session/${session.id}`}
                className="session-card"
              >
                <div className="session-icon">
                  {typeIcons[session.type]}
                </div>
                <div className="session-info">
                  <h3>{session.title}</h3>
                  <p className="session-description">{session.description}</p>
                  <div className="session-meta">
                    <span className="session-type">{typeLabels[session.type]}</span>
                    <span className="session-duration">{session.duration} мин</span>
                    <span className="session-category">{session.category}</span>
                  </div>
                </div>
              </Link>
            ))}
          </div>
        </section>
      </main>
    </div>
  )
}

export default HomePage

