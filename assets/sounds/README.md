# Sound Effects for MatchWise

This directory contains premium sound effects for app interactions.

## Required Sound Files

Place the following sound files in this directory:

### Interaction Sounds

- **tap.mp3** - Generic tap/click sound (subtle, ~50ms)
- **toggle.mp3** - Toggle switch sound (satisfying click, ~100ms)
- **pop.mp3** - Modal dismiss/pop sound (light pop, ~80ms)
- **whoosh.mp3** - Screen transition sound (smooth whoosh, ~200ms)

### Swipe Sounds

- **swipe_left.mp3** - Reject/pass sound (negative but not harsh, ~150ms)
- **swipe_right.mp3** - Accept/like sound (positive chime, ~200ms)
- **swipe_up.mp3** - Super like sound (special ascending chime, ~250ms)
- **undo.mp3** - Undo action sound (reverse whoosh, ~150ms)

### Notification Sounds

- **success.mp3** - Success confirmation (pleasant chime, ~300ms)
- **error.mp3** - Error notification (gentle alert, ~250ms)
- **notification.mp3** - General notification (attention bell, ~200ms)
- **completion.mp3** - Task completed (celebration sound, ~400ms)

## Sound Guidelines

### Quality

- Format: MP3, 192kbps or higher
- Sample Rate: 44.1kHz or 48kHz
- Channels: Stereo or Mono
- Duration: Keep under 500ms for responsiveness

### Volume

- Normalize all sounds to -3dB to -6dB
- Avoid clipping and distortion
- Balance levels across all sounds

### Character

- Professional and premium feel
- Not too loud or jarring
- Complement the app's modern aesthetic
- iOS and Android friendly

## Free Sound Resources

You can download free premium sounds from:

- **Freesound.org** - Creative Commons sounds
- **Zapsplat.com** - Free sound effects
- **Mixkit.co** - Free game sounds
- **SoundBible.com** - Royalty-free sounds

## Alternative: Generate with AI

Use AI tools like:

- **ElevenLabs Sound Effects** - Generate custom sounds
- **Adobe Podcast Enhanced** - Audio enhancement
- **Audacity** - Edit and optimize sounds

## Temporary Solution

If sounds are not available, the app will work without audio feedback (haptics only).
The FeedbackService handles missing sound files gracefully.
