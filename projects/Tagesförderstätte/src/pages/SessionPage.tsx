import { useParams, useNavigate } from 'react-router-dom'
import { useState } from 'react'
import { getSessionById } from '../data/sessions'
import SlideViewer from '../components/SlideViewer'
import QuizViewer from '../components/QuizViewer'
import MediaViewer from '../components/MediaViewer'
import LargeButton from '../components/LargeButton'
import { ArrowLeft, Play, Pause, SkipForward, SkipBack } from 'lucide-react'
import './SessionPage.css'

function SessionPage() {
  const { sessionId } = useParams<{ sessionId: string }>()
  const navigate = useNavigate()
  const session = sessionId ? getSessionById(sessionId) : undefined

  const [currentSlideIndex, setCurrentSlideIndex] = useState(0)
  const [showQuiz, setShowQuiz] = useState(false)
  const [showMedia, setShowMedia] = useState(false)

  if (!session) {
    return (
      <div className="session-page error">
        <h2>Занятие не найдено</h2>
        <LargeButton onClick={() => navigate('/')}>
          Вернуться на главную
        </LargeButton>
      </div>
    )
  }

  const currentSlide = session.slides?.[currentSlideIndex]
  const hasNextSlide = session.slides && currentSlideIndex < session.slides.length - 1
  const hasPrevSlide = currentSlideIndex > 0

  const handleNext = () => {
    if (hasNextSlide) {
      setCurrentSlideIndex(prev => prev + 1)
    } else if (session.quiz && !showQuiz) {
      setShowQuiz(true)
    }
  }

  const handlePrev = () => {
    if (showQuiz) {
      setShowQuiz(false)
    } else if (hasPrevSlide) {
      setCurrentSlideIndex(prev => prev - 1)
    }
  }

  return (
    <div className="session-page">
      <header className="session-header">
        <LargeButton onClick={() => navigate('/')} className="btn-outline">
          <ArrowLeft size={24} /> Назад
        </LargeButton>
        <div className="session-title">
          <h1>{session.title}</h1>
          <p>{session.description}</p>
        </div>
        <div className="session-progress">
          {session.slides && (
            <span>
              Слайд {currentSlideIndex + 1} из {session.slides.length}
            </span>
          )}
        </div>
      </header>

      <main className="session-main">
        {showQuiz && session.quiz ? (
          <QuizViewer quiz={session.quiz} onComplete={() => setShowQuiz(false)} />
        ) : currentSlide ? (
          <>
            <SlideViewer slide={currentSlide} />
            
            {currentSlide.media && currentSlide.media.length > 0 && (
              <div className="media-section">
                <h3>Медиа материалы</h3>
                {currentSlide.media.map((item, idx) => (
                  <MediaViewer key={idx} media={item} />
                ))}
              </div>
            )}

            {currentSlide.questions && currentSlide.questions.length > 0 && (
              <div className="questions-section">
                <h3>Вопросы для обсуждения</h3>
                {currentSlide.questions.map(q => (
                  <div key={q.id} className="question-card">
                    <p className="question-text">{q.text}</p>
                    {q.type === 'yes-no' && (
                      <div className="yes-no-buttons">
                        <LargeButton 
                          className="btn-success"
                          onClick={() => alert('Отлично! ' + (q.explanation || ''))}
                        >
                          Да
                        </LargeButton>
                        <LargeButton 
                          className="btn-outline"
                          onClick={() => alert('Подумайте еще. ' + (q.explanation || ''))}
                        >
                          Нет
                        </LargeButton>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </>
        ) : (
          <div className="session-structure">
            <h2>Структура занятия</h2>
            {session.structure.greeting && (
              <div className="structure-block">
                <h3>Приветствие</h3>
                <p>{session.structure.greeting}</p>
              </div>
            )}
            {session.structure.mainContent && (
              <div className="structure-block">
                <h3>Основная часть</h3>
                <p>{session.structure.mainContent}</p>
              </div>
            )}
            {session.structure.interactive && (
              <div className="structure-block">
                <h3>Интерактивная часть</h3>
                <p>{session.structure.interactive}</p>
              </div>
            )}
            {session.structure.closing && (
              <div className="structure-block">
                <h3>Завершение</h3>
                <p>{session.structure.closing}</p>
              </div>
            )}
            <LargeButton onClick={() => setCurrentSlideIndex(0)} className="btn-primary">
              <Play size={24} /> Начать занятие
            </LargeButton>
          </div>
        )}
      </main>

      <footer className="session-footer">
        <LargeButton 
          onClick={handlePrev} 
          disabled={!hasPrevSlide && !showQuiz}
          className="btn-outline"
        >
          <SkipBack size={24} /> Назад
        </LargeButton>
        
        {session.quiz && !showQuiz && (
          <LargeButton 
            onClick={() => setShowQuiz(true)}
            className="btn-secondary"
          >
            Перейти к викторине
          </LargeButton>
        )}
        
        <LargeButton 
          onClick={handleNext} 
          disabled={!hasNextSlide && !session.quiz}
          className="btn-primary"
        >
          Далее <SkipForward size={24} />
        </LargeButton>
      </footer>
    </div>
  )
}

export default SessionPage

