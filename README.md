# BitStream

A modern, native macOS application for downloading and managing media content. Built with SwiftUI and powered by [`yt-dlp`](https://github.com/yt-dlp/yt-dlp), BitStream combines a beautiful user interface with professional-grade functionality.

---

## 📸 Preview

*Coming Soon: Screenshots showcasing the modern gradient UI, progress tracking, and download management*

---

## ✨ Features

### Current Features

**🎨 Modern Native Interface**
- Clean, gradient-based SwiftUI design
- Seamless light/dark mode support
- Smooth animations and hover effects
- Card-based layout for better organization

**📥 Flexible Download Options**
- **Video Mode**: Download with customizable quality (480p - 4K)
- **Audio Mode**: Extract audio in multiple formats (MP3, M4A, FLAC, WAV, Opus)
- Smart format selection (best video + audio merging)
- Container format options (MKV, MP4, WebM, AVI, MOV)
- Audio quality presets (Best, High 320kbps, Medium 128kbps, Low 64kbps)

**📊 Real-Time Progress Tracking**
- Live download progress with percentage
- Download speed monitoring
- ETA (estimated time) display
- File size tracking
- Beautiful gradient progress bar with shimmer effect

**📚 Download History**
- Recent downloads list with metadata
- File type badges (Video/Audio)
- Format and quality information
- Quick actions:
  - Reveal in Finder
  - Remove from history
  - Clear all options

**⚙️ Advanced Configuration**
- Custom output folder selection
- Extra yt-dlp arguments support
- Network connectivity monitoring
- Proper error handling and user feedback

**🏗️ Professional Architecture**
- MVVM design pattern
- Modular component structure
- Combine framework for reactive updates
- Industry-standard file organization (150-250 lines per file)

---

## 🚀 Installation

### Prerequisites
- macOS 13.0 (Ventura) or later
- Xcode 15.0+
- Swift 5.9+
- `yt-dlp` binary (bundled with app)
- FFmpeg (recommended for format conversion)

### Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/gichukipaul/BitStream.git
   cd BitStream
   ```

2. **Open in Xcode:**
   ```bash
   open BitStream.xcodeproj
   ```

3. **Bundle yt-dlp:**
   - Download the latest `yt-dlp` binary from [yt-dlp releases](https://github.com/yt-dlp/yt-dlp/releases)
   - Add it to your project resources
   - Ensure it's marked as executable

4. **Install FFmpeg (optional but recommended):**
   ```bash
   brew install ffmpeg
   ```

5. **Build and run** on macOS (Cmd + R)

---

## 🛠️ Technologies Used

- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive programming and data flow
- **AppKit** - Native macOS integration (Finder, file system)
- **yt-dlp** - Media download engine
- **FFmpeg** - Format conversion and merging
- **UserDefaults** - Settings and history persistence
- **JSON Codable** - Data serialization

---

## 🎯 Architecture Highlights

**MVVM Pattern**
- Clean separation of concerns
- Testable business logic
- Reactive UI updates via Combine

**Modular Design**
- Single responsibility per component
- Reusable view components

**Best Practices**
- Files kept under 250 lines
- Composition over inheritance
- Type-safe enums for configuration
- Proper error handling
- Memory-safe async operations

---

## 🚧 Roadmap - Coming Soon

### High Priority

**1. Queue System** 🔄
- Add multiple URLs to the download queue
- Sequential or parallel downloads (user-configurable)
- Pause/resume individual items
- Drag-and-drop queue reordering
- Queue persistence across app launches

**2. Playlist & Channel Support** 📋
- Download entire playlists or channels
- Select specific videos from the playlist
- Auto-numbering to maintain order
- Show total playlist size before downloading
- Bulk format selection for playlists

**3. URL Validation & Preview** 🔍
- Validate URL before downloading
- Show video/audio metadata (title, duration, uploader)
- Thumbnail preview
- Estimated file size
- Warning for large downloads

**4. Preset System** ⚡
- Save format/quality combinations
- Quick preset switching
- Import/export configurations
- Built-in templates (Mobile, Archive, Podcast, etc.)

**5. Keyboard Shortcuts** ⌨️
- Quick download (Cmd + D)
- Paste URL (Cmd + V)
- Cancel download (Cmd + .)
- Clear history (Cmd + K)
- Full keyboard navigation support

### Medium Priority

**6. Smart File Management**
- Customizable filename templates
- Duplicate detection with auto-rename
- Auto-cleanup old history entries
- Special character removal options

**7. Subtitle & Extras**
- Auto-download subtitles (multi-language)
- Embed subtitles option
- Download and save thumbnails
- Chapter marker preservation

**8. Enhanced Search & Filter**
- Search downloads by title/URL/date
- Filter by type, format, date range
- Export history (CSV/JSON)
- Statistics dashboard

**9. Browser Integration**
- Safari extension for "Download with BitStream"
- Clipboard monitoring for URLs
- Drag-and-drop URL support

**10. Download Scheduler**
- Schedule downloads for off-peak hours
- Bandwidth limiting
- Auto-retry failed downloads
- Resume interrupted downloads

---

## 🎨 Design Philosophy

BitStream prioritizes:
- **User Experience**: Intuitive, modern interface with thoughtful animations
- **Performance**: Efficient resource usage, responsive UI
- **Reliability**: Robust error handling, network resilience
- **Maintainability**: Clean code, modular architecture, comprehensive documentation

---

## 🤝 Contributing

This is a professional-grade solo dev project demonstrating real-world workflows, including:
- Git flow and version control
- Modular architecture
- Code organization and best practices
- Documentation standards

Contributions, suggestions, and feedback are welcome

---

## 📄 License

MIT License © 2025
See the [MIT License](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - Powerful media download tool
- [FFmpeg](https://ffmpeg.org/) - Multimedia framework
- SwiftUI community for inspiration and best practices

---

**Built with ❤️ using Swift and SwiftUI**
