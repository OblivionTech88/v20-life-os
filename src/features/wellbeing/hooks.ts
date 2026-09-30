import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { experienceService, familyEntryService, familyProfileService, habitEntryService, habitService, healthService, specialDateService, v20MeetingService, workoutService } from './services'

const key = (name: string, workspaceId: string) => ['wellbeing', name, workspaceId] as const
export function useHabits(workspaceId: string) { return useQuery({ queryKey: key('habits', workspaceId), queryFn: () => habitService.list(workspaceId), enabled: Boolean(workspaceId) }) }
export function useHabitEntries(workspaceId: string) { return useQuery({ queryKey: key('habit-entries', workspaceId), queryFn: () => habitEntryService.today(workspaceId), enabled: Boolean(workspaceId) }) }
export function useHealthEntries(workspaceId: string) { return useQuery({ queryKey: key('health', workspaceId), queryFn: () => healthService.list(workspaceId), enabled: Boolean(workspaceId) }) }
export function useWorkouts(workspaceId: string) { return useQuery({ queryKey: key('workouts', workspaceId), queryFn: () => workoutService.list(workspaceId), enabled: Boolean(workspaceId) }) }
export function useFamilyProfiles(workspaceId: string) { return useQuery({ queryKey: key('family-profiles', workspaceId), queryFn: () => familyProfileService.list(workspaceId), enabled: Boolean(workspaceId) }) }
export function useFamilyEntries(workspaceId: string) { return useQuery({ queryKey: key('family-entries', workspaceId), queryFn: () => familyEntryService.list(workspaceId), enabled: Boolean(workspaceId) }) }
export function useExperiences(workspaceId: string) { return useQuery({ queryKey: key('experiences', workspaceId), queryFn: () => experienceService.list(workspaceId), enabled: Boolean(workspaceId) }) }
export function useSpecialDates(workspaceId: string) { return useQuery({ queryKey: key('special-dates', workspaceId), queryFn: () => specialDateService.list(workspaceId), enabled: Boolean(workspaceId) }) }
export function useSaveMeetingStep(workspaceId: string) { const qc = useQueryClient(); return useMutation({ mutationFn: ({ meetingId, stepKey, stepNumber, payload }: { meetingId: string; stepKey: string; stepNumber: number; payload: Record<string, unknown> }) => v20MeetingService.saveStep(meetingId, workspaceId, stepKey, stepNumber, payload), onSuccess: () => qc.invalidateQueries({ queryKey: ['wellbeing'] }) }) }
