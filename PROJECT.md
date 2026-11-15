# PROJECT.md: Drawing App Plan

This file records the plan for the app. The product owner makes the design
decisions. Anything marked **TO DECIDE** is waiting for the product owner's
answer..

_Last updated: 15 November 2026_

## Where we are now

- **Built:** 8 of the 9 must-have features are ✅. The last one, "Clear
  toolbar and layout", is ⚠️ because the Tools tab and the bottom panel are
  still empty. The left panel is now the Properties panel.
- **New (15 November 2026):** accounts (kept in the browser), a home page
  with templates and your drawings, automatic saving, photos, stickers, more
  shapes, filters, PDF and SVG export, keyboard shortcuts, and sharing with
  project files. See [Accounts and the home page](#accounts-and-the-home-page).
- **New (15 November 2026, later):** real **online accounts** (Supabase), so your account and drawings work on any device; **friends**; and **chat** (1-to-1 and groups) in the bottom panel. See [Online accounts, friends and chat](#online-accounts-friends-and-chat). Before it works, follow [SETUP-ONLINE.md](SETUP-ONLINE.md) once.
- **Next steps:**
  1. Follow [SETUP-ONLINE.md](SETUP-ONLINE.md) to connect Supabase and put the site on GitHub Pages.
  2. Run the [device tests](#device-tests) on a phone, iPad, laptop and PC.
  3. Answer the **TO DECIDE** questions below (app name, who it's for, purpose, what goes in the Tools tab).
  4. Finish the toolbar and layout.

## The basics

|                  |                                                                                                                                              |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **App name**     | **TO DECIDE.** The log-in screen, home page and saved file names say "Drawlab". The browser tab says "Drawlab!!". Pick one.                  |
| **Who it's for** | **TO DECIDE.** For example: kids, students, or anyone who wants to sketch quickly.                                                           |
| **Purpose**      | **TO DECIDE.** Fill in: "My app lets **_ draw _** so that \_\_\_."                                                                           |
| **Runs on**      | A web browser. It's one file, `hello.html`, with nothing to install. It needs the internet: accounts, drawings, friends and chats are saved online (Supabase). The website is on GitHub Pages. |
| **Devices**      | Phone, iPad, laptop and PC (decided)                                                                                                         |

## Expected behaviour (decided)

- **On start up:** the log-in screen shows (or the home page, if you were
  still logged in). When you open a drawing, the Home tab is open (and its
  button is bold), so the tools, colours and size are ready straight away.

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

| Feature                  | Why it matters                                               | Status                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| ------------------------ | ------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Drawing canvas           | Gives users a space to create artwork                        | ✅ Fills the space between the panels and grows with the window. It never shrinks, so no part of a drawing is ever lost.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| Basic brush              | Lets users draw freehand                                     | ✅ Works with a mouse, a finger or a stylus. A single tap or click leaves a dot.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| Colour palette           | Lets users express ideas with different colours              | ✅ Colour picker plus 4 quick colours (black, red, blue, green)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| Brush-size control       | Thin lines for detail, thick lines for colouring large areas | ✅ Slider from 1 to 40 (starts at 5), plus Thin (2), Medium (10) and Thick (30) buttons. A preview dot shows the exact size. Also sets the Eraser size and the outline of new shapes.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| Eraser                   | Fixes one part of a drawing                                  | ✅ A separate tool (Home → Tool: Eraser). It truly removes drawing (the pixels become empty), not paints over it. It doesn't change your colour, so going back to Brush keeps the colour you picked. Erases brush drawing only. Text and shapes are separate objects, so they're removed with Delete instead (see Design decisions).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| Undo                     | Takes back a mistake                                         | ✅ "↶ Undo" button and Ctrl+Z. Undoes drawing, text, shapes, moving, resizing, rotating, colours, fonts, Delete and Clear. There's no limit on steps (they're kept until the page is closed or refreshed).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| Clear canvas             | Starts a new picture                                         | ✅ One **Clear** button (Home tab, at the end of the row), with a red outline. It asks "Do you want to clear your whole drawing?" with **Clear it** and **Keep drawing**. After clearing, the canvas is completely blank (drawing, text and shapes), and the colour, size and tool stay the same. It can be undone.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| Save as PNG              | Keeps the artwork after the browser closes                   | ✅ "Save Picture" opens an **Export panel** in the middle of the screen, with a preview of the picture, the picture type, and **Discard** and **Export** buttons. Export downloads the drawing, with text and shapes. Discard (or Escape) closes it without saving. The types are **PNG** (the default, sharpest), **JPG** (smaller file), **WebP** (smallest file), **PDF** (for printing) or **SVG** (shapes and text stay sharp at any size). The name is like `drawlab-2026-11-15-1430.png` (year, month, day, hour and minute), ending in `.png`, `.jpg`, `.webp`, `.pdf` or `.svg`. It's the full size of the canvas you can see, with a solid white background (even where nothing was drawn or the eraser was used). A "Saved!" message shows under the button for 2 seconds. The drawing on screen doesn't change. |
| Clear toolbar and layout | Makes the app easy to understand                             | ⚠️ The top panel (⌂ Home page, the drawing's name, Home and Insert tabs, Undo, Delete, Share, Save Picture) works and wraps on small screens. The left panel is the **Properties** panel. The bottom panel is still empty. Both side panels can be resized by dragging. The **Tools** tab does nothing yet.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |

## Extra features already built

These aren't on the must-have list.

**TO DECIDE:** keep them in version 1, or count them as bonus features?

**Drawing helpers**

- **Straight lines:** hold still for 2 seconds while drawing, and the line turns straight. Keep holding to aim it.
- **Joining lines:** start a line near the end of another line, and it joins on. With a mouse, a blue dot shows where it will join.
- **Tool switch:** Home has three tools: Cursor (select and edit things), Brush (draw) and Eraser (rub out drawing). Picking a colour while the Eraser is on switches back to the Brush.
- **Keyboard shortcuts:** B = Brush, E = Eraser, V = Cursor, Ctrl+S = Save Picture (Cmd+S on a Mac), Ctrl+Z = Undo, Delete = delete the selected item. They don't work while you're typing, so typing "b" in a text box still types a "b". Hover over the tool buttons to see them.

**Text (Insert tab)**

- Text boxes: click to place one, type, and click it again later to edit.
- Text size setting.

**Shapes (Insert tab)**

- Rectangle, circle, triangle, line, arrow line, star, arrow, speech bubble and polygon. They use the brush colour and size.
- Polygons have a **Sides** box in Properties (3 to 12, starting at 6).
- Arrow lines have an arrow head that grows with the line's thickness. Like lines, they have no Fill.

**Photos and stickers (Insert tab)**

- **🖼 Photo:** pick a picture from your computer, phone or tablet. It goes in the middle of the canvas. Big photos are shrunk to at most 1600 pixels across, so they don't fill up the browser's storage.
- **Drag and drop a photo:** drag a picture from another website (in another tab or window) or a picture file from your computer straight onto the canvas. A blue dashed outline shows where it will go, and the photo's middle lands where you let go. Some websites don't allow their pictures to be copied; then Drawlab says so, and you can save the picture first and drag the saved file in.
- **😀 Stickers:** 42 emoji stickers. Pick one, then click the canvas. Each sticker is turned into a picture, so it looks the same in saved pictures.
- Photos and stickers can be moved, resized (they keep their shape), rotated and deleted like shapes.
- **Filters** (Properties panel): Brightness (0 to 200%), Contrast (0 to 200%) and Blur (0 to 20), plus Reset filters. Saved pictures include the filters.

**Sharing (project files)**

- **📤 Share** (top bar, and on each drawing on the home page) makes a `.drawlab` project file with everything in the drawing, still editable.
- On a laptop or PC it downloads the file. On a phone or iPad it opens the share menu (Messages, email, AirDrop...).
- Someone else opens it with **📂 Open a project file** on their home page. It becomes a new drawing in their account.

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

- Properties panel on the left, and the chat in the bottom panel. Drag the bar next to each one to make it bigger or smaller.

## Accounts and the home page

**Accounts:** see [Online accounts, friends and chat](#online-accounts-friends-and-chat).

**Home page**

- **Start something new:** 7 templates: Blank canvas, Birthday card, Poster, Comic strip, Certificate, Thank-you note and Mind map. Templates are made of normal text boxes, shapes and stickers, so everything in them can be changed. They fit any screen size.
- **My drawings:** every drawing in your account, newest first, with a small picture, its name and when it was last changed. Each one has **Open**, **Rename**, **📤 Share** and **Delete** (Delete asks first).
- **📂 Open a project file** opens a `.drawlab` file someone shared with you.

**In the editor**

- **⌂ Home page** (top left) saves and goes back to the home page.
- The drawing's **name** is next to it. Type to rename it.
- **Saving is automatic.** A moment after every change, the drawing is saved to your account. "Saving…" and then "Saved" shows next to the name.
- Undo starts fresh each time you open a drawing.

## Online accounts, friends and chat

**Accounts (decided: online, with Supabase)**

- **Sign up** asks for a username and a password (twice). **No email needed** (product owner's choice). Usernames are 3 to 20 letters, numbers, - or \_, and friends find you by it. "Sam" and "sam" are the same username. Passwords need at least 8 characters.
- **Log in** with your username and password, on any computer, phone or tablet. A wrong username or password gives the same message, so nobody can find out who has an account.
- **Adding an email is optional**, in **⚙ Account**. Nobody else can see it. Once you've added one, you log in with your email instead of your username, and **Forgot your password?** can email you a link to choose a new one. Without an email, a forgotten password can't be reset, so the account is lost.
- You stay logged in after a refresh, until you press **Log out**.
- **⚙ Account** (home page): add or change your email, change your password, or delete your account and everything in it (you type your username to be sure).
- **📦 Move drawings from this computer** (home page) only shows if this browser still has old "this browser only" accounts. Log in to the old account there, and its drawings are copied online, then removed from this computer.

**Friends (👥 Friends tab in the bottom panel)**

- Type a friend's username and press **Send request**. They see it in their Friends tab (with a red number) and press **✔ Accept** or **Decline**. If they had already asked you, you become friends straight away.
- Your friends have **💬 Message** and **Remove**. Requests you sent have **Cancel request**.

**Chat (💬 Chats tab in the bottom panel)**

- Your chats are on the left, newest first, with the last message. Chats with new messages have a ●, and the Chats tab shows how many.
- **1-to-1 chats:** press 💬 Message next to a friend.
- **Group chats:** press **＋ New group**, give it a name and tick some friends. In a group you can add more of your friends (**＋ Add a friend…**) or **Leave group**. Each message shows who sent it.
- Type a message and press Enter or **Send**. Messages show up for everyone straight away. Messages can be up to 2000 characters.
- Only friends can be put in chats. If you unfriend someone, neither of you can send messages in your 1-to-1 chat any more.

**How it's kept safe**

- Passwords are handled by Supabase, which keeps them scrambled (bcrypt). Drawlab never stores them.
- The database checks every read and write against the rules in [supabase-setup.sql](supabase-setup.sql) ("Row Level Security"). For example: only you can see your drawings; only people in a chat can read it; you can only send messages as yourself; only the person asked can accept a friend request. Changing Drawlab's code in a browser can't get round these, because the database does the checking.
- Emails are private: other people only see your username.
- Messages and names are always shown as plain text, so nobody can send something that runs code on your computer.
- Spam limits: at most 10 messages in 10 seconds, and 30 friend requests an hour.
- The Supabase helper file is checked with a fingerprint ("integrity"), so a changed copy won't run.
- These rules were tested on a real Postgres database (53 checks, all passing).

## Saved for version 2

**TO DECIDE.** Some ideas to choose from:

- A paint bucket (fill an area with colour)
- Redo (the opposite of Undo)
- Lines that can slope either way (right now a line always goes bottom-left to top-right)
- Layers, so you can put a shape behind or in front of other things
- Editing together live (online accounts are done, so this is possible now)
- Sending a drawing or picture in the chat
- Profile pictures, and seeing who's online
- Filters for the brush drawing, not just photos and stickers
- More templates, and template previews that show the real design

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
- [ ] Make more than 50 changes, then keep pressing Undo. You can go all the way back to how the drawing was when you opened it.- [ ] Save Picture downloads a PNG that looks like the screen (with text and shapes).
- [ ] The file is named like `drawlab-2026-11-15-1430.png`, with today's date and the time you saved.
- [ ] Press Save Picture. A panel opens in the middle with a preview of your drawing (with text and shapes), the file name, its size, and Picture type.
- [ ] Press Discard. The panel closes and nothing is downloaded. Laptop/PC: try Escape too.
- [ ] Change Picture type in the panel. The preview, file name and file size change to match.
- [ ] Press Export. The picture downloads, the panel closes, and "Saved!" shows.
- [ ] Open the panel again. It remembers the type you picked last time.
- [ ] Phone: the panel fits on the screen, and the preview shrinks to fit.
- [ ] In the panel, pick JPG, then export. The file ends in `.jpg` and opens normally. Do the same for WebP (`.webp`).
- [ ] The JPG and WebP files are smaller than the PNG, and their background is white too (not black).
- [ ] Open the saved PNG. The background is solid white everywhere: where nothing was drawn and where you erased.
- [ ] The saved picture is the same size as the canvas on screen (nothing squashed or cut off).
- [ ] "Saved!" shows under the Save Picture button and disappears after about 2 seconds.
- [ ] After saving, the drawing on screen hasn't changed, and a selected item is still selected.
- [ ] Phone/iPad: Save Picture downloads the picture (it may ask where to put it, or show it in Downloads or Files).

**Accounts and the home page**

- [ ] Open the app. The log-in screen shows. Press Sign up: it asks for a username and password only (no email). Make an account. Drawlab opens on the home page, saying "Hi, (your name)".
- [ ] Sign up with two different passwords. It says they don't match. Sign up with a username that's taken. It says so.
- [ ] Log out, then log in with the wrong password. It says "Wrong username or password". Log in properly. Your drawings are still there.
- [ ] Refresh the page. You're still logged in, on the home page.
- [ ] Log in on a different device (like your phone, using the GitHub Pages address). The same drawings are there. Change one on the phone, then open it on the PC: the change is there.
- [ ] ⚙ Account → Add email. It says the email is saved. Log out. Logging in with the username now says to use your email. Log in with the email.
- [ ] Forgot your password? Type that email. An email arrives, and its link lets you choose a new password. Log in with the new one.
- [ ] Try to add an email another account already uses. It says another account already uses it.
- [ ] ⚙ Account: change your password. Log out, then log in with the new one.
- [ ] On the PC where you made old "this browser only" accounts: 📦 Move drawings from this computer shows. Move them with the old username and password. They appear in My drawings, and the 📦 button goes away.
- [ ] Turn off the Wi-Fi and draw. It says "Not saved yet. Trying again soon…". Turn the Wi-Fi back on: it says "Saved" again.
- [ ] Press each template. Each one opens in the editor, fits the canvas, and everything in it can be moved and changed.
- [ ] Draw something, wait for "Saved", press ⌂ Home page. The drawing is in My drawings with a small picture of it.
- [ ] Rename a drawing (on the home page, and by typing in the name box in the editor). Delete one: it asks first, and Keep it doesn't delete.
- [ ] Close the browser completely, open the app again. Everything is still there.
- [ ] Make a second account. It can't see the first account's drawings.
- [ ] ⚙ Account → Delete account: it needs your username typed. After deleting, you can't log in, and your friends' lists no longer show you.

**Friends and chat** (you need two accounts, on two devices or two different browsers)

- [ ] Account A: 👥 Friends → type B's username → Send request. It shows under "Waiting for them to accept".
- [ ] Account B: a red 1 appears on 👥 Friends straight away. Press ✔ Accept. Both now show each other under "Your friends".
- [ ] Send a request to a username that doesn't exist. It says nobody has it.
- [ ] A: press 💬 Message next to B. Type a message and press Enter. B sees it appear straight away, with a ● and a red number on 💬 Chats until B opens the chat.
- [ ] Send a message like `<b>hi</b>`. It shows exactly like that, not in bold.
- [ ] Make a group with ＋ New group (a name, and tick some friends). Everyone ticked sees it. Messages show who sent them. Add another friend with ＋ Add a friend…. Press Leave group: it disappears for you, and the others still have it.
- [ ] Remove a friend. Neither of you can send messages in your 1-to-1 chat any more.
- [ ] Phone: drag the bar above the bottom panel up to make the chat bigger. Typing a message doesn't zoom the page.
- [ ] Press B, E or V while typing a message. It types the letter (it doesn't change the tool).

**Photos, stickers, shapes and filters**

- [ ] Insert → 🖼 Photo. Pick a photo. It appears in the middle, and can be moved, resized (it keeps its shape), rotated and deleted. Phone/iPad: you can pick from your photos or take one.
- [ ] Open a website with pictures (like Wikipedia) in a second window next to Drawlab. Drag a picture onto the canvas. A blue dashed outline appears while dragging, and the photo lands where you let go. Move, resize, rotate and delete it. Undo removes it.
- [ ] Drag a picture file from File Explorer onto the canvas. Same result.
- [ ] Drag a picture from Google Images or another big site. Either it appears, or Drawlab explains that the website won't allow it.
- [ ] Drop a picture next to the canvas (on a panel). The browser does not leave Drawlab.
- [ ] Insert → 😀 Stickers. Pick one and click the canvas. It appears there.
- [ ] Select a photo or sticker. Properties shows Size, Rotation and Filters (no Colour or Font). Move Brightness, Contrast and Blur, then Reset filters.
- [ ] Add an arrow line, star, arrow, speech bubble and polygon. Change the polygon's Sides. Fill the star and the speech bubble.
- [ ] Save Picture with photos, filters, stickers and the new shapes. The saved picture matches the screen.

**Export types and shortcuts**

- [ ] Save Picture → PDF. Open it. The page is your picture. Print preview looks right.
- [ ] Save Picture → SVG. Open it in a browser and zoom in a lot. Shapes and text stay sharp (brush drawing and photos go blurry, which is expected).
- [ ] Laptop/PC: press B, E and V. The tool changes to Brush, Eraser and Cursor. Type "bev" in a text box: the letters are typed and the tool doesn't change.
- [ ] Laptop/PC: press Ctrl+S (Cmd+S on a Mac). The Export panel opens, not the browser's "Save page".

**Sharing**

- [ ] Laptop/PC: press 📤 Share. A `.drawlab` file downloads, named after the drawing.
- [ ] Phone/iPad (over https, see Known issues): 📤 Share opens the share menu.
- [ ] On the home page, 📂 Open a project file and pick that file. It opens as a new drawing, with text, shapes, photos and stickers all still editable.
- [ ] Try to open a file that isn't a project (like a photo). It says it isn't a Drawlab project.

**Clear**

- [ ] The Clear button is at the end of the Home row, with a red outline, and is the same size as the other buttons. It isn't next to Undo or Save Picture.
- [ ] Press Clear. A box asks "Do you want to clear your whole drawing?" with Clear it and Keep drawing. Nothing else can be pressed until you answer.
- [ ] Press Keep drawing. The box closes and nothing is cleared. Laptop/PC: try Escape too.
- [ ] Pick a colour, size and tool, then press Clear and Clear it. The drawing, text and shapes all go, and the colour, size and tool are the same as before.
- [ ] Press Undo after clearing. Everything comes back.

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

- **Clear asks first.** Clearing wipes all your work, so a box asks "Do you
  want to clear your whole drawing?" with **Clear it** and **Keep drawing**.
  Keep drawing is picked first, so pressing Enter by accident is safe. The
  Clear button has a red outline (same size as other buttons) and sits at the
  end of the Home row, not next to Undo or Save. The old "New Drawing" button
  next to Save was removed, so there's only one Clear button. Clearing keeps
  the colour, size and tool.

- **Saving opens an Export panel first**, in case Save Picture was pressed by
  accident. It has a preview (the real file, so JPG's slight blur shows), the
  file name, the picture size and the file size, the Picture type, and two
  buttons: **Discard** (red, close without saving) and **Export** (green, save). Export is
  picked first, so pressing Enter saves. Discard and Escape do the same thing.
  The picture type moved from the top bar into this panel.
- **You choose the picture type when saving.** PNG is the default, because it
  keeps every pixel exactly, so lines and text stay crisp. JPG and WebP make
  smaller files, but blur sharp edges a little (saved at 92% quality). If a
  browser can't make WebP pictures (like older Safari), WebP isn't shown in
  the list.
  - The file name is `drawlab-YEAR-MONTH-DAY-HOURMINUTE` plus `.png`, `.jpg` or `.webp`, so saves sort
    in date order and never overwrite each other (unless you save twice in
    the same minute, when the browser adds a number like `(1)`).
  - The background is always solid white. This matters most for JPG, which
    can't be see-through, so empty spots would otherwise come out black.
  - "Saved!" shows for 2 seconds after saving.
  - "Full size" means the whole canvas area you can see, with one picture
    pixel for each screen pixel. If a panel is covering part of a bigger
    canvas, that hidden part isn't saved (see "The canvas never gets
    smaller").

- **Accounts are online, with Supabase** (product owner's choice, replacing
  the earlier "kept in the browser" accounts). Supabase gives free logins, a
  database, and live updates for chat, with no server program to write or look
  after, so Drawlab stays one HTML file. The safety rules live in the database
  ([supabase-setup.sql](supabase-setup.sql)), not in the page, because anyone
  can change the page's code in their own browser.
- **The website is on GitHub Pages** (product owner's choice): free, uses the
  Learn-web repository, and updates by itself after every push.
- **Email is optional** (product owner's choice). Supabase needs an email for
  every account, so an account without one gets a pretend one made from its
  username, like `sam@drawlab.invalid`. `.invalid` is reserved: it can never
  be a real email, so nobody else can own it or get mail for it. Adding a real
  email swaps the pretend one for it, so after that you log in with the email.
  Emails are never shown to anyone else.
- **Confirm email is off** (needed for accounts without an email). The
  downside: when you add an email, Supabase doesn't check it's really yours.
  Someone could add another person's email to their own account. That doesn't
  get them into anything, but the real owner then can't use that email for
  Drawlab.
- **Chats can be 1-to-1 or groups** (product owner's choice). Only friends can
  be put in a chat, so strangers can't message you.
- **Old browser accounts can be moved online** (product owner's choice). It
  asks for the old password, so on a shared computer nobody can move someone
  else's drawings into their own account.
- **Photos are only sent to the server when they change.** The drawing saves
  after every change, and photos are big, so this keeps saving quick.
- **Saves happen in order**, one after another, so an older save can never
  finish after a newer one and undo it.
- **Sharing is a project file** (product owner's choice), not a link. It works
  anywhere with no server. Files from someone else are checked before opening,
  and text boxes only keep text and styles from them, so a sneaky file can't
  run a program.
- **Every change saves automatically**, so there's no Save button to forget.
  Undo's snapshots are what get saved.
- **Templates are made of normal items** (text boxes, shapes and stickers), so
  everything can be edited. Their places are shares of the canvas, so they fit
  any screen.
- **Stickers are emoji turned into pictures.** Every device has emoji built in
  (free, nothing to download). Making them pictures keeps them looking the same
  in saved pictures.
- **PDF holds the picture as a JPG**, sized to print the same size as it shows
  on screen. That keeps the PDF code small. Text in the PDF can't be selected.
- **SVG keeps shapes and text as shapes and text**, so they stay sharp at any
  size. The brush drawing, photos and stickers are made of dots, so they go in
  as pictures.

## Known issues

- The **Tools** tab button does nothing.
- The Properties Colour controls don't show the selected item's current colour yet. They show the last colour you picked.
- After you erase a line, its ends are still remembered, so it can still join
  onto a new line (and the blue dot can still appear there).
- Shift to snap rotation only works with a keyboard, so phones and iPads can't snap.
- The file is still called `hello.html`. It could be renamed to match the app.
  (If you do, change the Site URL and Redirect URLs in Supabase too.)
- "⌂ Home page" and the "Home" tab have similar names. **TO DECIDE:** rename
  one (for example, the tab could become "Draw")?
- The template cards show an emoji, not a small picture of the real design.
- If the same drawing is open on two devices at once, whichever saves last
  wins, and the other device's changes are lost. (Fixing this is part of
  "editing together live" in version 2.)
- Drawlab needs the internet. Without it you can keep drawing, but nothing is
  saved until the internet is back (it keeps trying every 10 seconds). Closing
  the page while offline loses the unsaved changes.
- Chats only show the newest 100 messages.
- Free Supabase projects pause after a week of nobody using them (see
  [SETUP-ONLINE.md](SETUP-ONLINE.md)).
- Supabase's built-in email sender only sends a few emails an hour, so if lots
  of people ask for a new password at once, some might have to wait.
- Accounts without an email can't get a new password if they forget it.
- Adding an email isn't checked (see Design decisions).
- The chat is only in the editor's bottom panel, so you don't see new messages
  while you're on the home page.
- On a phone over `http://192.168...`, the share menu isn't available (browsers
  only allow it on https pages), so 📤 Share downloads the file instead.
- Filters only work on photos and stickers, not on the brush drawing.
- Dragging pictures from websites only works when the website allows copying its pictures. Many do (like Wikipedia); some don't. Dragging only works with a mouse on a computer, not on phones or iPads.
- Saved picture file names don't use the drawing's name yet.
