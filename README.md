# vim-autopairs-v9

A lightweight, high-performance auto-pairs plugin written entirely in **Vim9script**. It intelligently handles the insertion and deletion of parentheses, brackets, and quotes while respecting the syntax context.

## ✨ Features

*   **Vim9script**: Optimal performance compared to legacy VimL.
*   **Context-Aware**: Ability to ignore auto-completion within comments or strings.
*   **Triple Quotes**: Intelligent support for `""` and `''` without breaking your workflow.
*   **Fast Wrap**: Quickly wrap a word or a block with a pair.
*   **FlyMode** (Optional): Jump over existing closed pairs seamlessly.


## ⚙️ Configuration

The plugin works out of the box with sane defaults, but you can customize it in your `.vimrc`:

```vim
" Enable/Disable the plugin
let g:AutoPairsEnabled = 1

" Define custom pairs
let g:AutoPairs = {'(': ')', '[': ']', '{': '}', "'": "'", '"': '"', '`': '`'}

" Custom keybindings
let g:AutoPairsShortcutToggle = '<M-p>'
let g:AutoPairsShortcutFastWrap = '<M-e>'
let g:AutoPairsShortcutJump = '<M-n>'
```
## ⌨️ Usage

| Action | Result |
| :--- | :--- |
| Type `(` | Inserts `()` and places the cursor in the middle. |
| Type `)` (if already present) | Jumps over the existing `)`. |
| `Backspace` key | Deletes the pair if empty (e.g., `(|)` -> `|`). |
| `Space` key | Adds symmetrical spaces (e.g., `(|)` -> `( | )`). |

## 📄 License
MIT
