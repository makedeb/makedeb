# Code styling
1\. We use double spaces for indentation. Note that this means you **CAN NOT** use tabs. Some editors also have the ability to auto-indent on spaces - just make sure it saves to the file as double spaces and not tabs.

2\. Lines for nested indentations should not be separated by spaces.

I.e. **DO NOT** do this:

```sh
while true; do

  if [[ "${i}" == "e" ]]; then
    echo "yo"

    echo "whoah"
  fi

done
```

But rather do this:
```sh
while true; do
  if [[ "${i}" == "e" ]]; then
    echo "yo"

    echo "whoah"
  fi
done
```

Outside of indenting, spacing between lines should happen on a case by case basis - just make sure you're grouping logical pieces of code with each other.

3\. In general, if it makes sense to put something in a function, put it inside a function (see the directory layout in the next guideline for specific information on where to place them).

4\. Functions should also be isolated by themselves inside of files. The name of the file should also match the name of the contained function.

5\. Any lines that should be removed from `makedeb.sh` or function files should be appended with `# REMOVE AT PACKAGING`. The beginning of `makedeb.sh` contains a good example of such, which contains a chunk of code for sourcing functions from function files during build time.

Note that you shouldn't use this to improve styling in the built package, but rather only to omit commands.

# Directory layout
1\. All functions should be placed in the `src/functions/` folder.

2\. If your function is specific to a certain aspect of makedeb, feel free to put the function inside of a subfolder as well (see `src/functions/control_file/` as an example).

3\. All functions are automatically sourced before makedeb starts, so all that's needed to run a function is to call its name.
