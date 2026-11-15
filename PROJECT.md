# PROJECT.md: Drawing App Plan

This file records the plan for the app. The product owner makes the design
decisions. Anything marked **TO DECIDE** is waiting for the product owner's
answer.

*Last updated: 8 November 2026*

## Where we are now

- **Built:** 8 of the 9 must-have features are ✅. The last one, "Clear
  toolbar and layout", is ⚠️ because the Tools tab and the bottom panel are
  still empty. The left panel is now the Properties panel.
- **Next steps:**
  1. Run the [device tests](#device-tests) on a phone, iPad, laptop and PC.
  2. Answer the **TO DECIDE** questions below (app name, who it's for, purpose, what goes in the Tools tab and the bottom panel).
  3. Finish the toolbar and layout.

## The basics

| | |
|---|---|
| **App name** | **TO DECIDE.** The browser tab says "Drawlab!!", but the top panel says "My Drawing App". Pick one name for both. |
| **Who it's for** | **TO DECIDE.** For example: kids, students, or anyone who wants to sketch quickly. |
| **Purpose** | **TO DECIDE.** Fill in: "My app lets ___ draw ___ so that ___." |
| **Runs on** | A web browser. It's one file, `hello.html`, and needs nothing installed. |
| **Devices** | Phone, iPad, laptop and PC (decided) |

## Expected behaviour (decided)

- **On start up:** the Home tab is open (and its button is bold), so the
  tools, colours and size are ready straight away.

- **If the pointer leaves the canvas:** the line stops. If the pointer comes
  back while still pressed, the line stays stopped. You have to press again to
  draw. This works the same for a mouse, a finger and a stylus.
- **On phones and iPads:**
  - The page fits the screen, and the toolbar wraps onto more lines.
  - Corner handles, the rotate handle and the panel bars are bigger, so they're easy to grab with a finger.
  - A 🗑 Delete button does the job of the Delete key.
  - Lines join when you start drawing near a line's end, because fingers can't hover to show the blue dot.
  - A second finger is ignored while the first one is drawing.
  - Holding still for a straight line ignores small finger wobbles.
  - On small screens, the left and bottom panels start small.

## Version 1: must-have features

Status: ✅ built, ⚠️ partly built, ❌ not built yet

| Feature | Why it matters | Status |
|---|---|---|
| Drawing canvas | Gives users a space to create artwork | ✅ Fills the space between the panels and grows with the window. It never shrinks, so no part of a drawing is ever lost. |
| Basic brush | Lets users draw freehand | ✅ Works with a mouse, a finger or a stylus. A single tap or click leaves a dot. |
| Colour palette | Lets users express ideas with different colours | ✅ Colour picker plus 4 quick colours (black, red, blue, green) |
| Brush-size control | Thin lines for detail, thick lines for colouring large areas | ✅ Slider from 1 to 40 (starts at 5), plus Thin (2), Medium (10) and Thick (30) buttons. A preview dot shows the exact size. Also sets the Eraser size and the outline of new shapes. |
| Eraser | Fixes one part of a drawing | ✅ A separate tool (Home → Tool: Eraser). It truly removes drawing (the pixels become empty), not paints over it. It doesn't change your colour, so going back to Brush keeps the colour you picked. Erases brush drawing only. Text and shapes are separate objects, so they're removed with Delete instead (see Design decisions). |
| Undo | Takes back a mistake | ✅ "↶ Undo" button and Ctrl+Z. Undoes drawing, text, shapes, moving, resizing, rotating, colours, fonts, Delete and Clear. There's no limit on steps (they're kept until the page is closed or refreshed). |
| Clear canvas | Starts a new picture | ✅ "Clear" and "New Drawing" buttons. Also removes text and shapes, and can be undone. |
| Save as PNG | Keeps the artwork after the browser closes | ✅ "Save Picture" downloads `my-drawing.png`, with text and shapes. Saves exactly the part you can see. |
| Clear toolbar and layout | Makes the app easy to understand | ⚠️ The top panel (Home and Insert tabs, Undo, Delete, Save, New Drawing) works and wraps on small screens. The left panel is the **Properties** panel. The bottom panel is still empty. Both side panels can be resized by dragging. The **Tools** tab does nothing yet. |

## Extra features already built

These aren't on the must-have list.

**TO DECIDE:** keep them in version 1, or count them as bonus features?

**Drawing helpers**
- **Straight lines:** hold still for 2 seconds while drawing, and the line turns straight. Keep holding to aim it.
- **Joining lines:** start a line near the end of another line, and it joins on. With a mouse, a blue dot shows where it will join.
- **Tool switch:** Home has three tools: Cursor (select and edit things), Brush (draw) and Eraser (rub out drawing). Picking a colour while the Eraser is on switches back to the Brush.

**Text (Insert tab)**
- Text boxes: click to place one, type, and click it again later to edit.
- Text size setting.

**Shapes (Insert tab)**
- Rectangle, circle, triangle and line. They use the brush colour and size.

**Properties panel (left panel)**
- Shows the options for the selected text box, shape or line. With nothing selected, it shows a hint.
- **Colour** (text, shapes and lines): 12 colour squares, a colour wheel and R/G/B sliders. The heading says what it changes: "Text colour", "Outline colour" or "Line colour".
- **Thickness** (a slider): shapes and lines go from 1 to 40 (the outline). Text goes from 0 (normal) to 10 (very thick).
- **Show outline** (shapes, not lines): untick to hide a shape's outline.
- **Box outline** (text boxes only): a border round the text box, with Show outline, a colour and a thickness (1 to 20). It starts hidden. Picking a colour or thickness turns it on.
- **Fill** (text boxes and shapes, not lines): a colour inside. It starts empty. Picking a colour turns it on, and unticking Fill makes it empty again.
- **Size** (type a number): W and H for shapes and lines, Text size (8 to 300) for text boxes. The item grows or shrinks around its middle.
- **Rotation** (type a number): for example, type 90 and the item turns to 90°. The box keeps up when you rotate with the round handle.
- **Font** (text boxes only): 8 fonts. It's at the bottom of the panel, because the font list is long.
- The panel shows the selected item's own thickness, size and angle, and they update while you drag the handles.
- For text: highlight some letters to change just those, or change the whole box when nothing is highlighted. This works for Colour, Font and Thickness.
- On small screens, the panel opens up wider when you select something.

**Working with text boxes and shapes (Cursor tool)**
- Click to select. Only the selected item shows its blue border and handles.
- Drag to move.
- Pull a corner to resize. Text gets bigger, and shapes stretch.
- Drag the round handle to rotate. A label next to the pointer shows the angle in degrees while you rotate. On a laptop or PC, hold Shift to snap to 15° steps.
- Delete the selected item with the 🗑 Delete button, or the Delete or Backspace key.

**Layout**
- Properties panel on the left, and an empty bottom panel. Drag the bar next to each one to make it bigger or smaller.

## Saved for version 2

**TO DECIDE.** Some ideas to choose from:

- A paint bucket (fill an area with colour)
- Redo (the opposite of Undo)
- Opening a saved picture to keep working on it
- Lines that can slope either way (right now a line always goes bottom-left to top-right)
- Layers, so you can put a shape behind or in front of other things
- Saving the drawing automatically, so a refresh doesn't lose it

## Version 1 is finished when

**TO DECIDE.** A suggestion to start from:

- [ ] Every must-have feature above is ✅
- [x] Undo works for brush strokes, text and shapes
- [ ] A new user can work out every button without being told
- [ ] It works on a phone, an iPad, a laptop and a PC (see the device tests)
- [ ] One app name is used everywhere

## Device tests

So far these have only been checked on a PC, with automatic tests and a
phone-sized window. They still need to be done on real devices.

**How to open the app on a phone or iPad:** on the PC, open a terminal in the
`learn web` folder and run `python -m http.server 8000`. Then, on a phone or
iPad on the same Wi-Fi, open `http://192.168.3.5:8000/hello.html` (that's this
PC's address on the network, so it may change).

Tick each test on each device: Phone, iPad, Laptop, PC.

**Leaving the canvas**
- [ ] Draw a line and slide off the edge of the canvas while still pressing. The line stops at the edge.
- [ ] Keep pressing and come back onto the canvas. No new line appears.
- [ ] Lift or let go, then press again on the canvas. Drawing works normally.
- [ ] Draw off the edge into the top panel and the left panel. The line stops at the edge both times.

**Drawing**
- [ ] A quick tap or click leaves a dot.
- [ ] Freehand lines follow your finger, mouse or stylus with no gaps.
- [ ] Change the colour and size, then draw. The new colour and size are used.
- [ ] The size starts at 5. The slider goes from 1 to 40, and the number and preview dot change as you slide.
- [ ] Press Thin, Medium and Thick. The slider jumps to 2, 10 and 30, and the pressed button goes bold.
- [ ] Draw a thin line, switch to Thick and draw again. The new line is thick, and the old line stays thin.
- [ ] Change the size. The colour doesn't change. Change the colour. The size doesn't change.
- [ ] Pick a colour (like red), switch to Eraser and rub out part of a line, then switch back to Brush. You draw in red again.
- [ ] While the Eraser is on, add a shape or text box. It uses your colour, not white.
- [ ] While the Eraser is on, pick a colour. The tool switches back to Brush.
- [ ] Erase part of a line, then Undo (with the Eraser still on). The erased part comes back.
- [ ] Erase part of a drawing, then Save Picture. The erased spots are white in the saved PNG, not see-through or black.
- [ ] Hold still for 2 seconds while drawing. The line goes straight. Move to aim it, then let go.
- [ ] Start a new line near the end of an old one. They join.
- [ ] Phone/iPad: draw with one finger, then touch the canvas with a second finger. No extra line appears.

**Layout**
- [ ] Open or refresh the app. The Home tab is already open and its button is bold. Press Home to close it, and Insert to switch.
- [ ] Phone (upright): every toolbar button can be seen, with nothing cut off on the right.
- [ ] Phone/iPad: turn the device sideways and back. The canvas fills the space, and the drawing is still there.
- [ ] Drag both panel bars in and out. The drawing is never cut off.
- [ ] Phone: the page doesn't zoom when you double-tap a button.

**Text and shapes**
- [ ] Add a text box. The keyboard appears on phone and iPad, and you can type.
- [ ] Add a shape, then drag it, resize it from a corner and rotate it with the round handle.
- [ ] While rotating, a label shows the angle (like 90°) and disappears when you let go. Phone/iPad: your finger doesn't cover it.

**Properties panel**
- [ ] With nothing selected, the panel says "Select a text box, shape or line to change it."
- [ ] Select a shape or line. Colour shows, but Font doesn't. Pick a colour. The shape changes.
- [ ] Select a text box. Colour and Font both show. Pick a colour and a font. The whole box changes.
- [ ] Click into a text box, highlight a few letters, then pick a colour and a font. Only those letters change.
- [ ] Use the colour wheel and the R/G/B sliders on a selected item. The colour changes as you move them.
- [ ] Select a shape or line. The Thickness slider shows its current thickness. Slide it. The outline changes as you slide, and the brush Size in Home doesn't change.
- [ ] Select a text box and slide Thickness up and back to 0. The whole box gets thicker, then back to normal.
- [ ] Highlight a few letters and slide Thickness. Only those letters get thicker.
- [ ] Select a shape. Type a new W and H. The shape changes size and stays in the same place.
- [ ] Select a text box. Type a new Text size. The text gets bigger or smaller.
- [ ] Select anything and type 90 in Rotation. It turns to 90°. Type 0 and it goes back.
- [ ] Rotate or resize with the handles. The Rotation and Size numbers update as you drag.
- [ ] Select a rectangle, circle or triangle. Pick a Fill colour. The inside fills in. Untick Fill. It's empty again.
- [ ] Untick Show outline on a shape with a fill. Only the fill shows. Tick it again. The outline comes back.
- [ ] Select a line. There's no Fill and no Show outline (a line is just its outline).
- [ ] Select a text box. Pick a Box outline colour. A border appears round the box. Slide its thickness. The border gets thicker. Untick Show outline. The border goes.
- [ ] Pick a Fill colour for a text box. The box fills in behind the text.
- [ ] Select a different item, then go back. The panel shows each item's own outline and fill.
- [ ] Change an outline or fill, then Undo. It goes back.
- [ ] Save Picture keeps the fills and outlines (and hidden outlines stay hidden).
- [ ] Change a thickness, size or rotation in the panel, then Undo. It goes back.
- [ ] Save Picture keeps thick text, thick outlines, sizes and rotations.
- [ ] Click an empty part of the canvas. The panel goes back to the hint.
- [ ] Home still has the brush Colour, Quick colours and Size, and no Font or Text Colour.
- [ ] Phone: select something. The Properties panel opens up wide enough to use.
- [ ] Select an item and press 🗑 Delete. It's removed. On a laptop or PC, also try the Delete key.

**Undo and saving**
- [ ] Undo removes the last thing you did, several times in a row.
- [ ] Make more than 50 changes, then keep pressing Undo. You can go all the way back to the empty canvas.
- [ ] Save Picture downloads a PNG that looks like the screen (with text and shapes).

## Design decisions

- **The eraser only erases the brush drawing.** Text boxes and shapes are
  separate objects that sit on top of the drawing. To remove one, select it and
  press Delete. This is how most apps with separate objects work, like
  PowerPoint, Google Slides and Canva.
- **The canvas never gets smaller.** When a panel or the window takes up more
  room, the part of the canvas that doesn't fit is hidden, not cut off. Making
  the space bigger again brings it back. Save Picture saves only the part you
  can see.
- **A line stops when the pointer leaves the canvas** and doesn't start again
  until you press again (see Expected behaviour).

- **The Eraser is a separate tool, not a colour.** It doesn't change the colour
  you picked, so switching back to Brush brings your colour back.
- **The Eraser truly removes drawing.** It cuts the drawing away so those
  pixels are empty, instead of painting white over them. The drawing sits on a
  see-through layer with a white background behind it, and Save Picture adds
  that white background to the saved PNG.

- **Brush size: a slider plus three preset buttons**, because it's
  straightforward for the user and keeps the app simple. Smallest 1, largest
  40, default 5. A preview dot shows the current size. Changing the size only
  affects new lines, and size and colour never change each other.

- **The left panel is the Properties panel.** When a text box, shape or line
  is selected, its options (Colour, and Font for text) are shown there. They
  moved out of Home. The brush Colour, Quick colours and Size stay in Home,
  because they're for drawing, which works with nothing selected.
- **Thickness, Size and Rotation are in the Properties panel.**
  - Thickness is a slider for everything. For shapes and lines it's the outline (1 to 40). For text it's 0 to 10.
  - Text thickness is made by drawing an outline round each letter in the same colour, so it works with every font. (Normal and Bold buttons were tried first, but a slider was wanted.)
  - Size and Rotation are number boxes, so you can type exact values like 90°.
  - Font comes last in the panel, because its list is long.
- **Outline and Fill are in the Properties panel.**
  - A shape's outline uses the big Colour section and the Thickness slider, plus a Show outline tick box.
  - A text box's Colour and Thickness are for its letters, so its box outline has its own colour, thickness and Show outline in a "Box outline" section.
  - Fill works the same for text boxes and shapes.
  - Lines get no Fill and no Show outline, because a line is only an outline.
  - New text boxes start with no outline and no fill, and new shapes start with an outline and no fill, so nothing changes until you ask for it.

## Known issues

- The **Tools** tab button does nothing.
- The bottom panel is empty. **TO DECIDE:** what goes in it?
- The Properties Colour controls don't show the selected item's current colour yet. They show the last colour you picked.
- After you erase a line, its ends are still remembered, so it can still join
  onto a new line (and the blue dot can still appear there).
- Shift to snap rotation only works with a keyboard, so phones and iPads can't snap.
- The file is still called `hello.html`. It could be renamed to match the app.
