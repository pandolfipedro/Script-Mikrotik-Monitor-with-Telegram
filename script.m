/*  By @pandolfipedro

Create New Script using interface, configure, save and run.

ping1 is a destination for your first ping test
ping2 is a destination for your second ping test
pingCount is a quantity of pings in one test
lossLimit is a limit for "down" notification
interval is a interval within each ping

With my predefined config you receive a notification if your ping1 and ping2 tested by 50 times with a 150ms interval and loss is more than 80%.

You  can change variables by yourself.

Please set new /ip route for destinations you want. USE MIKROTIK DOCS FOR INFO.

*/

:global stopScript false
:local ping1 "8.8.8.8"
:local ping2 "208.67.222.222"

:local pingCount 50 
:local lossLimit 80
:local interval 150ms

:local downText "ISP is now DOWN"
:local upText "ISP is now UP"

:local botID "YOUR TELEGRAM BOT ID" //put inside "" your telegram bot id.
:local chatID "YOUR TELEGRAM CHAT ID" //put inside "" your telegram chat id, get this using getUpdates command, see telegram api docs for more info.

:global link //global variable to store state of your isp link

:do {
:local loss1 (100 - (([/ping $ping1 count=$pingCount interval=$interval] * 100) / $pingCount))
:local loss2 (100 - (([/ping $ping2 count=$pingCount interval=$interval] * 100) / $pingCount))

:if (($loss1 > $lossLimit) && ($loss2 > $lossLimit)) do={ //if loss1 and loss2 is more than limit is notify the link down using your variables
	:if ($link="UP") do={
		:set link "DOWN";
		/tool fetch mode=https url="https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID&parse_mode=html&text=$downText" keep-result=no
		:log warning "$downText"
	} else={:set link "DOWN";}
} else={
	:if ($link="DOWN") do={	
		:set link "UP";
		/tool fetch mode=https url="https://api.telegram.org/bot$botID/sendMessage?chat_id=$chatID&parse_mode=html&text=$upText" keep-result=no
		:log warning "$upText"
	} else={:set link "UP";}
}
:delay 5
} while=(!$stopScript) // executes script while your change global variable to "true"
