import { useState } from 'react'
import { QuizBlock } from '../types/session'
import LargeButton from './LargeButton'
import './QuizViewer.css'

interface QuizViewerProps {
  quiz: QuizBlock
  onComplete: () => void
}

function QuizViewer({ quiz, onComplete }: QuizViewerProps) {
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0)
  const [selectedAnswer, setSelectedAnswer] = useState<number | string | null>(null)
  const [showExplanation, setShowExplanation] = useState(false)
  const [score, setScore] = useState(0)
  const [answered, setAnswered] = useState(false)

  const currentQuestion = quiz.questions[currentQuestionIndex]
  const isLastQuestion = currentQuestionIndex === quiz.questions.length - 1

  const handleAnswer = (answer: number | string) => {
    if (answered) return
    
    setSelectedAnswer(answer)
    setAnswered(true)
    setShowExplanation(true)
    
    if (currentQuestion.correctAnswer !== undefined) {
      if (answer === currentQuestion.correctAnswer) {
        setScore(prev => prev + 1)
      }
    }
  }

  const handleNext = () => {
    if (isLastQuestion) {
      onComplete()
    } else {
      setCurrentQuestionIndex(prev => prev + 1)
      setSelectedAnswer(null)
      setShowExplanation(false)
      setAnswered(false)
    }
  }

  return (
    <div className="quiz-viewer">
      <div className="quiz-header">
        <h2>{quiz.title}</h2>
        <div className="quiz-progress">
          Вопрос {currentQuestionIndex + 1} из {quiz.questions.length}
          {score > 0 && <span className="quiz-score"> | Правильных ответов: {score}</span>}
        </div>
      </div>

      <div className="quiz-question">
        <h3>{currentQuestion.text}</h3>

        {currentQuestion.type === 'yes-no' && (
          <div className="quiz-answers yes-no">
            {(() => {
              const correctAnswer = currentQuestion.correctAnswer
              const yesIsCorrect = correctAnswer === 'yes'
              const noIsCorrect = correctAnswer === 'no'
              const yesSelected = selectedAnswer === 'yes'
              const noSelected = selectedAnswer === 'no'
              
              let yesClass = 'btn-outline'
              let noClass = 'btn-outline'
              
              if (answered) {
                // После ответа показываем правильный/неправильный
                yesClass = yesIsCorrect ? 'btn-success' : (yesSelected ? 'btn-error' : 'btn-outline')
                noClass = noIsCorrect ? 'btn-success' : (noSelected ? 'btn-error' : 'btn-outline')
              } else {
                // До ответа показываем выбранный вариант
                yesClass = yesSelected ? 'btn-primary' : 'btn-outline'
                noClass = noSelected ? 'btn-primary' : 'btn-outline'
              }
              
              return (
                <>
                  <LargeButton
                    className={yesClass}
                    onClick={() => handleAnswer('yes')}
                    disabled={answered}
                  >
                    Да
                  </LargeButton>
                  <LargeButton
                    className={noClass}
                    onClick={() => handleAnswer('no')}
                    disabled={answered}
                  >
                    Нет
                  </LargeButton>
                </>
              )
            })()}
          </div>
        )}

        {currentQuestion.type === 'multiple-choice' && currentQuestion.options && (
          <div className="quiz-answers multiple-choice">
            {currentQuestion.options.map((option, idx) => {
              const isCorrect = idx === currentQuestion.correctAnswer
              const isSelected = selectedAnswer === idx
              let buttonClass = 'btn-outline'
              
              if (answered) {
                if (isCorrect) buttonClass = 'btn-success'
                else if (isSelected && !isCorrect) buttonClass = 'btn-error'
              } else if (isSelected) {
                buttonClass = 'btn-primary'
              }

              return (
                <LargeButton
                  key={idx}
                  className={buttonClass}
                  onClick={() => handleAnswer(idx)}
                  disabled={answered}
                >
                  {option}
                </LargeButton>
              )
            })}
          </div>
        )}

        {showExplanation && currentQuestion.explanation && (
          <div className="quiz-explanation">
            <p>{currentQuestion.explanation}</p>
          </div>
        )}

        {answered && (
          <div className="quiz-actions">
            <LargeButton onClick={handleNext} className="btn-primary">
              {isLastQuestion ? 'Завершить викторину' : 'Следующий вопрос'}
            </LargeButton>
          </div>
        )}
      </div>
    </div>
  )
}

export default QuizViewer

