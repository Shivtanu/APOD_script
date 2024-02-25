#!/bin/bash

# NASA API key
API_KEY="imjxzKCRle3s1Ke5bael0JKoqFb3enSEJ7vnGGqP"

# Function to fetch and display image and description for a given date
fetch_image_and_description() {
    local date=$1
    local apod_data=$(curl -s "https://api.nasa.gov/planetary/apod?date=$date&api_key=$API_KEY")
    
    if [[ $(echo "$apod_data" | jq -r '.media_type') == "image" ]]; then
	local title=$(echo "$apod_data" | jq -r '.title')
        local image_url=$(echo "$apod_data" | jq -r '.url')
        local description=$(echo "$apod_data" | jq -r '.explanation')
        
        # Generate HTML
        cat <<EOF > apod_$date.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>APOD - $date</title>
</head>
<style>
	body{
		Font-family: ‘Arial’, sans-serial;
		Background-color: #001F3F;
		Color: #ffffff;
		margin: 0;
		padding: 100px;
		text-align: center;
	}
	h1{
		font-size: 38px;
		margin-bottom: 20px;
	}
	h2{
		font-size: 22px;
	}
	img{
		max-width: 100%;
		height: auto;
		border-radius: 8px;
		box-shadow: 0 0 10px rgba(255, 255, 255, 0.3);
	}
	p{
		font-size: 20px;
		line-height: 1.6;
	}
</style>
<body>
    <h1>Astronomy Picture of the Day - $date</h1>
	<h2>$title</h2>
    <img src="$image_url" alt="APOD Image">
    <p>$description</p>
</body>
</html>
EOF

        # Open HTML file in default browser
 	cmd.exe /C start chrome.exe "http://localhost:8000/apod_$date.html"
    fi
}
# Function to fetch and display image and description for a given date
fetch_image_and_description_range() {
    local date=$1
    local apod_data=$(curl -s "https://api.nasa.gov/planetary/apod?date=$date&api_key=$API_KEY")
    
    if [[ $(echo "$apod_data" | jq -r '.media_type') == "image" ]]; then
	local title=$(echo "$apod_data" | jq -r '.title')
        local image_url=$(echo "$apod_data" | jq -r '.url')
        local description=$(echo "$apod_data" | jq -r '.explanation')
        
        echo "<h1>Astronomy Picture of the Day - $date</h1>" >> apod_range.html
	echo "<h2>$title</h2>" >> apod_range.html
        echo "<img src=\"$image_url\" alt=\"APOD Image\">" >> apod_range.html
        echo "<p>$description</p>" >> apod_range.html
    fi
}

# Check the number of arguments
if [[ $# -eq 1 ]]; then
    # If only one argument is provided, display APOD for that date
    fetch_image_and_description "$1"
elif [[ $# -eq 2 ]]; then
    # If two arguments are provided, fetch images from start to end date
    start_date=$1
    end_date=$2
    
    # Generate HTML file for range
    cat <<EOF > apod_range.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>APOD - Range</title>
</head>
<style>
        body{
                Font-family: ‘Arial’, sans-serial;
                Background-color: #001F3F;
                Color: #ffffff;
                margin: 0;
                padding: 100px;
                text-align: center;
        }
        h1{
                font-size: 38px;
                margin-bottom: 20px;
		margin-top: 100px;
        }
	h2{
		font-size: 22px;
	}

        img{
                max-width: 100%;
                height: auto;
                border-radius: 8px;
                box-shadow: 0 0 10px rgba(255, 255, 255, 0.3);
        }
        p{
                font-size: 20px;
                line-height: 1.6;
        }
</style>
<body>
EOF

    # Iterate through dates and fetch images with descriptions
    current_date=$start_date
    while [[ $(date -d "$current_date" +%s) -le $(date -d "$end_date" +%s) ]]; do
        fetch_image_and_description_range "$current_date"
        current_date=$(date -d "$current_date + 1 day" +%Y-%m-%d)
        sleep 1  # optional delay between fetching images
    done

    echo "</body></html>" >> apod_range.html

    # Open HTML file in chrome on windows
    cmd.exe /C start chrome.exe "http://localhost:8000/apod_range.html"
else
    echo "Usage: $0 <date> or $0 <start_date> <end_date>"
    exit 1
fi


#code for creating server
#python3 -m http.server
