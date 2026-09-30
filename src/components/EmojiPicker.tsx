import { useState } from 'react'
import Picker from '@emoji-mart/react'
import data from '@emoji-mart/data'
import { X } from 'lucide-react'
type Props = { value: string; onChange: (emoji: string) => void; onClose: () => void }
export function EmojiPicker({ value, onChange, onClose }: Props) {
  const [open, setOpen] = useState(false)
  return <div className="relative"><button className="rounded-xl bg-surface p-2 text-2xl" onClick={() => setOpen(!open)} aria-label="Escolher emoji">{value}</button>{open && <div className="fixed inset-0 z-50 flex items-end bg-black/60 p-3 sm:items-center sm:justify-center"><div className="relative max-w-full"><button className="absolute right-2 top-2 z-10 rounded-full bg-ink p-1" onClick={onClose}><X size={16}/></button><Picker data={data} locale="pt" previewPosition="none" skinTonePosition="search" onEmojiSelect={(e: { native: string }) => { onChange(e.native); setOpen(false) }} /></div></div>}</div>
}
