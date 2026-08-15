import { useState } from 'react'
import { MediaItem } from '../types/session'
import './MediaViewer.css'

interface MediaViewerProps {
  media: MediaItem
}

function MediaViewer({ media }: MediaViewerProps) {
  const [error, setError] = useState(false)

  if (error) {
    return (
      <div className="media-viewer error">
        <p>Медиа файл не найден: {media.url}</p>
        {media.title && <p className="media-title">{media.title}</p>}
      </div>
    )
  }

  return (
    <div className="media-viewer">
      {media.type === 'image' && (
        <div className="media-image">
          <img
            src={media.url}
            alt={media.title || media.description || 'Изображение'}
            onError={() => setError(true)}
          />
          {media.title && <p className="media-title">{media.title}</p>}
          {media.description && <p className="media-description">{media.description}</p>}
        </div>
      )}
      
      {media.type === 'video' && (
        <div className="media-video">
          <video
            src={media.url}
            controls
            onError={() => setError(true)}
          >
            Ваш браузер не поддерживает видео.
          </video>
          {media.title && <p className="media-title">{media.title}</p>}
          {media.description && <p className="media-description">{media.description}</p>}
        </div>
      )}
      
      {media.type === 'audio' && (
        <div className="media-audio">
          {media.title && <p className="media-title">{media.title}</p>}
          <audio
            src={media.url}
            controls
            onError={() => setError(true)}
          >
            Ваш браузер не поддерживает аудио.
          </audio>
          {media.description && <p className="media-description">{media.description}</p>}
        </div>
      )}
    </div>
  )
}

export default MediaViewer

