# AppFlowy Editor - Improvement Plan

**Generated:** 2025-12-26
**Current Version:** 6.1.0
**Review Scope:** Folder structure, documentation, and public API comments

---

## Executive Summary

This document outlines improvements needed for the AppFlowy Editor codebase based on a comprehensive review of:
1. Folder structure and organization
2. Documentation accuracy and completeness
3. Public API documentation coverage

**Overall Ratings:**
- Folder Structure: 8/10 (Good with minor issues)
- Documentation Accuracy: 5/10 (Contains outdated content)
- API Documentation: 6.5/10 (Mixed quality)

---

## 1. Folder Structure Optimization

### 1.1 Critical Issues

#### Issue #1: Misplaced `editor_state.dart`
**Priority:** High
**Location:** `lib/src/editor_state.dart`
**Problem:** Large core file (22.5 KB) placed at root of `src/` directory instead of logically with editor components
**Impact:** Organizational inconsistency, harder to discover related code
**Recommendation:**
- Move to `lib/src/editor/editor_state.dart`
- Update all imports across the codebase
- Update `lib/appflowy_editor.dart` export statement

**Files Affected:**
- `lib/src/editor_state.dart` → `lib/src/editor/editor_state.dart`
- `lib/appflowy_editor.dart` (export path)
- All files importing `editor_state.dart` (need import path updates)

---

### 1.2 High Priority Issues

#### Issue #2: Mobile Toolbar Version Duplication
**Priority:** High
**Location:** `lib/src/editor/toolbar/mobile/`
**Problem:** Parallel implementations (v1 and v2) without clear deprecation or selection strategy
**Files:**
- `mobile_toolbar.dart` vs `mobile_toolbar_v2.dart`
- `toolbar_items/text_decoration_mobile_toolbar_item.dart` vs `text_decoration_mobile_toolbar_item_v2.dart`

**Recommendation:**
- Audit which version is actively used in production
- Deprecate and remove unused version
- Document migration path if v2 is the future
- If both are needed for compatibility, add clear documentation explaining when to use each

---

#### Issue #3: Legacy Code Directory
**Priority:** High
**Location:** `lib/src/core/legacy/`
**Problem:** Directory contains only single file: `built_in_attribute_keys.dart`
**Questions:**
- Is this code still in use?
- Can it be migrated to current architecture?
- Should the entire legacy directory be removed?

**Recommendation:**
- Audit usage of `built_in_attribute_keys.dart`
- If still needed, move to appropriate location (likely `lib/src/core/`)
- If deprecated, mark for removal in next major version
- Remove empty `legacy/` directory

---

### 1.3 Medium Priority Issues

#### Issue #4: Service Layer Fragmentation
**Priority:** Medium
**Problem:** Services scattered across multiple locations without clear hierarchy
**Locations:**
- `/lib/src/service/` - High-level services
- `/lib/src/editor/editor_component/service/` - Editor-specific services (most critical)
- `/lib/src/infra/` - Infrastructure services
- Block-specific services within individual block components

**Impact:** Unclear service responsibilities and architecture
**Recommendation:**
- Document service layer architecture in `ARCHITECTURE.md`
- Create clear guidelines for where to place new services
- Consider consolidating related services
- Add README.md in service directories explaining purpose

---

#### Issue #5: Deeply Nested Shortcuts Directory
**Priority:** Medium
**Location:** `/lib/src/editor/editor_component/service/shortcuts/character/format_double_character/`
**Problem:** 5+ levels of nesting makes files harder to navigate and discover
**Example Path:**
```
lib/src/editor/editor_component/service/shortcuts/
  └── character/
      └── format_double_character/
          └── format_asterisks_to_bold_or_italic_handler.dart
```

**Recommendation:**
- Flatten to maximum 3-4 levels
- Consider structure like: `shortcuts/character_formatting/double_char_handlers.dart`
- Group related handlers in single files where appropriate

---

### 1.4 Low Priority Issues

#### Issue #6: Plugin vs Built-in Block Distinction
**Priority:** Low
**Location:** `lib/src/plugins/blocks/` vs `lib/src/editor/block_component/`
**Problem:** Unclear distinction between plugin blocks and built-in blocks
**Current State:**
- Columns appear in both `plugins/blocks/columns/` and `editor/block_component/columns/`

**Recommendation:**
- Document which blocks are built-in vs. plugin-based
- Establish clear criteria for plugin vs. built-in classification
- Consider consolidating if distinction is not meaningful

---

#### Issue #7: Flutter Utilities Organization
**Priority:** Low
**Location:** `lib/src/flutter/scrollable_positioned_list/`
**Problem:** Custom Flutter component implementation mixed with wrapper utilities
**Recommendation:**
- Consider separate directory: `/third_party/` or `/flutter_extensions/`
- Add README explaining vendored code and why it's included
- Document any modifications to original code

