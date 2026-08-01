ytpdf() {
    # Check if at least one argument is provided
    if [ "$#" -lt 1 ]; then
        echo "Usage: ytpdf <YOUTUBE_URL>"
        return 1
    fi

    local url="$1"

    # Fetch the video ID (videoid)
    echo "Fetching video ID..."
    local videoid
    videoid=$(yt-dlp --get-id "$url" 2>/dev/null)

    if [ -z "$videoid" ]; then
        echo "Error: Could not retrieve video ID."
        return 1
    fi

    local srt_file="$videoid.srt"
    local pdf_file="$videoid.pdf"

    echo "Downloading subtitles to $srt_file..."
    # Download auto/manual subs directly to <videoid>.srt
    yt-dlp --write-auto-sub --sub-lang en --sub-format srt --skip-download -o "$videoid" "$url"

    # yt-dlp appends .en.srt by default; rename it to clean <videoid>.srt if needed
    if [ ! -f "$srt_file" ]; then
        if [ -f "$videoid.en.srt" ]; then
            mv "$videoid.en.srt" "$srt_file"
        fi
    fi

    if [ -f "$srt_file" ]; then
        echo "Converting $srt_file to $pdf_file..."
        cat "$srt_file" | ~/.local/bin/str2pdf "$pdf_file"
        echo "Done! Saved $srt_file and $pdf_file."
    else
        echo "Error: Failed to download $srt_file"
        return 1
    fi
}
