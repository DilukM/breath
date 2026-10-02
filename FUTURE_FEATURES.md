# Future Feature Implementation Roadmap

This document outlines proposed high-leverage features for future implementation in the Breath app.

---

## 1. Situational Quick-Start Presets

### Overview
Reframe app onboarding and Home screen interaction around real-world user problems rather than abstract duration numbers or technical breathing patterns.

### Key Entry Points
- **"Can't sleep"**: Maps to deep calming / sleep technique (e.g., 4-7-8 breathing, ~10 mins).
- **"Before a stressful call/meeting"**: Maps to quick grounding technique (e.g., Box breathing, ~3-5 mins).
- **"Panic / anxious right now"**: Maps to immediate nervous system regulation (e.g., Physiological Sigh or extended exhale, ~2-3 mins).
- **"Can't focus"**: Maps to energizing/alertness technique (e.g., Coherence breathing or 4-4 breathing, ~5 mins).

### Implementation Details
- Add moment-based visual shortcut cards/chips on the Home screen.
- Directly trigger the pre-configured session parameters (technique + duration + default audio) on tap.

---

## 2. Smart Reminder Notifications & Retention Nudges

### Overview
Prevent user drop-off—the #1 failure mode of wellness apps—by implementing intelligent local reminders and streak recovery notifications.

### Key Capabilities
- **Daily Practice Reminder**: Configurable daily scheduled reminder (e.g., morning check-in or evening unwind).
- **Streak Recovery Nudge**: Triggered when a user hasn't practiced in 48 hours ("You haven't practiced in 2 days — take a quick 2-minute breath").
- **Customization**: Option to turn reminders on/off and select preferred reminder times in Settings.

---

## 3. Do Not Disturb (DND) Integration During Sessions

### Overview
Prevent incoming calls, notifications, and audio alerts from disrupting a live breathing session.

### Implementation Details
- Request DND permission / system notification policy access on supported platforms.
- Automatically enable Do Not Disturb when a breathing session starts.
- Seamlessly restore original system notification settings when the session completes or ends.

---

## 4. Standalone Sleep Sound & Ambience Mode

### Overview
Allow users to utilize background soundscapes (Rain, Ocean, Forest, Om) independently of guided breathing exercises.

### Implementation Details
- Dedicated audio player section/screen for ambience sounds.
- Auto-stop sleep timer (e.g., 15m, 30m, 45m, 60m, custom duration).
- Volume controls and continuous smooth looping using existing audio infrastructure.
