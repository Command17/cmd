# Creating commands

Now lets make a simple command that shows us the version of the plugin

```lua
return {
	["version"] = function()
		
	end,
}
```

{% hint style="info" %}
A package is able to have more than one command.
{% endhint %}

Now lets make it show our version:

```lua
return {
	["version"] = function(args, cmdInterface, cmd)
		cmdInterface:newMsg("The version is: " .. cmd.Version)
	end,
}
```

Now we have simple command that shows us the version!
