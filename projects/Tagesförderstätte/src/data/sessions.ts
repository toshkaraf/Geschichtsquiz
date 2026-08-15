import { Session } from '../types/session'

// Примеры занятий - здесь будут храниться все занятия
export const sessions: Session[] = [
  {
    id: 'romische-kaiser',
    title: 'Римские императоры: от Августа до Нерона',
    description: 'Интерактивное путешествие по истории Римской империи через биографии великих императоров',
    type: 'biography',
    category: 'История',
    duration: 60,
    structure: {
      greeting: 'Сегодня мы отправимся в Древний Рим и познакомимся с великими императорами',
      mainContent: 'Рассказ о жизни и правлении римских императоров',
      interactive: 'Викторина на закрепление материала',
      additional: 'Просмотр изображений древнеримских памятников',
      closing: 'Подведение итогов и анонс следующей темы'
    },
    slides: [
      {
        id: 'slide-1',
        title: 'Октавиан Август',
        content: 'Первый римский император, правил с 27 года до н.э. до 14 года н.э. При нем Рим стал империей.',
        media: [
          {
            type: 'image',
            url: '/media/rome/augustus.jpg',
            title: 'Статуя Августа'
          }
        ],
        questions: [
          {
            id: 'q1',
            text: 'Август был первым римским императором?',
            type: 'yes-no',
            correctAnswer: 'yes',
            explanation: 'Да, Октавиан Август стал первым императором Рима в 27 году до н.э.'
          }
        ]
      },
      {
        id: 'slide-2',
        title: 'Нерон',
        content: 'Последний император династии Юлиев-Клавдиев. Известен своей жестокостью и любовью к искусству.',
        questions: [
          {
            id: 'q2',
            text: 'Нерон был известен своей любовью к музыке?',
            type: 'yes-no',
            correctAnswer: 'yes',
            explanation: 'Да, Нерон любил петь и играть на лире, хотя его талант был спорным.'
          }
        ]
      }
    ],
    quiz: {
      id: 'quiz-1',
      title: 'Викторина: Римские императоры',
      questions: [
        {
          id: 'quiz-q1',
          text: 'Кто был первым римским императором?',
          type: 'multiple-choice',
          options: ['Юлий Цезарь', 'Октавиан Август', 'Нерон', 'Траян'],
          correctAnswer: 1,
          explanation: 'Октавиан Август стал первым императором Рима в 27 году до н.э.'
        },
        {
          id: 'quiz-q2',
          text: 'В каком году началось правление Августа?',
          type: 'multiple-choice',
          options: ['44 до н.э.', '27 до н.э.', '14 н.э.', '31 до н.э.'],
          correctAnswer: 1,
          explanation: 'Август стал императором в 27 году до н.э.'
        }
      ]
    },
    metadata: {
      created: '2024-01-01',
      tags: ['Рим', 'история', 'императоры', 'Древний мир'],
      difficulty: 'medium'
    }
  },
  {
    id: 'berlin-1920',
    title: 'Берлин в 1920-е годы: Золотые двадцатые',
    description: 'Виртуальное путешествие по Берлину эпохи Веймарской республики',
    type: 'virtual-tour',
    category: 'История',
    duration: 60,
    structure: {
      greeting: 'Сегодня мы отправимся в Берлин 1920-х годов',
      mainContent: 'Экскурсия по культурной жизни Берлина',
      interactive: 'Викторина "Узнай место по фотографии"',
      additional: 'Прослушивание музыки эпохи',
      closing: 'Обсуждение влияния эпохи на современность'
    },
    slides: [
      {
        id: 'slide-berlin-1',
        title: 'Культурная столица Европы',
        content: 'Берлин 1920-х годов был центром искусства, музыки и литературы. Здесь творили Бертольт Брехт, Марлен Дитрих и многие другие.',
        media: [
          {
            type: 'image',
            url: '/media/berlin/1920s.jpg',
            title: 'Берлин 1920-х'
          }
        ]
      }
    ],
    metadata: {
      created: '2024-01-01',
      tags: ['Берлин', '1920-е', 'культура', 'Германия'],
      difficulty: 'medium'
    }
  }
]

// Функция для получения занятия по ID
export function getSessionById(id: string): Session | undefined {
  return sessions.find(session => session.id === id)
}

// Функция для получения занятий по категории
export function getSessionsByCategory(category: string): Session[] {
  return sessions.filter(session => session.category === category)
}

// Функция для получения занятий по типу
export function getSessionsByType(type: Session['type']): Session[] {
  return sessions.filter(session => session.type === type)
}

