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
- **Newest:** drawing together live with friends (share through a 📥 Inbox, with a "who's editing" sign), photos and videos in the chat, unsend, deleting chats and groups, nicknames, blocking, and profile pictures. Project files were removed. See [Sharing: drawing together with friends](#extra-features-already-built) and [Online accounts, friends and chat](#online-accounts-friends-and-chat).
- **Next steps:**
  1. Follow [SETUP-ONLINE.md](SETUP-ONLINE.md) to connect Supabase and put the site on GitHub Pages.
  2. Run the [device tests](#device-tests) on a phone, iPad, laptop and PC.
  3. Answer the **TO DECIDE** questions below (who it's for, purpose, what goes in the Tools tab).
  4. Finish the toolbar and layout.

## The basics

|                  |                                                                                                                                              |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **App name**     | **Sunrise** (decided, 15 November 2026; it was called Drawlab before). A few hidden names inside still say "drawlab" (like the pretend `@drawlab.invalid` emails), because changing them would break existing accounts and saved data. Nobody sees them. |
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
| Clear canvas             | Starts a new picture                                         | ✅ One **Clear** button (top bar, right after Undo), with a red outline. It asks "Do you want to clear your whole drawing?" with **Clear it** and **Keep drawing**. After clearing, the canvas is completely blank (drawing, text and shapes), and the colour, size and tool stay the same. It can be undone.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| Save as PNG              | Keeps the artwork after the browser closes                   | ✅ "Save Picture" opens an **Export panel** in the middle of the screen, with a preview of the picture, the picture type, and **Discard** and **Export** buttons. Export downloads the drawing, with text and shapes. Discard (or Escape) closes it without saving. The types are **PNG** (the default, sharpest), **JPG** (smaller file), **WebP** (smallest file), **PDF** (for printing) or **SVG** (shapes and text stay sharp at any size). The name is like `drawlab-2026-11-15-1430.png` (year, month, day, hour and minute), ending in `.png`, `.jpg`, `.webp`, `.pdf` or `.svg`. It's the full size of the canvas you can see, with a solid white background (even where nothing was drawn or the eraser was used). A "Saved!" message shows under the button for 2 seconds. The drawing on screen doesn't change. |
| Clear toolbar and layout | Makes the app easy to understand                             | ⚠️ The top panel (⌂ Home page, the drawing's name, Home and Insert tabs, Undo, Clear, Delete, Share, Save Picture) works and wraps on small screens. The left panel is the **Properties** panel. The bottom panel is the chat. Both side panels can be resized by dragging. The **Tools** tab does nothing yet.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |

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
- **Drag and drop a photo:** drag a picture from another website (in another tab or window) or a picture file from your computer straight onto the canvas. A blue dashed outline shows where it will go, and the photo's middle lands where you let go. Some websites don't allow their pictures to be copied; then Sunrise says so, and you can save the picture first and drag the saved file in.
- **😀 Stickers:** 42 emoji stickers. Pick one, then click the canvas. Each sticker is turned into a picture, so it looks the same in saved pictures.
- Photos and stickers can be moved, resized (they keep their shape), rotated and deleted like shapes.
- **Filters** (Properties panel): Brightness (0 to 200%), Contrast (0 to 200%) and Blur (0 to 20), plus Reset filters. Saved pictures include the filters.

**Sharing: drawing together with friends**

- **📤 Share** (top bar, and on each drawing on the home page) opens the Share panel. Tick friends and press **Share**. Only friends can be picked, and only the owner can share a drawing.
- They get it in the **📥 Inbox** at the top of their home page ("Sam wants to draw 'My card' with you"), with **✔ Accept** and **Decline**. It shows up straight away, with a red number.
- After they accept, the drawing is in their My drawings, marked "Shared by Sam".
- **Everyone edits at once** (product owner's choice). Brush drawing, erasing, text boxes, shapes, photos, stickers, moving, resizing, deleting and the drawing's name all show up for everyone a moment later.
- **Who's editing:** a small sign next to the drawing's name shows the profile pictures of everyone else who has it open, like "Alex is editing".
- The Share panel shows who it's shared with: "✓ Shared" or "⏳ Waiting for them". The owner can **Stop sharing** with someone.
- Friends it's shared with can **Leave** it (on the home page, or in the Share panel). Only the owner can **Delete** it, which deletes it for everyone.
- The old `.drawlab` project files are gone (product owner's choice).

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

**Layers (Properties panel)**

- Select any item: the **Layer** section says where it is, like "Layer 2 of 5 (1 = at the back)".
- Type how many layers to move, then press **▲ Forward** or **▼ Backward**.
- **⏫ To front** puts it in front of everything; **⏬ To back** puts it behind every other item (the brush drawing is always at the very back).
- Undo works, saved pictures keep the order, and friends drawing with you see it.

**Zoom**

- The **− 100% +** buttons float in the bottom-right corner of the canvas. Press the % to fit the page on screen (or go back to 100%).
- **Ctrl + mouse wheel** zooms where the mouse is (pinching a laptop touchpad works too). On phones and iPads, **pinch with two fingers** to zoom and move.
- **Drag the page** (Cursor tool): when there's more to see (zoomed in, or a tall page), press on an empty part of the canvas or the background round the page and drag. The pointer is a ✋ hand. Pressing on an item still moves the item. On phones, drag with one finger (Cursor tool) or two fingers (any tool).
- 25% to 400% (a vertical page can zoom out further, to fit). Scroll bars show when there's more to see. Drawing, moving, resizing and dropping photos all land in the right place at any zoom.

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

- **Vertical pages:** two templates with a fixed portrait page: **Vertical (phone)** (1080 × 1920, like a phone story) and **Vertical (A4)** (1240 × 1754, like A4 paper). The page shows in the middle of the canvas area with a soft background round it, zoomed to fit. Saved pictures are exactly that page. The page size is saved with the drawing.
- **Start something new:** 7 templates: Blank canvas, Birthday card, Poster, Comic strip, Certificate, Thank-you note and Mind map. Templates are made of normal text boxes, shapes and stickers, so everything in them can be changed. They fit any screen size.
- **My drawings:** every drawing in your account, newest first, with a small picture, its name and when it was last changed. Each one has **Open**, **Rename**, **📤 Share** and **Delete** (Delete asks first). Drawings friends shared with you say "Shared by (name)" and have **Leave** instead of Delete.
- **Up to 20 drawings each** (product owner's choice). "My drawings" shows how many you have, like "(12 of 20)". At 20, pressing a template says "You can have up to 20 drawings. Delete one to make a new one." Drawings friends shared with you don't count. The server checks this too.
- **Chat on the home page:** the chat panel (💬 Chats and 👥 Friends) is on the left of the home page too. It's the same panel as the editor's bottom panel, so an open chat stays open when you go between them. On phones it's above your drawings.
- **📥 Inbox** (only shows when there's something in it): drawings friends want to share with you.
- Your **profile picture** shows at the top, next to "Hi, (your name)".

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
- **⚙ Account** (home page): choose a **profile picture** (or remove it), add or change your email, change your password, or delete your account and everything in it (you type your username to be sure).
- **📦 Move drawings from this computer** (home page) only shows if this browser still has old "this browser only" accounts. Log in to the old account there, and its drawings are copied online, then removed from this computer.

**Friends (👥 Friends tab in the bottom panel)**

- Type a friend's username and press **Send request**. They see it in their Friends tab (with a red number) and press **✔ Accept** or **Decline**. If they had already asked you, you become friends straight away.
- Each friend has a **⋮** button (three dots, one above the other). Pressing it opens a small panel next to it with **💬 Message**, **✏ Nickname**, **🔕 Mute**, **Unfriend** and **🚫 Block**. Requests you sent have **Cancel request**.
- **🔕 Mute** (friends and groups): a muted chat never gets a red number, and shows 🔕. Press it again to unmute. Only you see that you muted it.
- **✏ Nickname:** your own private name for a friend. It shows instead of their name everywhere (chats, friends, "is editing"), but only for you.
- **🚫 Block:** you stop being friends, and they can't message you or send you friend requests (to them it looks like your username doesn't exist). Blocked people are listed under **Blocked**, with **Unblock**.
- **Online dots:** a **green** dot on a friend's picture means they have Sunrise open right now; **grey** means they don't. They show in the friends list, the chat list and at the top of a 1-to-1 chat. Sunrise tells the server "I'm here" every minute while it's showing; after 2 minutes without that, you show as offline (closing Sunrise or logging out tries to make it grey straight away). **Only friends** can see if you're online.
- Everyone has a **profile picture** (or the first letter of their name on a colour, if they haven't picked one).

**Chat (💬 Chats tab in the bottom panel)**

- Your chats are on the left, newest first, with the last message. A chat with unread messages has a **red circle with how many** (not for muted chats), and the 💬 Chats tab shows the total. Each chat has a **⋮** menu too.
- **Sent / Delivered / Read** shows under your newest message: Sent = it's on the server, Delivered = their device got it, Read = they opened the chat. In groups it can say "Read by 2" until everyone has read it.
- **"Alex is typing…"** (or "is editing…") shows just above the message box while someone in the open chat is typing. You never see it for yourself.
- **Hold down** your own message (or right-click it on a computer) for **✏ Edit** and **Unsend**. Edit puts the words back in the message box (with a yellow "Editing your message · Cancel" bar); press Enter to save. Edited messages say **Edited** under them, for everyone. Photos and videos can be unsent, not edited.
- **1-to-1 chats:** ⋮ → 💬 Message next to a friend. The ⋮ at the top of the chat has **✏ Nickname**, **🔕 Mute**, **Unfriend**, **🚫 Block** and **🗑 Delete chat**.
- **Group chats:** press **＋ New group**, give it a name and tick some friends. In a group you can add more of your friends (**＋ Add a friend…**), and its ⋮ has **🔕 Mute** and **Leave group**. Each message shows who sent it, with their picture. The person who made the group also has **🗑 Delete group** in the ⋮.
- Type a message and press Enter or **Send**. Messages show up for everyone straight away. Messages can be up to 2000 characters.
- **Photos and videos:** press **📎**, or drag a photo or video into the chat (from your computer, or a picture from a website). Photos are shrunk to 1 MB or less (at most 1280 pixels across, saved as JPG). Videos can be MP4, WebM or MOV, up to 5 MB. Each person can send up to 50 MB of photos and videos a week. Click a photo to open it full size; videos play in the chat.
- **Photos and videos are deleted from the server once everyone in the chat has them** (product owner's choice, like WhatsApp). Each person's browser keeps its own copy, so they still show. On another device, or after clearing browser data, they show as "no longer available". If someone never opens the chat, the file is deleted after 7 days anyway.
- **Messages are deleted after 7 days** (product owner's choice), with their photos and videos. Each chat shows a small reminder at the top. The server keeps only the last week of messages.
- **Unsend** (hold down your message): deletes the message (and its photo or video) for everyone.
- **Deleting a chat deletes everything in it** (messages, photos and videos) for everyone in it. 1-to-1 chats: either person can delete. Groups: only the person who made it.
- **When the last person leaves a group,** the group is deleted with all its messages, photos and videos.
- **Up to 10 chats each** (product owner's choice), 1-to-1 chats and groups together. The chat list shows "3 of 10 chats". At 10, New group and messaging a new friend say "You can have up to 10 chats. Delete or leave one first." You also can't put a friend who already has 10 into a new chat ("Alex already has 10 chats."). The server checks this too.
- Only friends can be put in chats. If you unfriend or block someone, neither of you can send messages in your 1-to-1 chat any more.

**How it's kept safe**

- Passwords are handled by Supabase, which keeps them scrambled (bcrypt). Sunrise never stores them.
- The database checks every read and write against the rules in [supabase-setup.sql](supabase-setup.sql) ("Row Level Security"). For example: only you can see your drawings; only people in a chat can read it; you can only send messages as yourself; only the person asked can accept a friend request. Changing Sunrise's code in a browser can't get round these, because the database does the checking.
- Emails are private: other people only see your username.
- Messages and names are always shown as plain text, so nobody can send something that runs code on your computer.
- Whether you're online is private: only your friends can find out (the time you were last seen can't be read by anyone directly).
- Spam limits: at most 10 messages in 10 seconds, and 30 friend requests an hour.
- Chat messages are kept on the server for 7 days, then deleted for good (a job on the server runs every hour, and a rule hides them the moment they turn 7 days old).
- Chat photos and videos are only kept on the server until everyone in the chat has received them. The server checks the limits itself (1 MB photos, 5 MB videos, 50 MB a week each, and at most 5 files uploaded but not sent yet), so changing Sunrise's code can't get round them.
- Chat photos and videos are kept in a private storage area. Only the people in that chat can see them, and the links to them stop working after an hour.
- Drawing together uses private channels: only people the drawing is shared with (who accepted) can join, listen or send changes.
- Changes from friends are checked before they're shown (for example, pictures must really be pictures, and text boxes only keep text and styles).
- The Supabase helper file is checked with a fingerprint ("integrity"), so a changed copy won't run.
- These rules were tested on a real Postgres database (101 checks, all passing), and the website was tested with two Sunrise windows side by side (49 checks, all passing).

## Saved for version 2

**TO DECIDE.** Some ideas to choose from:

- A paint bucket (fill an area with colour)
- Redo (the opposite of Undo)
- Lines that can slope either way (right now a line always goes bottom-left to top-right)
- Layers, so you can put a shape behind or in front of other things
- Sending a drawing in the chat
- Seeing who's online, and "typing…" in chats
- Notifications for new messages while you're on the home page
- Showing where each friend's pointer is while drawing together
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

- [ ] Open the app. The log-in screen shows. Press Sign up: it asks for a username and password only (no email). Make an account. Sunrise opens on the home page, saying "Hi, (your name)".
- [ ] Sign up with two different passwords. It says they don't match. Sign up with a username that's taken. It says so.
- [ ] Log out, then log in with the wrong password. It says "Wrong username or password". Log in properly. Your drawings are still there.
- [ ] Refresh the page. You're still logged in, on the home page.
- [ ] Log in on a different device (like your phone, using the GitHub Pages address). The same drawings are there. Change one on the phone, then open it on the PC: the change is there.
- [ ] ⚙ Account → Add email. It says to click the link in the email. Click it. Log out. Logging in with the username now says to use your email. Log in with the email.
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
- [ ] Open a website with pictures (like Wikipedia) in a second window next to Sunrise. Drag a picture onto the canvas. A blue dashed outline appears while dragging, and the photo lands where you let go. Move, resize, rotate and delete it. Undo removes it.
- [ ] Drag a picture file from File Explorer onto the canvas. Same result.
- [ ] Drag a picture from Google Images or another big site. Either it appears, or Sunrise explains that the website won't allow it.
- [ ] Drop a picture next to the canvas (on a panel). The browser does not leave Sunrise.
- [ ] Insert → 😀 Stickers. Pick one and click the canvas. It appears there.
- [ ] Select a photo or sticker. Properties shows Size, Rotation and Filters (no Colour or Font). Move Brightness, Contrast and Blur, then Reset filters.
- [ ] Add an arrow line, star, arrow, speech bubble and polygon. Change the polygon's Sides. Fill the star and the speech bubble.
- [ ] Save Picture with photos, filters, stickers and the new shapes. The saved picture matches the screen.

**Export types and shortcuts**

- [ ] Save Picture → PDF. Open it. The page is your picture. Print preview looks right.
- [ ] Save Picture → SVG. Open it in a browser and zoom in a lot. Shapes and text stay sharp (brush drawing and photos go blurry, which is expected).
- [ ] Laptop/PC: press B, E and V. The tool changes to Brush, Eraser and Cursor. Type "bev" in a text box: the letters are typed and the tool doesn't change.
- [ ] Laptop/PC: press Ctrl+S (Cmd+S on a Mac). The Export panel opens, not the browser's "Save page".

**Sharing and drawing together** (two accounts that are friends, on two devices)

- [ ] A: open a drawing, press 📤 Share, tick B, press Share. It says "⏳ Waiting for them".
- [ ] B: on the home page, 📥 Inbox appears straight away with a red 1. Press ✔ Accept. The drawing is in My drawings, saying "Shared by A".
- [ ] Both open it. Each sees the other's picture and "(name) is editing" next to the drawing's name.
- [ ] A draws with the brush. B sees it a moment later. B erases part of it. A sees that.
- [ ] A adds a text box, a shape, a photo and a sticker. B sees them all. B moves, resizes, rotates and deletes them. A sees that.
- [ ] A renames the drawing. B sees the new name.
- [ ] Both draw at the same time in different places. Both drawings end up on both screens.
- [ ] B presses Undo after A changed something. A's change is not undone.
- [ ] B leaves the drawing: A's "is editing" sign goes away.
- [ ] B: on the home page, the shared drawing has Leave (not Delete). Leave it. It's gone from B's drawings, but still in A's.
- [ ] A: Share panel → Stop sharing. B can't open it any more.
- [ ] A deletes a shared drawing. It's gone for B too.
- [ ] "My drawings" shows "(N of 20)". With 20 drawings, pressing a template shows a red message and doesn't open a new drawing. Delete one, and you can make a new one again.
- [ ] Decline a share from the inbox. It goes away and isn't in My drawings.

**Profile pictures, nicknames, blocking**

- [ ] ⚙ Account → Choose picture. Pick a photo. It shows (as a circle) in the Account panel, at the top of the home page, and to your friends in their friends list, chats and the "is editing" sign. Remove it: the first letter of your name shows instead.
- [ ] ✏ Nickname for a friend. It shows everywhere for you, but your friend's own screen still shows their real name.
- [ ] 🚫 Block a friend. You're not friends any more, they're under Blocked, and your 1-to-1 chat says you can't send messages. On their side, sending you a friend request says nobody has that username. Unblock: they can send requests again.

**Chat photos, videos and deleting**

- [ ] Press 📎 and send a photo. It shows in the chat for both people. Click it: it opens full size. Once your friend has seen it, it's gone from Supabase → Storage → chat-files, but still shows for both of you.
- [ ] Log in on another device and open that chat. The old photo says "no longer available".
- [ ] Send a big photo (like a phone camera photo). It's shrunk and sent. Try a video over 5 MB: it says it's too big.
- [ ] Drag a photo from your computer into the chat, and a picture from a website. Both send.
- [ ] Send an MP4 video under 5 MB (from a phone too). It plays in the chat.
- [ ] Every chat says "🕒 Messages are deleted after 7 days" at the top. In Supabase → Integrations (or Database) → Cron, the job "drawlab-delete-old-messages" is listed, running every hour.
- [ ] Friends tab: ⋮ next to a friend opens a panel with Message, Nickname, Mute, Unfriend, Block. Clicking somewhere else closes it.
- [ ] B sends A 3 messages while A is in another chat. A's chat list shows a red 3, and the Chats tab shows 3. ⋮ → Mute: the red number goes, 🔕 shows. Unmute: it comes back. Open the chat: it goes.
- [ ] A sends a message. Under it: Sent, then Delivered (B's device got it), then Read (B opened the chat). Only A's newest message shows this.
- [ ] A types: B sees "(A's name) is typing…" above the box. A doesn't. A deletes the words: it goes away.
- [ ] Phone: hold your finger on your own message for half a second. Edit and Unsend appear. Computer: right-click it. Nothing appears for other people's messages.
- [ ] Edit a message: B sees "… is editing…", then the new words with "Edited" under them. Escape or Cancel stops editing.
- [ ] Home page: the chat is on the left. Open a chat, then open a drawing: the same chat is in the bottom panel. Go back home: it's on the left again. Phone: the chat is above your drawings.
- [ ] Two friends with Sunrise open: each sees a green dot on the other's picture (friends list and chats). One closes Sunrise or logs out: within about 2 minutes, the other sees a grey dot. Someone who isn't your friend never shows a dot.
- [ ] The chat list shows "N of 10 chats". With 10 chats, New group and 💬 Message (to a friend you haven't chatted with) say you can have up to 10. Leave or delete one, and it works again. Try to start a chat with a friend who has 10: it says they already have 10.
- [ ] Layers: make 3 overlapping shapes. Select the bottom one: "Layer 1 of 3". Type 2 and press ▲ Forward: it's on top. ⏬ To back and ⏫ To front work. Undo puts it back. Save Picture keeps the order.
- [ ] Zoom: − and + change the % and everything gets smaller or bigger together. Draw and drag at 200%: they land where you point. Press the %: back to 100%. Ctrl + mouse wheel zooms where the mouse is. Phone/iPad: pinch with two fingers.
- [ ] Cursor tool, zoomed in: the pointer is a ✋ over empty canvas. Drag it: the page moves with you. Dragging a shape still moves the shape. At 100% on a normal drawing there's no hand (nothing more to see).
- [ ] Vertical (phone) and Vertical (A4): a white portrait page in the middle. Draw at the bottom of it, add shapes and a photo. Save Picture: the picture is exactly the page (1080 × 1920 or 1240 × 1754 at Normal). Go home and open it again: still a page.
- [ ] Export: Graphic shows Normal / High / Best. The pixel size in the panel doubles at High and triples at Best. Text and shapes look much sharper at High than at Normal.
- [ ] Unsend a message and a photo. They disappear for both people.
- [ ] Delete a 1-to-1 chat. It's gone for both people, with all its messages and photos.
- [ ] Make a group. Others don't have 🗑 Delete group; the maker does. Delete it: gone for everyone.
- [ ] Make another group. Everyone leaves. After the last person leaves, it's gone (check in Supabase → Table Editor → chats).

**Clear**

- [ ] The Clear button is right after Undo in the top bar (always visible), with a red outline, the same size as the other buttons. Pressing it always asks first.
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
  Clear button has a red outline (same size as other buttons) and sits right
  after Undo in the top bar (moved there 15 November 2026, product owner's
  choice; it used to be at the end of the Home row, away from Undo). Because
  it's next to Undo now, the "are you sure?" box matters even more. The old "New Drawing" button
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
  after, so Sunrise stays one HTML file. The safety rules live in the database
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
- **Confirm email is off** (needed for accounts without an email), and so is
  **Secure email change** (the pretend email can't confirm anything). When you
  add a real email, Supabase emails it a link, and the email only changes once
  you click it. That proves the email is really yours.
- **Chats can be 1-to-1 or groups** (product owner's choice). Only friends can
  be put in a chat, so strangers can't message you.
- **Old browser accounts can be moved online** (product owner's choice). It
  asks for the old password, so on a shared computer nobody can move someone
  else's drawings into their own account.
- **Photos are only sent to the server when they change.** The drawing saves
  after every change, and photos are big, so this keeps saving quick.
- **Saves happen in order**, one after another, so an older save can never
  finish after a newer one and undo it.
- **Sharing is with friends, through an inbox** (product owner's choice). Project
  files were removed. Only the owner can share, and only with friends.
- **Everyone edits at once** (product owner's choice). Each change is sent as
  "what's different": the items that changed, and a small picture of the part of
  the brush drawing that changed. If two people change the very same thing at
  the same moment, the last change wins. Changes that arrive while you're
  drawing or dragging wait until you let go.
- **Undo only undoes your own work.** After a friend's change, Undo starts again
  from there, so it can never undo something they did.
- **Chat photos and videos are deleted once delivered** (product owner's choice).
  The server only passes them along: when everyone in the chat has
  downloaded a file (each browser says "got it"), it's deleted. Each browser
  keeps its own copy (in IndexedDB). This keeps the 1 GB of free storage from
  filling up. The catch: other devices can't see old photos.
- **Size limits** (product owner's choice): photos 1 MB, videos 5 MB, 50 MB a
  week per person.
- **Export quality ("Graphic")** (product owner's choice): Normal (same size as the screen), **High** (2× sharper, the default) and Best (3× sharper). High and Best draw everything again at that size, so text, shapes and photos come out crisp. The brush drawing is made of dots, so it gets bigger but not sharper. PDFs print the same size whatever you pick, just sharper; SVG is sharp anyway.
- **Zoom works on a "stage"**: the canvas and every item sit on one box that's scaled up or down, so they always zoom together. Mouse movements are divided by the zoom, so dragging and drawing land in the right place.
- **Sunrise theme** (product owner's choice): warm sunrise colours (coral, orange, peach, gold) with a soft, rounded, modern look (inspired by apps like Canva, but our own design). Only colours, corners, shadows and the font changed; **nothing moved**. Borders kept their thickness, so every panel is exactly where it was. All the colours are in one list at the top of hello.html (the `--sr-...` names), so the theme can be tuned in one place. The colours you draw with aren't affected.
- **Up to 10 chats each** (product owner's choice). It counts every chat
  you're in, so it's checked for everyone being added, not just the person
  making the chat.
- **Up to 20 drawings each** (product owner's choice), so the 500 MB free
  database can't fill up. Drawings are kept on the server until deleted (so
  they open on every device); this limit keeps that safe.
- **Chat photos and videos are kept in Supabase Storage** while they wait to
  be delivered, not in the database, because videos are big. Each chat has its own private folder, so deleting a
  chat can delete all its files.
- **Chat messages are deleted after 7 days** (product owner's choice), instead
  of being kept for ever. Most chat apps keep messages on the server (so they
  show on every device); keeping only the last week is a middle ground for
  privacy. Supabase doesn't let the database delete stored files, so old
  photos and videos are deleted by Sunrise itself, once a day, when someone
  logs in.
- **Profile pictures are tiny** (128 × 128 pixels), so they load fast everywhere.
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
- Sunrise needs the internet. Without it you can keep drawing, but nothing is
  saved until the internet is back (it keeps trying every 10 seconds). Closing
  the page while offline loses the unsaved changes.
- Chats only show the newest 100 messages.
- Free Supabase projects pause after a week of nobody using them (see
  [SETUP-ONLINE.md](SETUP-ONLINE.md)).
- Supabase's built-in email sender only sends a few emails an hour, so if lots
  of people ask for a new password at once, some might have to wait.
- Accounts without an email can't get a new password if they forget it.
- The online dot can take up to about 2 minutes to turn grey (if Sunrise
  closes without saying goodbye, like when a phone goes to sleep), and up to
  30 seconds to update on your screen.
- When drawing together, if two people change the very same item at the same
  moment, one change wins and the other is lost. Two people drawing with the
  brush in the same spot at the same moment can also overwrite each other's
  strokes there.
- After a friend changes the drawing, Undo can't go back past their change.
- A very big change (like a huge photo, or Clear on a big canvas) is too big to
  send live, so it's saved first, and the others load the saved drawing. That
  takes a few seconds.
- If you delete your account, photos and videos you sent stay in the storage
  (their messages are deleted, so nobody can see them). They can be cleaned
  up in Supabase → Storage.
- Free Supabase storage is 1 GB in total for chat photos and videos (it only
  holds files that haven't been delivered yet).
- Old chat photos and videos only show on the device that received them. On a
  new device, or after clearing browser data, they say "no longer available".
- A photo or video in a group stays on the server until everyone in the group
  has opened the chat (at most 7 days).
- Old chat photos and videos are only deleted when someone in that chat logs
  in (at most once a day), so they can stay in storage a little longer than 7
  days. Nobody can see them after 7 days, because their messages are gone.
- Filters only work on photos and stickers, not on the brush drawing.
- Dragging pictures from websites only works when the website allows copying its pictures. Many do (like Wikipedia); some don't. Dragging only works with a mouse on a computer, not on phones or iPads.
- Saved picture file names don't use the drawing's name yet.
