ytpdf() {
    # 1. Check for required URL argument
    if [ "$#" -lt 1 ]; then
        echo "Usage: ytpdf <YOUTUBE_URL>" >&2
        return 1
    fi

    local url="$1"

    # 2. Fetch the video ID (videoid)
    echo "Fetching video ID..."
    local videoid
    videoid=$(yt-dlp --get-id "$url" 2>/dev/null)

    if [ -z "$videoid" ]; then
        echo "Error: Could not retrieve video ID." >&2
        return 1
    fi

    local srt_file="${videoid}.srt"
    local pdf_file="${videoid}.pdf"

    # 3. Download subtitles
    echo "Downloading subtitles to $srt_file..."
    yt-dlp --write-auto-sub --sub-lang en --sub-format srt --skip-download -o "$videoid" "$url"

    # 4. Handle default yt-dlp language suffix appending
    if [ ! -f "$srt_file" ]; then
        if [ -f "${videoid}.en.srt" ]; then
            mv "${videoid}.en.srt" "$srt_file"
        fi
    fi

    # 5. Convert to PDF using your local str2pdf script
    if [ -f "$srt_file" ]; then
        echo "Converting $srt_file to $pdf_file..."
        ~/.local/bin/str2pdf "$srt_file"
        echo "Done! Saved $srt_file and $pdf_file."
    else
        echo "Error: Failed to download $srt_file" >&2
        return 1
    fi
}
