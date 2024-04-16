## 2.3.4
* feat: support customizing mobile page style by @LucasXu0 in [769](https://github.com/AppFlowy-IO/appflowy-editor/pull/769)
* feat: add table style by @q200892907 in [766](https://github.com/AppFlowy-IO/appflowy-editor/pull/766)
* feat: support auto complete for text block by @LucasXu0 in [764](https://github.com/AppFlowy-IO/appflowy-editor/pull/764)
* fix: unable to select multiple words by @LucasXu0 in [761](https://github.com/AppFlowy-IO/appflowy-editor/pull/761)
* fix: filter invalid text editing value by @LucasXu0 in [760](https://github.com/AppFlowy-IO/appflowy-editor/pull/760)
* feat: combine diff operations by @LucasXu0 in [759](https://github.com/AppFlowy-IO/appflowy-editor/pull/759)
* fix: delta insert error by @LucasXu0 in [758](https://github.com/AppFlowy-IO/appflowy-editor/pull/758)
* feat: add more gesture interceptors by @Xazin in [757](https://github.com/AppFlowy-IO/appflowy-editor/pull/757)
* feat: support remote selections by @LucasXu0 in [753](https://github.com/AppFlowy-IO/appflowy-editor/pull/753)
* fix: late initialization error by @LucasXu0 in [750](https://github.com/AppFlowy-IO/appflowy-editor/pull/750)
* feat: add diff document/nodes function by @LucasXu0 in [748](https://github.com/AppFlowy-IO/appflowy-editor/pull/748)
* fix: render paragraph hot reload error by @LucasXu0 in [742](https://github.com/AppFlowy-IO/appflowy-editor/pull/742)
* feat: disable converting heading block to numbered list block by @LucasXu0 in [740](https://github.com/AppFlowy-IO/appflowy-editor/pull/740)
* fix: xtra space from numbered list item by @lming in [724](https://github.com/AppFlowy-IO/appflowy-editor/pull/724)
* fix: disable tableActionHandler when the editorState is not editable by @Taverz in [733](https://github.com/AppFlowy-IO/appflowy-editor/pull/733)
* feat: add fixed toolbar example by @LucasXu0 in [739](https://github.com/AppFlowy-IO/appflowy-editor/pull/739)

## 2.3.3
* feat: word counter service by @Xazin in [706](https://github.com/AppFlowy-IO/appflowy-editor/pull/706)
* feat: support scaling the svg by @LucasXu0 in [722](https://github.com/AppFlowy-IO/appflowy-editor/pull/722)
* feat: support selecting word on iOS through long pressing by @LucasXu0 in [728](https://github.com/AppFlowy-IO/appflowy-editor/pull/728)
* fix: Slash command menu bad positioning in Web Version by @dagyu in [709](https://github.com/AppFlowy-IO/appflowy-editor/pull/709)
* fix: unable to export image block in markdown format by @rileyhawk1417 in [713](https://github.com/AppFlowy-IO/appflowy-editor/pull/713)
* fix: unable to click the items in a long list by @LucasXu0 in [725](https://github.com/AppFlowy-IO/appflowy-editor/pull/725)
* fix: resolve data loss issue during block type conversion by @LucasXu0 in [726](https://github.com/AppFlowy-IO/appflowy-editor/pull/726)
* fix: unable to redo/undo in lists by @LucasXu0 in [727](https://github.com/AppFlowy-IO/appflowy-editor/pull/727)
* fix: flutter analyze by @LucasXu0 in [730](https://github.com/AppFlowy-IO/appflowy-editor/pull/730)
* chore: upgrade flutter version to 3.19.0 by @LucasXu0 in [719](https://github.com/AppFlowy-IO/appflowy-editor/pull/719)
* chore: rename highlight color to background color by @LucasXu0 in [729](https://github.com/AppFlowy-IO/appflowy-editor/pull/729)

## 2.3.2
* fix: platform api cause error on web platform.

## 2.3.1
* feat: backslash to ignore shortcut event by @hyj1204 in [#635](https://github.com/AppFlowy-IO/appflowy-editor/pull/635)
* feat: support formatting greater hyphen to single arrow by @Jayaprakash-dev in [#665](https://github.com/AppFlowy-IO/appflowy-editor/pull/665)
* feat: parse nested numbered list by @pithuene in [#674](https://github.com/AppFlowy-IO/appflowy-editor/pull/674)
* feat: optimize Enter operation by @q200892907 in [#673](https://github.com/AppFlowy-IO/appflowy-editor/pull/673)
* feat: add contentInsertionConfiguration to editor and text input service by @stevenosse in [#691](https://github.com/AppFlowy-IO/appflowy-editor/pull/691)
* fix: the menu dismissed after selecting block style by @LucasXu0 in [#670](https://github.com/AppFlowy-IO/appflowy-editor/pull/670)
* fix: solve the problem that Chinese IME cannot continue deleting after deleting input content by @q200892907 in [#672](https://github.com/AppFlowy-IO/appflowy-editor/pull/672)
* fix: the magnifier doesn't disappear when the selection is collapsed by @LucasXu0 in [#675](https://github.com/AppFlowy-IO/appflowy-editor/pull/675)
* fix: headingBlockComponentBuilder doesn't use placeholderTextStyle by @LucasXu0 in [#677](https://github.com/AppFlowy-IO/appflowy-editor/pull/677)
* fix: unable to use slide gesture to close keyboard by @LucasXu0 in [#676](https://github.com/AppFlowy-IO/appflowy-editor/pull/676)
* fix: upgrade markdown to 7.2.1 by @Xazin in [#686](https://github.com/AppFlowy-IO/appflowy-editor/pull/686)
* fix: windows chinese ime issue by @q200892907 in [#682](https://github.com/AppFlowy-IO/appflowy-editor/pull/682)
* fix: add support for breakline and divider by @penkzhou in [#690](https://github.com/AppFlowy-IO/appflowy-editor/pull/690)
* chore: localize more items by @jpenna in [#680](https://github.com/AppFlowy-IO/appflowy-editor/pull/680)
* chore: fix pasting keeps current node by @jpenna in [#689](https://github.com/AppFlowy-IO/appflowy-editor/pull/689)
* chore: translate commands by @jpenna in [#687](https://github.com/AppFlowy-IO/appflowy-editor/pull/687)

## 2.3.0
* feat: support customizing cursor width by @LucasXu0 in [#654](https://github.com/AppFlowy-IO/appflowy-editor/pull/654)
* feat: support updating cursor position via spacebar by @LucasXu0 in [#655](https://github.com/AppFlowy-IO/appflowy-editor/pull/655)
* feat: add markdown divider encoder parser by @hamishjohnson in [#639](https://github.com/AppFlowy-IO/appflowy-editor/pull/639)
* fix: Chinese input issue by @q200892907 in [#652](https://github.com/AppFlowy-IO/appflowy-editor/pull/652)
* fix: move cursor up/down issues by @LucasXu0 in [#657](https://github.com/AppFlowy-IO/appflowy-editor/pull/657)
* fix: ignore parent gesture by @q200892907 in [#660](https://github.com/AppFlowy-IO/appflowy-editor/pull/660)
* fix: support character deletion while holding down the Shift key by @Jayaprakash-dev in [#659](https://github.com/AppFlowy-IO/appflowy-editor/pull/659)

## 2.2.0
* feat: support customizing the mobile magnifier by @LucasXu0 in ([#625](https://github.com/AppFlowy-IO/appflowy-editor/pull/625))
* feat: support keep editor focus on mobile by @LucasXu0 in ([#628](https://github.com/AppFlowy-IO/appflowy-editor/pull/628))
* feat: support clicking the selection area to disable floating toolbar by @LucasXu0 in ([#632](https://github.com/AppFlowy-IO/appflowy-editor/pull/632))
* feat: adding an ability to have a link check before embedding by @johansutrisno in ([#603](https://github.com/AppFlowy-IO/appflowy-editor/pull/603))
* feat: Add markdown link syntax formatting by @jazima in ([#618](https://github.com/AppFlowy-IO/appflowy-editor/pull/618))
* feat: Table navigation using TAB key by @AnsahMohammad in ([#627](https://github.com/AppFlowy-IO/appflowy-editor/pull/627))
* feat: improve android selection gesture by @LucasXu0 in ([#647](https://github.com/AppFlowy-IO/appflowy-editor/pull/647))
* feat: improve ios touch gesture by @LucasXu0 in ([#648](https://github.com/AppFlowy-IO/appflowy-editor/pull/648))
* fix: indent/outdent doesn't work in not collapsed selection by @LucasXu0 in ([#626](https://github.com/AppFlowy-IO/appflowy-editor/pull/626))
* fix: renamed duplicated shortcut key by @AnsahMohammad in ([#629](https://github.com/AppFlowy-IO/appflowy-editor/pull/629))
* fix: todo list lost focus by @LucasXu0 in ([#633](https://github.com/AppFlowy-IO/appflowy-editor/pull/633))
* fix: resolve dead loop in node_iterator toList by @Linij in ([#623](https://github.com/AppFlowy-IO/appflowy-editor/pull/623))
* fix: active hover on upload image by @johansutrisno in ([#597](https://github.com/AppFlowy-IO/appflowy-editor/pull/597))
* fix:text_decoration_mobile_toolbar_padding by @q200892907 in ([#621](https://github.com/AppFlowy-IO/appflowy-editor/pull/621))
* fix: android 14 issues by @LucasXu0 in ([#649](https://github.com/AppFlowy-IO/appflowy-editor/pull/649))

## 2.1.0
* feat: show magnifier when dragging the handlers by @LucasXu0 in ([#601](https://github.com/AppFlowy-IO/appflowy-editor/pull/601))
* feat: refactor keyboard height observer to support multiple listeners by @LucasXu0 in ([#602](https://github.com/AppFlowy-IO/appflowy-editor/pull/602))
* fix: floating_toolbar_position_error by @q200892907 in ([#598](https://github.com/AppFlowy-IO/appflowy-editor/pull/598))
* fix: selection menu positioning on right half of editor by @zoli in ([#600](https://github.com/AppFlowy-IO/appflowy-editor/pull/600))
* fix: editor cannot scroll when editable is false by @LucasXu0 in ([#599](https://github.com/AppFlowy-IO/appflowy-editor/pull/599))
* fix: markdown does not support nested lists by @JessicaJHee in ([#611](https://github.com/AppFlowy-IO/appflowy-editor/pull/611))
* fix: input chinese issue by @q200892907 in ([#608](https://github.com/AppFlowy-IO/appflowy-editor/pull/608))
* fix: header/footer focus issue by @q200892907 in ([#607](https://github.com/AppFlowy-IO/appflowy-editor/pull/607))
* chore: upgrade to flutter 3.16 by @LucasXu0 in ([#614](https://github.com/AppFlowy-IO/appflowy-editor/pull/614))

## 2.0.0
* feat: support Flutter stable channel by @LucasXu0 in ([#581](https://github.com/AppFlowy-IO/appflowy-editor/pull/581))
* feat: support toggling format style when the selection is collapsed by @LucasXu0 in ([#586](https://github.com/AppFlowy-IO/appflowy-editor/pull/586))
* feat: optimize editing experience on mobile by @LucasXu0 in ([#592](https://github.com/AppFlowy-IO/appflowy-editor/pull/592))
* feat: support display number of the numbered list in latin or roman format by @q200892907 in ([#595](https://github.com/AppFlowy-IO/appflowy-editor/pull/595))
* fix: don't rebuild mobile toolbar every time by @LucasXu0 in ([#579](https://github.com/AppFlowy-IO/appflowy-editor/pull/579))
* fix: solve the left and right key bug by @q200892907 in ([#584](https://github.com/AppFlowy-IO/appflowy-editor/pull/584))
* fix: unable to set toolbar icon theme by @LucasXu0 in ([#596](https://github.com/AppFlowy-IO/appflowy-editor/pull/596))

## 2.0.0-beta.1
* feat: support Flutter stable channel by @LucasXu0 in ([#581](https://github.com/AppFlowy-IO/appflowy-editor/pull/581))

## 1.5.2
* feat: show placeholder override for paragraph block by @Xazin in ([#571](https://github.com/AppFlowy-IO/appflowy-editor/pull/571))
* feat: Checkbox unresponsive in custom Theme example in editor example app by @johansutrisno in ([#543](https://github.com/AppFlowy-IO/appflowy-editor/pul/543))
* fix: quit editing button doesn't work by @LucasXu0 in ([#5677](https://github.com/AppFlowy-IO/appflowy-editor/pull/577))
* fix: check if header exists for footer by @MayurSMahajan in ([#559](https://github.com/AppFlowy-IO/appflowy-editor/pull/559))
* fix: 'PageStorage.of' returns null by @LucasXu0 in ([#575](https://github.com/AppFlowy-IO/appflowy-editor/pull/575))
* fix: catch regex `FormatException` and show a corresponding error message  by @sun-jiao in ([#573](https://github.com/AppFlowy-IO/appflowy-editor/pull/573))
* chore: changed padding values and added borderRadius by @Kritarthsharma in ([#567](https://github.com/AppFlowy-IO/appflowy-editor/pull/567))
* chore: refactor character replacement by @Xazin in ([#570](https://github.com/AppFlowy-IO/appflowy-editor/pull/570))

## 1.5.1
* feat: toggledStyle notifier by @Xazin in ([#562](https://github.com/AppFlowy-IO/appflowy-editor/pull/562))
* feat: power checkbox shortcut by @Xazin in ([#553](https://github.com/AppFlowy-IO/appflowy-editor/pull/553))
* * fix: Applied Corner Radius to Block Selection Area by @0xJaskeerat in ([#557](https://github.com/AppFlowy-IO/appflowy-editor/pull/557))
* fix: do not select all if selection is null by @Xazin in ([#563](https://github.com/AppFlowy-IO/appflowy-editor/pull/563))
* fix: on ui event reset selection type by @Xazin in ([#55](https://github.com/AppFlowy-IO/appflowy-editor/pull/555))
* fix: image copy error width/height is double by @q200892907 in ([#566](https://github.com/AppFlowy-IO/appflowy-editor/pull/566))

## 1.5.0
* feat: enable toggling and canceling of formatting with shortcuts by @LucasXu0 in ([#528](https://github.com/AppFlowy-IO/appflowy-editor/pull/528))
* feat: disable the toolbar in the code block by @LucasXu0 in ([#534](https://github.com/AppFlowy-IO/appflowy-editor/pull/534))
* feat: refactor logic for converting color string to Color in background_color_mixin.dart by @LucasXu0 in ([#538](https://github.com/AppFlowy-IO/appflowy-editor/pull/538))
* feat: add an extra info parameter to the node by @LucasXu0 in ([#539](https://github.com/AppFlowy-IO/appflowy-editor/pull/539))
* feat: support parsing the nested list when exporting the document to markdown format by @LucasXu0 in ([#540](https://github.com/AppFlowy-IO/appflowy-editor/pull/540))
* feat: optimize editable features by @LucasXu0 in ([#541](https://github.com/AppFlowy-IO/appflowy-editor/pull/541))
* feat: table HTML encoder and decoder added by @alihassan143 in ([#449](https://github.com/AppFlowy-IO/appflowy-editor/pull/449))
* feat: support overriding i18n by @LucasXu0 in ([#550](https://github.com/AppFlowy-IO/appflowy-editor/pull/550))
* feat: convert = and > to ⇒ by @Gen1us1100 in ([#523](https://github.com/AppFlowy-IO/appflowy-editor/pull/523))
* fix: cursor blinks at the wrong location when inserting text by @LucasXu0 in ([#529](https://github.com/AppFlowy-IO/appflowy-editor/pull/529))
* fix: pinyin IME on Linux by @LucasXu0 in ([#531](https://github.com/AppFlowy-IO/appflowy-editor/pull/531))
* fix: unable to clear the style by toggling twice by @LucasXu0 in ([#532](https://github.com/AppFlowy-IO/appflowy-editor/pull/532))

## 1.4.4
* feat: support customizing error block by @LucasXu0 in ([#524](https://github.com/AppFlowy-IO/appflowy-editor/pull/524))
* feat: export JSON in mobile and update mobile_example.json by @hyj1204 in ([#515](https://github.com/AppFlowy-IO/appflowy-editor/pull/515))
* feat: add regex and case sensitive to `FindReplaceMenu` by @sun-jiao in ([#480](https://github.com/AppFlowy-IO/appflowy-editor/pull/480))
* feat: customize desktop toolbar style by @q200892907 in ([#519](https://github.com/AppFlowy-IO/appflowy-editor/pull/519))
* feat: support RTL in toolbar by @1akhanBaheti in ([#496](https://github.com/AppFlowy-IO/appflowy-editor/pull/496))
* feat: optimize the find and replace logic by @LucasXu0 in ([#510](https://github.com/AppFlowy-IO/appflowy-editor/pull/510))
* feat: enable shift+press for selection range by @Xazin in ([#512](https://github.com/AppFlowy-IO/appflowy-editor/pull/512))
* feat: image block revamp by @LucasXu0 in ([#516](https://github.com/AppFlowy-IO/appflowy-editor/pull/516))
* fix: undo failed in a nested list in a special case by @LucasXu0 in ([#503](https://github.com/AppFlowy-IO/appflowy-editor/pull/503))
* fix: the cursor will flicker one frame to its previous position by @LucasXu0 in ([#506](https://github.com/AppFlowy-IO/appflowy-editor/pull/506))
* fix: delete the divider on mobile will raise an error by @LucasXu0 in ([#508](https://github.com/AppFlowy-IO/appflowy-editor/pull/508))
* fix: unable to update selection sometimes when the editor lost focus by @LucasXu0 in ([#509](https://github.com/AppFlowy-IO/appflowy-editor/pull/509))
* fix: search integration issues by @LucasXu0 in ([#511](https://github.com/AppFlowy-IO/appflowy-editor/pull/511))
* fix: image block revamp issues by @LucasXu0 in ([#517](https://github.com/AppFlowy-IO/appflowy-editor/pull/517))
* fix: impossible to click on any sub-items if the top level item is off-screen by @LucasXu0 in ([#522](https://github.com/AppFlowy-IO/appflowy-editor/pull/522))
* fix: the selection should be clear if header or footer is focusing by @LucasXu0 in ([#525](https://github.com/AppFlowy-IO/appflowy-editor/pull/525))
* fix: the selection handles remain on the screen after cutting the text ([#526](https://github.com/AppFlowy-IO/appflowy-editor/pull/526))

## 1.4.3
* fix: the text within the `<mark>` tag didn't parse correctly when pasting HTML by @LucasXu0 in ([#501](https://github.com/AppFlowy-IO/appflowy-editor/pull/501))

## 1.4.2
* fix: platform issue on Web by @LucasXu0 in ([#498](https://github.com/AppFlowy-IO/appflowy-editor/pull/498))

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
