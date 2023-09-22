## 1.4.1
* fix: build error on Flutter 3.13 by @LucasXu0 in ([#488](https://github.com/AppFlowy-IO/appflowy-editor/pull/488))

## 1.4.0
* feat: adjust the loading large document optimization in mobile platform by @LucasXu0 in ([#474](https://github.com/AppFlowy-IO/appflowy-editor/pull/474))
* feat: simplify auto scroll behavior in ScrollServiceWidget by @LucasXu0 in ([#437](https://github.com/AppFlowy-IO/appflowy-editor/pull/437))
* feat: implement delta diff and provide external values by @LucasXu0 in ([#444](https://github.com/AppFlowy-IO/appflowy-editor/pull/444))
* feat: add more showcases on the mobile platform by @LucasXu0 in ([#479](https://github.com/AppFlowy-IO/appflowy-editor/pull/479))
* feat: add more showcases on desktop/mobile platform by @LucasXu0 in ([#481](https://github.com/AppFlowy-IO/appflowy-editor/pull/481))
* feat: support customizing the record time by @LucasXu0 in ([#461](https://github.com/AppFlowy-IO/appflowy-editor/pull/461))
* feat: bulk open links shortcut by @Tony-MK in ([#419](https://github.com/AppFlowy-IO/appflowy-editor/pull/419))
* feat: optimize the performance by @LucasXu0 in ([#442](https://github.com/AppFlowy-IO/appflowy-editor/pull/62))
* fix: request focus in find replace menu by @Xazin in ([#440](https://github.com/AppFlowy-IO/appflowy-editor/pull/440))
* fix: remove unused check in non_delta_input_service by @LucasXu0 in ([#447](https://github.com/AppFlowy-IO/appflowy-editor/pull/447))
* fix: unable to paste html contains section by @LucasXu0 in ([#448](https://github.com/AppFlowy-IO/appflowy-editor/pull/448))
* fix: sometimes failed to paste content from google translation by @LucasXu0 in ([#451](https://github.com/AppFlowy-IO/appflowy-editor/pull/451))
* fix: duration cannot be zero in animate by @Xazin in ([#452](https://github.com/AppFlowy-IO/appflowy-editor/pull/452))
* fix: image upload on web by @garv-shah in ([#453](https://github.com/AppFlowy-IO/appflowy-editor/pull/453))
* fix block selection area by @LucasXu0 in ([#462](https://github.com/AppFlowy-IO/appflowy-editor/pull/462))
* fix: resolve `RangeError` when last row deleted. by @sun-jiao in ([#470](https://github.com/AppFlowy-IO/appflowy-editor/pull/470))
* fix: resolve layout problem of `FindMenuWidget` by @sun-jiao in ([#467](https://github.com/AppFlowy-IO/appflowy-editor/pull/467))
* fix: show reset color button even if one of the selected text was formatted by @LucasXu0 in ([#476](https://github.com/AppFlowy-IO/appflowy-editor/pull/476))
* fix: selection area doesn't show if in the long selection by @LucasXu0 in ([#477](https://github.com/AppFlowy-IO/appflowy-editor/pull/477))
* fix: DT_TOOLCHAIN_DIR path in Podfile for iOS and macOS by @LucasXu0 in ([#483](https://github.com/AppFlowy-IO/appflowy-editor/pull/483))
* fix: respect default and last direction on new line and indent by @zoli in ([#482](https://github.com/AppFlowy-IO/appflowy-editor/pull/482))
* fix: link menu overflow in right by @sun-jiao in ([#478](https://github.com/AppFlowy-IO/appflowy-editor/pull/478))
* fix: resolve "Bad state: no element" when in-table paragraph deleted by @sun-jiao in ([#471](https://github.com/AppFlowy-IO/appflowy-editor/pull/471))
* chore: add jumpTo to editor scroll service by @Xazin in ([#466](https://github.com/AppFlowy-IO/appflowy-editor/pull/466))
* chore: update l10n by @sun-jiao in ([#463](https://github.com/AppFlowy-IO/appflowy-editor/pull/463))
* chore: refactor attribute comparison in Delta class diff loop by @LucasXu0 in ([#456](https://github.com/AppFlowy-IO/appflowy-editor/pull/456))
* chore: update Chinese l10n by @sun-jiao in ([#445](https://github.com/AppFlowy-IO/appflowy-editor/pull/445))
* chore: migrate tests by @MayurSMahajan in ([#438](https://github.com/AppFlowy-IO/appflowy-editor/pull/438))
* chore: refactor color conversion method to handle RGB and hex formatsRefactor method to handle RGB and hex formats, improving color conversion by @LucasXu0 in ([#450](https://github.com/AppFlowy-IO/appflowy-editor/pull/450))

## 1.3.0
* feat: support table plugin by @zoli in ([#62](https://github.com/AppFlowy-IO/appflowy-editor/pull/62))
* feat: support alignment for block component by @LucasXu0 in ([#425](https://github.com/AppFlowy-IO/appflowy-editor/pull/425))
* feat: toggle highlight using ctrl/cmd + shift + h by @MayurSMahajan in ([#333](https://github.com/AppFlowy-IO/appflowy-editor/pull/333))
* feat: refactor floating toolbar positioning logic by @LucasXu0 in ([#422](https://github.com/AppFlowy-IO/appflowy-editor/pull/42))
* feat: default text direction property by @zoli in ([#402](https://github.com/AppFlowy-IO/appflowy-editor/pull/402))
* fix: rect of the divider block is incorrect by @LucasXu0 in ([#415](https://github.com/AppFlowy-IO/appflowy-editor/pull/415))
* fix: replace matches on the same node by @MayurSMahajan in ([#418](https://github.com/AppFlowy-IO/appflowy-editor/pull/418))
* fix: update resizable image width calculation with minimum width constraint by @LucasXu0 in ([#421](https://github.com/AppFlowy-IO/appflowy-editor/pull/421))
* fix: fixed the cursor not moving to next line after inserting divider by @Mukund-Tandon in ([#371](https://github.com/AppFlowy-IO/appflowy-editor/pull/371))
* fix: html encoder not adding multiple text decorations by @alihassan143 in ([#424](https://github.com/AppFlowy-IO/appflowy-editor/pull/424))
* fix: exception on prev node text direction null by @zoli in ([#404](https://github.com/AppFlowy-IO/appflowy-editor/pull/404))

## 1.2.4
* feat: improve CJK IME support by @LucasXu0 in ([#412](https://github.com/AppFlowy-IO/appflowy-editor/pull/412))
* feat: implement find dialog by @MayurSMahajan in ([#106](https://github.com/AppFlowy-IO/appflowy-editor/pull/106))
* feat: improve functionality for pasting from html by @LucasXu0 in ([#391](https://github.com/AppFlowy-IO/appflowy-editor/pull/391))
* feat: placeholder on paragraph when selected by @Xazin in ([#390](https://github.com/AppFlowy-IO/appflowy-editor/pull/390))
* feat: double hyphen to em dash by @Xazin in ([#395](https://github.com/AppFlowy-IO/appflowy-editor/pull/395))
* feat: skip whitespace between words while navigating with CTRL+ARROW keys by @johansutrisno in ([#363](https://github.com/AppFlowy-IO/appflowy-editor/pull/363))
* feat: add support for context menu items to the editor by @LucasXu0 in ([#410](https://github.com/AppFlowy-IO/appflowy-editor/pull/410))
* feat: add support for custom parser for markdown to document by @Mukund-Tandon in ([#403](https://github.com/AppFlowy-IO/appflowy-editor/pull/403))
* fix: miss the nested node when copying by @LucasXu0 in ([#406](https://github.com/AppFlowy-IO/appflowy-editor/pull/406))
* fix: refactor _onSelectionChange to update _showPlaceholder state more efficiently by @LucasXu0 in ([#409](https://github.com/AppFlowy-IO/appflowy-editor/pull/409))

## 1.2.3
* feat: add edit link menu on mobile by @hyj1204 in ([#320](https://github.com/AppFlowy-IO/appflowy-editor/pull/320))
* feat: html encode parser added by @alihassan143 in ([#314](https://github.com/AppFlowy-IO/appflowy-editor/pull/314))
* feat: support scroll without animation by @LucasXu0 in ([#343](https://github.com/AppFlowy-IO/appflowy-editor/pull/343))
* feat: expose context in nodeBuilder by @hyj1204 in ([#350](https://github.com/AppFlowy-IO/appflowy-editor/pull/350))
* feat: paste plaintext shortcut by @MayurSMahajan in ([#338](https://github.com/AppFlowy-IO/appflowy-editor/pull/338))
* fix: indent padding from left when rtl by @zoli in ([#318](https://github.com/AppFlowy-IO/appflowy-editor/pull/318))
* fix: fixed numbered list being treated as a paragraph by @Mukund-Tandon in ([#335](https://github.com/AppFlowy-IO/appflowy-editor/pull/335))
* fix: copy handler migrated to latest api by @alihassan143 in ([#240](https://github.com/AppFlowy-IO/appflowy-editor/pull/240))
* fix: improve performance on editor overlays by @richardshiue in ([#336](https://github.com/AppFlowy-IO/appflowy-editor/pull/336))
* fix: fixed the issue of code block not being exported in markdown by @Mukund-Tandon in ([#347](https://github.com/AppFlowy-IO/appflowy-editor/pull/347))
* fix: fixed unresponsive behavior of context menu items by @Mukund-Tandon in ([#349](https://github.com/AppFlowy-IO/appflowy-editor/pull/349))
* fix: selection reason should be ui event when clicking by @LucasXu0 in ([#359](https://github.com/AppFlowy-IO/appflowy-editor/pull/359))
* fix: show selection menu at left by @zoli in([#361](https://github.com/AppFlowy-IO/appflowy-editor/pull/361))
* fix: selection menu respect current node direction by @zoli in ([#359](https://github.com/AppFlowy-IO/appflowy-editor/pull/360))

## 1.2.2
* chore: minor updates to documentation.

## 1.2.1
* feat: support collapsed list by @LucasXu0 in ([#319](https://github.com/AppFlowy-IO/appflowy-editor/pull/319))
* feat: improve keyboard behavior in mobile toolbar by @hyj1204 in ([#287](https://github.com/AppFlowy-IO/appflowy-editor/pull/287))
* feat: support for shift + home/end keys by @MayurSMahajan in ([#306](https://github.com/AppFlowy-IO/appflowy-editor/pull/306))
* feat: delete right word with ctrl+delete by @MayurSMahajan in ([#309](https://github.com/AppFlowy-IO/appflowy-editor/pull/309))
* fix: fix overflow in heading mobile toolbar menu by @hyj1204 in ([#291](https://github.com/AppFlowy-IO/appflowy-editor/pull/291))
* fix: allow active toolbar widget color to be customized by @garv-shah in ([#261](https://github.com/AppFlowy-IO/appflowy-editor/pull/261))
* fix: block selection overflow by @LucasXu0 in ([#312](https://github.com/AppFlowy-IO/appflowy-editor/pull/312))
* fix: toolbar item tooltips are too responsive by @johansutrisno in ([#315](https://github.com/AppFlowy-IO/appflowy-editor/pull/315))

## 1.2.0
* feat: added support for RTL and AUTO direction by @zoli in ([#191](https://github.com/AppFlowy-IO/appflowy-editor/pull/191))
* feat: added support for customizing href behavior by @LucasXu0 in ([#293](https://github.com/AppFlowy-IO/appflowy-editor/pull/293))
* feat: added support for delete key shortcut by @MayurSMahajan in ([#272](https://github.com/AppFlowy-IO/appflowy-editor/pull/272))
* feat: added support customize the font family by @LucasXu0 in ([#300](https://github.com/AppFlowy-IO/appflowy-editor/pull/300))
* fix: slash menu keyword not shows up the option by @johansutrisno in ([#268](https://github.com/AppFlowy-IO/appflowy-editor/pull/268))
* fix: unable to access the slash menu on web platform by @LucasXu0 in ([#303](https://github.com/AppFlowy-IO/appflowy-editor/pull/303))
* chore: change windows and linux command for redo by @MayurSMahajan in ([#294](https://github.com/AppFlowy-IO/appflowy-editor/pull/294))
* chore: optimize the textSpan decorator by @LucasXu0 in ([#290](https://github.com/AppFlowy-IO/appflowy-editor/pull/290))
* chore: remove the reference of the deprecated values by @LucasXu0 in ([#304](https://github.com/AppFlowy-IO/appflowy-editor/pull/304))

## 1.1.0
* feat: support IME by @LucasXu0 in ([#253](https://github.com/AppFlowy-IO/appflowy-editor/pull/253))
* feat: support text and background color in mobile toolbar by @hyj1204 in ([#233](https://github.com/AppFlowy-IO/appflowy-editor/pull/233))
* feat: support broadcast the transaction before applying it by @LucasXu0 in ([#226](https://github.com/AppFlowy-IO/appflowy-editor/pull/226))
* feat: support customizing text attribute key and rendering by @LucasXu0 in ([#244](https://github.com/AppFlowy-IO/appflowy-editor/pull/244))
* feat: support customizing the block icon widget by @LucasXu0 in ([#274](https://github.com/AppFlowy-IO/appflowy-editor/pull/274))
* feat: support uploading images from local files by @Mukund-Tandon in ([#232](https://github.com/AppFlowy-IO/appflowy-editor/pull/232))
* feat: add underline syntax parser by @vedant-pandey in ([#256](https://github.com/AppFlowy-IO/appflowy-editor/pull/256))
* feat: migrate the delta encoder by @LucasXu0 in ([#277](https://github.com/AppFlowy-IO/appflowy-editor/pull/277))
* feat: support divider toolbar item in mobile by @hyj1204 in ([#281](https://github.com/AppFlowy-IO/appflowy-editor/pull/281))
* feat: customized color options by @hyj1204 in ([#270](https://github.com/AppFlowy-IO/appflowy-editor/pull/270))
* feat: support exiting link menu by ESC by @vincenzoursano in ([#124](https://github.com/AppFlowy-IO/appflowy-editor/pull/124))
* fix: focus node doesn't work on mobile by @LucasXu0 in ([#227](https://github.com/AppFlowy-IO/appflowy-editor/pull/227))
* fix: the cursor is inaccuracy when the text contains special emoji by @LucasXu0 in ([#238](https://github.com/AppFlowy-IO/appflowy-editor/pull/238))
* fix: extend attribute keys shouldn't be sliced by @LucasXu0 in ([#248](https://github.com/AppFlowy-IO/appflowy-editor/pull/248))
* fix: keep keyboard appearance as same brightness as system theme by @hyj1204 in ([#264](https://github.com/AppFlowy-IO/appflowy-editor/pull/264))

## 1.0.4
* feat: support mobile drag selection by @LucasXu0 in ([#209](https://github.com/AppFlowy-IO/appflowy-editor/pull/209))
* feat: support customizing number of the numbered list by @LucasXu0 in ([#219](https://github.com/AppFlowy-IO/appflowy-editor/pull/219))
* feat: optimize the scroll service by @LucasXu0 in ([#210](https://github.com/AppFlowy-IO/appflowy-editor/pull/210))
* feat: added code block support for conversion from  markdown to document by @Mukund-Tandon in ([#197](https://github.com/AppFlowy-IO/appflowy-editor/pull/197))
* feat: add underline shortcut by @AmanNegi in ([#199](https://github.com/AppFlowy-IO/appflowy-editor/pull/199))
* feat: support IME in macOS by @LucasXu0 in ([#221](https://github.com/AppFlowy-IO/appflowy-editor/pull/221))
* fix: behavior of home and end keys on windows by @MayurSMahajan in ([#213](https://github.com/AppFlowy-IO/appflowy-editor/pull/213))
* fix: toolbar position at most top by @zoli in ([#214](https://github.com/AppFlowy-IO/appflowy-editor/pull/214))
* fix: tabbing whitespace at the front will convert current paragraph into heading by @LucasXu0 in ([#206](https://github.com/AppFlowy-IO/appflowy-editor/pull/206))
* fix: added default options to both text color and background color by @the-jasoney in ([#208](https://github.com/AppFlowy-IO/appflowy-editor/pull/208))
* fix: numbered lists have issue with the dot by @LucasXu0 in ([#217](https://github.com/AppFlowy-IO/appflowy-editor/pull/217))
* fix: unable to delete the divider via backspace by @LucasXu0 in ([#216](https://github.com/AppFlowy-IO/appflowy-editor/pull/216))
* fix: mobile selection scroll should work on both side by @LucasXu0 in ([#220](https://github.com/AppFlowy-IO/appflowy-editor/pull/220))
* fix: copy handler migrated to latest api by @alihassan143 in ([#192](https://github.com/AppFlowy-IO/appflowy-editor/pull/192))
* chore: export key mapping file and fix outdent typo by @MayurSMahajan in ([#207](https://github.com/AppFlowy-IO/appflowy-editor/pull/207))

## 1.0.3
* feat: clear selection automatically when editor lost focus by @LucasXu0 in ([#194](https://github.com/AppFlowy-IO/appflowy-editor/pull/194))
* feat: support customizing the focus node of editor by @LucasXu0 in ([#198](https://github.com/AppFlowy-IO/appflowy-editor/pull/198))

## 1.0.2
* feat: support mobile toolbar by @hyj1204 in ([#161](https://github.com/AppFlowy-IO/appflowy-editor/pull/161))
* feat: support shrinkWrap by @LucasXu0 in ([#186](https://github.com/AppFlowy-IO/appflowy-editor/pull/186))
* feat: support updating the character of shortcut event by @LucasXu0 in ([#187](https://github.com/AppFlowy-IO/appflowy-editor/pull/187))
* chore: mark selectionMenuItems as deprecated ignored by @LucasXu0 in ([#182](https://github.com/AppFlowy-IO/appflowy-editor/pull/182))

## 1.0.1
* feat: support inserting divider through `***` by @glunkad in ([#118](https://github.com/AppFlowy-IO/appflowy-editor/pull/118))
* feat: document to html encoder added by @alihassan143 in ([#175](https://github.com/AppFlowy-IO/appflowy-editor/pull/175))
* fix: v0.1.0 bugs by @LucasXu0 in ([#176](https://github.com/AppFlowy-IO/appflowy-editor/pull/176))
* fix: nested elements getting ignored by @alihassan143 in ([#178](https://github.com/AppFlowy-IO/appflowy-editor/pull/178))

## 1.0.0
* chore: release 1.0.0

## 1.0.0-dev.4
* fix: the background color of nested block component overflow by @LucasXu0 in ([#172](https://github.com/AppFlowy-IO/appflowy-editor/pull/172))
* fix: upload image menu overflow by @LucasXu0 in ([#172](https://github.com/AppFlowy-IO/appflowy-editor/pull/172))
* fix: merge the block component into the block which shouldn't render children block by @LucasXu0 in ([#172](https://github.com/AppFlowy-IO/appflowy-editor/pull/172))
* fix: select all command doesn't work in nested list by @LucasXu0 in ([#173](https://github.com/AppFlowy-IO/appflowy-editor/pull/173))
* fix: ignore delete operation if it's repeated by @LucasXu0 in ([#173](https://github.com/AppFlowy-IO/appflowy-editor/pull/173))

## 1.0.0-dev.3
* fix: block selection size overflow by @LucasXu0 in ([#169](https://github.com/AppFlowy-IO/appflowy-editor/pull/169))
* fix: the default index should be 0 in slash menu by @LucasXu0 in ([#171](https://github.com/AppFlowy-IO/appflowy-editor/pull/171))

## 1.0.0-dev.2
* fix: toolbar item size by @LucasXu0 in ([#167](https://github.com/AppFlowy-IO/appflowy-editor/pull/167))
* fix: scroll widget layout by @LucasXu0 in ([#167](https://github.com/AppFlowy-IO/appflowy-editor/pull/167))
* fix: image align overflow by @LucasXu0 in ([#167](https://github.com/AppFlowy-IO/appflowy-editor/pull/167))
* fix: editable parameter doesn't work by @LucasXu0 in ([#167](https://github.com/AppFlowy-IO/appflowy-editor/pull/167))
* fix: fixed toolbar item tooltip description for embed code button by @Mukund-Tandon in in ([#163](https://github.com/AppFlowy-IO/appflowy-editor/pull/163))

## 1.0.0-dev.1
* feat: rename delta keys and document keys by @LucasXu0 in ([#153](https://github.com/AppFlowy-IO/appflowy-editor/pull/153))
* fix: floating toolbar overflow by @LucasXu0 in ([#146](https://github.com/AppFlowy-IO/appflowy-editor/pull/146))
* fix: missing format when converting html to document by @alihassan143 in ([#152](https://github.com/AppFlowy-IO/appflowy-editor/pull/152))
* fix: unable to delete node on the mobile platform by @LucasXu0 in ([#154](https://github.com/AppFlowy-IO/appflowy-editor/pull/154))

## 1.0.0-dev.0
* feat: refactor the editor part for supporting the mobile platform by @LucasXu0 in ([#129](https://github.com/AppFlowy-IO/appflowy-editor/pull/129))
* feat: upgrade flutter to 3.10.1 by @Xazin in ([#136](https://github.com/AppFlowy-IO/appflowy-editor/pull/136))
* feat: support auto scroll after selection updated by @LucasXu0 in ([#140](https://github.com/AppFlowy-IO/appflowy-editor/pull/140))
* fix: image placeholder border color by @nurmukhametdaniyar in ([#119](https://github.com/AppFlowy-IO/appflowy-editor/pull/119))

## 0.1.12
* chore: minor updates to documentation.

## 0.1.11
* feat: allow textPadding customization by @simonbengtsson in ([#108](https://github.com/AppFlowy-IO/appflowy-editor/pull/108))
* fix: nested text node parser by @Xazin ([#115](https://github.com/AppFlowy-IO/appflowy-editor/pull/115))

## 0.1.10
* feat: support single asterisk to italic by @Xazin in ([#92](https://github.com/AppFlowy-IO/appflowy-editor/pull/92))
* fix: remove platform check in theme on web by @Xazin in ([#91](https://github.com/AppFlowy-IO/appflowy-editor/pull/91))
* fix: improves cursor left word delete by @MayurSMahajan in ([#8](https://github.com/AppFlowy-IO/appflowy-editor/pull/88))
* fix: one overlay entry for selection menu by @Xazin in ([#82](https://github.com/AppFlowy-IO/appflowy-editor/pull/82))
* fix: changing heading from one level to another from toolbar by @LucasXu0 in ([#96](https://github.com/AppFlowy-IO/appflowy-editor/pull/96))

## 0.1.9
* feat: dark mode improvement by @hyj1204 in ([#90](https://github.com/AppFlowy-IO/appflowy-editor/pull/90))
* feat: shift+tab to outdent a indented bulletpoint or checkbox. by @MayurSMahajan in ([#63](https://github.com/AppFlowy-IO/appflowy-editor/pull/63))
* fix: enter to outdent checkbox/bullet lists by @Xazin in ([#84](https://github.com/AppFlowy-IO/appflowy-editor/pull/84))

## 0.1.8
* chore: minor updates to documentation.

## 0.1.7
* feat: delete "sentence" shortcut by @Xazin in ([#32](https://github.com/AppFlowy-IO/appflowy-editor/pull/32))
* feat: allow developer to change toolbar color as well as option to show default toolbar items and html to document converter added by @alihassan143 in ([#58](https://github.com/AppFlowy-IO/appflowy-editor/pull/58))
* fix: add custom color selector for text by @Xazin in ([#74](https://github.com/AppFlowy-IO/appflowy-editor/pull/74))
* fix: delete node does not propagate non null selection by @squidrye in ([#45](https://github.com/AppFlowy-IO/appflowy-editor/pull/45))
* fix: lessen horizontal editor padding for mobile by @Xazin in ([#70](https://github.com/AppFlowy-IO/appflowy-editor/pull/70))
* test: improve coverage by @Xazin in ([#61](https://github.com/AppFlowy-IO/appflowy-editor/pull/61))

## 0.1.6
* fix: documentation typo issue by @Mukund-Tandon in ([#36](https://github.com/AppFlowy-IO/appflowy-editor/pull/36))
* fix: avoid using Platform code in Web by @LucasXu0 in ([#48](https://github.com/AppFlowy-IO/appflowy-editor/pull/48))

## 0.1.5
* feat: add em and divider support to html converter by @Xazin in ([#27](https://github.com/AppFlowy-IO/appflowy-editor/pull/22))
* feat: alt + arrow key to move cursor one word by @Xazin in ([#28](https://github.com/AppFlowy-IO/appflowy-editor/pull/28))
* fix: cannot edit image or see link menu if editorState is uneditable by @Xazin in ([#30](https://github.com/AppFlowy-IO/appflowy-editor/pull/30))
* fix: Copy Paste on Web by @Akshay-akkay in ([#33](https://github.com/AppFlowy-IO/appflowy-editor/pull/33))
* chore: add danish translations by @Xazin in ([#34](https://github.com/AppFlowy-IO/appflowy-editor/pull/34))
* chore: Sync the latest code from AppFlowy by @LucasXu0 in ([#41](https://github.com/AppFlowy-IO/appflowy-editor/pull/41))
* test: improve test coverage by @Xazin in ([#23](https://github.com/AppFlowy-IO/appflowy-editor/pull/23))
* test: redo undo with text formatting by @MayurSMahajan in ([#38](https://github.com/AppFlowy-IO/appflowy-editor/pull/38))

## 0.1.4
* chore: export editor style ([#27](https://github.com/AppFlowy-IO/appflowy-editor/pull/25)).

## 0.1.3
* chore: update the dependencies to the latest release by @LucasXu0 ([#25](https://github.com/AppFlowy-IO/appflowy-editor/pull/25)).

## 0.1.2
* fix: bug on node iterator with nested nodes by @LucasXu0 ([#11](https://github.com/AppFlowy-IO/appflowy-editor/pull/11)).
* fix: SVG display error in the latest version by @LucasXu0 ([#12](https://github.com/AppFlowy-IO/appflowy-editor/pull/12)).
* fix: Using the mouse to highlight text very easy to miss the first letter by @LucasXu0 ([#13](https://github.com/AppFlowy-IO/appflowy-editor/pull/13)).
* chore: fix some known issues by @LucasXu0 in ([#14](https://github.com/AppFlowy-IO/appflowy-editor/pull/14)).

## 0.1.1
* Relicense Appflowy Editor by @hyj1204.
* Improve the toolbar user-experience by @LucasXu0.
* Improve the test code coverage by @GouravShDev.

## 0.1.0
* Support Flutter 3.7.5.

## 0.0.9
* Support customize the text color and text background color.
* Fix some bugs.

## 0.0.8
* Fix the toolbar display issue.
* Fix the copy/paste issue on Windows.
* Minor Updates.

## 0.0.7
* Refactor theme customizer, and support dark mode.
* Support export and import markdown.
* Refactor example project.
* Fix some bugs.

## 0.0.6
* Add three plugins: Code Block, LateX, and Horizontal rule.
* Support web platform.
* Support more markdown syntax conversions.
    * `~ ~` to format text as strikethrough
    * `_ _` to format text as italic
    * \` \` to format text as code
    * `[]()` to format text as link
* Fix some bugs.

## 0.0.5
* Support customize the hotkeys for a shortcut on different platforms.
* Support customize a theme.
* Support localizations.
* Support insert numbered lists.
* Fix some bugs.

## 0.0.4
* Support more shortcut events.
* Fix some bugs.
* Update the documentation.

## 0.0.3
* Support insert image.
* Support insert link.
* Fix some bugs.

## 0.0.2
Minor Updates to Documentation.

## 0.0.1
Initial Version of the library.