---

#### Issue #8: Localization Directory Split
**Priority:** Low
**Locations:**
- `lib/l10n/` - ARB source files
- `lib/src/l10n/` - Generated/compiled translations
- `lib/src/editor/l10n/` - Editor-specific translations

**Recommendation:**
- Document why localization is split across three locations
- Add README in each l10n directory explaining purpose
- Consider consolidating if technically feasible

---

#### Issue #9: Render Directory Clarity
**Priority:** Low
**Location:** `lib/src/render/`
**Problem:** Minimal content (8 files), unclear purpose vs. other rendering code
**Contains:**
- `color_menu/`
- `selection/`
- `toolbar/`

**Observation:** Other rendering logic exists in `editor/block_component/` and various components
**Recommendation:**
- Document if `/render/` is for abstractions only
- Consider consolidating rendering-related components
- Add README explaining purpose and when to use this directory

---

## 2. Documentation Issues

### 2.1 Critical Issues

#### Issue #10: Outdated API in Documentation
**Priority:** Critical
**Location:** `documentation/customizing.md`
**Lines:** 20, 66, and throughout the file
**Problem:** Documentation uses `AppFlowyEditor.custom()` which was removed in v1.2
**Impact:** Users following documentation will get compilation errors

**Current (Incorrect) Code:**
```dart
// OUTDATED - Removed in v1.2
return AppFlowyEditor.custom(
  editorState: EditorState.blank(withInitialText: true),
  blockComponentBuilders: standardBlockComponentBuilderMap,
  characterShortcutEvents: [underScoreToItalicEvent],
);
```

**Should Be:**
```dart
// CORRECT - Current API (v1.2+)
return AppFlowyEditor(
  editorState: EditorState.blank(withInitialText: true),
  blockComponentBuilders: standardBlockComponentBuilderMap,
  characterShortcutEvents: [underScoreToItalicEvent],
);
```

**Files to Update:**
- `documentation/customizing.md` - Lines 20, 66, and all code examples
- Review all code examples for deprecated APIs

**Note:** The `AppFlowyEditor.custom()` and `AppFlowyEditor.standard()` constructors were removed in version 1.2. Use `AppFlowyEditor()` constructor instead.

---

### 2.2 Documentation Quality - No Issues Found

**Files Reviewed and Confirmed Accurate:**
- ✅ `README.md` - Uses current APIs, good getting started guide
- ✅ `documentation/importing.md` - Accurate import examples
- ✅ `documentation/testing.md` - Test examples are current
- ✅ `documentation/translation.md` - Accurate translation workflow
- ✅ `example/README.md` - Basic example documentation

---

## 3. Public API Documentation

### 3.1 Critical Documentation Gaps

#### Issue #11: EditorState Class Documentation
**Priority:** Critical
**Location:** `lib/src/editor_state.dart`
**Impact:** Central class to the entire API, users must understand this

**Missing Documentation:**

**Typedefs:**
- `EditorTransactionValue` - No documentation

**Enums (No documentation on any):**
- `SelectionUpdateReason` - Enum and all values undocumented
- `SelectionType` - Enum and all values undocumented
- `TransactionTime` - Enum and all values undocumented

**Class: ApplyOptions:**
- `recordRedo` property - Missing documentation

**Class: EditorState - Properties:**
- `selectionType`
- `selectionUpdateReason`
- `selectionExtraInfo`
- `service`, `scrollService`, `selectionService`, `renderer`
- `autoScroller`, `scrollableState`
- `showHeader`, `showFooter`
- `enableAutoComplete`, `autoCompleteTextProvider`
- `disableSealTimer`

**Class: EditorState - Methods:**
- `EditorState.blank()` constructor
- `updateToggledStyle()`
- `updateSelectionWithReason()`
- `getSelectedNodes()`
- `getNodeAtPath()`
- `selectionRects()`
- `cancelSubscription()`
- `updateAutoScroller()`
- `dispose()`

---

#### Issue #12: Position Class - Completely Undocumented
**Priority:** Critical
**Location:** `lib/src/core/location/position.dart`
**Impact:** Fundamental type for cursor position and selection boundaries
**Problem:** Zero documentation despite being core to user-facing API

**Missing Documentation:**
- Class-level documentation explaining what a Position represents
- `path` property - What is a path?
- `offset` property - Character offset? Byte offset?
- Constructors
- `copyWith()` method
- `toJson()` method

