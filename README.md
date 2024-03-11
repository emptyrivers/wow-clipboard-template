# Clipboard

An attempt to make an xml template that can be imported like a library. This probably won't go anywhere, but it's worth a try!

## Okay, but what's in here?

Oh I'm glad you asked! There's an intrinsic that I'm calling a ClipBoard, which is basically an EditBox which the user copy from, but can't edit in any way, and also a ScrollingClipBoardBox, which serves as a drop-in replacement for ScrollingEditBox, so you can have a ClipBoard that scrolls!

## I still don't understand why you'd want this

Well, really I wouldn't want this either, except that sometimes you want your addon's users to copy some text and paste it elsewhere (like, say, in a bug ticket). It would be GREAT if I could create a Button with a label that says 'Copy To Clipboard', and which does exactly that when you click it, but sadly Blizzard doesn't offer that functionality. So, we have to improvise. "Industry" "Standard" currently is to vomit some text into an EditBox, call HighLightText(), and hope for the best, but there are drawbacks, like:

- what if the user fat fingers a keypress and overwrites some or all of the text with garbage?
- what if the user changes the selection & only copies a subset of the text you put in their face?

This template attempts to solve that, by making it impossible for the user to do anything but copy the whole text you put up, and nothing else.

## Installation

To the extent possible, all of this code is public domain, so 'installing' really just means downloading the files & committing them directly. That being said...

### Get the names right

By far the most annoying thing about XML templates when it comes to libraries is that there's no good way to do version control. And nobody's yet written a github action or whatever to automatically change the names of the various virtual nodes & mixins to avoid collisions.

So, if you're willing to go thru it manually, I've tried to make it easy for you: All "namespaceable" bits of this "library" are prefixed with MyAddOn (MyAddOnClipBoardMixin, etc). Find & replace them with whatever your actual addon name is & you should be good to go.

I've provided a tiny script for your convenience (if you don't have grep & sed, it's not very convenient):

```sh
./fixmynames.sh MyAmazingAddOn # would replace MyAddOn with MyAmazingAddOn
```

### Extend the Schema

If you're a stickler for lint errors, then you'll need to extend the schema definition you're using when including this library. Again, I've made that as easy I could manage. You can either use `schema.xsd` as your shemaLocation in the Ui node, like this:

```xml
<Ui
  xmlns="http://www.blizzard.com/wow/ui/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  schemaLocation="http://www.blizzard.com/wow/ui/ path/to/ClipBoard/schema.xsd"
>
  <!-- xml crap go here -->
</Ui>
```

...or (the 'better' idea) include it in a root xsd file which serves as your schema, like this:

```xml
<xs:schema
  xmlns="http://www.blizzard.com/wow/ui/"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ui="http://www.blizzard.com/wow/ui/"
  targetNamespace="http://www.blizzard.com/wow/ui/"
>
  <xs:include  schemaLocation="https://raw.githubusercontent.com/Gethe/wow-ui-source/live/Interface/FrameXML/UI_shared.xsd" />
  <xs:include schemaLocation="path/to/ClipBoard/schema.xsd" />
</xs:schema>
```
