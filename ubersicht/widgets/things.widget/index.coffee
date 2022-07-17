refreshFrequency: 60000

homeDir = process.env['HOME']
sqliteDb = homeDir + '/Library/Containers/com.culturedcode.things/Data/Library/Application\ Support/Cultured\ Code/Things/ThingsLibrary.db'

todaySql = 'select ZTITLE from ZTHING where ZTRASHED=0 AND ZSTATUS=0 AND ZFOCUSLEVEL IS NULL AND ZSCHEDULER =1 AND ZSTART==1 AND ZTYPE=0 ORDER BY ZTITLE ASC'

command: "sqlite3 '#{sqliteDb}' '#{todaySql}' | awk 'BEGIN {print \"\"} {print substr($0,0)\"<br />\"} /^[*]/ {print \"<blockquote><li>\"substr($0,2)\"</li></blockquote>\"} END {print \"\"}'"

style: """
  border-radius: 6px
  padding: 0px 20px
  top: 1%
  left: 0px
  color: #fff
  font-family: Caviar Dreams
  font-weight:bold

  h
    display: block
    text-align: center
    font-size: 24px
    font-weight: 100

  div
    display: block
    text-shadow: 0 0 1px rgba(#000, 0.5)
    font-size: 14px

  ol
    padding-left: 20px

  .things_icon
    float:left

  .thingslist
    float:left

  .completed
    color: #888
    font-weight: regular
    text-decoration:line-through
"""


render: -> """
  <h>Today's Tasks</h>
  <div class='things_container'>
    <div class='things_icon'><img src="things.widget/things-icon.png" height="61" width="61"></div>
    <div class='thingslist'></div>
  </div>
"""

update: (output, domEl) ->
  $(domEl).find('.thingslist').html(output)