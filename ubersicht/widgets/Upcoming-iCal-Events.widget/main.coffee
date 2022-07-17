# Author: Connor Beardsmore <connor.beardsmore@gmail.com>
# Last Modified: 22/03/18

# Bash command to pull events from icalBuddy
# Set +2 to how many days you want to show
# icalBuddy has more functionality that can be used here
command: "/usr/local/bin/icalBuddy -n eventsToday+2"

# Update is called once per hour
refreshFrequency: "1h"

# CSS styling
style: """
    top: 10px
    top: 1.3%
    right: 1%
    color: black
    font-family: Open Sans
    font-weight: normal
    line-height: 1.5
    opacity: .5
    padding 15px
    border-radius 5px
    border: solid 2px rgba(255,255,255,.3)

    div
        display: block
        color white
        font-size: 14px
        font-weight: 450
        text-align left

    #head
        font-weight: bold
        font-size: 14px
        text-transform: uppercase

    #subhead
        font-weight: bold
        font-size: 12px
        text-transform: uppercase
        border-bottom solid 1px clear
        padding-top: 10px
        padding-bottom: 0
    .cal
        font-size: 9px
        font-weight: bold
        background: white
        opacity: .5
        color: black
        padding: 1px 4px
        border-radius: 4px
        text-transform: uppercase
    .time
        font-weight: bold
"""

# Initial render for heading
render: (output) -> """
"""

# Update when refresh occurs
update: (output, domEl) ->
    lines = output.split('\n')
    bullet = lines[0][0]
    dom = $(domEl)
    
    dom.empty()
    dom.append("""<div id="head"> Upcoming Events </div>""")

    # Show which calendar you pulled from before event name
    SHOW_CALENDER = true
    # Ignore specific calendars
    IGNORE_CALENDER = [ 'name of calendar to ignore', 'other calendar etc' ]
    # Show full date including time
    SHOW_DATE_TIME = true
    # Characters after this value will be replaced with ...
    MAX_CHARACTERS = 50

    # Filter out all lines that aren't event headers or dates
    lines = lines.filter (x) -> ( ( x.startsWith(bullet) ) ||
                         ( x.search('(today|tomorrow)') != -1  ) )

    #Add No Events tag if nothing upcoming
    if ( lines.length == 0 )
        # Don't add tag twice
        if (! dom.text().includes("No Events"))
            dom.append(""" <div id="subhead"> No Events </div> """)
        return

    # Go over all events and append data into the DOM
    for i in [0...lines.length-1]
        # Print today subheading
        header = ""
        if (lines[i+1].startsWith("    today"))
            if (! dom.text().includes('Today'))
                header = 'Today'
        # Print tomorrow subheading
        else if ( lines[i+1].startsWith("    tomorrow") )
            if (! dom.text().includes('Tomorrow'))
                header = 'Tomorrow'
        # Print later subheading
        else if ( lines[i+1].startsWith("    day after"))
            if (!dom.text().includes('Day After Tomorrow'))
                header = 'Day After Tomorrow'

        # If required add in the header
        if (header != "")
            dom.append("""<div id="subhead">#{header}</div> """)

        # Events start with bullet point
        if (lines[i][0] == bullet)
            nameAndCalendar = lines[i].split('(')

            if nameAndCalendar.length < 2
            	continue

            name = nameAndCalendar[0].replace(bullet, '')
            calendar = nameAndCalendar[1].replace(')','')

            if IGNORE_CALENDER.includes(calendar)
                continue

            if ( name.length > MAX_CHARACTERS )
                name = name.substr(0, MAX_CHARACTERS) + "..."

            date = ((lines[i+1].split("at"))[1])
            if ( date == undefined )
                date = ""
            else
                date = date.substr(0,9)

            # Combine all fields
            final = name
            if (SHOW_DATE_TIME)
                final = "<span class='time'>" + date + "</span>" + final
            if (SHOW_CALENDER)
                final = final + "<span class='cal'>" + calendar + "</span>"


            # Add this HTML to previous
            dom.append("""<div>#{final}</div>""")