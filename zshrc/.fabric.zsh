
# ================================================================
# 🤖 FABRIC AI PATTERNS - DYNAMIC OBSIDIAN INTEGRATION
# ================================================================
# * This file dynamically creates functions for all Fabric patterns
# * Each pattern can be used with or without a title parameter
# * Files are automatically saved to Obsidian vault with timestamps

# * Define the base directory for Obsidian notes
obsidian_base="/home/marcus/notes/Vortex/99-Setup/Al Chat History"

# * Loop through all files in the ~/.config/fabric/patterns directory
# ? This creates a function for each pattern found in the patterns directory
for pattern_file in ~/.config/fabric/patterns/*; do
    # * Get the base name of the file (i.e., remove the directory path)
    pattern_name=$(basename "$pattern_file")

    # * Remove any existing alias with the same name
    unalias "$pattern_name" 2>/dev/null

    # * Define a function dynamically for each pattern
    # ? Each function accepts an optional title parameter
    eval "
    $pattern_name() {
        local title=\$1
        local date_stamp=\$(date +'%Y-%m-%d')
        local output_path=\"\$obsidian_base/\${date_stamp}-\${title}.md\"

        # * Check if a title was provided
        if [ -n \"\$title\" ]; then
            # * If a title is provided, use the output path
            fabric --pattern \"$pattern_name\" -o \"\$output_path\"
        else
            # ? If no title is provided, use --stream for real-time output
            fabric --pattern \"$pattern_name\" --stream
        fi
    }
    "
done

# ================================================================
# 📺 YOUTUBE TRANSCRIPT FUNCTION
# ================================================================
# * Extract transcripts from YouTube videos with optional timestamps
# * Usage: yt [-t | --timestamps] youtube-link

# * YouTube Transcript extractor with timestamp support
yt() {
    if [ "$#" -eq 0 ] || [ "$#" -gt 2 ]; then
        echo "Usage: yt [-t | --timestamps] youtube-link"
        echo "Use the '-t' flag to get the transcript with timestamps."
        return 1
    fi

    transcript_flag="--transcript"
    if [ "$1" = "-t" ] || [ "$1" = "--timestamps" ]; then
        transcript_flag="--transcript-with-timestamps"
        shift
    fi
    local video_link="$1"
    
    # * Use fabric to extract the transcript
    fabric -y "$video_link" $transcript_flag
}