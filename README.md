
# Table of Contents

1.  [Reaper-Keys](#org8226321)
    1.  [Pros](#org8e78f9a)
        1.  [Bind key sequences](#org5805ef3)
        2.  [Compose actions](#org53e0c82)
        3.  [Multi-modal](#org02723cf)
        4.  [Macros](#org33b7bc1)


<a id="org8226321"></a>

# Reaper-Keys

Reaper-Keys is an extension for the [REAPER DAW](https://www.reaper.fm/), that provides a new action
mapping system based on key sequences instead of key chords. The system is 
very similar to [Vim](https://en.wikipedia.org/wiki/Vim_%28text_editor%29), a modal text editor, and by default comes with vim-like bindings. 

Reaper-keys provides features like composable actions, macros, multiple edit
modes and more.


<a id="org8e78f9a"></a>

## Pros

-   Saving a couple minutes per hour
-   Developing arthritis at 60 instead of 40
-   Reduced mouse usage
-   A more fluid experience


<a id="org5805ef3"></a>

### Bind key sequences

With reaper-keys, you may bind key sequences to actions, rather then singular
key presses. This allows one to make use of mnemonics, such as 't' for track,
or 'a' for arming.

A completion/feedback window is provided to assist with command completion. Here
is an example of navigating through the menu to render a project.

![img](img/save.gif)


<a id="org53e0c82"></a>

### Compose actions

Reaper-keys  lets one compose actions of different types to create new commands.
For example, any `timeline motion`  action can follow any  `timeline operator`
action, and any `number` can prefix a `timeline motion`.

If one enters `c2L` it would compose into `(c = "Change", 2, L = "NextMeasure")`,
and trigger a command to set up a record loop and record over the next 2 measures.

![img](img/change.gif)

To select the items in the next 2  measures, one could enter `s2L`.

![img](img/select.gif)

This grows the number of available actions exponentially but still preserves your
brain, as you only need to know the `timeline_motions`, `timeline_operators`, and
the fact that you can compose them. 


<a id="org02723cf"></a>

### Multi-modal

Changing modes changes the way keys compose. By default, it is in `normal` mode, but you could for example go into `visual timeline` mode by pressing `v`.

In this mode, `timeline motions` extend the current time selection, and `timeline
actions` operate immediately and return one to `normal` mode. Useful if you want
visual feedback before executing a timeline action, or just want to extend the
time selection using motion commands.

![img](img/visual_timeline.gif)


<a id="org33b7bc1"></a>

### Macros

Macros are a way to save a sequence of commands, and play them back later.

To record a macro, enter `q` and an arbitrary character to specify the `register` that
the macro will save into. Then, perform a series of actions, and finish
recording by pressing `q`. 

![img](img/rec_macro.gif)

You may play it back by entering `@` and the character you specified earlier.
Optionally, prefix it with a number to indicate the number of repetitions.

![img](img/play_macro.gif)

Here is an example of recording and playing a macro that deletes item parts across
two tracks in a ribbon style.

