import { Slide } from '../types/session'
import './SlideViewer.css'

interface SlideViewerProps {
  slide: Slide
}

function SlideViewer({ slide }: SlideViewerProps) {
  return (
    <div className="slide-viewer">
      <div className="slide-content">
        <h2>{slide.title}</h2>
        <div className="slide-text">
          {slide.content.split('\n').map((paragraph, idx) => (
            <p key={idx}>{paragraph}</p>
          ))}
        </div>
        {slide.duration && (
          <div className="slide-duration">
            ⏱️ Примерное время: {slide.duration} минут
          </div>
        )}
      </div>
    </div>
  )
}

export default SlideViewer