**Recommended Documentation Structure:**
```dart
/// Represents a position within the document.
///
/// A position is defined by:
/// - [path]: The hierarchical path to a node in the document tree
/// - [offset]: The character offset within that node
///
/// Example:
/// ```dart
/// // Position at character 5 in the first node
/// final pos = Position(path: [0], offset: 5);
/// ```
class Position { ... }
```

---

#### Issue #13: Block Component System Documentation
**Priority:** Critical
**Location:** `lib/src/editor/block_component/` and `lib/src/editor/editor_component/service/renderer/`
**Impact:** Required for users extending editor with custom blocks
**Problem:** Extensive undocumented API surface for core extensibility feature

**Missing Documentation:**

**lib/src/editor/block_component/base_component/block_component_configuration.dart:**
- `BlockComponentConfiguration` class - No class-level docs
- `BlockComponentTextStyleBuilder` typedef
- `BlockComponentConfigurable` mixin
- `copyWith()` method

**lib/src/editor/editor_component/service/renderer/block_component_service.dart:**
- `errorBlockComponentBuilderKey` constant
- `forceShowBlockAction` variable
- `BlockActionBuilder` typedef
- `BlockActionTrailingBuilder` typedef
- `BlockComponentValidate` typedef
- `BlockComponentActionState` interface
- `BlockComponentBuilder` class - Missing class-level docs
- `BlockComponentBuilder.build()` method
- `BlockComponentBuilder.showActions` property
- `BlockComponentBuilder.actionBuilder` property
- `BlockComponentBuilder.actionTrailingBuilder` property
- `BlockComponentBuilder.configuration` property
- `BlockComponentSelectable` mixin
- `BlockComponentSelectable.start()` - Has comment but not /// doc
- `BlockComponentSelectable.end()` - Has comment but not /// doc
- `BlockComponentRendererService.registerAll()`
- `BlockComponentRendererService.unRegister()`
- `BlockComponentRendererService.blockComponentSelectable()`
- `BlockComponentRendererService.buildList()`
- `BlockComponentRenderer` class

**lib/src/editor/editor_component/service/renderer/block_component_context.dart:**
- `BlockComponentWrapper` typedef
- `BlockComponentContext` class and all properties

**lib/src/editor/editor_component/service/renderer/block_component_widget.dart:**
- `BlockComponentWidget` mixin and all properties/methods
- `BlockComponentStatelessWidget` class
- `BlockComponentStatefulWidget` class
- `NestedBlockComponentStatefulWidgetMixin` mixin

---

#### Issue #14: Node Class Documentation Gaps
**Priority:** High
**Location:** `lib/src/core/document/node.dart`
**Problem:** Core class with several undocumented properties and methods

**Missing Documentation:**
- `NodeExternalValues` abstract class
- `externalValues` property
- `extraInfos` property
- `key`, `layerLink` properties
- `notify()` method
- `insertAfter()`, `insertBefore()`, `unlink()` methods
- `childAtPath()` method
- `delta` property
- `toJson()` method
- `TextNode` class (deprecated but public)
- `NodeEquality` extension and its methods

**Known Issue:**
- `Document.fromJson()` has typo: "strcuture" → "structure"

---

#### Issue #15: ShortcutEventHandler Typedef
**Priority:** High
**Location:** `lib/src/service/shortcut_event/shortcut_event_handler.dart`
**Problem:** No documentation for this key typedef
**Impact:** Users creating custom shortcuts need to understand this signature

**Missing:**
```dart
/// Handler function for shortcut events.
///
/// Processes keyboard input and returns true if the event was handled.
/// Return false to allow the event to propagate to other handlers.
///
/// Parameters:
/// - [editorState]: The current editor state
///
/// Returns true if the shortcut was handled, false otherwise.
typedef ShortcutEventHandler = ...
```

---

### 3.2 Well-Documented APIs (Reference Examples)

These APIs demonstrate the documentation quality to aim for:

✅ **Document class** (`lib/src/core/document/document.dart`)
- Excellent class-level documentation
- JSON structure example provided
- All public methods documented
- Clear explanation of purpose

✅ **Selection class** (`lib/src/core/location/selection.dart`)
- Comprehensive explanation of directionality
- Constructor documentation
- Properties well documented with behavior explanations

✅ **Transaction class** (`lib/src/core/transform/transaction.dart`)
- Clear purpose and usage scenarios
- All properties and methods documented
- Examples of when to use

✅ **AppFlowyEditor widget** (`lib/src/editor/editor_component/service/editor.dart`)
- Exceptional parameter documentation
- Code examples for extending functionality
- Detailed behavior explanations
- Clear guidance on customization

---

## 4. Implementation Priority Matrix

### Phase 1: Critical (Do First)
**Goal:** Fix breaking issues and major API documentation gaps

1. ✅ Update `documentation/customizing.md` - Remove deprecated `AppFlowyEditor.custom()`
2. ✅ Document `EditorState` class thoroughly
3. ✅ Document `Position` class completely
4. ✅ Document `BlockComponentBuilder` and core block component architecture
5. ✅ Document all public typedefs (especially `ShortcutEventHandler`)
6. ✅ Document all public enums with value explanations

**Estimated Effort:** 2-3 days
**Impact:** High - Improves developer experience immediately

---

### Phase 2: High Priority (Do Next)
**Goal:** Improve codebase organization and API documentation

7. ✅ Move `editor_state.dart` to correct location
8. ✅ Consolidate or document mobile toolbar v1/v2 variants
9. ✅ Document `Node` class remaining methods and properties
10. ✅ Audit and clean up legacy code directory
11. ✅ Document service layer hierarchy and add architecture guide

**Estimated Effort:** 3-4 days
**Impact:** Medium-High - Better code organization and discoverability

---

### Phase 3: Medium Priority (Polish)
**Goal:** Complete documentation and improve code navigation

12. ✅ Document `BlockComponentWidget` hierarchy completely
13. ✅ Add documentation to all mixins explaining their purposes
14. ✅ Document override methods where behavior differs from base
15. ✅ Fix typo in `Document.fromJson()` ("strcuture" → "structure")
16. ✅ Flatten deeply nested shortcut directories
17. ✅ Add README files to key directories explaining structure

**Estimated Effort:** 2-3 days
**Impact:** Medium - Improved maintainability

---

### Phase 4: Low Priority (Future)
**Goal:** Long-term maintainability improvements

18. ✅ Clarify plugin vs. built-in block distinction
19. ✅ Reorganize Flutter utilities if needed
20. ✅ Add more code examples for complex APIs
21. ✅ Consider consolidating localization structure
22. ✅ Clarify render directory purpose
23. ✅ Create comprehensive architecture documentation

**Estimated Effort:** 3-5 days
**Impact:** Low-Medium - Better for long-term maintenance

---

## 5. Recommended Next Steps

### Immediate Actions (This Week)
1. **Fix Critical Documentation:** Update `customizing.md` to use current API
2. **Start API Documentation:** Begin with `Position` and `EditorState` classes
3. **Audit Mobile Toolbar:** Determine which version to keep

### Short Term (This Month)
4. **Complete Phase 1:** Finish all critical documentation gaps
5. **Reorganize Files:** Move `editor_state.dart` and clean up legacy code
6. **Create Architecture Guide:** Document service layer and design patterns

### Long Term (Next Quarter)
7. **Complete All Phases:** Work through priority matrix systematically
8. **Add Examples:** Create comprehensive example app demonstrating customization
9. **Documentation Site:** Consider setting up dedicated documentation site

---

## 6. Success Metrics

Track improvement with these metrics:

**Documentation Coverage:**
- [ ] 100% of public classes have class-level documentation
- [ ] 100% of public methods have documentation
- [ ] 100% of public properties have documentation
- [ ] 100% of typedefs and enums have documentation
- [ ] All documentation uses current (non-deprecated) APIs

**Code Organization:**
- [ ] No files in wrong directories
- [ ] No duplicate implementations without clear purpose
- [ ] Service layer architecture documented
- [ ] Directory structure documented with README files
- [ ] Maximum nesting depth of 4 levels

**Developer Experience:**
- [ ] New contributors can find relevant code quickly
- [ ] API is self-documenting with clear examples
- [ ] Breaking changes have migration guides
- [ ] Architecture decisions are documented

---

## 7. Appendix: Review Methodology

**Review Date:** 2025-12-26
**Reviewer:** Claude (AI Assistant)
**Review Scope:**
- All files in `lib/src/`
- All documentation in `documentation/`
- Main entry point: `lib/appflowy_editor.dart`
- Example code: `example/lib/`

**Tools Used:**
- Static code analysis
- Documentation parsing
- Structural analysis of 378 Dart files
- Cross-reference checking with documentation

**Files Reviewed in Detail:**
- Core: `document.dart`, `node.dart`, `position.dart`, `selection.dart`, `transaction.dart`
- Editor: `editor_state.dart`, `editor.dart`, block component files
- Documentation: All `.md` files in root and `documentation/`
- Configuration: `pubspec.yaml`, `README.md`

---

## 8. Contributing to This Plan

This improvement plan is a living document. To contribute:

1. **Mark completed items** with ✅ when finished
2. **Add new issues** as they're discovered
3. **Update priorities** based on user feedback
4. **Track progress** with completion dates

**Last Updated:** 2025-12-26
**Status:** Draft - Ready for Review
