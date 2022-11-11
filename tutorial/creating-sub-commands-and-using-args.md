# Creating sub-commands and using args

And now we are going to do a math command so lets create a command:

```lua
return {
	["math"] = {}
}
```

As you can see, this time we are not making it a function.

Now lets make the sub-command:

```lua
return {
	["math"] = {
		["addtion"] = function(args, cmdInterface, cmd)
		
		end),
	}
}
```

{% hint style="info" %}
Yep. Also commands are able to have mutliple sub-commands
{% endhint %}

Lets use args now:

```lua
return {
	["math"] = {
		["addtion"] = function(args, cmdInterface, cmd)
			local arg1 = args[1]
			local arg2 = args[2]
			
			if arg1 and arg2 then
				
			end
		end),
	}
}
```

{% hint style="danger" %}
Args are able to be nil so use if.
{% endhint %}

Last but not least, now we are doing the cmdInterface:newMsg()

```lua
return {
	["math"] = {
		["addtion"] = function(args, cmdInterface, cmd)
			local arg1 = args[1]
			local arg2 = args[2]
			
			if arg1 and arg2 then
				local num1 = tonumber(arg1)
				local num2 = tonumber(arg2)
				
				if num1 and num2 then
					cmdInterface:newMsg("Result is: " .. tostring(num1 + num2))
)				end
			end
		end),
	}
}
```

Now we are done!
