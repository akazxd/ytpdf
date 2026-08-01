function ytpdf --description "Download YouTube subtitles to <videoid>.srt and convert to <videoid>.pdf"
    if test (count $argv) -lt 1
        echo "Usage: ytpdf <YOUTUBE_URL>"
        return 1
    end

    set -l url $argv[1]

    # Fetch the video ID (videoid)
    echo "Fetching video ID..."
    set -l videoid (yt-dlp --get-id "$url" 2>/dev/null)

    if test -z "$videoid"
        echo "Error: Could not retrieve video ID."
        return 1
    end

    set -l srt_file "$videoid.srt"
    set -l pdf_file "$videoid.pdf"

    echo "Downloading subtitles to $srt_file..."
    # Download auto/manual subs directly to <videoid>.srt
    yt-dlp --write-auto-sub --sub-lang en --sub-format srt --skip-download -o "$videoid" "$url"

    # yt-dlp appends .en.srt by default; rename it to clean <videoid>.srt if needed
    if not test -f "$srt_file"
        if test -f "$videoid.en.srt"
            mv "$videoid.en.srt" "$srt_file"
        end
    end

    if test -f "$srt_file"
        echo "Converting $srt_file to $pdf_file..."
        cat "$srt_file" | ~/.local/bin/str2pdf "$pdf_file"
        echo "Done! Saved $srt_file and $pdf_file."
    else
        echo "Error: Failed to download $srt_file"
        return 1
    end
end
