// Типы для различных элементов занятий

export type SessionType = 
  | 'presentation'      // Презентация с рассказом
  | 'quiz'              // Викторина
  | 'virtual-tour'      // Виртуальное путешествие
  | 'biography'         // Биография
  | 'cultural'          // Культурная программа
  | 'science'           // Научная тема
  | 'language'          // Языковая тема
  | 'discussion'        // Тематическая дискуссия

export interface MediaItem {
  type: 'image' | 'video' | 'audio'
  url: string
  title?: string
  description?: string
  thumbnail?: string
}

export interface Slide {
  id: string
  title: string
  content: string
  media?: MediaItem[]
  questions?: Question[]  // Вопросы для интерактивности
  duration?: number      // Длительность в минутах
}

export interface Question {
  id: string
  text: string
  type: 'yes-no' | 'multiple-choice' | 'open'
  options?: string[]
  correctAnswer?: string | number
  explanation?: string
}

export interface QuizBlock {
  id: string
  title: string
  questions: Question[]
  timeLimit?: number
}

export interface Session {
  id: string
  title: string
  description: string
  type: SessionType
  category: string
  duration: number  // Общая длительность в минутах
  slides?: Slide[]
  quiz?: QuizBlock
  media?: MediaItem[]
  structure: {
    greeting?: string
    mainContent: string
    interactive?: string
    additional?: string
    closing?: string
  }
  metadata: {
    created: string
    updated?: string
    tags: string[]
    difficulty: 'easy' | 'medium' | 'hard'
  }
}

