/// Record Status
enum RecordStatus {
  inactive,
  recording,
  preview,
  view,
}

/// Extension for Record Status
extension RecordStatusExtension on RecordStatus {
  bool get isInactive => this == RecordStatus.inactive;
  bool get isRecording => this == RecordStatus.recording;
  bool get isPreview => this == RecordStatus.preview;
  bool get isView => this == RecordStatus.view;
}

/// Recording Status
enum RecordingStatus {
  playing,
  paused,
}

/// Extension for Recording Status
extension RecordingStatusExtension on RecordingStatus {
  bool get isPlaying => this == RecordingStatus.playing;
  bool get isPaused => this == RecordingStatus.paused;
}
