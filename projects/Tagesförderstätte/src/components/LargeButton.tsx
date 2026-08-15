import { ReactNode } from 'react'
import './LargeButton.css'

interface LargeButtonProps {
  children: ReactNode
  onClick: () => void
  disabled?: boolean
  className?: string
}

function LargeButton({ children, onClick, disabled, className = '' }: LargeButtonProps) {
  return (
    <button
      className={`large-button ${className}`}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  )
}

export default LargeButton

