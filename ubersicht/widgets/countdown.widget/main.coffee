MILLIS_IN_DAY: 24 * 60 * 60 * 1000
MILLIS_IN_HOUR: 60 * 60 * 1000
MILLIS_IN_MINUTE: 60 * 1000
MILLIS_IN_SECOND: 1000

countdowns: [
	label: "New Year's Day"
	time: "Jan 1, 2020 12:00 AM"
,
	label: "LISA Matures"
	time: "Nov 12, 2019"
]

command: ""

refreshFrequency: 1000

style: """
	top: 10px
	top: 1.3%
	left: 1%
	*
		margin 0
		padding 0
		font-family: Open Sans
		color rgba(#fff, .5)

	#container
    border-radius 5px
    border: solid 2px rgba(255,255,255,.3)
		font-family Open Sans
		padding 0
	
	.title
		background: rgba(255,255,255,.3)
		color: black
		font-weight: bold
		font-size: 14px
		text-transform: uppercase
		text-align: center

	ul
		list-style none

	li
		padding 0 0 5px

	thead
		font-size 8pt
		font-weight bold

		td
			width 60px

	tbody
		font-size 12pt

	td
		text-align center
"""

render: -> """
	<div id="container">
		<ul>
		</ul>
	</div>
"""

afterRender: ->
	for countdown in @countdowns
		countdown.millis = new Date(countdown.time).getTime()

update: (output, domEl) ->
	$countdownList = $(domEl).find("#container").find("ul")
	$countdownList.empty()

	now = new Date().getTime()

	# $root.html new Date
	# $root.html new Date @countdowns[1].time
	for countdown in @countdowns
		millisUntil = countdown.millis - now
		timeUntil = {}

		timeUntil.days = millisUntil // @MILLIS_IN_DAY
		millisUntil %= @MILLIS_IN_DAY

		timeUntil.hours = millisUntil // @MILLIS_IN_HOUR
		millisUntil %= @MILLIS_IN_HOUR

		timeUntil.minutes = millisUntil // @MILLIS_IN_MINUTE
		millisUntil %= @MILLIS_IN_MINUTE

		timeUntil.seconds = millisUntil // @MILLIS_IN_SECOND
		millisUntil %= @MILLIS_IN_SECOND

		$countdownList.append("""
			<li>
				<div class="title">#{countdown.label}</div>
				<table>
					<thead>
						<tr>
							<td>DAYS</td>
							<td>HOURS</td>
							<td>MINUTES</td>
							<td>SECONDS</td>
						</tr>
					</thead>

					<tbody>
						<tr>
							<td>#{timeUntil.days}</td>
							<td>#{timeUntil.hours}</td>
							<td>#{timeUntil.minutes}</td>
							<td>#{timeUntil.seconds}</td>
						</tr>
					</tbody>
				</table>
			</li>
		""")