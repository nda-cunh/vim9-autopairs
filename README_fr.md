# vim-autopairs-v9

Un plugin d'auto-paires léger, performant et écrit entièrement en **Vim9script**. Il gère intelligemment l'insertion et la suppression des parenthèses, crochets et guillemets tout en respectant le contexte syntaxique.

## ✨ Caractéristiques

*   **Vim9script** : Performances optimales par rapport au VimL classique.
*   **Context-Aware** : Capacité à ignorer l'auto-complétion dans les commentaires ou les chaînes de caractères (strings).
*   **Triple Quotes** : Support intelligent pour les `""` et `''` sans casser le workflow.
*   **Fast Wrap** : Entourez rapidement un mot ou un bloc avec une paire.
*   **FlyMode** (Optionnel) : Pour sauter par-dessus les paires existantes.

## ⚙️ Configuration

Le plugin fonctionne directement avec des valeurs par défaut saines, mais vous pouvez le personnaliser dans votre `.vimrc` :

```vim
vim9script
# Activer/Désactiver le plugin
g:AutoPairsEnabled = 1

# Définir ses propres paires
g:AutoPairs = {'(': ')', '[': ']', '{': '}', "'": "'", '"': '"', '`': '`'}

# Raccourcis clavier personnalisés
g:AutoPairsShortcutToggle = '<M-p>'
g:AutoPairsShortcutFastWrap = '<M-e>'
g:AutoPairsShortcutJump = '<M-n>'
```

## ⌨️ Utilisation

| Action | Résultat |
| :--- | :--- |
| Taper `(` | Insère `()` et place le curseur au milieu. |
| Taper `)` (si déjà présent) | Saute par-dessus le `)`. |
| Touche `Backspace` | Supprime la paire si elle est vide (ex: `(|)` -> `|`). |
| Touche `Espace` | Ajoute des espaces symétriques (ex: `(|)` -> `( | )`). |

## 📄 Licence
MIT
