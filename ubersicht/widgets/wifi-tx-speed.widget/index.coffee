# WiFi Transmission Speed Widget
#
# Joe Kelley
#
# Unlike the little "signal strength" icon, this simple little widget tells you how fast your WiFi connection is actually communicating
# It uses the built-in OS X airport framework to get the actual transmission speed calculated using the most recent wireless network traffic
# It is particularly useful for finding the best place to position your computer and/or access point for best performance.

command: "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep TxRate | cut -c 18-20"

refreshFrequency: '5s'

# Adjust the style settings to suit. I've set the position to be just below the WiFi icon in my menu bar.

style: """
  top: 0.5%
  left: 50%
  color: rgba(#fff, 0.5)
  font-family Open Sans


  div
    display: block
    border: 2px solid rgba(#fff, 0.5)
    border-radius 5px
    text-shadow: 0 0 1px rgba(#000, 0.5)
    background: rgba(#000, 0.5)
    font-size: 11px
    font-weight: 400
    padding: 4px 6px 4px 6px
    


    &:after
      content: 'WiFi Tx'
      font-family Open Sans
      text_align: "center"
      position: absolute
      color: rgba(#fff, 0.5)
      left: 40px
      top: 4px
      font-size: 9px
      font-weight: 300
      
 img
    height: 24px
    width: 24px
    margin-bottom: -3px
      
"""

render: -> """
  <div><img src="wifi-tx-speed.widget/icon48.png">
   <a class='tx_speed'></a></div>
"""

update: (output) ->
	if(output)
  		$('.tx_speed').html(output + 'Mbps')
  	else
  		 $('.tx_speed').html(output + 'WiFi OFF')

